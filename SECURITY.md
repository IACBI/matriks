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

- Without the owner's git-ignored `android/key.properties`, an Android release build is
  signed with the debug key; only builds made with the upload key are distributable.
- The inspected Windows release executable is unsigned.
- The web app shares the `iacbi.github.io` origin with the owner's other GitHub Pages
  projects, which can therefore reach its stored preferences and offline cache. This
  is accepted until it moves to its own domain; a report needs a flaw in Matriks itself.

Production signing identities belong to the release owner. Dated findings are kept in
[docs/SECURITY_REVIEW.md](docs/SECURITY_REVIEW.md).
