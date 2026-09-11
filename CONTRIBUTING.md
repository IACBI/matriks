# Contributing

[AGENTS.md](AGENTS.md) is the working contract. It covers architecture boundaries,
playback invariants, UI and accessibility rules, and the numerical limits the app
must keep stating honestly. Read it before touching `lib/features/step_player` or
`packages/matrix_engine`.

## Setup

The engine is a separate package, so resolve both:

```sh
flutter pub get
dart pub get --directory packages/matrix_engine
flutter gen-l10n
```

## Before opening a pull request

```sh
flutter analyze
flutter test
cd packages/matrix_engine && dart analyze && dart test
```

The same commands run in CI, plus a check that `lib/l10n/generated` matches the ARB
sources. Format changed files with `dart format <paths>`.

## Things that are easy to get wrong

- **Translations.** Edit all five `lib/l10n/app_*.arb` files, then run `flutter gen-l10n`.
  Never edit `lib/l10n/generated/` by hand.
- **Playback timing.** `MatrixDisplayGrid` owns the clock; `PlayerCubit` advances only on
  completion for the active `animationRevision`. Do not add a separate lesson timer.
- **Exactness.** Values are `BigInt` rationals. Do not introduce floating point into the
  engine, and never substitute zero for invalid input.
- **Honest labels.** `ResultAccuracy` and `ResultCompleteness` exist because parts of the
  eigen solver are approximate or partial. Do not widen a claim the solver cannot meet.

## Reporting a wrong result

Wrong answers are the reports worth the most. Include the topic, the exact matrix you
entered, what the app showed and what you expected — the
[bug report form](https://github.com/IACBI/matriks/issues/new?template=bug_report.yml)
asks for exactly that.
