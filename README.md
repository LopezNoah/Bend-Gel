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

## SQLite package

`packages/sqlite` provides an affine SQLite connection for native and
JavaScript Bend programs. The package exposes `SQLite.open`, `SQLite.execute`,
`SQLite.query`, and `SQLite.close`; its integration test runs against an
in-memory database. Native checks install the SQLite runtime library in the
container so the same test exercises the C foreign backend.
