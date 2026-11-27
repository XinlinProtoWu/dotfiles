![[Part1.pdf#page=70&selection=0,12,0,23|Part1, page 70]]
P[A|B] = ${}\frac{P[A \cap B]}{P[B]}{}$
where:
- P[A] is a *priori* (before B has occured)
- P[A|B] is a *posteriori* (After B has occured)

**VERBALLY: Under the circumstances of Event B, what are the chances of Event A happening?**

- Experiment performed *n* times
- Event *B* occurs ${}n_{B}{}$ times
- The event ${}A \cap B{}$ occurs ${}n_{A \cap B}{}$ times
${}\frac{n_{A \cap B}}{n_{B}} = \frac{n_{A \cap B}}{\frac{n}{\frac{n_{B}}{n}}}\to \frac{P[A \cap B]}{P[B]}{}$

[[Part1.pdf#page=72&selection=0,0,0,7|EXAMPLE]]

${}P[A_{2} = 0.1]{}$
${}P[A_{8} = 0.1]{}$

*Suppose integer chosen is greater than 5*
B = {6, 7, 8, 9, 10}
${}P[A_{8} | B] = \frac{P[A \cap B]}{P[B]} = \frac{P[{2} \cap {6, 7, 8, 9, 10}]}{P[{6, 7, 8, 9, 10}]} = 0{}$ 
${}P[A_{8} | B] = \frac{P[A \cap B]}{P[B]} = \frac{P[{8} \cap {6, 7, 8, 9, 10}]}{P{6, 7, 8, 9, 10}} = 0.2{}$ 

[[Part1.pdf#page=82&selection=0,0,0,5|Total Probability Theorem]]
If ${}B_{1}, B_{2} \dots B_{n}{}$ partition the sample space, then for any event *A*
${}P[A] = \sum_{i=1}^{n}P[A|B_{i}]P[B_{i}]{}$

[[Part1.pdf#page=85&selection=0,0,0,5|Baye's Rule]]
${}P[B_{j}|A] = \frac{P[AB_{j}]}{P[A]} = \frac{P[A|B_{j}]P[B_{j}]}{\sum_{k=1}^{n}P[A|B_{k}]P[B_{k}]}{}$

[[Part1.pdf#page=88&selection=0,0,0,12|Independence of Events]]
${}P[A|B] = \frac{P[A \cap B]}{P[B]} = \frac{P[A]P[B]}{P[B]} = P[A]{}$
and vice versa

For *3 Events*
- ${}P[A_{1} A_{2}] = P[A_{1}]P[A_{2}]{}$
- ${}P[A_{1} A_{3}] = P[A_{1}]P[A_{3}]{}$
- ${}P[A_{2} A_{3}] = P[A_{2}]P[A_{3}]{}$ 

${}P[A_{1} A_{2} A_{3}] = P[A_{1}]P[A_{2}]P[A_{3}]{}$

**In other words, All events need to be pairwise independent in order for the 3 events to be independent**

