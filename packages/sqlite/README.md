# Bend SQLite

This package exposes SQLite through Bend's affine `IO` effects. The connection
handle uses Base's opaque `File` handle type because Bend currently reserves
custom opaque handle laws for Base effects; it cannot be copied or constructed
by Bend code. Use `SQLite.close` rather than the unrelated `File` operations.

`query` returns rows in query order. Each row contains values in column order;
integers and reals are represented by their text representation, blobs by hex,
and nulls by `SqlNull`.

The native backend loads the platform SQLite shared library at runtime. Native
programs therefore need SQLite installed (`libsqlite3-0` on Debian/Ubuntu;
SQLite is part of macOS). The JavaScript backend uses Bun's `bun:sqlite` module
when available and falls back to Node's built-in `node:sqlite` module.
