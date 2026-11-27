#!/usr/bin/env python3
"""Dump a PDF page by page with page markers, or find which pages mention text.

Used to locate the slide that holds a diagram before embedding it with
``![[deck.pdf#page=N]]``. Remember: the PDF page number is NOT the printed
slide number, so always trust this tool over what the slide footer says.

Usage:
    pdf-pages.py deck.pdf                 # every page, with markers
    pdf-pages.py deck.pdf 20 32           # pages 20..32 inclusive
    pdf-pages.py deck.pdf --find "hidden terminal"
    pdf-pages.py deck.pdf --count
"""
import subprocess
import sys


def pages(path):
    out = subprocess.run(["pdfinfo", path], capture_output=True, text=True).stdout
    for line in out.splitlines():
        if line.startswith("Pages:"):
            return int(line.split()[1])
    raise SystemExit(f"could not read page count of {path}")


def page_text(path, n):
    return subprocess.run(
        ["pdftotext", "-f", str(n), "-l", str(n), "-layout", path, "-"],
        capture_output=True, text=True,
    ).stdout


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    path = argv[1]
    args = argv[2:]
    total = pages(path)

    if "--count" in args:
        print(f"{path}: {total} pages")
        return 0

    if "--find" in args:
        needle = args[args.index("--find") + 1].lower()
        hits = [n for n in range(1, total + 1) if needle in page_text(path, n).lower()]
        print(f"'{needle}' appears on {len(hits)} page(s) of {total}:")
        print(", ".join(map(str, hits)) if hits else "  (no hits)")
        return 0

    nums = [a for a in args if a.isdigit()]
    start, end = (int(nums[0]), int(nums[1])) if len(nums) >= 2 else (
        (int(nums[0]), int(nums[0])) if nums else (1, total))
    for n in range(start, min(end, total) + 1):
        print(f"\n########## PAGE {n} / {total} ##########")
        print(page_text(path, n).rstrip())
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
