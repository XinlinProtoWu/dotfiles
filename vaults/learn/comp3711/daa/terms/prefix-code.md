# Prefix(-free) code

**What it is.** An encoding where no codeword is a prefix of another codeword. Equivalently, the
codewords are the leaves of a binary tree (left edge 0, right edge 1), so no leaf lies on the path
to another.

**Why it exists.** Variable-length codes save bits (common characters get short codewords) but
destroy the decoder's ability to find codeword boundaries. Prefix-freeness restores unique
decodability *without* separators: read bits until they match a codeword, emit that character,
continue. UTF-8 adds the extra property that continuation bytes start with `10`, giving
self-synchronisation after a corruption or a mid-file jump.

**Example.** $C_1 = \{a{=}00,\, b{=}01,\, c{=}10,\, d{=}11\}$ and
$C_2 = \{a{=}0,\, b{=}110,\, c{=}10,\, d{=}111\}$ are prefix codes; `1100111` under $C_2$ is
`bad`. $C_3 = \{a{=}1,\, b{=}110,\, c{=}10,\, d{=}111\}$ is not, and `1101111` decodes as both
`bad` and `acad`.

**Where it appears:** [[lec_10-11_greedy]] Sections 10, 11

**Related:** [[terms/huffman-coding]] · [[terms/weighted-external-path-length]]
