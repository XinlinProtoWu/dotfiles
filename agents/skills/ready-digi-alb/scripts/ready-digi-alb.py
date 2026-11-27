#!/usr/bin/env python3
"""Ready a downloaded/purchased digital album for the Shanling Q2 library.

Turns a store-dump folder (ID-numbered FLACs, giant duplicated cover art,
label/UUID junk tags, no sidecar cover) into the shape the rest of
/run/media/xinuwu/6883-87F1/music uses:

  * sidecar `cover.jpg` (downscaled, cheap) + same art embedded once per file
  * `NN.Title.flac` (or `NN - Title.flac`) filenames in disc/track order
  * clean Vorbis tags: ALBUM, ALBUMARTIST, ARTIST, TITLE, TRACKNUMBER,
    TRACKTOTAL (per disc), DISCNUMBER, DISCTOTAL, DATE, GENRE (+ optionally
    COMPOSER/ISRC/LABEL/CATALOGNUMBER/BARCODE/MUSICBRAINZ_*)
  * a JSON backup of the original filenames+tags outside the music tree
  * verification that the audio stream still matches its internal MD5

Idempotent and resumable: if a rename already happened it skips to retagging,
so a killed run can simply be started again.

Usage:
  ready-digi-alb.py ALBUM_DIR --genre J-Pop [options]

Options:
  --artist, --album, --date     override metadata read from tags
  --genre G                     genre to write (default: keep existing; if the
                                store left it blank it stays blank -> pass this)
  --style {auto,dot,dash}       01.Title vs 01 - Title (auto: copy the artist's
                                sibling folders, else dash)
  --cover PATH                  use this image instead of the embedded art
  --cover-size N                square cover edge in px (default 500)
  --backup-dir DIR              where to write tag-backup-before-*.json
  --dry-run                     print the plan, change nothing
  --no-verify                   skip `flac -t`
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import unicodedata

CARD = "/run/media/xinuwu/6883-87F1"
DEFAULT_LIBRARY = CARD + "/music"

# Tags kept from the store file (everything else is label/uuid junk).
KEEP = {
    "COMPOSER", "ISRC", "LABEL", "CATALOGNUMBER", "BARCODE",
    "MUSICBRAINZ_ALBUMID", "MUSICBRAINZ_TRACKID", "MUSICBRAINZ_RELEASEGROUPID",
    "MUSICBRAINZ_ARTISTID", "MUSICBRAINZ_ALBUMARTISTID",
    "CONDUCTOR", "PERFORMER", "LYRICIST", "ARRANGER",
}
WRITE_ORDER = [
    "ALBUM", "ALBUMARTIST", "ARTIST", "TITLE", "TRACKNUMBER", "TRACKTOTAL",
    "DISCNUMBER", "DISCTOTAL", "DATE", "GENRE",
]
FORBIDDEN = '\\/:*?"<>|'
TAG_NAMES = {
    "disc": ("DISCNUMBER", "DISC", "DISKNUMBER"),
    "track": ("TRACKNUMBER", "TRACK"),
    "title": ("TITLE",),
    "album": ("ALBUM",),
    "artist": ("ARTIST",),
    "albumartist": ("ALBUMARTIST", "ALBUM ARTIST", "ALBUM_ARTIST"),
    "date": ("DATE", "YEAR"),
    "genre": ("GENRE",),
    "disctotal": ("DISCTOTAL", "TOTALDISCS", "ALLDISCCOUNT"),
    "tracktotal": ("TRACKTOTAL", "TOTALTRACKS", "ALLTRACKCOUNT"),
}


def die(msg):
    sys.stderr.write("ERROR: %s\n" % msg)
    sys.exit(1)


def run(cmd, **kw):
    return subprocess.run(cmd, capture_output=True, text=True, **kw)


def read_tags(path):
    """All Vorbis comments as UPPER KEY -> first value ('' if empty)."""
    out = run(["metaflac", "--export-tags-to=-", path]).stdout
    tags = {}
    for line in out.splitlines():
        if "=" not in line:
            continue
        k, v = line.split("=", 1)
        k = k.strip().upper()
        tags.setdefault(k, v.strip())
    return tags


def tag(tags, key):
    for name in TAG_NAMES[key]:
        v = tags.get(name, "").strip()
        if v:
            return v
    return ""


def num(s, what, path):
    try:
        return int(re.sub(r"[^0-9].*$", "", s.strip()))
    except (ValueError, AttributeError):
        die("unreadable %s %r in %s" % (what, s, path))


def slugify(s):
    s = unicodedata.normalize("NFKC", s)
    return re.sub(r"[\s\-_./'\"()\[\]&,]+", "", s)


def safe_filename(title):
    """Library precedent: '8/31' is stored as '831.flac' - drop the chars exFAT
    forbids, squeeze the resulting gaps."""
    out = "".join("" if ch in FORBIDDEN else ch for ch in title).strip()
    out = re.sub(r"\s{2,}", " ", out).strip(" .")
    return out or "untitled"


def detect_style(artist, album_dir):
    """Return '.' or ' - ' by looking at the artist's other albums."""
    parent = os.path.dirname(album_dir.rstrip("/"))
    scores = {". |": 0, " - ": 0}   # ".|" so the separator is exactly "."
    if os.path.isdir(parent):
        want = slugify(artist)
        for d in os.listdir(parent):
            if not os.path.isdir(os.path.join(parent, d)):
                continue
            if slugify(d.split("-")[0]) != want:
                continue
            for f in os.listdir(os.path.join(parent, d))[:50]:
                if re.match(r"^\d{2,3}\.[^ ]", f):
                    scores[". |"] += 1
                elif re.match(r"^\d{2,3} - ", f):
                    scores[" - "] += 1
    return "." if scores[". |"] > scores[" - "] else " - "


