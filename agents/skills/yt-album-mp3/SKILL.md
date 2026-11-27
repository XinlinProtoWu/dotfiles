---
name: yt-album-mp3
description: Download a YouTube / YouTube Music album playlist with yt-dlp, convert it to MP3 with ffmpeg, and install it on the Shanling Q2 card as a ready album — NN - Title.mp3 filenames, ID3v2.3 tags, 500x500 cover.jpg plus embedded front cover, provenance backup, and decode verification. Use when asked to grab an album from a YouTube link, rip a YT Music playlist, or "make this playlist an album for the device".
---

# YouTube playlist → ready MP3 album

The library's MP3 albums (`Kyougen-Ado`, `Zanmu-Ado`,
`SimplyTheBest-ChetBaker`, `Persona 5 Royal Full ost`) were all made exactly
this way: yt-dlp download → ffmpeg `libmp3lame` → `Lavf`-encoded ID3 tags +
embedded `mjpeg` front cover. This skill reproduces that, with the traps that
cost time on the first attempt.

Asset: `scripts/yt-album.py` — downloads (resumable), converts, tags, names,
backs up, and verifies. It does not decide metadata; you do.

## 1. Read the playlist before downloading

```bash
yt-dlp --flat-playlist --dump-single-json "<PLAYLIST_URL>" \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['title'], d['playlist_count']); \
[print(' ', e.get('id'), '|', e.get('duration'), '|', e['title']) for e in d['entries']]"
```

Flat extraction works even when playback is blocked, so always start here:
you get the title (= album), the track count and the video IDs to quote later.

A URL like `...&list=OLAK5uy_…` is a **YouTube Music album playlist**: the
entries are "art tracks" from the label's Topic channel. Ordinary
`watch?v=…&list=…` playlists mix official videos and art tracks — watch for
durations that disagree with the album (see §4).

## 2. Get canonical titles, durations and dates from MusicBrainz

Store/YouTube titles are dirty (`宇多田ヒカル - Automatic`,
`Automatic (Johnny Vicious Remix)`) and may be the *video* version, not the
album version. Match a release first:

```bash
curl -s -A 'yt-album/1.0 ( local )' -G 'https://musicbrainz.org/ws/2/release/' \
  --data-urlencode 'query=artist:"<artist>" AND release:"<album>"' \
  --data 'fmt=json' --data 'limit=10' \
| python3 -c "import json,sys
[print(r['id'], r['date'], r.get('country'), r.get('barcode'), r.get('track-count'), r['title']) for r in json.load(sys.stdin)['releases']]"
```

MusicBrainz answers **503 with an empty body** if you query faster than
1 request/second; the script retries with backoff, and if a manual `curl`
comes back blank just wait a minute and repeat. Sub-second "durations match"
is the test for a good release.

Pick the release whose track count equals the playlist count and whose
durations match. Pass its id as `--mb-release`: the script then uses its
titles, refuses to run if the counts differ (no silent mis-mapping), and pulls
`front-*.jpg` from the Cover Art Archive. Prefer CAA art over the video
thumbnail — that is what `cover.jpg` means in this library.

## 3. Make yt-dlp able to download

Two independent gates, both seen on the first attempt:

- **JS challenge.** Without a solver, yt-dlp reports *"Signature solving
  failed / n challenge solving failed"* and then *"Only images are available
  for download"*. Fix: a current yt-dlp **plus**
  `--remote-components ejs:github`. The distro build here
  (2026.08.19) failed the challenge even with the flag; a fresh venv worked:

  ```bash
  python3 -m venv /tmp/ytv && /tmp/ytv/bin/pip install -q -U yt-dlp
  /tmp/ytv/bin/yt-dlp --version        # 2026.11.23 at the time
  ```

  Keep it in `/tmp` rather than shadowing the system package.
