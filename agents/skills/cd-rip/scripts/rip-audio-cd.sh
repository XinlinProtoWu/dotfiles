#!/usr/bin/env bash
# Securely rip all audio tracks from a CD to WAV files.
#
# Usage: rip-audio-cd.sh [DEVICE] [OUTDIR]
#   DEVICE  optical device (default /dev/sr0)
#   OUTDIR  output directory (default /tmp/cdrip)
#
# Produces OUTDIR/trackNN.cdda.wav, OUTDIR/rip.log, OUTDIR/rip.out.
set -euo pipefail

DEVICE="${1:-/dev/sr0}"
OUTDIR="${2:-/tmp/cdrip}"

if ! command -v cd-paranoia >/dev/null 2>&1; then
    echo "error: cd-paranoia (libcdio) not found; install libcdio-utils" >&2
    exit 1
fi
if ! command -v cd-discid >/dev/null 2>&1; then
    echo "error: cd-discid not found; install libcdio-utils" >&2
    exit 1
fi
if [[ ! -e "$DEVICE" ]]; then
    echo "error: no such device: $DEVICE" >&2
    exit 1
fi
if [[ ! -r "$DEVICE" ]]; then
    echo "error: cannot read $DEVICE; check permissions/ACL (getfacl $DEVICE)" >&2
    exit 1
fi

mkdir -p "$OUTDIR"
rm -f "$OUTDIR"/track*.cdda.wav "$OUTDIR/rip.log" "$OUTDIR/rip.out"

TRACKS="$(cd-discid "$DEVICE" | awk '{print $2}')"
echo "Ripping $TRACKS track(s) from $DEVICE to $OUTDIR" | tee "$OUTDIR/rip.out"

set +e
cd-paranoia -d "$DEVICE" -B -l "$OUTDIR/rip.log" 2>&1 | tee -a "$OUTDIR/rip.out"
STATUS=${PIPESTATUS[0]}
set -e

if [[ $STATUS -ne 0 ]]; then
    echo "error: cd-paranoia exited with status $STATUS" >&2
    exit "$STATUS"
fi

if grep -qE '8-\||:-0|:-\(|;-\)|8-X' "$OUTDIR/rip.log"; then
    echo "WARNING: rip log reports read problems; inspect $OUTDIR/rip.log" >&2
    echo "Consider re-ripping with a lower speed: cd-paranoia -S 4 ..." >&2
    exit 2
fi

shopt -s nullglob
WAVS=("$OUTDIR"/track*.cdda.wav)
if [[ ${#WAVS[@]} -ne $TRACKS ]]; then
    echo "error: expected $TRACKS WAV files, found ${#WAVS[@]}" >&2
    exit 3
fi

echo "Rip completed cleanly: ${#WAVS[@]} track(s) in $OUTDIR"
