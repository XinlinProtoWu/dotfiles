#!/usr/bin/env python3
"""Audit Markdown lecture notes (and their term files) for this skill's rules.

FAIL (exit 1):
  * ``![[deck.pdf#page=N]]`` pointing at a missing file or an out-of-range page
  * ``[[Note]]`` / ``[[terms/X]]`` links whose target does not exist
  * pipe tables whose rows have inconsistent cell counts
  * an unescaped ``|`` inside ``$...$`` within a table row (breaks the cell;
    use ``\\vert`` or ``\\lvert``)
  * unbalanced ``$`` / ``$$`` math delimiters

WARN (reported; fatal only with --strict):
  * a ``## 0. Terms`` index is missing  (the note has no term links)
  * a legacy ``## 0. Abbreviations`` table is still present
  * box-drawing characters: a hand-drawn diagram that should be a PDF embed
  * a code span that looks like mathematics (``$...$`` would render better)
  * a term file that no note links to

Usage:
    notes-audit.py [--strict] [--terms DIR] FILE.md [FILE.md ...]
"""
import os
import re
import subprocess
import sys

BOX = re.compile(r"[\u2500-\u257f\u2580-\u259f]")
EMBED = re.compile(r"!\[\[([^\]|#]+?\.pdf)#page=(\d+)\]\]")
WIKILINK = re.compile(r"(?<!!)\[\[([^\]|#]+?)(?:#[^\]|]*)?(?:\|[^\]]*)?\]\]")
TERM_LINK = re.compile(r"\[\[(terms/[^\]|#]+)")
SEPARATOR = re.compile(r"^\|[\s:|-]+\|$")
MATHISH_CODE = re.compile(r"`[^`]*[=×÷≤≥∑√^_]{1,}[^`]*`")

_pdf_cache = {}


def pdf_pages(path):
    if path not in _pdf_cache:
        try:
            out = subprocess.run(["pdfinfo", path], capture_output=True, text=True).stdout
            _pdf_cache[path] = int(next(l.split()[1] for l in out.splitlines()
                                        if l.startswith("Pages:")))
        except Exception:
            _pdf_cache[path] = None
    return _pdf_cache[path]


def count_cells(line):
    """Count table cell separators, ignoring escaped \\|."""
    return len(re.findall(r"(?<!\\)\|", line))


def code_fences(lines):
    """Indices of lines that belong to fenced code blocks."""
    inside, out = False, set()
    for i, line in enumerate(lines):
        if line.lstrip().startswith("```"):
            inside = not inside
            out.add(i)
            continue
        if inside:
            out.add(i)
    return out


def rendered_width(tex):
    """Rough on-screen width of a math snippet: strip markup, count visible chars.

    TeX source length is a bad proxy (``\\frac{a}{b}`` is 12 source chars but 3
    on screen), so commands, braces, script marks and alignment ``&`` are removed
    before measuring.
    """
    s = re.sub(r"\\[a-zA-Z]+\*?", "", tex)      # \frac, \text, \times, ...
    s = re.sub(r"[{}$&~^_\\]", "", s)            # braces, delimiters, scripts
    return len(" ".join(s.split()))


def math_problems(lines, fenced, text):
    """Inline math must live on ONE line; display math should fit on the page.

    A ``$...$`` span split across a line break is the classic silent failure: the
    delimiters stop pairing and raw TeX is printed as text. Counting unescaped
    ``$`` per line (skipping ``$$`` blocks and code) catches it exactly.

    For display math the risk is horizontal overflow, so the check is on the
    *length of the TeX*, not the length of the source line.
    """
    fails, warns = [], []
    in_display = False
    for i, line in enumerate(lines):
        if i in fenced:
            continue
        stripped = line.strip()
        if in_display:
            if "$$" in line:
                in_display = False
            continue
        if stripped.startswith("$$") and stripped.count("$$") == 1:
            in_display = True
            continue
        no_display = re.sub(r"\$\$.+?\$\$", "", line)
        n = len(re.findall(r"(?<!\\)\$", no_display))
        if n % 2:
            fails.append(f"math: line {i + 1} has {n} unescaped '$' — an inline span "
                         f"cannot cross a newline; re-join the line")
    if in_display:
        fails.append("math: an opening '$$' is never closed")

    # brace balance and unescaped TeX specials, per span
    for m in re.finditer(r"\$\$(.+?)\$\$|(?<!\$)\$(?!\$)([^$\n]+?)(?<!\$)\$(?!\$)", text, re.S):
        body = m.group(1) or m.group(2) or ""
        line = text[:m.start()].count("\n") + 1
        if (line - 1) in fenced:
            continue
        if body.count("{") != body.count("}"):
            fails.append(f"math: line {line} has unbalanced braces in "
                         f"{m.group(0)[:60]!r} — an unclosed '{{' swallows the rest")
        if re.search(r"(?<!\\)[%#]", body):
            fails.append(f"math: line {line} has an unescaped '%' or '#' in "
                         f"{m.group(0)[:60]!r} — write \\% or \\#")

    for m in re.finditer(r"\$\$(.+?)\$\$", text, re.S):
        body = m.group(1)
        rows = [r for r in body.split("\\\\") if r.strip()] if "aligned" in body else [body]
        widest = max(rendered_width(r) for r in rows)
        if widest > 70:
            line = text[:m.start()].count("\n") + 1
            warns.append(f"math: display block at line {line} has a {widest}-char row — "
                         f"likely to overflow; split it with \\begin{{aligned}}")
    return fails, warns