- **Account / bot check.** *"Sign in to confirm you're not a bot"* →
  `--cookies-from-browser chrome` (the user's Chrome profile is signed in).
  Without cookies, only some clients work at all.

Probe one track before committing to a 12-track download:

```bash
/tmp/ytv/bin/yt-dlp --remote-components ejs:github --cookies-from-browser chrome \
  -f bestaudio --simulate --print '%(title)s | %(duration)s | %(format_id)s' \
  "https://www.youtube.com/watch?v=<ID>"
```

## 4. Check for Premium-gated tracks — do not silently substitute

Some entries answer `This video is only available to Music Premium members`
on **every** client. To confirm it is the video, not your flags, loop the
clients:

```bash
for c in web web_embedded web_safari web_creator mweb tv tv_simply \
         android android_vr android_music ios ios_music web_music; do
  printf '%-14s ' "$c"
  /tmp/ytv/bin/yt-dlp --remote-components ejs:github --cookies-from-browser chrome \
    --extractor-args "youtube:player_client=$c" -f bestaudio --simulate \
    --print '%(format_id)s' "https://www.youtube.com/watch?v=<ID>" 2>&1 | tail -1
done
```

If all fail, the playlist is only partly downloadable. **Stop and tell the
user** with the list, then offer: (a) sign in to a Premium account and retry
the same link, (b) take the missing songs from public uploads, verifying each
duration against MusicBrainz, or (c) another source. Do not quietly replace
label audio with fan re-uploads — say which track came from where.

Never install a partial album on the card; the script exits `3` and keeps the
audio for a resume unless `--allow-partial` is passed.

## 5. Build

```bash
S=~/.agents/skills/yt-album-mp3/scripts/yt-album.py

# plan only, no network writes
python3 $S "<PLAYLIST_URL>" --artist "宇多田ヒカル" --album "First Love" \
  --date 1999-03-10 --genre J-Pop --mb-release 4202c672-402d-3629-8078-e51bdaf1b77a \
  --dest "/run/media/xinuwu/6883-87F1/music/FirstLove-UtadaHikaru" --dry-run

# real run
python3 $S "<PLAYLIST_URL>" --artist "宇多田ヒカル" --album "First Love" \
  --date 1999-03-10 --genre J-Pop --mb-release 4202c672-402d-3629-8078-e51bdaf1b77a \
  --dest "/run/media/xinuwu/6883-87F1/music/FirstLove-UtadaHikaru" \
  --yt-dlp /tmp/ytv/bin/yt-dlp --cookies-from-browser chrome
```

Per track: `ffmpeg -c:a libmp3lame -q:a 0` (V0, ~240 kbps, native sample
rate), `-id3v2_version 3`, tags `title/artist/album_artist/album/track=N/T/
date/genre`, cover as `-disposition:v attached_pic` + `title=Album cover,
comment=Cover (front)`, output `NN - Title.mp3` (`--style dot` for the
`NN.Title` folders). Album folder default is `<AlbumSlug>-<ArtistSlug>`; the
Ado folders set that pattern (`Kyougen-Ado`, `Zanmu-Ado`).

### Building with substituted tracks

When a playlist entry is the wrong edit (video version, single edit) and the
user agrees to swap it, drop the replacement into the workdir with the same
`NN-<video id>` stem and point its `playlist_index` at the slot it fills —
`gather()` orders purely by that field:

```bash
cd /tmp/yt-album && rm -f 05-*
/tmp/ytv/bin/yt-dlp --remote-components ejs:github --cookies-from-browser chrome \
  -f bestaudio --write-info-json -o "05-<VIDEO_ID>.%(ext)s" "https://youtu.be/<VIDEO_ID>"
python3 -c "import json;p='05-<VIDEO_ID>.info.json';d=json.load(open(p));d['playlist_index']=5;json.dump(d,open(p,'w'),ensure_ascii=False)"
```

Then delete the old album folder and its `tag-backup-before-*.json` (the
backup must describe the final sources) and rebuild with `--audio-dir`.
Record in the report which tracks came from which channel.

Keep one master across the album: on *Bad* the playlist mixed "2012 Remaster"
uploads, and the four video entries were replaced with the same series
(`… (2012 Remaster)` from the official channel), so nothing jumps in level or
EQ. A duration match alone is not enough — match the remaster too.

`--audio-dir /tmp/yt-album` re-runs the build from already downloaded
`NN-<id>.info.json` + audio without touching the network — use it after a
partial download or to re-tag.

Resume/cleanup: yt-dlp skips files already present, so re-running the same
command continues; the workdir (`/tmp/yt-album`) holds only downloads and can
be deleted afterwards. Nothing is written to the card before every track is
accounted for.

## 6. Verify by hand

```bash
cd "/run/media/xinuwu/6883-87F1/music/<AlbumDir>"
ls -la                                  # NN - Title.mp3 ... cover.jpg
ffprobe -v quiet -show_entries format_tags -show_entries stream=codec_name \
  -of default=nw=1 "01 - <Title>.mp3"   # mp3 + mjpeg + your tags
ffmpeg -v error -i "01 - <Title>.mp3" -f null - && echo DECODE_OK
```

Then ask for a library rescan on the player.

## Gotchas

- `bestaudio` is usually **opus/webm**, not mp3 — always transcode with
  `libmp3lame`; `-c copy` to `.mp3` fails or lies.
- `-c:v copy` for the cover works because `cover.jpg` is already JPEG; ffmpeg
  writes it as an `mjpeg` attached picture. Verify the stream exists — a
  missing `-disposition:v attached_pic` silently drops the art.
- ID3 track tags store `N/T`; read them as an int before comparing, not as a
  zero-padded string.
- ID3v2.3 + `-write_id3v1 1` is redundant; the library files are ID3v2-only.
- The provenance backup (`tag-backup-before-<album>.json`) belongs at the
  **card root** next to the existing `tag-backup-*.json`, never in the album
  folder (the player would index it). The script only does that when the
  destination is under `/run/media/…/music`; for a scratch `--dest` it writes
  beside the folder.
- exFAT: drop `\ / : * ? " < > |` from filenames but keep the real title in
  the tag (`8/31` → `831.flac` is the library precedent).
- A playlist entry that is a **PV/music video** can be 60 s shorter than the
  album track. Flag the mismatch instead of shipping the wrong edit.
- Playlists can mix channels — *Got to Be There* had one entry uploaded by
  "Classic Motown" rather than the artist. Matching by position against
  MusicBrainz handles it, provided the count matches.
- MusicBrainz titles use typographic punctuation (’ “ ”), which is legal on
  exFAT but unlike the rest of the library; the script maps them to ASCII.
- The gate in §4 is per video/catalogue, not per playlist: the Michael
  Jackson / Motown album downloaded in full while the Utada Hikaru one did
  not. Always probe before declaring a playlist broken.
- `.lrc` lyrics are not added for these albums; the card root's `.sldp/`,
  `.coverflow/`, `.scrobbler.log`, `.ratings.tsv`, `update.tar` are the
  player's — leave them alone.
