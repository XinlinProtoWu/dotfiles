# Lecture 20 — Stable Matching

> Source: `20_StableMarriage.pdf` (18 pages). Goal: pair two equal-sized groups using their
> preference lists so that no pair would rather abandon their assigned partners for each other —
> and prove that the Gale–Shapley propose-and-reject algorithm always produces such a matching.
> This is a greedy algorithm, but the proof is an **exchange/improvement** argument rather than a
> cut argument, and the running time is quadratic.

## 0. Terms

Definitions live outside these notes, one file per term, under `terms/`. They are shared
across lectures (a term defined once is reused by every note that mentions it) and each is
linked at its **first use** in the text below.

**The problem:** [[terms/stable-matching|Stable matching]] · [[terms/Gale-Shapley|Gale–Shapley propose-and-reject]]

**Related structures:** [[terms/bipartite|Bipartite graph]] · [[terms/greedy-algorithm|Greedy algorithm]] · [[terms/queue|Queue (FIFO)]]

**Analysis:** [[terms/big-O]]

---

## 1. The problem

**Input.** $n$ men and $n$ women. Each man ranks all women from best to worst; each woman ranks
all men. The lists are complete and strict (no ties).

**Output.** A **perfect matching**: $n$ man–woman pairs, everyone matched exactly once. It must
also be **stable**: there is no unmatched pair $m$–$w$ such that $m$ prefers $w$ to his assigned
partner **and** $w$ prefers $m$ to her assigned partner. Such a pair is called an **unstable pair**
or a blocking pair.