def collect(album_dir):
    files = [f for f in sorted(os.listdir(album_dir))
             if f.lower().endswith(".flac") and
             os.path.isfile(os.path.join(album_dir, f))]
    if not files:
        die("no .flac files in %s" % album_dir)
    rows = []
    for f in files:
        p = os.path.join(album_dir, f)
        t = read_tags(p)
        title = tag(t, "title")
        if not title:
            die("no TITLE tag in %s - fix metadata before running" % p)
        rows.append({
            "old": f,
            "path": p,
            "disc": num(tag(t, "disc") or "1", "disc number", p),
            "track": num(tag(t, "track") or "1", "track number", p),
            "title": title,
            "tags": t,
            "size": os.path.getsize(p),
        })
    rows.sort(key=lambda r: (r["disc"], r["track"]))
    seen = {}
    for r in rows:
        key = (r["disc"], r["track"])
        if key in seen:
            die("duplicate disc/track %s: %s and %s"
                % (key, seen[key], r["old"]))
        seen[key] = r["old"]
    return rows


def make_cover(rows, album_dir, cover_arg, size, dry):
    target = os.path.join(album_dir, "cover.jpg")
    if cover_arg:
        src = cover_arg
    elif os.path.exists(target) and os.path.getsize(target):
        return target, os.path.getsize(target)
    else:
        src = "/tmp/ready-digi-alb-cover-src.img"
        p = run(["metaflac", "--export-picture-to=" + src, rows[0]["path"]])
        if p.returncode != 0 or not os.path.getsize(src):
            # maybe a sidecar image already exists
            cands = [f for f in os.listdir(album_dir)
                     if re.search(r"\.(jpe?g|png)$", f, re.I)
                     and not f.lower().startswith("cover")]
            if not cands:
                die("no embedded art and no sidecar image - pass --cover PATH")
            src = os.path.join(album_dir, cands[0])
    if dry:
        print("  cover: %s -> cover.jpg (%dx%d)" % (src, size, size))
        return target, 0
    tmp = target + ".tmp.jpg"
    run(["magick", src, "-resize", "%dx%d^" % (size, size),
         "-gravity", "center", "-extent", "%dx%d" % (size, size),
         "-strip", "-quality", "88", tmp])
    if not os.path.getsize(tmp):
        die("cover conversion failed")
    os.replace(tmp, target)
    return target, os.path.getsize(target)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("album_dir")
    ap.add_argument("--artist")
    ap.add_argument("--album")
    ap.add_argument("--date")
    ap.add_argument("--genre")
    ap.add_argument("--style", choices=["auto", "dot", "dash"], default="auto")
    ap.add_argument("--cover")
    ap.add_argument("--cover-size", type=int, default=500)
    ap.add_argument("--backup-dir")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--no-verify", action="store_true")
    a = ap.parse_args()

    album_dir = a.album_dir.rstrip("/")
    if not os.path.isdir(album_dir):
        die("not a directory: %s" % album_dir)

    rows = collect(album_dir)
    first = rows[0]["tags"]
    album = a.album or tag(first, "album") or os.path.basename(album_dir)
    artist = a.artist or tag(first, "artist") or tag(first, "albumartist")
    if not artist:
        die("no ARTIST tag - pass --artist")
    albumartist = tag(first, "albumartist") or artist
    date = a.date or tag(first, "date")
    genre = a.genre
    if genre is None:
        genre = tag(first, "genre")
        if not genre:
            print("WARNING: source has no genre; pass --genre to set one "
                  "(e.g. J-Pop, Classical)")

    if a.style == "auto":
        sep = detect_style(artist, album_dir)
    else:
        sep = "." if a.style == "dot" else " - "

    discs = sorted({r["disc"] for r in rows})
    disctotal = len(discs)
    per_disc = {d: sum(1 for r in rows if r["disc"] == d) for d in discs}
    width = max(2, len(str(len(rows))))

    # Filenames keep counting across discs (01..25), while TRACKNUMBER restarts
    # per disc - otherwise disc 2 would collide with disc 1 in one folder.
    plan = []
    idx = 0
    for d in discs:
        for r in [x for x in rows if x["disc"] == d]:
            idx += 1
            plan.append((r, ("%0*d" % (width, idx)) + sep +
                         safe_filename(r["title"]) + ".flac"))

    targets = [n for _, n in plan]
    dupes = {n for n in targets if targets.count(n) > 1}
    if dupes:
        die("filename collision: %s" % ", ".join(sorted(dupes)))

    lib = os.path.dirname(album_dir)
    backup_dir = a.backup_dir
    if not backup_dir:
        backup_dir = os.path.dirname(lib) if os.path.basename(lib) == "music" else lib
    backup = os.path.join(
        backup_dir, "tag-backup-before-%s.json" % safe_filename(album))

    print("album : %s" % album)
    print("artist: %s (albumartist %s)" % (artist, albumartist))
    print("discs : %s  tracks: %d  style: %r" % (discs, len(rows), sep.strip()))
    print("genre : %s" % (genre or "(blank)"))
    print("backup: %s" % backup)
    for r, new in plan:
        print("  %-28s -> %s" % (r["old"], new))

    if a.dry_run:
        make_cover(rows, album_dir, a.cover, a.cover_size, dry=True)

    if not a.dry_run:
        if os.path.exists(backup):
            print("backup exists, keeping the original: %s" % backup)
        else:
            with open(backup, "w", encoding="utf-8") as fh:
                json.dump({"folder": album_dir,
                           "files": [{"file": r["old"], "disc": r["disc"],
                                      "track": r["track"], "title": r["title"],
                                      "tags": r["tags"]} for r in rows]},
                          fh, ensure_ascii=False, indent=2)
            print("wrote backup")

    cover_path, cover_bytes = (make_cover(rows, album_dir, a.cover,
                                          a.cover_size, a.dry_run)
                               if not a.dry_run else (None, 0))
    if not a.dry_run:
        print("cover : cover.jpg (%d bytes)" % cover_bytes)

    before = sum(r["size"] for r in rows)
    for i, (r, new) in enumerate(plan, 1):
        src = r["path"]
        dst = os.path.join(album_dir, new)
        if a.dry_run:
            continue
        if os.path.exists(src) and os.path.abspath(src) != os.path.abspath(dst):
            if os.path.exists(dst):
                die("target exists: %s" % dst)
            os.rename(src, dst)
        elif not os.path.exists(dst):
            die("missing %s (and no renamed file)" % src)
        # Two passes: metaflac refuses to mix major (--remove --block-type)
        # with shorthand (--set-tag/--import-picture-from) operations.
        p = run(["metaflac", "--remove", "--block-type=PICTURE",
                 "--dont-use-padding", dst])
        if p.returncode:
            die("metaflac remove picture failed on %s: %s" % (dst, p.stderr))
        args = ["metaflac", "--remove-all-tags", "--dont-use-padding",
                "--set-tag=ALBUM=" + album,
                "--set-tag=ALBUMARTIST=" + albumartist,
                "--set-tag=ARTIST=" + artist,
                "--set-tag=TITLE=" + r["title"],
                "--set-tag=TRACKNUMBER=%02d" % r["track"],
                "--set-tag=TRACKTOTAL=%d" % per_disc[r["disc"]]]
        if disctotal > 1:
            args += ["--set-tag=DISCNUMBER=%d" % r["disc"],
                     "--set-tag=DISCTOTAL=%d" % disctotal]
        if date:
            args.append("--set-tag=DATE=" + date)
        if genre:
            args.append("--set-tag=GENRE=" + genre)
        for k, v in r["tags"].items():
            if k in KEEP and v:
                args.append("--set-tag=%s=%s" % (k, v))
        args += ["--import-picture-from=" + cover_path, dst]
        p = run(args)
        if p.returncode:
            die("metaflac tag failed on %s: %s" % (dst, p.stderr))
        print("  [%d/%d] %s" % (i, len(rows), new), flush=True)

    if a.dry_run:
        return

    after = sum(os.path.getsize(os.path.join(album_dir, n)) for _, n in plan)
    print("size  : %.1f MB -> %.1f MB (saved %.1f MB)"
          % (before / 1e6, after / 1e6, (before - after) / 1e6))

    bad = []
    for _, n in plan:
        p = os.path.join(album_dir, n)
        t = read_tags(p)
        if tag(t, "title") == "" or tag(t, "album") != album:
            bad.append(n + " (tags)")
            continue
        pic = run(["metaflac", "--list", p]).stdout
        if pic.count("type: 6 (PICTURE)") != 1:
            bad.append(n + " (picture)")
        if not a.no_verify:
            if run(["flac", "-t", "-s", p]).returncode:
                bad.append(n + " (flac md5)")
        print("  checked %s" % n, flush=True)
    if bad:
        die("verification failed: %s" % "; ".join(bad))
    print("OK: %d tracks verified, cover.jpg in place" % len(plan))
    print("Next: run a library rescan on the player.")


if __name__ == "__main__":
    main()
