# Library conventions

Observed in `/run/media/xinuwu/6883-87F1/music` (exFAT, 2026-11).

## Folder layout

```
music/
├── AlbumName/                       # album-only name
├── Album-Artist/                    # most common: album then artist, spaces removed
│   ├── 01 - Track Title.flac
│   ├── ...
│   └── cover.jpg
└── Artist-Album/                    # occasional reverse order
```

Examples: `15`, `Soulboy`, `爱爱爱`, `Kat's Diner`, `Kyougen-Ado`,
`Zanmu-Ado`, `SimplyTheBest-ChetBaker`, `ヨルシカ-だから僕は音楽を辞めた`.

New rips should prefer **`AlbumArtistSlug-AlbumSlug`** (spaces and punctuation
removed), e.g. `VivaldiLocatelli-ChloeChua`. Check for an existing folder for
the same album first.

## Track files

- Primary naming: `NN - Title.flac` with two-digit track numbers
  (`01 - Gotta Make a Change.flac`, `01 - Kat's Diner.flac`).
- A few older folders use `NN.Title.flac` or three-digit numbers; do not copy
  those unless the folder already uses them.
- Formats present: FLAC (lossless rips) and MP3 (downloads). New CD rips are
  FLAC, encoded with `flac -8`.

## Tags

Vorbis comments, lower-case keys. Common set:

```
album=...
artist=...
albumartist=...        # sometimes album_artist
title=...
tracknumber=...        # sometimes track
tracktotal=...
date=YYYY-MM-DD
genre=...
composer=...
isrc=...
label=...
catalognumber=...
barcode=...
musicbrainz_albumid=...
```

Existing albums vary (some only have album/artist/albumartist/title/
tracknumber), but the richer set above is used for new rips.

## Cover art

- File at the album root: `cover.jpg` is the norm (some rips use
  `AlbumCover.jpg`, `KyogenCover.jpg`, etc. — prefer `cover.jpg` for new work).
- **Also embedded** in every FLAC as picture type 3 (Cover (front)),
  MIME `image/jpeg`, empty description. This matters for players that ignore
  sidecar images.
- Cover Art Archive `front-1200.jpg` is a good source (1200×1200).

## Sidecars and other files

- `.lrc` lyric files exist only for some non-CD albums. CD rips do not need
  them.
- `.coverflow/`, `.sldp/`, `.scrobbler.log`, `.ratings.tsv` at the drive root
  belong to the player/app; leave them alone.
- exFAT forbids `\ / : * ? " < > |` in names. Existing names replace `:` with
  `,` or ` - `, `/` with `⧸`, and use fullwidth `～` for `~`. Keep filenames
  and tags in sync (see `scripts/encode-album.py`).
