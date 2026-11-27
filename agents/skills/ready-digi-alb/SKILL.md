---
name: ready-digi-alb
description: Ready a downloaded/purchased digital album (Qobuz, mora, Ototoy, Universal store dump, etc.) for the Shanling Q2 player — extract and shrink the cover into cover.jpg, rename ID-numbered FLACs to NN.Title.flac in disc/track order, strip label/UUID junk tags, write clean Vorbis tags with disc totals, back up the originals, and verify every file. Use when asked to ready, fix, normalise, tag, tidy, or "make playable like the others" a newly copied digital album on the SD card.
---

# Ready a purchased digital album

Store dumps arrive as `446700624.flac`, `0044713930.flac`, …: filenames that are
store item IDs, a 1–3 MB cover embedded in *every* track, no `cover.jpg`,
`Genre=` blank, and 20+ junk tags (UUID-keyed comments, `RcMusicID`,
`RcAlbumID`, `TitleSort`, `Copyright`, …). The player (Shanling Q2, HiBy-style
library: `.sldp/`, `.coverflow/`, `.scrobbler.log` at the card root) happily
plays them, but they look wrong next to the rest of
`/run/media/xinuwu/6883-87F1/music`.

This skill reproduces the Lantern (ヨルシカ-幻燈) pass. It is a *metadata and
layout* job — never re-encode; the audio stream and its internal MD5 must stay
byte-identical.

Assets in this skill:

- `scripts/ready-digi-alb.py` — does the whole job, idempotent, resumable.

## 1. Look before touching

```bash
cd "/run/media/xinuwu/6883-87F1/music/<AlbumDir>"
ls -la
metaflac --list "$(ls *.flac | head -1)" | grep -E 'comment\[|type: 6|width|height|length'
```

Write down:

- **Disc/track structure.** `DiscNumber`/`TrackNumber`/`AllDiscCount` tell you
  if it is a multi-disc release that must keep `DISCNUMBER`/`DISCTOTAL`.
- **Title tags present?** If `TITLE` is missing there is nothing to name files
  from — resolve metadata first (MusicBrainz, or read the store receipt) and
  only then run this skill.
- **Which sibling folders belong to the same artist** (`ls ../ | grep <Artist>`)
  — they decide the filename style (step 2) and a sensible genre.
- **The album is not already on the card** under another name.

Do not delete or move anything yet: the card copy is usually the only copy.

## 2. Decide the four choices

**Filename style.** Copy the artist's existing folders; do not impose one.

| folder | style |
|---|---|
| `ヨルシカ-盗作`, `ヨルシカ-だから僕は音楽を辞めた` | `01.夏の肖像.flac` (dot) |
| `15`, `Soulboy`, `危险世界`, Mozart/Chloe Chua discs | `01 - Goto.flac`, `01 - Track.flac` (dash) |

The script auto-detects this (`--style auto`) by counting `NN.` vs `NN - ` files
in the artist's sibling folders and falling back to dash. Override with
`--style dot` / `--style dash`.

**Cover.** 500×500 q88 `cover.jpg` (~60–120 KB) matches the older library;
newer Pentatone rips use 1200. Take it from the embedded art (or `--cover
PATH`) and let the script re-embed the *same* small image, reclaiming
~2.5 MB per track.

**Genre.** Store files leave it blank; the library fills it. Copy the artist's
neighbours (`Alternative`, `J-Pop`, `Classical`, `misc`) and pass `--genre`.
The script never guesses.

**Discs.** Keep a real multi-disc release as discs (`DISCNUMBER`, `DISCTOTAL`,
per-disc `TRACKTOTAL`), but let filenames count straight through
(`01…25`) so folder order and any tag-blind sort both come out right.

## 3. Dry run, then run

```bash
S=~/.agents/skills/ready-digi-alb/scripts/ready-digi-alb.py

python3 $S "ヨルシカ-幻燈" --genre J-Pop --dry-run     # prints the plan + backup path
python3 $S "ヨルシカ-幻燈" --genre J-Pop
```

What it does, in order:

1. Tags read once per file (`metaflac --export-tags-to=-`), sorted by
   disc/track; duplicate disc+track aborts.
2. Writes `tag-backup-before-<album>.json` (all original filenames + tags) to
   the **card root**, next to `tag-backup-before-albums.json` — never into the
   album folder, where the player would index it. An existing backup is kept,
   not overwritten.
3. Exports the picture from track 1, resizes to 500×500 q88 → `cover.jpg`.
4. Renames to the chosen style (sanitising exFAT-forbidden `\ / : * ? " < > |`
   by dropping them, so `8/31` becomes `831` like the existing library; the
   `TITLE` tag keeps the real title).
5. Two `metaflac` passes per file: remove all picture blocks, then
   `--remove-all-tags` + the clean tag set + `--import-picture-from=cover.jpg`
   (absolute path).
6. Verifies every file: tags, exactly one `type: 6` picture, and `flac -t`
   (internal MD5 ⇒ audio untouched), then reports MB saved.

Renames happen before tagging, and the mapping comes from the backup, so a
killed run resumes correctly — just run the same command again.

## 4. Check the result by hand

```bash
cd "/run/media/xinuwu/6883-87F1/music/<AlbumDir>"
ls -la                                    # NN.Title.flac ... cover.jpg
flac -t -s *.flac && echo ALL_FLAC_OK
metaflac --export-tags-to=- "01.<Title>.flac"
metaflac --list "01.<Title>.flac" | grep -A8 'type: 6'
```

Expected tag set (order-insensitive, lower/upper case both exist in the
library — the script writes upper):

```
ALBUM / ALBUMARTIST / ARTIST / TITLE / TRACKNUMBER / TRACKTOTAL
DISCNUMBER / DISCTOTAL      (multi-disc only)
DATE / GENRE
COMPOSER / ISRC / LABEL / BARCODE / MUSICBRAINZ_*   (only if the store had them)
```

Then tell the user to run a **library rescan/update** on the device; stale rows
for the old `446700624.flac` names disappear on the next scan.

## Gotchas

- **`metaflac` will not mix major and shorthand operations** — `--remove
  --block-type=PICTURE` together with `--set-tag`/`--import-picture-from` fails
  with *"you may not mix shorthand and major operations"*. Hence two passes.
- **Every `metaflac` edit rewrites the whole file.** Two passes over a 25-track
  2 GB album on exFAT takes ~6 minutes; do not run it under a short timeout,
  send it to a log and poll (`nohup … >/tmp/ready.log 2>&1 &`, `tail -f`).
  Progress lines are flushed per file.
- `--dont-use-padding` is what actually reclaims the removed cover art.
- `--import-picture-from` resolves the path against the current directory —
  pass an absolute path.
- exFAT: `os.rename` within the card is fine; `rename` from `/tmp` is not
  (`EXDEV`) — copy instead.
- Do not add `.lrc` files: Japanese/digital albums in this library have none.
- Leave the card root alone (`.sldp/`, `.coverflow/`, `.scrobbler.log`,
  `.ratings.tsv`, `update.tar`) — they belong to the player.
- Never re-encode to "fix" tags; `flac -t` must pass afterwards, which proves
  the audio stream was preserved.
