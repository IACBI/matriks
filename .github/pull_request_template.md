## What changed and why

<!-- The behaviour, not the diff. If it fixes a reported problem, link the issue. -->

## What was actually verified

<!-- Name the scenarios you ran. State anything you could not check rather than
     leaving it implied — unsigned builds, platforms you have no device for,
     performance you did not measure. -->

- [ ] `flutter analyze` and `flutter test`
- [ ] `dart analyze` and `dart test` in `packages/matrix_engine`
- [ ] Translations changed in all five `lib/l10n/app_*.arb` files and `flutter gen-l10n` run
- [ ] Regression coverage added for changed logic

<!-- Playback changes: cover phase boundaries, pause/resume, replay, scrubbing, speed,
     stale completions and disposal.
     Layout changes: cover both themes, 320-1440 px, 200% text and 5x5 matrices. -->
