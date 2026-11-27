---
name: lecture-notes
description: Turn one or more lecture slide decks (PDF) into Markdown study notes that explain each important concept with a worked example, typeset the maths in LaTeX, embed the deck's own diagrams by PDF page instead of redrawing them in ASCII, and link every term to a shared per-term explanation file. Use when asked to write/summarise/make lecture notes, study notes, or revision notes from slides or a PDF deck.
---

# Markdown lecture notes from a slide deck

Works for **any** Obsidian vault of lecture PDFs, not just one course. Two
instances this skill was built from:

| Vault | Deck granularity | Note naming | Index |
|---|---|---|---|
| `~/learn/elec3120/network1` | one deck = one lecture (`13-LAN.pdf`) | `NN_Topic.md` | `00_Index.md` |
| `~/learn/elec2600/probability` | one deck = many lectures (`Part2.pdf` holds lectures 5–12) | `lec_NN_topic.md` | `lec_13_to_20_index.md` |

Output in both cases: numbered sections, tables for comparisons, `$...$` maths,
and `![[deck.pdf#page=N]]` for every diagram.

The three non-negotiables (they were the user's explicit corrections):

1. **Diagrams come from the PDF.** Embed the slide. Do not draw the topology,
   flow chart, or protocol exchange with `---`, `|`, `└`, or arrows.
2. **Maths is LaTeX**, not a code span. `$O(\lvert E\rvert + \lvert V\rvert \log \lvert V\rvert)$`,
   not `` `O(|E| + |V| log |V|)` ``.
3. **Every in-class example is explained twice: plain words first, numbers second.**
   A friend who is not taking the course must be able to follow the first pass.
   Without it the file is a transcript of the deck, not study notes. See §3.5.

## Inputs — which deck(s) to note

This skill does **not** search for or guess decks. The deck must be named in the
request, either as PDF path(s) or as lecture number(s) against the course folder.

| The request | Resolves to |
|---|---|
| "make notes for `13-LAN.pdf`" | one note: `13_LAN.md` |
| "…for lectures 13 to 16" | four notes, one per deck, in one pass |
| "…for `14-Distance_Vector.pdf` and `16_Wireless.pdf`" | two notes; 15 untouched |
| "…for the deck at `/tmp/foo.pdf`" | copy it into the vault, then note it |
| "re-do `15`" | update the existing `15_Link_Layer.md` in place |
| "…pages 40–70 of `16_Wireless.pdf`" | one note covering a page range only |

### Step 0 — learn the vault's conventions, do not invent them

Before writing anything, run three commands in the target folder and copy what you
find:

```bash
ls *.pdf                                  # which decks, and how many
ls *.md | head -30                        # naming convention + index file
ls -d terms/ .obsidian 2>/dev/null        # term files? is this even a vault?
```

Decide four things from that listing:

| Question | Read it off |
|---|---|
| Note filename | the sibling `.md` files: `13_LAN.md` ⇒ `NN_Topic.md`; `lec_13_pairs_of_...md` ⇒ `lec_NN_topic.md` |
| Index file | whichever file looks like a hub (`00_Index.md`, `*index*.md`) — **append to it**, do not create a second one |
| Deck ↔ lecture | does one PDF hold one lecture, or many? Use the deck's own lecture-title slides to find page ranges |
| Terms | `terms/` exists ⇒ reuse and extend it; absent ⇒ one `terms/` at the vault root covers the whole course |

If the folder has **no** `.obsidian/`, the `![[...]]` embeds will not render — say
so, and either make it a vault or fall back to `[Part2, p. 17](Part2.pdf#page=17)`
links with the diagram described in prose.

### Resolution rules

1. **Directory = vault root, next to the deck.** Embeds are relative —
   `![[13-LAN.pdf#page=4]]` only resolves when the PDF sits in the same folder as
   the note, and `notes-audit.py` checks exactly that. If the deck lives
   elsewhere, copy it in first and embed from the copy.
2. **Note name — follow the siblings.** Copy the pattern the vault already uses;
   never introduce a second convention in the same folder.
   - `13-LAN.pdf` → `13_LAN.md` (hyphen between number and topic becomes `_`).
   - `Part2.pdf` → **not** `Part2.md`; find the lecture title on the slide, then
     `lec_05_random_variables_and_discrete_random_variables.md`.
   Never renumber a note that already exists.
3. **Granularity follows the deck, not the file count.** If one PDF holds several
   lectures, write **one note per lecture** and embed only that lecture's page
   range (`![[Part2.pdf#page=17]]`); the vault's other notes will follow the same
   pattern. If one PDF is one lecture, one note per deck.
4. **One pass, one index update.** A multi-deck or multi-lecture request produces
   several notes, each with its own `## 0. Terms` block, then **one** index update
   at the end. Never merge two lectures into one note.
5. **Terms are per course, not per note.** Reuse and extend an existing
   `terms/X.md` rather than create a near-duplicate (`terms/CSMA.md` grew to cover
   CSMA/CD and CSMA/CA instead of spawning three files).
6. **An existing note is an update unless the user says otherwise.** Read it first
   and preserve its section numbering and any hand-added content; "re-do" means
   replace the body, keep the filename.
7. **Match the vault's prose shape too.** If the siblings open with
   `> **Big picture.**` and a `## Learning goals` list, do the same; a notes folder
   with two different document templates is worse than either one alone.

### Ask first if

- a named deck is missing — **list the `*.pdf` files** in the folder instead of
  guessing which one was meant;
- two decks would map to the same `NN_` number;
- a lecture number has no matching `NN-*.pdf`;
- a deck already has a note and it is unclear whether to extend or replace it.

### Then confirm the plan in one line

> "`13-LAN.pdf` (96 pp) → `13_LAN.md`; embeds from pp. 4–93; ~11 sections."

That is cheap, and it catches a wrong file before 500 lines of notes exist.

## 1. Read the deck properly

```bash
S=~/.agents/skills/lecture-notes/scripts
python3 $S/pdf-pages.py 13-LAN.pdf --count          # 96 pages
python3 $S/pdf-pages.py 13-LAN.pdf 20 32            # pages 20..32
python3 $S/pdf-pages.py 13-LAN.pdf --find "spanning tree"
```

**PDF page != printed slide number.** Decks here are offset by one or two, and
some slides number skip (e.g. a page printed "48" sitting on PDF page 37). Always
use the PDF page for embeds; `notes-audit.py` will catch an out-of-range page.

Read the whole deck before writing. The last slide of each deck ("Some
Highlights") is the author's own summary — reuse its claims as the closing
section, reworded.

## 2. Outline before prose

Map the deck onto numbered sections, one per concept cluster. For each concept
decide whether it is *important* (gets an example) or *listed* (gets a table
row). Aims: 8–12 sections per 90-page deck, each section 30–80 lines.

Skeleton:

```markdown
# 13 — Local Area Networks

> Source: `13-LAN.pdf`. Goal: <one sentence>. Continues from [[12_Internetworking]].

## 1. <Concept>

<motivation: why does this exist / what breaks without it>

![[13-LAN.pdf#page=4]]
*Figure: what the slide shows. (`13-LAN.pdf` p. 4)*

<definition>

**In plain words.** <the deck's own example retold with no symbols, ordinary
objects, and the reason it works or fails — see §3.5>

**Example (traced).** <that same instance, real numbers, every step, verified>

> [!important] <the one examinable claim>

---

## N. Highlights (p. 96)

- <from the deck's own summary slide>

> [!tip] Exam traps
> - <misconception -> correction>
```

## 3. Explain every important concept the same way

Use this fixed pattern; it is what makes the notes teachable:

| Beat | Content |
|---|---|
| **1. Motivate** | what problem forces this idea to exist ("why do we need a *third* address scheme?") |
| **2. Define** | one sentence, then a table of fields/cases |
| **3. Plain words** | the deck's example retold as *what is happening in the world*, zero symbols (§3.5) |
| **4. Trace it** | that same example with real numbers, every step shown, computed |
| **5. Figure** | embed the slide that shows it |
| **6. Trap** | the misconception an exam will test |

Rules for beat 4:

- **Compute the numbers.** Verify arithmetic with `python3 -c` before writing
  it. (Real catches: `500 MB @ 1 Mbps = 4000 s = 1.1 h`; `P(X>10)` for
  `X ~ Binomial(35, 0.1) = 0.0004`; `512 bits @ 10 Mbps = 51.2 µs`.)
- Prefer an example that **distinguishes two similar things** ("the same packet,
  but the Ethernet destination changed and the IP destination did not").
- If the deck's own worked example is incomplete, finish it — and say which part
  is yours.

## 3.5 The plain-words pass is mandatory, and it comes first

**What counts as an in-class example.** Any worked instance, exercise, figure or
counterexample that *the deck itself* presents — not the ones you invent to
check a number. Each one gets two passes, in this order:

1. `**In plain words.**` — one to four sentences, **no maths, no variable names,
   no $O(\cdot)$, no undefined jargon**, using a homely analogy drawn from
   ordinary life. It says *who wants what, what the rule is actually doing, and
   why the obvious alternative fails*. This is the pass that makes the idea
   stick; it is not optional and it is not a summary of the numbers.
2. The existing `**Example (traced).**` block — the same instance with real
   numbers, every step, arithmetic verified.

The plain pass goes **immediately before** the trace, so a reader can read only
the plain sentences and still understand the slide, then read the trace to see it
happen.

| Bad (fails the pass) | Good (passes) |
|---|---|
| "In plain words: DP fills $r[j]$ bottom-up, so the recurrence is $\Theta(n^2)$." | "In plain words: a timber yard pays more for two short planks than for the one long log they came from. So you cannot pick cuts by price per metre — one good cut early can ruin what is left. Work out the best income for 1 metre, then 2, then 3, and each new length only asks about lengths you have already solved." |
| "In plain words: BFS visits in layers so $d[v] = d[u] + 1$." | "In plain words: drop a stone in a pond. Every ripple reaches places at the same distance at the same moment, and the first ripple that touches a spot proves no shorter route exists." |
| "In plain words: greedy fails here, showing that local choices are not always globally optimal." | "In plain words: the greedy rule grabs the biggest coin every time. Here the biggest coin strands you: it leaves an amount that only small coins can fill, so you end up paying with more coins than a quieter choice would have needed." |

**The test to apply before moving on.** Delete every `$...$` from the paragraph.
It must still read as a sentence, must still name the concrete objects (coins,
rooms, cables, planks, ripple, suitcase), and must still explain the *failure or
success*, not just the mechanism. If only a formal statement survives the
deletion, rewrite it.

**For a counterexample the plain pass must say where the trap bites**
("the biggest coin strands you", "the long job blocks three short ones"). For a
correct algorithm it must say what the rule is protecting
("finish as early as you can, so the rest of the day stays free").

**For an exercise the deck asks the reader to solve**, the plain pass explains the
question in everyday terms *before* the answer ("eight people at a party, can
everyone shake a different number of hands? then the person who shook seven hands
must have shaken the hand of the person who shook none — contradiction").

**Anti-patterns.**

- Restating the formula in words ("the best value is the maximum over all first
  pieces") — that is beat 2 again, not a plain-words pass.
- Vague praise ("this shows why greedy is tricky") — say *which* choice goes
  wrong and *what it costs*.
- A second, longer technical explanation — the plain pass is short by design; if
  it needs four equations it is the wrong pass.
- Dropping it for "obvious" examples. The obvious ones are exactly where the
  reader's understanding is thinnest.

## 4. Embedding figures

```markdown
![[13-LAN.pdf#page=44]]
*Figure: a learning switch's forwarding table. (`13-LAN.pdf` p. 44)*
```

- Always the **next line** is an italic caption naming the deck and the PDF page.
- One embed per idea. Decks here animate, so pages 34–38 of `13-LAN.pdf` are five
  frames of the *same* animation — embed one representative frame, not five.
- Cross-reference instead of duplicating: "*see `15-Link_Layer.pdf` p. 15 for the
  full table*".
- **Never** transcribe a multi-column diagram from `pdftotext` output; it comes
  out interleaved and wrong. Embed the page and describe it in prose.

### When ASCII is legitimate

| Allowed | Example |
|---|---|
| Pseudocode / algorithm listing | the learning-switch or Bellman–Ford loop |
| Field-by-field header dump | `dst / src / ethertype / payload / FCS` |
| A literal packet or config trace | `src 10.2.2.2:1000 -> dst 198.2.4.5:80` |
| **Not** allowed | topologies, box diagrams, flow charts, protocol timing diagrams |

If you invented the example yourself and there is no slide for it, use a **table**
or **LaTeX** for the structure, and describe the shape in words. Never a drawing.

## 5. LaTeX conventions

| Need | Write |
|---|---|
| Inline maths | `$O(\#\text{nodes})$` |
| Display maths | `$$\text{MAX\_DIST} = (N-1) \cdot w_{\max}$$` |
| Set size / absolute value | `$\lvert E\rvert$`, **never** raw `\|` (it breaks table cells) |
| Multiple lines | `$$\begin{aligned} a &= b \\ c &= d \end{aligned}$$` |
| Words inside maths | `\text{users}`, `\text{bit times}` |
| Units | `$500\,\text{MB}$`, `$8\,\mu\text{s}$` (thin space, upright text) |
| Big integers | `$2^{48} = 281{,}474{,}976{,}710{,}656$` |
| Membership / sets | `$K \in \{0,\dots,2^n-1\}$` |
| Expectation | `$\mathbb{E}[\text{active}]$` |
| Implies | `$\Longrightarrow$` |
| minima over sets | `$\min_{v \in N(x)} \bigl[w(x,v) + d(v,y)\bigr]$` |

### Five ways LaTeX silently fails here

`notes-audit.py` now fails the build on all five, because each one renders as raw
TeX or as a red error instead of maths:

| Failure | Why it breaks | Do this |
|---|---|---|
| **An inline `$...$` split across a line break** | the `$` pair never closes, so raw TeX prints as text | keep the span on one line — re-join the sentence |
| **Unbalanced `{`** | the last `\text{` swallows the rest of the paragraph | count braces per span; close every `\text{` |
| **Unescaped `#`** | `#` is TeX's parameter character | `\#`, as in `$O(\#\text{nodes})$` |
| **Unescaped `%`** | `%` starts a TeX comment, eating the closing `$` | `\%` |
| **A display block whose widest row is > 70 rendered chars** | it overflows the pane horizontally | split with `\begin{aligned}` and an `&=` per row |

Two more rules that are style, not breakage:

- **`\begin{aligned}` is for multi-line derivations only**, one `&=` per row;
  a single equation stays single-line.
- **Do not use `\!-\!` to write a path or a range** (`$1\!-\!2\!-\!4$` reads as
  subtraction). Write paths with `\to` (`$1 \to 2 \to 4$`) and ranges as plain
  text with an en dash (`1–2, 1–3, 2–4`).

Keep **identifiers and message names** in code spans (`MAX_DIST`, `DHCP DISCOVER`,
`FF:FF:FF:FF:FF:FF`) and put **expressions and equations** in `$...$`. Do not
LaTeX-ify a hash of a protocol field name.

## 6. Callouts and closing sections

```markdown
> [!important] Why LS kills count-to-infinity
> <the structural reason, one sentence>
```

Use `[!important]` for the load-bearing claim, `[!tip]` for rules of thumb,
`[!warning]` for silent failure modes, `[!note]` for definitions quoted from the
deck, `[!example]` for long worked examples.

End every note with:

1. **Highlights** — the deck's own summary slide, reworded.
2. **Exam traps** — 6–12 bullets of the form *misconception* → *correction*.
   These are the highest-value lines in the file; put the subtle ones here
   ("`MAX_DIST` too *low* is a correctness bug, too *high* is a performance bug").

## 7. Term files — one definition, many referrers

Every note opens with a `## 0. Terms` block: an index of **links** to `terms/`,
not a table of definitions. Definitions live once, in one file per term, and every
note that uses the term links to that file. A term like `STP` is explained once,
not five times in five slightly different ways.

The `## 0. Terms` block looks like this:

```markdown
## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are
shared across lectures (a term defined once is reused by every note that mentions
it) and each is linked at its **first use** in the text below.

**Addressing and the link layer:** [[terms/MAC]] · [[terms/ARP]] · [[terms/DHCP]]

**Switching and spanning tree:** [[terms/STP]] · [[terms/big-O]]
```

### Format of a term file

One file per term, named after the term, in `terms/` (`terms/MAC.md`,
`terms/CSMA.md`, `terms/link-state.md`). Group inseparable terms into one file and
point every alias at it — `RTS`, `CTS` and `RTS/CTS` all live in
`terms/RTS-CTS.md`.

```markdown
# MAC address — Media Access Control address

**What it is.** A 48-bit hardware identifier burned into a network interface by
its manufacturer, written as six hex pairs: `34:f3:e4:ae:66:44`.

**Why it exists.** <the problem it solves, in one paragraph>

**Example.** <one concrete instance with real values>

**Where it appears:** [[13_LAN]] Sections 2, 4 · [[16_Wireless]] Section 4.5

**Related:** [[terms/Ethernet]] · [[terms/ARP]] · [[terms/IP]]
```

Keep those four beats — **what / why / example / where** — so the files stay
predictable. Backlink every lecture that uses the term; that turns `terms/` into a
navigable index of the course.

### Linking style inside the notes

- **First use in the prose:** carry the expansion in the alias —
  `[[terms/MAC|Media Access Control (MAC)]]` when introducing it, or
  `[[terms/CSMA|CSMA/CD]]` when the note is about a *variant* of the term file.
  Always keep the alias when the display text differs from the filename:
  `[[terms/link-state|OSPF]]`, `[[terms/multiplexing|TDM]]`,
  `[[terms/SNR-BER|BER]]`, `[[terms/IP|IPv4]]`.
- **After that:** plain text, no link. One link per term per note is enough; a
  page of blue text is unreadable.
- **Cross-references: write `Section 4`, not `§4`.** The section sign is compact
  but few readers recognise it, and the notes are for revision, not for publication.
  Ranges become `Sections 8–9`; a cross-note reference becomes
  `[[15_Link_Layer]] Section 10`; consecutive refs collapse to `Sections 2, 4`.
- **Inside a table row, never use an alias.** The `|` in `[[target|alias]]` is a
  cell separator and silently splits the row. Either drop the alias when the
  filename already reads correctly (`[[terms/DHCP]]` renders as "DHCP"), or drop
  the link and keep plain text (`| **Home Subscriber Server (HSS)** |`).
- **Never link inside** a code span, a fenced block, an embed, or another link.
  A regex auto-linker is fine, but check its output: linking `RTS` and then `CTS`
  on the same line nests one link inside another
  (`[[terms/RTS-[[terms/RTS-CTS|CTS]]|RTS]]`) and breaks both. Afterwards run
  `grep -n '\[\[terms/[^]]*\[\[' *.md` — it must print nothing — and check
  `grep -n '^|.*\[\[terms/[^]]*|' *.md` for aliases that leaked into tables.

## 8. Audit, then fix

```bash
python3 $S/notes-audit.py *.md            # FAIL -> must fix
python3 $S/notes-audit.py --strict *.md   # warnings also fail
```

It checks: embed page ranges against `pdfinfo`, that every `[[wikilink]]` target
exists (including every `[[terms/X]]`), pipe-table cell counts, unescaped `|`
inside `$...$` in a table row, unbalanced `$`, box-drawing characters (ASCII
diagram), maths written in code spans, orphan term files, and leftover
`## 0. Abbreviations` glossaries.

With `--terms <dir>` it also audits the term files themselves and reports terms
no note links to.

Loop until clean. Warnings are real: each one is a note that breaks one of the
non-negotiables at the top of this file.

**Then count the plain-words passes** — the audit cannot see prose quality, so do
this by hand:

```bash
grep -c 'In plain words' *.md          # plain passes written
grep -n '^\*\*Example' *.md | wc -l    # examples that exist
```

One plain pass per in-class example, minimum. A deck with a dozen worked examples
and a note with three plain passes is a transcript, not notes — go back to §3.5.

Finally update the vault's index file (the hub you found in Step 0 — `00_Index.md`,
`lec_13_to_20_index.md`, …): lecture/row mapping, dependency chain, formula sheet
entries, exam traps, and a pointer to `terms/`.

## Gotchas

- **The plain-words pass is not a warm-up.** If the plain sentences could have
  been written without reading the deck, they are filler. Each one must mention
  the deck's own actors (the timber yard's prices, the 8-party guests, the 6-cycle,
  the two knapsacks) and the specific thing that goes right or wrong.
- **Do not let a plain pass smuggle in symbols.** `$\Theta(n \log n)$`,
  `f(i_{r+1})`, `d[v]`, "the invariant" — all fail §3.5. Rewrite with the object
  itself: "the finish times", "the ripple", "the planks".
- **`edit` can merge two table rows.** If the match string absorbs the trailing
  newline, the header glues onto the `|---|---|` separator. Re-run the audit
  after every batch of table edits.
- **`|` inside `$...$` inside a table splits the cell.** Use `\lvert` or `\vert`.
  Same for `O(|E| + |V| log |V|)` — write it with `\lvert`.
- **Don't expand `![[deck.pdf#page=N]]` or `[[Note_Name]]`**; the text is a
  filename. Likewise leave `` `13-LAN.pdf` `` in inline code alone.
- **Slide numbers in captions** — quoting the deck's printed number is a nice
  touch for cross-checking against the lecturer's PDF, but the *embed* must use
  the PDF page. When the two differ, the caption can say both.
- **Animations**: five consecutive pages of the same diagram usually mean a build
  sequence. Embed the page where the idea is *complete*.
- **Decks under-report**: some slides are one line of text and a picture. Read the
  picture's caption text from the PDF rather than guessing from the title.
