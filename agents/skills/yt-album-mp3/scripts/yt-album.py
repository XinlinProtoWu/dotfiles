#!/usr/bin/env python3
"""Build a ready-to-play MP3 album on the Shanling Q2 card from a YouTube
playlist (YouTube Music album playlist, official album upload, etc.).

Pipeline: yt-dlp bestaudio -> ffmpeg libmp3lame -> ID3v2.3 tags + 500x500
embedded front cover + sidecar cover.jpg -> `NN - Title.mp3` -> backup JSON at
the card root -> verification (tags, picture, full decode).

It is resumable: audio already downloaded into the workdir is reused, tracks
that YouTube Premium-gates are reported and skipped (exit 3), and nothing is
written to the card unless every track is accounted for (override with
--allow-partial, which only makes sense for testing).

Examples
  # 1. dry run: see what would be made, no downloads
  yt-album.py URL --album "First Love" --artist "宇多田ヒカル" \
      --genre J-Pop --date 1999-03-10 --dry-run

  # 2. download + build
  yt-album.py URL --album "First Love" --artist "宇多田ヒカル" \
      --genre J-Pop --date 1999-03-10

  # 3. resume a download-only pass, or rebuild from already fetched audio
  yt-album.py URL --audio-dir /tmp/album --album ... --artist ...

Notes
  * Downloading needs a yt-dlp that can solve YouTube's n/sig challenge:
    a current release plus `--remote-components ejs:github` (the script passes
    it). If the system yt-dlp is old, `--yt-dlp /tmp/ytv/bin/yt-dlp`.
  * `--cookies-from-browser chrome` is how an account (and its Premium status)
    is used; without it YouTube may answer "Sign in to confirm you're not a bot".
"""

import argparse
import json
import os
import re
import subprocess
import sys
import time

CARD = "/run/media/xinuwu/6883-87F1"
LIBRARY = CARD + "/music"
FORBIDDEN = '\\/:*?"<>|'


def die(msg, code=1):
    sys.stderr.write("ERROR: %s\n" % msg)
    sys.exit(code)


def run(cmd, **kw):
    return subprocess.run(cmd, capture_output=True, text=True, **kw)


def log(msg):
    print(msg, flush=True)


def safe(s):
    out = "".join("" if ch in FORBIDDEN else ch for ch in s).strip()
    out = re.sub(r"\s{2,}", " ", out).strip(" .")
    return out or "untitled"


def slug(s):
    return re.sub(r"[\s\-_./'\"()\[\]&,]+", "", s) or "album"


def ascii_quotes(s):
    """Michael Jackson’s ’ is legal on exFAT but the library uses ASCII '."""
    for a, b in (("\u2019", "'"), ("\u2018", "'"), ("\u201c", '"'),
                 ("\u201d", '"')):
        s = s.replace(a, b)
    return s


def clean_title(title, artist):
    """'宇多田ヒカル - Automatic' -> 'Automatic'; keeps real hyphens."""
    for sep in (" - ", " – ", " − ", "｜", " | "):
        if sep in title:
            left, right = title.split(sep, 1)
            if artist and (left.strip().lower() == artist.strip().lower()
                           or artist.strip().lower() in left.strip().lower()):
                return right.strip()
    return title.strip()


# ---------------------------------------------------------------- downloading
def youtube_dl(a, playlist, workdir):
    os.makedirs(workdir, exist_ok=True)
    cmd = [a.yt_dlp, "--no-update", "--no-warnings",
           "--remote-components", "ejs:github",
           "-f", "bestaudio/best",
           "--write-info-json",
           "-o", os.path.join(workdir, "%(playlist_index)02d-%(id)s.%(ext)s")]
    if a.cookies_from_browser:
        cmd += ["--cookies-from-browser", a.cookies_from_browser]
    if a.impersonate:
        cmd += ["--impersonate", a.impersonate]
    cmd.append(playlist)
    log("yt-dlp: downloading audio to %s" % workdir)
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                         text=True)
    failed = []
    for line in p.stdout:
        line = line.rstrip()
        if line.startswith("[download] Downloading item"):
            log("  " + line)
        elif line.startswith("ERROR:"):
            failed.append(line)
            log("  " + line)
        elif "Destination:" in line:
            log("  " + line.split("Destination:", 1)[1].strip())
    p.wait()
    return failed


