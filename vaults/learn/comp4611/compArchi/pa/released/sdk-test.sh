#!/usr/bin/env bash
set -eo pipefail
# conda's shell functions are not compatible with set -u.
source /mnt/home/public/course-envs/COMP4611/PA2/activate.sh
set -u
cd "$TACC_WORKDIR"
date -Is
hostname
nvidia-smi -L || true
printf 'CONDA_PREFIX=%s\n' "$CONDA_PREFIX"
for program in nvcc make; do
    binary=$(readlink -f "$(command -v "$program")")
    case "$binary" in
        /mnt/home/public/course-envs/COMP4611/PA2/comp4611-pa2-v1/bin/*) ;;
        *) echo "Unexpected binary for $program: $binary" >&2; exit 1 ;;
    esac
    printf '%s=%s\n' "$program" "$binary"
done
bash ./test.sh
