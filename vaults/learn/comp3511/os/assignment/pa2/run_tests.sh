#!/bin/bash
# Compile mlfq.c and run all provided pa2 test cases.
set -u

cd "$(dirname "$0")"

echo "==> Compiling mlfq.c"
gcc -std=c99 -Wall -Wextra -o mlfq mlfq.c || exit 1

pass=0
fail=0

for in in pa2_given_io/in*.txt; do
  [ -e "$in" ] || continue
  base=$(basename "$in" .txt)        # e.g. in01
  out="pa2_given_io/${base/in/out}.txt"  # e.g. out01.txt
  tmp="/tmp/${base}.out"

  ./mlfq < "$in" > "$tmp"

  if diff -q "$tmp" "$out" >/dev/null 2>&1; then
    echo "PASS  $base"
    pass=$((pass + 1))
  else
    echo "FAIL  $base"
    diff --side-by-side "$tmp" "$out" | head -20
    fail=$((fail + 1))
  fi
done

echo "==> $pass passed, $fail failed"
[ "$fail" -eq 0 ]
