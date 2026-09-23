# Cardinality algebra audit

Audited `Cardinality.add`, `Cardinality.mul`, `Cardinality.le`, and
`Cardinality.accepts` against [Section 2.1 of *Querying Graph-Relational
Data*](https://arxiv.org/html/2507.16089#S2.SS1). No discrepancies found.

| Bend constructor | Paper interval | Accepted lengths |
| --- | --- | --- |
| `CEmpty` | [0, 0] | 0 |
| `COptional` | [0, 1] | 0, 1 |
| `COne` | [1, 1] | 1 |
| `CMany` | [0, ∞] | all |
| `CNonEmptyMany` | [1, ∞] | positive |

The order compares intervals by inclusion: a wider interval has a lower (or
equal) minimum and a higher (or equal) maximum. Addition adds lower bounds,
rounding to 1 when the sum is positive, and adds upper bounds, rounding 2 or
more to ∞. Multiplication multiplies both bounds, with zero annihilating ∞.
These are the five-mode operations described in the paper.

`tests/CardinalityAuditTest.bend` computes the operations independently from
these bounds, comparing all 25 pairs for addition, multiplication, and order,
and checks membership at lengths 0, 1, 2, and 4 for every mode. The existing
`LAWS.bend` / `PROOF.bend` obligations additionally establish the algebraic
laws and length compatibility for arbitrary accepted lengths.
