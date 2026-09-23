# Bend Gel

## Containerized checks

Docker is the only host dependency. Run the proof and test suite without
installing Bend locally:

```sh
sh ./build-container.sh
```

The Docker image installs Bend under `/opt/bend` using the official installer,
copies the project into the image, and runs `bend PROOF.bend` followed by every
`tests/*Test.bend` file. The check container is non-root, has no network, uses a
read-only filesystem, and is removed after the run. No project files are bind
mounted, so the checks cannot write into the working tree.

The image build itself needs network access to download Debian packages and
Bend. Runtime network access is disabled, and Bend telemetry is disabled with
`BEND_NO_TELEMETRY=1`.

For source text, use `src/EdgeQLSource.bend`'s `parse_source` and
`parse_document_source`. For already-tokenized input, use
`src/EdgeQLParser.bend`'s `parse` and `parse_document`. Keeping the lexer
outside the token parser shortens proof-only checks without changing the
source-to-surface language boundary.

## SQLite package

`packages/sqlite` provides an affine SQLite connection for native and
JavaScript Bend programs. The package exposes `SQLite.open`, `SQLite.execute`,
`SQLite.query`, and `SQLite.close`; its integration test runs against an
in-memory database. Native checks install the SQLite runtime library in the
container so the same test exercises the C foreign backend.

### EdgeQL schema to SQLite

`src/SQLiteSchema.bend` compiles a supported subset of SDL/DDL into a list of
SQLite `CREATE TABLE` statements. Call `SQLiteSchema.from_source(source)` for
EdgeQL text, or `SQLiteSchema.compile(schema)` for an existing `Schema.Schema`.
Both return `DDLReady{statements}` or `DDLFailed{}`; execute the statements in
order with `SQLite.execute` (see `tests/SQLiteSchemaTest.bend` for a complete
in-memory example).

For example, this schema:

```edgeql
module default {
  type User {
    required property name -> str;
    property active -> bool;
    required link manager -> User;
    multi link friends -> User;
    multi property tags -> str;
  }
}
```

produces these tables (one statement per table):

```sql
CREATE TABLE "User" ("id" INTEGER PRIMARY KEY, "name" TEXT NOT NULL, "active" INTEGER CHECK ("active" IN (0, 1)), "manager" INTEGER NOT NULL REFERENCES "User"("id"));
CREATE TABLE "User.friends" ("source_id" INTEGER NOT NULL REFERENCES "User"("id") ON DELETE CASCADE, "target_id" INTEGER NOT NULL REFERENCES "User"("id"), PRIMARY KEY ("source_id", "target_id"));
CREATE TABLE "User.tags" ("source_id" INTEGER NOT NULL REFERENCES "User"("id") ON DELETE CASCADE, "value" TEXT NOT NULL, PRIMARY KEY ("source_id", "value"));
```

Single links use an integer reference column on the owner; multi links and
multi properties use junction tables named `Owner.field`. Set
`PRAGMA foreign_keys = ON` on each SQLite connection to enforce references.
Required single fields use `NOT NULL`; the nonempty part of a `required multi`
field is not enforced by this DDL. Each object has an auto-generated integer
`id` primary key. SQLite `bool` values are integers constrained to 0 or 1.

The source reader accepts `module default { type ... }` and `create type ...`
declarations with `property`/`link`, optional `required` or `multi` qualifiers,
and `str`, `int64`, and `bool` properties. Query statements in the same document
are ignored during schema extraction. Unsupported schema syntax, unknown link
targets, and unsupported link properties fail compilation explicitly. This
compiles schema DDL only; translating EdgeQL query expressions into SQL is a
separate step.

## Architecture roadmap

- [`TODO.md`](TODO.md) tracks the ordered implementation and proof work.
- [`docs/adr/0001-surface-parser-core-calculus.md`](docs/adr/0001-surface-parser-core-calculus.md)
  records the surface parser/core calculus boundary.
- [`docs/adr/0002-proof-development-order.md`](docs/adr/0002-proof-development-order.md)
  records the metatheory dependency order.
