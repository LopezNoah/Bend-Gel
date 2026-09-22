# ADR 0001: Keep Surface Parsing Separate From the Core Calculus

- Status: Accepted
- Date: 2026-09-21

## Context

The concrete EdgeQL language and the calculus used by the Gel paper are not
the same language. Surface syntax contains implicit bindings, shorthand
projections, set notation, and other conveniences that must be made explicit
before typing or evaluation can reason about them. Some of those rewrites may
eventually be type-directed.

The repository already has the beginnings of this boundary:

- `src/EdgeQLSyntax.bend` defines `SurfaceExpr` and retains surface-only
  constructs such as partial paths and implicit subjects.
- `src/EdgeQLParser.bend` produces surface syntax trees.
- `src/Elaborate.bend` lowers surface syntax to `src/Syntax.bend`'s core
  `Expr`.
- `src/Typecheck.bend` and `src/Eval.bend` operate on the core `Expr`, not on
  surface syntax.

Putting concrete parsing directly into the core calculus would couple parser
correctness to store preservation and make both proof families harder to
state and maintain.

## Decision

Maintain the following pipeline:

```text
source text
    -> lexer / parser
    -> SurfaceExpr
    -> elaboration / desugaring
    -> CoreExpr (currently Syntax.Expr)
    -> type synthesis
    -> evaluation / compilation
```

The parser and elaborator are separate from the core metatheory. Core typing,
evaluation, preservation, and totality must not depend on lexer tokens,
surface-only AST constructors, or concrete spelling choices.

When parser helpers need a home, use a project-local `Parse` module. It may
contain cursor or span state, token positions, parse errors, identifier and
keyword handling, and small deterministic sequencing helpers. It should not
become a general parser-combinator package. Direct recursive descent and
explicit state machines are preferred because Bend closures are affine, the
language has no typeclasses, and inference is intentionally limited.

## Correctness Boundaries

Parser correctness is its own theorem family. Early parser obligations are:

- successful parsing advances monotonically;
- a full parse consumes exactly the input through EOF;
- parsing is deterministic;
- precedence and associativity match the grammar;
- for a canonical printer subset,
  `parse(pretty(ast)) = ast`.

Elaboration has a separate boundary obligation: every successful elaboration
produces a well-formed core expression. Type preservation and store
preservation begin only after that boundary.

## Consequences

This keeps parser changes local and lets the core preservation proof ignore
whether an expression was written with braces, shorthand projections, or
explicit core bindings. It also means surface syntax may evolve without
forcing changes to the core evaluator.

The cost is an explicit `SurfaceExpr` to core representation and a separate
set of parser/elaborator tests and proofs. That cost is intentional.
