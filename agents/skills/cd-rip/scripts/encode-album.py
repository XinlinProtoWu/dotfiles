#!/usr/bin/env python3
"""Encode ripped WAVs to FLAC, tag them, embed cover art, and install an album.

Usage:
    encode-album.py MANIFEST [--cleanup] [--force]

MANIFEST is a JSON file (see references/manifest-example.json). Required keys:
    music_root  library root, e.g. /run/media/xinuwu/6883-87F1/music
    album_dir   folder name to create under music_root
    wav_dir     directory containing trackNN.cdda.wav
    cover       path to a JPEG/PNG front cover
    release     dict of album-level tags (album, artist, albumartist, date, ...)
    tracks      list of dicts with at least number and title; other keys
                (composer, isrc, length, ...) become per-track tags. `length`
                is used to verify the encoded duration (seconds). `tag_title`
                overrides the sanitized title written to the tag.

Existing output tracks are skipped unless --force is given. With --cleanup,
the source WAVs and temp files are removed after a fully successful run.
"""
import argparse
import json
import mimetypes
import os
import re
import shutil
import subprocess
import sys

# exFAT forbids these in file names; the library also sanitizes tags to match.
FILENAME_MAP = {
    "/": "\u29f8",  # ⧸
    "\\": "\u29f8",
    "*": "\uff0a",  # ＊
    "?": "\uff1f",  # ？
    '"': "'",
    "<": "\u2039",  # ‹
    ">": "\u203a",  # ›
    "|": "\u00a6",  # ¦
}
CONTROL = re.compile(r"[\x00-\x1f\x7f]")


def sanitize(title: str) -> str:
    s = title.replace(": ", " - ").replace(":", " - ")
    for bad, good in FILENAME_MAP.items():
        s = s.replace(bad, good)
    s = CONTROL.sub("", s)
    s = re.sub(r"\s+", " ", s).strip().rstrip(" .")
    return s


def run(args):
    subprocess.run(args, check=True)


def probe_duration(path: str):
    try:
        out = subprocess.run(
            ["ffprobe", "-v", "error", "-show_entries", "format=duration",
             "-of", "default=nw=1:nk=1", path],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
        return float(out)
    except (OSError, ValueError, subprocess.CalledProcessError):
        return None


def main() -> int:
    ap = argparse.ArgumentParser(description="Install a ripped CD as a tagged FLAC album.")
    ap.add_argument("manifest", help="path to manifest JSON")
    ap.add_argument("--cleanup", action="store_true",
                    help="delete source WAVs and temp files after success")
    ap.add_argument("--force", action="store_true",
                    help="overwrite existing output FLACs")
    args = ap.parse_args()

    with open(args.manifest, encoding="utf-8") as fh:
        m = json.load(fh)

    music_root = m["music_root"]
    album_dir = os.path.join(music_root, m["album_dir"])
    wav_dir = m["wav_dir"]
    cover = m["cover"]
    release = {str(k).lower(): str(v) for k, v in m.get("release", {}).items()
               if v not in (None, "")}
    tracks = m["tracks"]

    if not os.path.isfile(cover):
        sys.exit(f"error: cover not found: {cover}")
    if not tracks:
        sys.exit("error: manifest has no tracks")
    if "album" not in release:
        sys.exit("error: manifest release must include 'album'")

    numbers = [int(t["number"]) for t in tracks]
    if len(set(numbers)) != len(numbers):
        sys.exit("error: duplicate track numbers in manifest")

    pending = []
    skipped = 0
    for track in sorted(tracks, key=lambda t: int(t["number"])):
        n = int(track["number"])
        title = sanitize(str(track.get("tag_title") or track["title"]))
        out = os.path.join(album_dir, f"{n:02d} - {title}.flac")
        if os.path.exists(out) and not args.force:
            print(f"skip existing: {out}")
            skipped += 1
            continue
        pending.append((track, n, title, out))

    missing = [n for _, n, _, _ in pending
               if not os.path.isfile(os.path.join(wav_dir, f"track{n:02d}.cdda.wav"))]
    if missing:
        sys.exit(f"error: missing WAVs for tracks: {missing}")

    mime = mimetypes.guess_type(cover)[0] or "image/jpeg"
    os.makedirs(album_dir, exist_ok=True)

    warnings = []
    written = 0

    for track, n, title, out in pending:
        wav = os.path.join(wav_dir, f"track{n:02d}.cdda.wav")
        tmp = os.path.join(wav_dir, f".{n:02d}.flac")

        tags = dict(release)
        for k, v in track.items():
            if k in ("number", "title", "tag_title", "length"):
                continue
            if v not in (None, ""):
                tags[str(k).lower()] = str(v)
        tags["title"] = title
        tags["tracknumber"] = str(n)
        tags["tracktotal"] = str(len(tracks))

        run(["flac", "-8", "-f", "-s", "-o", tmp, wav])

        margs = ["metaflac"]
        for k, v in tags.items():
            margs.append(f"--set-tag={k}={v}")
        margs.append(tmp)
        run(margs)
        run(["metaflac", f"--import-picture-from=3|{mime}|||{cover}", tmp])

        expected = track.get("length")
        actual = probe_duration(tmp)
        if expected is not None and actual is not None and abs(actual - float(expected)) > 0.5:
            warnings.append(f"track {n:02d}: duration {actual:.2f}s != expected {float(expected):.2f}s")

        shutil.move(tmp, out)  # cross-device safe
        print(f"wrote: {out}")
        written += 1

    shutil.copyfile(cover, os.path.join(album_dir, "cover.jpg"))

    print(f"\nAlbum: {album_dir}")
    print(f"Wrote {written}, skipped {skipped}, total {len(tracks)} track(s)")
    for w in warnings:
        print(f"WARNING: {w}", file=sys.stderr)

    if args.cleanup:
        for n in numbers:
            for p in (os.path.join(wav_dir, f"track{n:02d}.cdda.wav"),
                      os.path.join(wav_dir, f".{n:02d}.flac")):
                try:
                    os.remove(p)
                except FileNotFoundError:
                    pass
        print("Cleaned up source WAVs and temp files.")

    return 1 if warnings else 0


if __name__ == "__main__":
    sys.exit(main())
