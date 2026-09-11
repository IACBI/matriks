# Security Policy

## Reporting a vulnerability

Report privately through
[GitHub's advisory form](https://github.com/IACBI/matriks/security/advisories/new)
rather than a public issue. Please allow a reasonable window for a fix before
disclosing.

## What the attack surface actually is

Matriks calculates locally. There is no backend, account system, remote data store or
telemetry; only presentation preferences are persisted, never matrices or quiz history.
That removes most of the usual surface, so reports will normally concern the client:

- Dependency advisories in `pubspec.lock` or the engine package.
- Denial of service through user-controlled computation. Cell input is bounded to 32
  characters and most operations to dimensions 1–5 for this reason; a way past either
  bound is in scope.
- The published web build at <https://iacbi.github.io/matriks/>.

## Known, accepted limits

These are recorded rather than hidden, and are not useful as reports:

- The Android release build still uses the debug signing configuration.
- The inspected Windows release executable is unsigned.

Production signing identities belong to the release owner. Dated findings are kept in
[docs/SECURITY_REVIEW.md](docs/SECURITY_REVIEW.md).