def gather(audio_dir):
    tracks = []
    for f in sorted(os.listdir(audio_dir)):
        if not f.endswith(".info.json") or f.startswith("00-"):
            continue
        info = json.load(open(os.path.join(audio_dir, f), encoding="utf-8"))
        stem = f[:-len(".info.json")]
        audio = None
        for ext in (".webm", ".m4a", ".opus", ".mp3", ".mkv", ".mp4", ".ogg"):
            if os.path.exists(os.path.join(audio_dir, stem + ext)):
                audio = stem + ext
                break
        if not audio:
            continue
        tracks.append({
            "index": info.get("playlist_index") or len(tracks) + 1,
            "id": info.get("id"),
            "raw_title": info.get("title") or stem,
            "duration": info.get("duration"),
            "url": info.get("webpage_url") or
                   ("https://youtu.be/" + (info.get("id") or "")),
            "path": os.path.join(audio_dir, audio),
        })
    tracks.sort(key=lambda t: t["index"])
    return tracks


# ---------------------------------------------------------------- metadata
def musicbrainz_release(release_id):
    """MusicBrainz rate-limits hard (1 req/s) and answers 503 with an empty
    body, so retry and insist on a response that actually carries media."""
    url = ("https://musicbrainz.org/ws/2/release/%s"
           "?inc=recordings+artist-credits+labels&fmt=json" % release_id)
    last = "no response"
    for attempt in range(6):
        p = run(["curl", "-s", "-A", "yt-album/1.0 ( local )", url])
        if p.returncode == 0 and p.stdout.lstrip().startswith("{"):
            try:
                d = json.loads(p.stdout)
            except json.JSONDecodeError:
                d = {}
            if d.get("media"):
                return d
            last = "response without media (rate limited?)"
        else:
            last = (p.stdout.strip() or p.stderr.strip())[:120] or "empty response"
        time.sleep(2 + attempt)
    die("MusicBrainz lookup failed for %s: %s" % (release_id, last))


def musicbrainz_tracks(release):
    out = []
    for medium in release.get("media", []):
        for t in medium.get("tracks", []):
            out.append({
                "title": t.get("title", ""),
                "length": int((t.get("length") or 0) / 1000),
                "disc": medium.get("position", 1),
            })
    return out


def cover_art_archive(release_id, dest, size):
    for name in ("front-%d.jpg" % size, "front-1200.jpg", "front-500.jpg",
                 "front.jpg"):
        tmp = dest + ".tmp"
        p = run(["curl", "-sL", "-A", "yt-album/1.0 ( local )",
                 "https://coverartarchive.org/release/%s/%s" % (release_id, name),
                 "-o", tmp])
        if p.returncode == 0 and os.path.getsize(tmp) > 5000:
            head = open(tmp, "rb").read(3)
            if head == b"\xff\xd8\xff":          # real JPEG, not an HTML error
                os.replace(tmp, dest)
                return dest
        if os.path.exists(tmp):
            os.remove(tmp)
    return None


def library_genre(artist):
    """Borrow the genre this artist's existing albums use."""
    if not artist or not os.path.isdir(LIBRARY):
        return ""
    hits = {}
    for d in os.listdir(LIBRARY):
        if os.path.basename(artist).lower()[:4] not in d.lower():
            continue
        for f in sorted(os.listdir(os.path.join(LIBRARY, d)))[:5]:
            if not f.lower().endswith((".flac", ".mp3")):
                continue
            p = run(["ffprobe", "-v", "quiet", "-show_entries",
                     "format_tags=genre", "-of", "default=nw=1:nk=1",
                     os.path.join(LIBRARY, d, f)])
            g = p.stdout.strip()
            if g:
                hits[g] = hits.get(g, 0) + 1
    return max(hits, key=hits.get) if hits else ""


def make_cover(src, dest, size):
    p = run(["magick", src, "-resize", "%dx%d^" % (size, size),
             "-gravity", "center", "-extent", "%dx%d" % (size, size),
             "-strip", "-quality", "88", dest])
    if p.returncode or not os.path.getsize(dest):
        die("cover conversion failed: %s" % p.stderr.strip())
    return os.path.getsize(dest)


# ---------------------------------------------------------------- encoding
def encode(track, meta, cover, out_path, style_sep):
    title = track["title"]
    name = "%02d%s%s.mp3" % (track["index"], style_sep, safe(title))
    out = os.path.join(out_path, name)
    args = ["ffmpeg", "-v", "error", "-y", "-i", track["path"],
            "-i", cover, "-map", "0:a", "-map", "1:v",
            "-c:a", "libmp3lame", "-q:a", "0",
            "-c:v", "copy", "-disposition:v", "attached_pic",
            "-id3v2_version", "3",
            "-metadata", "title=" + title,
            "-metadata", "artist=" + meta["artist"],
            "-metadata", "album_artist=" + meta["albumartist"],
            "-metadata", "album=" + meta["album"],
            "-metadata", "track=%d/%d" % (track["index"], meta["total"]),
            "-metadata:s:v", "title=Album cover",
            "-metadata:s:v", "comment=Cover (front)"]
    if meta.get("date"):
        args += ["-metadata", "date=" + meta["date"]]
    if meta.get("genre"):
        args += ["-metadata", "genre=" + meta["genre"]]
    args.append(out)
    p = run(args)
    if p.returncode:
        die("ffmpeg failed for %s: %s" % (track["raw_title"], p.stderr.strip()))
    return out, name