![[20_StableMarriage.pdf#page=2]]
*Figure: the deck's three men and three women with their complete preference lists. (`20_StableMarriage.pdf` p. 2)*

**In plain words.** Three men and three women each write down the others in the order they like
them. A pairing is "stable" if no two people who are not paired with each other would both rather
swap. The trouble is that a pairing can look fine person by person and still leave a mutually
preferred couple outside it.

**Example (the deck's lists).**

| man | 1st | 2nd | 3rd |
|---|---|---|---|
| X | A | B | C |
| Y | B | A | C |
| Z | A | B | C |

| woman | 1st | 2nd | 3rd |
|---|---|---|---|
| A | Y | X | Z |
| B | X | Y | Z |
| C | X | Y | Z |

**Applications.** The names are historical; the same structure matches medical residents to
hospitals, applicants to university places (JUPAS), and advertisers to search slots.

![[20_StableMarriage.pdf#page=3]]
*Figure: the problem is not really about gender — residency matching, auctions, JUPAS. (`20_StableMarriage.pdf` p. 3)*

---

## 2. Testing stability, and non-uniqueness

**Question 1: is $X\text{–}C$, $Y\text{–}B$, $Z\text{–}A$ stable?**

No. $X$ is with $C$ but prefers $B$; $B$ is with $Y$ but prefers $X$ (her list is $X,Y,Z$). So
$X$–$B$ is a blocking pair.

![[20_StableMarriage.pdf#page=6]]
*Figure: the unstable pair $X$–$B$ in the assignment $X\text{–}C$, $Y\text{–}B$, $Z\text{–}A$. (`20_StableMarriage.pdf` p. 6)*

**In plain words.** $X$ was given his last choice while his second choice $B$ was given a man she
likes less than $X$. Both would happily leave their current partners for each other, so the
arrangement cannot last.

**Question 2: is $X\text{–}A$, $Y\text{–}B$, $Z\text{–}C$ stable?**

Yes. Check every unmatched pair:

| pair | does the man prefer her? | does she prefer him? | blocking? |
|---|---|---|---|
| $X$–$B$ | yes ($B$ is 2nd) | no ($B$ prefers $Y$) | no |
| $X$–$C$ | no ($C$ is 3rd) | — | no |
| $Y$–$A$ | no ($A$ is 2nd, he has 1st) | — | no |
| $Y$–$C$ | yes? $C$ is 3rd, he has $B$ 1st | no | no |
| $Z$–$A$ | yes ($A$ is 1st) | no ($A$ prefers $Y$) | no |
| $Z$–$B$ | yes ($B$ is 2nd) | no ($B$ prefers $X$) | no |

No pair is mutual, so the matching is stable.

![[20_StableMarriage.pdf#page=7]]
*Figure: the stable matching $X\text{–}A$, $Y\text{–}B$, $Z\text{–}C$. (`20_StableMarriage.pdf` p. 7)*

**Question 3: is the stable matching unique?**

No. On the same lists, $X\text{–}B$, $Y\text{–}A$, $Z\text{–}C$ is also stable. The deck shades
those entries on p. 8. So stability does not determine a unique answer; it only rules out blocking
pairs.

![[20_StableMarriage.pdf#page=8]]
*Figure: a second stable matching $X\text{–}B$, $Y\text{–}A$, $Z\text{–}C$ for the same lists. (`20_StableMarriage.pdf` p. 8)*

**In plain words.** There can be more than one seating plan with no couple wanting to swap. The
question "which stable matching" therefore needs an extra criterion — and Gale–Shapley supplies
one: it favours the side that proposes.

> [!important] Existence is not obvious
> A perfect matching always exists (pair anyone), but a *stable* one is not guaranteed by the
> definitions. The Gale–Shapley algorithm proves existence constructively.

---

## 3. The propose-and-reject algorithm (Gale–Shapley)

```text
Initialize each person to be free.
while some man m is free and has not proposed to every woman
    w <- the first woman on m's list to whom he has not yet proposed
    if w is free then
        engage m and w
    else if w prefers m to her current fiance m' then
        engage m and w;  set m' free
    else
        w rejects m
```

![[20_StableMarriage.pdf#page=9]]
*Figure: the algorithm — men propose in decreasing preference order, women accept or trade up. (`20_StableMarriage.pdf` p. 9)*

**In plain words.** The men take turns proposing down their lists. A woman who is free accepts; a
woman who is engaged compares the new proposal with her current fiancé and keeps the one she
prefers, releasing the other. A released man continues down his own list. Nobody ever proposes to
the same person twice, and no woman ever goes back to a worse partner.

**Example (traced on the deck's lists).** Process the free men in the order $X,Y,Z$:

| step | man | proposes to | response | engaged pairs |
|---|---|---|---|---|
| 1 | X | A | A free, accepts | X–A |
| 2 | Y | B | B free, accepts | X–A, Y–B |
| 3 | Z | A | A prefers X to Z, rejects Z | X–A, Y–B |
| 4 | Z | B | B prefers Y to Z, rejects Z | X–A, Y–B |
| 5 | Z | C | C free, accepts | X–A, Y–B, Z–C |

The result is the stable matching of Section 2. Notice that $Z$ proposed to all three women and
was rejected twice.

---

## 4. Termination: at most $n^2$ proposals

**Claim.** The while loop runs at most $n^2$ times.

**Proof.** Each man walks down his list from first to last and never proposes to the same woman
twice. There are $n$ men and $n$ women, hence at most $n\cdot n=n^2$ distinct proposals. Each
iteration makes exactly one new proposal, so there are at most $n^2$ iterations. $\blacksquare$

![[20_StableMarriage.pdf#page=10]]
*Figure: the $n^2$ proposal bound. (`20_StableMarriage.pdf` p. 10)*

**In plain words.** There are only so many possible letters a man can post — one per woman — and
he never posts the same letter twice. Even if every man writes to every woman, the postbox empties
after $n^2$ letters.

---

## 5. Perfection: everyone ends up matched

**Observation 1.** Men propose in decreasing order of preference (they never go back up their
list).

**Observation 2.** Once a woman is engaged, she never becomes free again; she only trades up to a
man she prefers.

**Claim.** At termination, every man and every woman is matched.

**Proof.** Suppose some man $Z$ is unmatched at the end. Then $Z$ must have proposed to every
woman and been rejected by all of them (otherwise he would still be engaged). Every woman who
rejects a man is engaged at that moment, and by Observation 2 she stays engaged forever. So every
woman is matched. Since there are $n$ men and $n$ women, and every woman is matched to a distinct
man, all $n$ men are matched too — contradicting that $Z$ is unmatched. $\blacksquare$

![[20_StableMarriage.pdf#page=11]]
*Figure: the perfection proof — an unmatched man would have proposed to every woman. (`20_StableMarriage.pdf` p. 11)*

**In plain words.** A man can only end up single if every woman turned him down. But a woman only
turns a man down when she already has someone better, and she never gives up that someone. So if
one man is single, every woman is taken, which leaves no woman for the other men either — an
impossible headcount.

---

## 6. Stability: no blocking pair

**Claim.** The final matching has no unstable pair.

**Proof.** Suppose $A$–$Z$ is a blocking pair: $Z$ prefers $A$ to his final partner, and $A$
prefers $Z$ to her final partner. Consider whether $Z$ ever proposed to $A$.

- **Case 1: $Z$ never proposed to $A$.** Since $Z$ proposes in decreasing preference order, he
  stopped before reaching $A$, so his final partner is someone he prefers to $A$. That contradicts
  $Z$ preferring $A$.
- **Case 2: $Z$ proposed to $A$.** Then $A$ rejected him, either immediately or later in favour of
  a better man. By Observation 2, $A$'s final partner is at least as good as the man she had when
  she rejected $Z$, hence better than $Z$. That contradicts $A$ preferring $Z$.

Both cases contradict the assumption, so no blocking pair exists. $\blacksquare$

![[20_StableMarriage.pdf#page=12]]
*Figure: the two cases of the stability proof. (`20_StableMarriage.pdf` p. 12)*

**In plain words.** Take any woman $A$ and man $Z$ who are not together. Either $Z$ never got far
enough down his list to propose to her — then he likes his current partner more — or he did
propose and she said no — then she already had someone better and only improved from there. In
neither case can both of them prefer each other.

> [!important] Why the two observations are enough
> The men's monotone walk down their lists and the women's monotone improvement are the only
> invariants needed. Termination, perfection and stability each follow from one of them.

---

## 7. An $O(n^2)$ implementation

**Data structures.**

| Structure | Purpose |
|---|---|
| `wife[m]` | woman matched to man $m$, or 0 if free |
| `husband[w]` | man matched to woman $w$, or 0 if free |
| `next[m]` | index of the next woman on $m$'s list to propose to |
| free list (queue or stack) | men currently unmatched |
| `rank[w][m]` | position of $m$ in $w$'s preference list (inverse list) |

The inverse list turns "does $w$ prefer $m$ to $m'$?" into an $O(1)$ comparison:
$w$ prefers $m$ iff `rank[w][m] < rank[w][m']`.

![[20_StableMarriage.pdf#page=14]]
*Figure: building the inverse preference list for constant-time comparisons. (`20_StableMarriage.pdf` p. 14)*

**In plain words.** Each woman keeps an address book that says where each man sits on her list. To
compare two suitors she reads two page numbers instead of scanning the whole list. Building the
address book costs one pass; every later comparison is instant.

**Cost.** At most $n^2$ proposals, each handled in $O(1)$ after preprocessing, so the algorithm is
$O(n^2)$ time and $O(n^2)$ space for the preference lists and ranks.

![[20_StableMarriage.pdf#page=13]]
*Figure: `wife`, `husband`, the free list, and each man's remaining list. (`20_StableMarriage.pdf` p. 13)*

---

## 8. Which stable matching does Gale–Shapley return?

**Claim.** For a fixed instance, every execution of Gale–Shapley (regardless of the order in which
free men propose) returns the **same** matching, and it is **optimal for the men**: each man gets
his best possible partner among all stable matchings.

**Proof.** Omitted in the deck (the textbook proves it by an exchange argument on the first
rejection of a man-optimal partner).

**The algorithm is not symmetric.** Men propose and women accept/reject. To get the
**woman-optimal** matching, swap the roles: women propose and men accept/reject. The two
matchings can differ; on the deck's lists, men get $X\text{–}A,Y\text{–}B,Z\text{–}C$ while women
would get $X\text{–}B,Y\text{–}A,Z\text{–}C$ if they proposed.

![[20_StableMarriage.pdf#page=15]]
*Figure: all man-proposing executions agree and are men-optimal; swapping roles gives women-optimal. (`20_StableMarriage.pdf` p. 15)*

**In plain words.** The side that does the proposing holds the upper hand: they never get turned
down by anyone they like more than their final partner. The side that waits can only trade up, but
they end up with the best they can get given the other side's proposals. Running it the other way
round gives the other side the advantage.

> [!tip] "Optimal" here means optimal among stable matchings
> A man-optimal stable matching is not necessarily the man's first choice overall — that partner
> may simply be unattainable in any stable matching. The guarantee is relative to the set of
> stable matchings, not to all perfect matchings.

---

## 9. Runtime questions

**Q. If a man and a woman rank each other first, must they be paired in every stable matching?**

Yes. If they were not paired, they would both prefer each other to their assigned partners, so they
would be a blocking pair. The pair is forced in every stable matching.

**Q. Is the worst case $\Omega(n^2)$?**

Yes. Give all men the same preference list. In round 1 every man proposes to the same woman; she
keeps her favourite and rejects the other $n-1$. In round 2 all but that favourite propose to the
second woman, and so on. The total number of proposals is

$$n+(n-1)+(n-2)+\cdots+1=\frac{n(n+1)}{2}=\Omega(n^2).$$

![[20_StableMarriage.pdf#page=16]]
*Figure: the three runtime questions and their answers. (`20_StableMarriage.pdf` p. 16)*

**Q. What is the best case?**

$O(n)$: if each man's first choice is a different woman, every man proposes once and is accepted.

**In plain words.** The worst case is a queue at a single popular counter: everyone tries the same
first choice, then the same second choice, and the queue only shortens by one each round. The best
case is everyone's first choice being different, so the first round pairs everybody.

---

## 10. The roommates problem: stability can fail without bipartition

$2n$ people must be paired into $n$ rooms. Each person ranks all $2n-1$ others, so the graph is
**not bipartite**. Does a stable matching always exist?

**No.** Take four people with lists

| person | 1st | 2nd | 3rd |
|---|---|---|---|
| A | B | C | D |
| B | C | A | D |
| C | A | B | D |
| D | any | any | any |

There are exactly three perfect matchings:

| matching | unstable pair | why |
|---|---|---|
| $(A,B),(C,D)$ | $B$–$C$ | $B$ prefers $C$ to $A$; $C$ prefers $B$ to $D$ |
| $(A,C),(B,D)$ | $A$–$B$ | $A$ prefers $B$ to $C$; $B$ prefers $A$ to $D$ |
| $(A,D),(B,C)$ | $A$–$C$ | $A$ prefers $C$ to $D$; $C$ prefers $A$ to $B$ |

Every matching has a blocking pair, so no stable matching exists.

![[20_StableMarriage.pdf#page=17]]
*Figure: the four-person roommates counterexample and its three matchings. (`20_StableMarriage.pdf` p. 17)*

**In plain words.** Three flatmates each have a clear favourite among the other two. Whichever pair
you put together, the two left out (or one of them and someone else) can find a mutual improvement.
The bipartite structure of the marriage problem is what prevents this cycle of preferences; with
an odd cycle of people, the cycle can rotate forever.

**Example (traced).** In the matching $(A,B),(C,D)$: $B$'s list is $C,A,D$, so $B$ prefers $C$ to
his partner $A$. $C$'s list is $A,B,D$, so $C$ prefers $B$ to her partner $D$. Hence $B$–$C$ is
blocking. The other two rows check the same way. This proves the claim "a stable matching always
exists" is **false** for general graphs.

> [!warning] The theorem is about bipartite instances
> Gale–Shapley needs the two sides to be disjoint and all edges to cross between them. The
> roommates problem has edges within one group and can have no stable solution at all.

---

## 11. JUPAS: a real instance

Each applicant ranks all programs; each program ranks all applicants using its own formula. JUPAS
uses stable matching with **applicants as the proposers** (the "men") and **program places as the
women**), so the result is applicant-optimal.

**Naive reduction.** $n$ applicants and $m$ programs with $n$ total places. Treat each **place** as
a separate woman, with all places of the same program sharing the program's ranking. There are $n$
places, so the instance has $n$ men and $n$ women and runs in $O(n^2)$.

**Optimised JUPAS algorithm.** Exploit the fact that all places in a program have identical
preferences; the running time drops to $O(mn)$.

![[20_StableMarriage.pdf#page=18]]
*Figure: JUPAS uses applicants as proposers; the naive reduction is $O(n^2)$, the optimised one $O(mn)$. (`20_StableMarriage.pdf` p. 18)*

**In plain words.** Think of each university place as a separate seat with the same opinion of
every applicant. A program with 100 seats is 100 identical women, so the standard algorithm still
works; the optimised version notices the duplication and processes all 100 seats together instead
of one at a time.

---

## 12. Highlights

- A **perfect matching** pairs everyone once; it is **stable** if no unmatched pair mutually
  prefers each other to their assigned partners.
- Stable matchings need not be unique, but at least one always exists for a bipartite instance.
- **Gale–Shapley**: men propose in decreasing preference order; women accept or trade up. It
  terminates in at most $n^2$ proposals, matches everyone, and leaves no blocking pair.
- **Termination**: at most $n^2$ distinct proposals.
- **Perfection**: an unmatched man would have proposed to every woman, which would leave every
  woman engaged, a headcount contradiction.
- **Stability**: for any non-pair, either the man never reached her on his list (so he prefers his
  partner) or she rejected him (so she prefers hers).
- With inverse preference lists, each comparison is $O(1)$, giving an $O(n^2)$ implementation.
- The proposing side gets its **optimal** stable matching; the other side gets the
  **pessimal** one. Swapping roles swaps the advantage.
- The result is **not** guaranteed for non-bipartite instances: the four-person roommates example
  has no stable matching.
- JUPAS is this algorithm with applicants proposing to program places.

## 13. Exam traps

- **"A stable matching is unique."** $\to$ false. The deck's own lists have two: $X\text{–}A,Y\text{–}B,Z\text{–}C$
  and $X\text{–}B,Y\text{–}A,Z\text{–}C$.
- **"Gale–Shapley returns the best possible partner for everyone."** $\to$ it returns the
  **men-optimal** stable matching. A man may still envy a partner he cannot get in any stable
  matching; and the women's result is the worst stable matching for them.
- **"The order in which free men are chosen affects the final matching."** $\to$ for a fixed
  instance, every execution returns the same men-optimal matching. The order affects only the
  sequence of proposals, not the result.
- **"Every woman ends up with her first choice."** $\to$ no; she may be rejected by men above her
  final partner. What is true is that a woman never ends up with a man worse than one she rejected.
- **"A woman can become free again after being engaged."** $\to$ false. She only trades up; the
  rejected man becomes free, not her.
- **"A man proposes to the same woman more than once."** $\to$ false; he walks strictly down his
  list. This is what gives the $n^2$ bound.
- **"The algorithm needs $O(n^3)$ because comparisons scan a list."** $\to$ with inverse ranks, a
  comparison is $O(1)$; the total is $O(n^2)$.
- **"The worst case is $O(n)$ because each proposal either engages a man or moves him down."** $\to$
  a man can be rejected $n-1$ times, and all men can be rejected in the same round, giving
  $\Omega(n^2)$ with identical lists.
- **"A mutual first choice need not be paired."** $\to$ it must be; otherwise it is a blocking pair.
- **"Gale–Shapley works for the roommates problem too."** $\to$ false; the four-person example has
  no stable matching. The theorem requires a bipartite instance.
- **"Stability means nobody is unhappy with their partner."** $\to$ stability is only about
  *mutual* improvement. One person can be unhappy; as long as the person they prefer does not
  prefer them back, the matching is stable.
- **"Adding more acceptable pairs can only help."** $\to$ not necessarily; enlarging preference
  lists can create new blocking pairs and change the set of stable matchings.
- **"Ties can be broken arbitrarily without changing stability."** $\to$ ties change which pairs are
  blocking and can create or destroy stable matchings; break them consistently and state the rule.
