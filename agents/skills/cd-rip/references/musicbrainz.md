# MusicBrainz and Cover Art Archive notes

## Rules

- Send a descriptive `User-Agent`, e.g. `cd-rip/1.0 ( local )`.
- Stay at or below **1 request per second**.
- Use `fmt=json` and parse with `python3 -m json.tool` or Python.
- These are public APIs; no token is needed. Cover Art Archive redirects to
  archive.org, so use `curl -L`.

## Find a release by barcode (MCN)

```bash
curl -s -A 'cd-rip/1.0 ( local )' \
  'https://musicbrainz.org/ws/2/release/?query=barcode:8717306260626&fmt=json'
```

JSON path: `releases[0].id`, `.title`, `.artist-credit`, `.media[0].track-count`,
`.label-info`, `.date`, `.status`.

Select by: barcode matches, track count matches the disc, `media[].format` is
`CD`, `status` is `Official`.

## Fetch a release with recordings and labels

```bash
curl -s -A 'cd-rip/1.0 ( local )' \
  'https://musicbrainz.org/ws/2/release/<RELEASE_ID>?inc=recordings+artist-credits+labels+release-groups&fmt=json'
```

Useful fields:

- `title`, `date`, `barcode`, `id`
- `artist-credit[].name` (release-level artist string)
- `label-info[].catalog-number`, `label-info[].label.name`
- `media[0].tracks[].number`, `.title`, `.length` (milliseconds)
- `release-group.id` (for cover fallback)

## Find a release by disc ID

If the barcode is missing, compute a disc ID with libdiscid (`discid` /
`python3-discid`) and look it up:

```bash
curl -s -A 'cd-rip/1.0 ( local )' \
  'https://musicbrainz.org/ws/2/discid/<DISCID>?inc=artists+recordings+release-groups&fmt=json'
```

Caveat: on this machine `cd-discid` (libcdio) returned a malformed ID
(`... 3731` as leadout), which MusicBrainz rejects as "Invalid discid".
`cd-info` reads the TOC and CD-TEXT correctly, so use MCN/barcode and CD-TEXT
first.

## CD-TEXT from cd-info

```bash
cd-info --no-device-info /dev/sr0
```

- Disc block: `TITLE`, `PERFORMER`, `UPC_EAN` (MCN).
- Track blocks: `TITLE`, `PERFORMER`, `COMPOSER`, `ISRC`.

Use CD-TEXT for **composers and ISRCs** (MusicBrainz does not return composer
relations in the basic release response). Use MusicBrainz for album title,
dates, label, catalog number, and often cleaner track titles.

## Cover Art Archive

```bash
# release front cover, 1200 px
curl -sL -A 'cd-rip/1.0 ( local )' \
  'https://coverartarchive.org/release/<RELEASE_ID>/front-1200.jpg' \
  -o /tmp/cdrip/art/cover.jpg

# fallback via release group
curl -sL -A 'cd-rip/1.0 ( local )' \
  'https://coverartarchive.org/release-group/<RG_ID>/front-1200.jpg' \
  -o /tmp/cdrip/art/cover.jpg

# check what exists
curl -s -A 'cd-rip/1.0 ( local )' \
  'https://coverartarchive.org/release/<RELEASE_ID>'
```

Thumbnail variants: `front-250.jpg`, `front-500.jpg`, `front-1200.jpg`.
Always verify with `file` — a missing cover can return an HTML/JSON error
body with HTTP 200 after redirects.

## Manifest fields

`scripts/encode-album.py` consumes JSON like
`references/manifest-example.json`:

| Key | Meaning |
|---|---|
| `music_root` | library root on the exFAT drive |
| `album_dir` | new folder name under `music_root` |
| `wav_dir` | directory with `trackNN.cdda.wav` |
| `cover` | path to downloaded front cover |
| `release` | album-level tags; `album` is required |
| `tracks[]` | `number`, `title`, optional `composer`, `isrc`, `length`, other tags |

Per-track keys override release-level tags (so each track can carry its own
`composer`). `length` is in seconds (MusicBrainz milliseconds / 1000) and is
only used for verification. `tag_title` lets you keep a different tag text
from the sanitized filename, if ever needed.