def audit(path, base, is_term=False):
    text = open(path, encoding="utf-8").read()
    lines = text.split("\n")
    fenced = code_fences(lines)
    fails, warns = [], []

    # 1. figure embeds
    for m in EMBED.finditer(text):
        deck, anchor = m.group(1), m.group(2) or ""
        target = os.path.join(base, deck)
        if not os.path.exists(target):
            fails.append(f"embed: {deck} not found")
            continue
        found = re.search(r"page=(\d+)", anchor)
        if not found:
            continue                      # embed without a page anchor: nothing to check
        page = int(found.group(1))
        total = pdf_pages(target)
        if total is None:
            fails.append(f"embed: cannot read page count of {deck}")
        elif not 1 <= page <= total:
            fails.append(f"embed: {deck}#page={page} out of range (1..{total})")

    # 2. wikilinks (note links and term links alike)
    for m in WIKILINK.finditer(text):
        name = m.group(1).strip()
        if name.startswith("http"):
            continue
        cand = os.path.join(base, name if name.endswith(".md") else name + ".md")
        if not os.path.exists(cand):
            fails.append(f"wikilink: [[{name}]] -> no such file")

    # 3. tables
    for i, line in enumerate(lines):
        if i in fenced or not SEPARATOR.match(line):
            continue
        cells = count_cells(line)
        j = i + 1
        while j < len(lines) and lines[j].startswith("|"):
            if j not in fenced:
                if count_cells(lines[j]) != cells:
                    fails.append(f"table: row {j + 1} has {count_cells(lines[j])} pipes, "
                                 f"header has {cells}")
                for math in re.findall(r"\$[^$]*\$", lines[j]):
                    if "|" in math.replace("\\vert", "").replace("\\mid", "") \
                                 .replace("\\lvert", "").replace("\\rvert", ""):
                        fails.append(f"table: row {j + 1} has an unescaped '|' inside "
                                     f"$...$ — use \\vert")
            j += 1

    # 4. math: an inline span may not cross a newline, and display math should fit
    mf, mw = math_problems(lines, fenced, text)
    fails.extend(mf)
    warns.extend(mw)

    # 5. conventions (warnings)
    if not is_term and "## 0. Terms" not in text:
        warns.append("terms: no '## 0. Terms' index of term links")
    if not is_term and "## 0. Abbreviations" in text:
        warns.append("terms: leftover '## 0. Abbreviations' glossary — "
                     "definitions belong in term files")
    for i, line in enumerate(lines):
        if BOX.search(line):
            warns.append(f"ascii: line {i + 1} draws a diagram with box-drawing "
                         f"characters — embed the PDF page instead")
        if i not in fenced:
            for span in MATHISH_CODE.findall(line):
                if "$" in span:
                    continue
                if re.search(r"[A-Za-z]\s*[=<>≤≥×/^]\s*[A-Za-z0-9]", span):
                    warns.append(f"latex: line {i + 1} writes math in a code span "
                                 f"{span!r} — prefer $...$")
    return fails, warns


def orphan_terms(terms_dir, notes):
    """Term files that no note links to."""
    used = set()
    for note in notes:
        text = open(note, encoding="utf-8").read()
        used.update(m.group(1)[len("terms/"):] for m in TERM_LINK.finditer(text))
    out = []
    for name in sorted(os.listdir(terms_dir)):
        if name.endswith(".md") and name[:-3] not in used:
            out.append(name[:-3])
    return out


def main(argv):
    strict = "--strict" in argv
    quiet = "--quiet-warn" in argv
    args = [a for a in argv[1:] if not a.startswith("-")]
    terms_dir = None
    if "--terms" in argv:
        terms_dir = argv[argv.index("--terms") + 1]
        args = [a for a in args if a != terms_dir]
    if not args:
        print(__doc__)
        return 2

    base = os.path.dirname(os.path.abspath(args[0])) or "."
    failed, warned = False, False
    for path in args:
        fails, warns = audit(path, base)
        if fails:
            failed = True
            print(f"FAIL {path}")
            for f in fails:
                print(f"     {f}")
        else:
            print(f"OK   {path}")
        if warns and not quiet:
            warned = True
            for w in warns:
                print(f"  warn {path}: {w}")

    if terms_dir:
        tdir = terms_dir if os.path.isabs(terms_dir) else os.path.join(base, terms_dir)
        tbase = os.path.dirname(os.path.abspath(tdir))
        files = sorted(os.path.join(tdir, n) for n in os.listdir(tdir) if n.endswith(".md"))
        for path in files:
            fails, warns = audit(path, tbase, is_term=True)
            if fails:
                failed = True
                print(f"FAIL {path}")
                for f in fails:
                    print(f"     {f}")
            elif warns:
                warned = True
                for w in warns:
                    print(f"  warn {path}: {w}")
        orphans = orphan_terms(tdir, args)
        print(f"terms: {len(files)} files, {len(orphans)} unreferenced"
              + (": " + ", ".join(orphans) if orphans else ""))
        if orphans:
            warned = True

    if failed or (strict and warned):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