def verify(path, track, meta):
    problems = []
    probe = run(["ffprobe", "-v", "quiet", "-print_format", "json",
                 "-show_format", "-show_streams", path])
    info = json.loads(probe.stdout or "{}")
    tags = {k.lower(): v for k, v in (info.get("format", {}).get("tags") or {}).items()}
    for k, want in (("title", track["title"]), ("album", meta["album"]),
                    ("artist", meta["artist"]), ("album_artist", meta["albumartist"])):
        if tags.get(k, "") != want:
            problems.append("%s tag %r != %r" % (k, tags.get(k), want))
    try:
        if int(tags.get("track", "0").split("/")[0]) != track["index"]:
            problems.append("track tag %r" % tags.get("track"))
    except ValueError:
        problems.append("track tag %r" % tags.get("track"))
    pics = [s for s in info.get("streams", [])
            if s.get("codec_type") == "video" and s.get("disposition", {}).get("attached_pic")]
    if len(pics) != 1:
        problems.append("%d attached pictures" % len(pics))
    dur = float(info.get("format", {}).get("duration") or 0)
    if track.get("duration") and abs(dur - track["duration"]) > 2:
        problems.append("duration %.1fs vs youtube %ss" % (dur, track["duration"]))
    dec = run(["ffmpeg", "-v", "error", "-i", path, "-f", "null", "-"])
    if dec.returncode or dec.stderr.strip():
        problems.append("decode errors: " + dec.stderr.strip()[:120])
    return problems


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("playlist", nargs="?", help="YouTube playlist URL")
    ap.add_argument("--album", help="album title (default: playlist title)")
    ap.add_argument("--artist", help="artist (default: channel name)")
    ap.add_argument("--albumartist", help="album artist (default: artist)")
    ap.add_argument("--date", default="")
    ap.add_argument("--genre", default=None,
                    help="default: borrow from this artist's existing folders")
    ap.add_argument("--mb-release", help="MusicBrainz release id for canonical "
                                         "titles/durations and cover art")
    ap.add_argument("--cover", help="cover image file to use")
    ap.add_argument("--cover-size", type=int, default=500)
    ap.add_argument("--workdir", default="/tmp/yt-album")
    ap.add_argument("--audio-dir", help="reuse already downloaded audio here")
    ap.add_argument("--dest", help="album folder on the card "
                                   "(default: %s/<AlbumSlug>-<ArtistSlug>)" % LIBRARY)
    ap.add_argument("--style", choices=["dash", "dot"], default="dash")
    ap.add_argument("--yt-dlp", default="yt-dlp")
    ap.add_argument("--cookies-from-browser")
    ap.add_argument("--impersonate")
    ap.add_argument("--allow-partial", action="store_true",
                    help="build even if some playlist tracks are unavailable")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()

    if not a.audio_dir and not a.playlist:
        die("give a playlist URL (or --audio-dir)")
    if not a.artist:
        die("--artist is required (YouTube does not expose a reliable artist tag)")

    workdir = os.path.abspath(a.audio_dir or a.workdir)
    playlist_title = a.album
    channel = a.artist
    failed = []

    if not a.audio_dir:
        failed = youtube_dl(a, a.playlist, workdir)
        pj = [f for f in os.listdir(workdir) if f.startswith("00-") and
              f.endswith(".info.json")]
        if pj:
            d = json.load(open(os.path.join(workdir, pj[0]), encoding="utf-8"))
            playlist_title = playlist_title or d.get("title")

    tracks = gather(workdir)
    if not tracks:
        die("no audio in %s - download failed" % workdir)

    total_expected = None
    pj = [f for f in os.listdir(workdir) if f.startswith("00-") and
          f.endswith(".info.json")]
    if pj:
        d = json.load(open(os.path.join(workdir, pj[0]), encoding="utf-8"))
        total_expected = d.get("playlist_count")
    if failed:
        log("\n%d/%s tracks unavailable:" % (len(failed), total_expected or "?"))
        for line in failed:
            log("  " + line)
        if not a.allow_partial:
            die("stopping: fix access (Premium cookies / different source) or "
                "re-run with --allow-partial. Audio is kept in %s" % workdir, 3)

    album = a.album or playlist_title or os.path.basename(workdir)
    artist = a.artist
    albumartist = a.albumartist or artist
    genre = a.genre if a.genre is not None else library_genre(artist)
    if not genre:
        log("WARNING: no genre known for %s - pass --genre" % artist)

    mb_tracks = []
    if a.mb_release:
        release = musicbrainz_release(a.mb_release)
        mb_tracks = musicbrainz_tracks(release)
        album = a.album or release.get("title") or album
        artist = (release.get("artist-credit") or [{}])[0].get("name") or artist
        albumartist = a.albumartist or artist
        if a.date == "":
            a.date = release.get("date", "")
        if len(mb_tracks) != len(tracks):
            die("playlist has %d tracks, MusicBrainz release has %d - refusing "
                "to guess a mapping" % (len(tracks), len(mb_tracks)))
    for i, t in enumerate(tracks):
        t["title"] = ascii_quotes(mb_tracks[i]["title"] if mb_tracks
                                  else clean_title(t["raw_title"], artist))
        if mb_tracks and t.get("duration") and mb_tracks[i]["length"] and \
                abs(t["duration"] - mb_tracks[i]["length"]) > 5:
            log("WARNING: track %02d duration %ss vs MusicBrainz %ss - %s"
                % (i + 1, t["duration"], mb_tracks[i]["length"], t["title"]))

    dest = a.dest or os.path.join(LIBRARY, "%s-%s" % (slug(album), slug(artist)))
    if os.path.abspath(dest).startswith(os.path.abspath(LIBRARY) + os.sep):
        backup_dir = os.path.dirname(LIBRARY.rstrip("/"))   # card root
    else:
        backup_dir = os.path.dirname(os.path.abspath(dest))
    backup = os.path.join(backup_dir,
                          "tag-backup-before-%s.json" % safe(album))

    log("\nalbum : %s" % album)
    log("artist: %s (albumartist %s)" % (artist, albumartist))
    log("genre : %s   date: %s" % (genre or "(blank)", a.date or "(blank)"))
    log("dest  : %s" % dest)
    for t in tracks:
        log("  %02d | %-40s | %ss | %s" % (t["index"], t["title"],
                                           t.get("duration"), t["id"]))
    if a.dry_run:
        return

    # ---- cover
    os.makedirs(workdir, exist_ok=True)
    raw_cover = a.cover
    if not raw_cover and a.mb_release:
        raw_cover = cover_art_archive(a.mb_release,
                                      os.path.join(workdir, "caa.jpg"),
                                      a.cover_size)
    if not raw_cover:
        pj = [f for f in os.listdir(workdir) if f.startswith("00-") and
              f.endswith(".info.json")]
        thumbs = []
        if pj:
            thumbs = json.load(open(os.path.join(workdir, pj[0]),
                                    encoding="utf-8")).get("thumbnails") or []
        for th in reversed(thumbs):
            tmp = os.path.join(workdir, "thumb.img")
            if run(["curl", "-sL", th["url"], "-o", tmp]).returncode == 0 and \
                    os.path.getsize(tmp) > 5000:
                raw_cover = tmp
                break
    if not raw_cover:
        die("no cover: pass --cover or --mb-release (Cover Art Archive)")

    os.makedirs(dest, exist_ok=True)
    cover = os.path.join(dest, "cover.jpg")
    size = make_cover(raw_cover, cover, a.cover_size)
    log("\ncover : cover.jpg (%d bytes)" % size)

    # ---- backup of what is being fetched (origin URLs)
    meta = {"album": album, "artist": artist, "albumartist": albumartist,
            "date": a.date, "genre": genre, "total": len(tracks),
            "source": a.playlist, "tracks": []}
    sep = " - " if a.style == "dash" else "."
    made = []
    for i, t in enumerate(tracks, 1):
        out, name = encode(t, meta, cover, dest, sep)
        meta["tracks"].append({"index": t["index"], "title": t["title"],
                               "youtube_id": t["id"], "url": t["url"],
                               "duration": t.get("duration"), "file": name})
        made.append((out, t))
        log("  [%d/%d] %s" % (i, len(tracks), name))

    if not os.path.exists(backup):
        with open(backup, "w", encoding="utf-8") as fh:
            json.dump(meta, fh, ensure_ascii=False, indent=2)
        log("backup: %s" % backup)

    log("\nverifying:")
    bad = []
    for out, t in made:
        problems = verify(out, t, meta)
        if problems:
            bad.append("%s: %s" % (os.path.basename(out), "; ".join(problems)))
        else:
            log("  ok %s" % os.path.basename(out))
    if bad:
        die("verification failed:\n  " + "\n  ".join(bad))
    log("\nOK: %d mp3 tracks + cover.jpg in %s" % (len(made), dest))
    log("Next: run a library rescan on the player.")


if __name__ == "__main__":
    main()
