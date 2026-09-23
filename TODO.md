# TODO

This is the active implementation and proof roadmap. Items are ordered by
dependency; do not treat the order as a list of independent feature ideas.
`CoreExpr` below means `Syntax.Expr` until the core module is renamed.

## 1. Preserve The Language Boundary

- [ ] Keep `EdgeQLParser` responsible only for producing `SurfaceExpr` and
  surface documents.
- [ ] Keep `Elaborate` as the only surface-to-core lowering boundary.
- [ ] Add a project-local `src/Parse.bend` for reusable cursor/span, token
  position, parse error, identifier/keyword, and deterministic sequencing
  machinery when extracting those concerns from `EdgeQLParser` becomes useful.
- [ ] Do not introduce a standalone parser package or a highly abstract
  parser-combinator framework.
- [x] Define a structural core-expression validity predicate for the
  elaboration boundary.
- [x] Prove that successful elaboration produces a valid `CoreExpr`.

## 2. Parser Correctness

- [x] Test and, where practical, prove that successful parser transitions
  consume tokens monotonically. Expression/shape suffix regressions and local
  binary-token/comma transition proofs cover the current parser paths.
- [x] Test that a full expression/document parse ends at EOF, allowing only
  the explicitly supported trailing semicolon form.
- [x] Test deterministic results and deterministic errors for the same token
  stream.
- [x] Add precedence and associativity cases for union, coalesce, equality,
  addition, calls, and parentheses.
- [x] Add a canonical token printer for a deliberately small subset and prove
  `parse(pretty(ast)) = ast` for that subset; test its textual rendering through
  the lexer separately.

## 3. Cardinality Algebra

- [x] Audit `Cardinality.add`, `Cardinality.mul`, `Cardinality.le`, and
  `Cardinality.accepts` against the five modes in the paper.
- [x] Prove both additive identity laws and both multiplicative identity laws.
- [x] Prove multiplication annihilation by `CEmpty` on both sides.
- [x] Prove addition and multiplication associativity and addition
  commutativity.
- [x] Prove multiplication commutativity.
- [x] Prove multiplication distributivity over addition in both orientations
  required by the core rules.
- [x] Complete the cardinality ordering laws: reflexivity, transitivity,
  antisymmetry, and the ordering cases used by typing.
- [x] Prove monotonicity of addition and multiplication with respect to the
  cardinality ordering.
- [x] Treat `accepts(card, length)` as the semantic relation “length belongs to
  cardinality”.
- [x] Add executable `accepts_order`, `accepts_add`, and `accepts_mul`
  compatibility predicates.
- [x] Prove that cardinality ordering preserves accepted lengths.
- [x] Prove the addition and multiplication length-compatibility facts
  corresponding to Appendix B.5 and B.7 for arbitrary accepted lengths.
- [x] Keep the finite constructor proofs exhaustive where that is clearer than
  introducing an abstraction.

## 4. Executable Type Synthesis

- [ ] Treat `Typecheck.synth` as the executable synthesis interface returning
  either `TypeError` or `(QueryType, Card)`.
- [ ] Audit every `Syntax.Expr` constructor and remove placeholder branches
  that only synthesize a source while ignoring a body, shape, filter, or key.
- [ ] Make schema lookup, contexts, cardinality checks, builtin arities, and
  mutation checks total and deterministic for the supported core language.
- [ ] State the declarative typing judgment represented by `synth`.
- [ ] Prove successful synthesis is sound with respect to that judgment.
- [ ] Prove synthesis is complete for the supported core constructors.
- [ ] Derive Theorem 4.1-style decidability from the executable function.
- [ ] Derive Theorem 4.2-style uniqueness from deterministic synthesis.

## 5. Store Extension And Value Conversion

- [ ] Define the store-extension relation and its component relations in
  `src/Store.bend` rather than encoding extension informally in mutation cases.
- [ ] Prove the B.3-style lemma: successful evaluation implies the resulting
  store extends the initial store in the required sense.
- [ ] Prove the B.4-style lemma: store extension preserves value typing and
  environment typing.
- [ ] State stored-value typing and computed-value typing separately.
- [ ] Prove the B.6-style stored-to-computed value conversion lemma.
- [ ] Prove the B.8-style computed-to-stored conversion preservation lemma.
- [ ] Add focused tests for references, nested fields, empty values, and
  mutation-created objects before using these lemmas in Preservation.

## 6. Core Metatheory

- [ ] State the core evaluation and typing relations in a form suitable for
  induction, while retaining executable `Eval.eval` and `Typecheck.synth`.
- [ ] Prove Theorem 4.3-style preservation by induction on evaluation.
- [ ] Use the cardinality, extension, and conversion lemmas to discharge
  iteration, projection, insert, and update cases.
- [ ] Prove Theorem 4.4-style totality by induction on typing.
- [ ] Connect successful elaboration, synthesis, evaluation, and the core
  preservation theorem without making parser details part of the core proof.

## 7. Regression Coverage

- [ ] Keep parser/elaborator tests separate from core type/evaluation tests.
- [ ] Add a small end-to-end suite covering source text through elaboration,
  synthesis, and evaluation.
- [ ] Run `sh ./build-container.sh` after each proof milestone so `PROOF.bend`
  and every `tests/*Test.bend` file remain checked together.

## 8. SQLite Schema And Query Translation

- [x] Parse a strict subset of SDL/DDL schema declarations into `Schema` and
  compile object tables, single-link columns, and multi-field junction tables.
- [ ] Extend schema parsing to modules beyond `default`, constraints, computed
  fields, and link properties; keep unsupported declarations explicit errors.
- [ ] Add migrations/diffing for existing SQLite databases and decide how to
  enforce nonempty multi cardinality across writes.
- [ ] Translate supported, elaborated EdgeQL query expressions into SQLite
  SELECT/INSERT/UPDATE statements using the generated table layout.
