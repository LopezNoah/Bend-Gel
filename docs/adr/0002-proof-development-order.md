# ADR 0002: Develop the Metatheory in Dependency Order

- Status: Accepted
- Date: 2026-09-21

## Context

The Gel paper's main results form a useful dependency graph:

- Theorem 4.1: type synthesis is decidable.
- Theorem 4.2: type synthesis is unique.
- Theorem 4.3: preservation.
- Theorem 4.4: totality.

The first two follow from the syntax-directed static semantics. Preservation
and totality depend on supporting facts about cardinalities, store extension,
and conversion between stored and computed values. The paper's Appendix B
isolates those facts because proving them inline in mutation and iteration
cases makes the main arguments unnecessarily large.

## Decision

Implement and prove the development in this order:

1. Complete the five-element cardinality algebra: identities, annihilation,
   associativity, commutativity, distributivity, ordering, and monotonicity.
   Define and prove the semantic relation that says a finite length belongs to
   a cardinality. Exhaustive proofs are appropriate because there are only
   five cardinality modes.
2. Make type synthesis the executable interface, morally
   `synth(schema, context, expr) -> SynthError | (QueryType, Card)`. Prove
   that successful synthesis corresponds to the declarative typing judgment.
   Derive uniqueness from the deterministic algorithm rather than starting
   with an abstract existential theorem.
3. Formalize store extension before mutation-specific proofs. Prove the
   paper's B.3-style result that evaluation implies extension and its B.4-style
   result that extension preserves value and environment typing.
4. Prove the stored/computed value conversion lemmas, including the B.6-style
   conversion from stored-value typing to computed-value typing and the
   B.8-style preservation result for converting computed values back to stored
   form.
5. Prove preservation by induction on evaluation, using the preceding helper
   lemmas in insertion, update, iteration, and projection cases.
6. Prove totality by induction on typing after preservation and its supporting
   lemmas are available.

Parser and elaborator correctness remain outside this four-theorem core
sequence. They are developed as an additional theorem family, with successful
elaboration producing a valid core expression as its key boundary theorem.

## Consequences

The implementation order follows proof dependencies instead of feature
visibility. This may leave some evaluator cases present before their complete
metatheory is proved, but it avoids duplicating cardinality, extension, and
conversion arguments inside every case.

The executable synthesis function is a first-class artifact, not merely an
implementation detail. The declarative typing relation is retained as the
specification against which synthesis is shown sound and complete for the
supported core language.
