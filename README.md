# Matriks

An interactive linear algebra learning application built with Flutter. Explore twelve topics, edit matrices, inspect worked calculations, play instructional animations, practice with a quiz, and visualize 2D transformations. Turkish, English, Simplified Chinese, Spanish and Russian interfaces, light/dark themes and a personalized mathematics studio are included.

## Architecture

- `lib/features/topics`: searchable topic catalog and navigation.
- `lib/features/matrix_input`: bounded numeric editor and asynchronous solve flow.
- `lib/features/step_player`: worked steps, playback, matrix visualization, and cell inspection.
- `lib/features/practice`: five-language five-question practice flow.
- `lib/features/transform_visualizer`: animated basis vectors and matrix controls.
- `lib/core`: shared theme and widgets.
- `packages/matrix_engine`: immutable matrices, BigInt rational arithmetic, and solver tests.

The application computes locally. It has no application backend, account system, or persistent user-data store. Preferences are stored locally; matrix history is not saved. Loading the web application initially requires its hosted runtime assets; offline installation is not guaranteed.

## Development

Requires Flutter compatible with the Dart SDK constraint in `pubspec.yaml` (validated with Flutter 3.47.1 / Dart 3.13.1).

```sh
flutter pub get
cd packages/matrix_engine
dart pub get
cd ../..
flutter gen-l10n
flutter run
```

Edit translations in all five `lib/l10n/app_*.arb` source files, then regenerate them. Do not edit generated localization classes manually.

## Validation and builds

```sh
flutter analyze
flutter test
cd packages/matrix_engine
dart analyze
dart test
cd ../..
flutter build web --release
flutter build windows --release
```

Serve `build/web` through an HTTP server. Distribute the entire Windows `build/windows/x64/runner/Release` directory, including DLLs and data, rather than the executable alone.

## Numerical scope

Most operations accept dimensions from 1 to 5. Fractions use exact rational arithmetic. Eigen analysis supports 2×2 and 3×3 matrices; irrational 2×2 roots use decimal approximations, and the 3×3 implementation searches integer roots only from −20 to 20. It is not a general-purpose numerical eigensolver. Input is limited to 32 characters per cell to bound user-controlled computation.

## Project status and roadmap

Start with the [documentation index](docs/README.md), [current project review](docs/PROJECT_REVIEW.md), and [prioritized roadmap](docs/ROADMAP.md). The roadmap distinguishes verified defects, product opportunities, dependencies and release acceptance criteria; it does not describe already implemented work.

The studio redesign adds adaptive navigation, persistent preferences, three solution modes, five-language quizzes and explicit eigen result scope. See [implementation and validation notes](docs/STUDIO_REDESIGN.md) and the [short Turkish publishing guide](docs/YAYINLAMA.md). Historical test counts are in dated reports; rerun checks before release.

[Design rules](docs/DESIGN_SYSTEM.md) describe the implemented UI. [Security review](docs/SECURITY_REVIEW.md) records the scoped checks and limits. Earlier implementation reports are historical snapshots. Android release still uses development signing; the inspected Windows executable is unsigned. Owner-managed release identities and production-host validation are required before public distribution. Android/Apple device builds and physical screen-reader support were not validated here.

## Contributor and agent guide

See [AGENTS.md](AGENTS.md) for architecture boundaries, playback invariants, UI rules, and verification commands. The optional reproducible motion benchmark lives in `tool/motion_benchmark_test.dart`; run it with `flutter test tool/motion_benchmark_test.dart --reporter expanded`. Store disposable verification files in ignored `output/`.
