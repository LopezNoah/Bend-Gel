import Base
import ./Cardinality.bend as C

# Human-facing semantic contract for the Bend Gel prototype.
#
# These are identity laws of the paper's cardinality algebra: [0,0] is the
# identity for sequence union, and [1,1] is the identity for multiplication
# (the cardinality effect of a one-value for-body).
#
# The next expansion will add evaluator/refinement laws for deterministic
# union, unique synthesis, evaluation preservation, and store preservation.
# They remain absent until their executable relations are present: an open
# claim would make PROOF.bend fail rather than falsely report coverage.

law add_empty_left:
  for card: C.Card
  {C.add(C.CEmpty{}, card) == card : C.Card}

law multiply_one_left:
  for card: C.Card
  {C.mul(C.COne{}, card) == card : C.Card}
