---
name: cd-rip
description: Rip an audio CD from /dev/sr0 (or another optical drive) into the user's music library as a tagged FLAC album with cover art. Uses MusicBrainz/CD-TEXT metadata, the Cover Art Archive, and the library's existing folder, filename, and tag conventions. Use when asked to rip, import, digitize, or copy a CD.
---

# CD ripping

This skill reproduces the workflow used to build the library at
`/run/media/xinuwu/6883-87F1/music` (an exFAT drive). Read
`references/library-conventions.md` before choosing names/tags and
`references/musicbrainz.md` for API details.

If the user names a different target directory, use that instead of the path above.

## 1. Inspect the disc and tools

```bash
ls -l /dev/sr0
cd-info --no-device-info /dev/sr0
```

Collect:

- **MCN/barcode** from the `Media Catalog Number (MCN)` line.
- **Disc title / performer** from the `CD-TEXT for Disc` section.
- **Per-track title, performer, composer, ISRC** from `CD-TEXT for Track N`.

Check tools: `cd-paranoia`, `flac`, `metaflac`, `ffprobe`, `curl`, `python3`.
`cdparanoia` is usually **not** installed here; use `cd-paranoia` (libcdio).
If `/dev/sr0` is unreadable, check `getfacl /dev/sr0` (this user normally has an ACL).

## 2. Identify the release on MusicBrainz

Query by barcode first (see `references/musicbrainz.md` for exact commands):

```bash
curl -s -A 'cd-rip/1.0 ( local )' \
  'https://musicbrainz.org/ws/2/release/?query=barcode:<MCN>&fmt=json'
```

Pick the release whose barcode, track count, and medium (CD) match. Prefer
`status: Official`. Then fetch it with recordings/labels:

```bash
curl -s -A 'cd-rip/1.0 ( local )' \
  'https://musicbrainz.org/ws/2/release/<RELEASE_ID>?inc=recordings+artist-credits+labels+release-groups&fmt=json'
```

Notes:

- MusicBrainz requires a User-Agent and **at most 1 request/second**.
- `cd-discid` may emit an invalid disc ID under libcdio here. Prefer the
  barcode/MCN; only compute a disc ID if the barcode lookup fails.
- CD-TEXT titles are authoritative for the physical disc; MusicBrainz titles
  are usually cleaner and consistent. Check both, and prefer the disc's
  composer/ISRC data from CD-TEXT.

## 3. Download the cover

```bash
mkdir -p /tmp/cdrip/art
curl -sL -A 'cd-rip/1.0 ( local )' \
  'https://coverartarchive.org/release/<RELEASE_ID>/front-1200.jpg' \
  -o /tmp/cdrip/art/cover.jpg
file /tmp/cdrip/art/cover.jpg
```

Fall back to `front-500.jpg` or the release-group URL if the release has no
art. Confirm it is a real JPEG/PNG (not an HTML error page).

## 4. Rip the disc

```bash
bash scripts/rip-audio-cd.sh /dev/sr0 /tmp/cdrip
```

This runs a secure `cd-paranoia -B` rip to `/tmp/cdrip/trackNN.cdda.wav` and
exits non-zero if the log shows read problems. A 60–70 minute disc takes
roughly 20–30 minutes here (about 2× realtime). For long rips run it in the
background and poll:

```bash
nohup bash scripts/rip-audio-cd.sh /dev/sr0 /tmp/cdrip >/tmp/cdrip/rip.out 2>&1 &
# later: tail /tmp/cdrip/rip.out; pgrep -x cd-paranoia
```

Do not rip with `abcde` unless the user asks: its default reader is not
installed, and this skill already handles naming/tagging.

## 5. Build the manifest and install the album

Create `/tmp/cdrip/manifest.json` using
`references/manifest-example.json` as the template. Choose `album_dir`
yourself from the release metadata (see conventions below). Each track needs
`number`, `title`, and per-track `composer`/`isrc` where available. `length`
(seconds from MusicBrainz) is optional but enables duration verification.

Then:

```bash
python3 scripts/encode-album.py /tmp/cdrip/manifest.json --cleanup
```

The script encodes FLAC (`-8`), writes lower-case Vorbis tags, embeds the
cover as picture type 3 in every track, copies `cover.jpg` to the album
folder, verifies each duration against the manifest, and moves files onto the
exFAT drive (copy, not rename). It is idempotent: existing tracks are skipped
unless `--force` is passed.

## 6. Verify

```bash
cd "/run/media/xinuwu/6883-87F1/music/<AlbumDir>"
ls -la
flac -t -s *.flac && echo ALL_FLAC_OK
metaflac --export-tags-to=- "01 - <Title>.flac"
metaflac --list "01 - <Title>.flac" | grep -A8 PICTURE   # must show type 3
```

Also confirm:

- `rip.log` contains no error smilies (`:-(`, `;-(`, `8-|`, `8-X`, `:-0`).
- Every FLAC duration matches the MusicBrainz length to within ~0.01 s.
- `cover.jpg` exists and every FLAC embeds exactly one front picture.
- Temporary WAVs are gone after `--cleanup`.

## Naming and tagging defaults

- Folder: `AlbumArtistSlug-AlbumSlug` with spaces and punctuation removed
  (`VivaldiLocatelli-ChloeChua`, `Kyougen-Ado`, `SimplyTheBest-ChetBaker`).
  Some albums use just the album name; check the existing library first.
- Tracks: `NN - Title.flac`, two-digit track numbers.
- Tags (lower-case): `album`, `artist`, `albumartist`, `title`, `tracknumber`,
  `tracktotal`, `date`, `genre`, `composer`, `isrc`, `label`,
  `catalognumber`, `barcode`, `musicbrainz_albumid`. Add or omit fields as the
  release warrants.
- Cover: `cover.jpg` in the album folder **and** an embedded front cover in
  each FLAC. Other albums sometimes use `AlbumNameCover.jpg`; prefer
  `cover.jpg` for new rips.

## Gotchas

- exFAT forbids `\ / : * ? " < > |` in filenames. `encode-album.py` sanitizes
  titles (e.g. `:` → ` - `, `/` → `⧸`) and applies the same value to tags so
  filenames and tags stay in sync, matching the rest of the library.
- `metaflac --import-picture-from` needs five pipe-separated fields:
  `3|image/jpeg|||/path/to/cover.jpg` (the empty width/height field matters).
- `/tmp` and the exFAT drive are different filesystems: rename fails with
  `EXDEV`; copy/move instead.
- Do not add `.lrc` files for CD rips; only some non-CD albums have them.
- If the rip log reports errors, re-clean the disc or lower the read speed
  (`cd-paranoia -S 4 ...`) rather than accepting `;-(` tracks.
