# Agent Guide

## Purpose and starting points

Matriks is a Flutter app for learning linear algebra through exact matrix calculations, worked steps, quizzes, and 2D transformations. Preserve existing operations, all five languages (en/tr/zh/es/ru), and light/dark themes.

Before editing, read the relevant implementation and nearby tests. Use `README.md` for setup, `docs/README.md` as the documentation index, `docs/ROADMAP.md` for prioritized proposed work, and `docs/DESIGN_SYSTEM.md` for implemented interface rules. `docs/PROJECT_REVIEW.md` and `docs/SECURITY_REVIEW.md` record dated findings and limits. Roadmap items are not implemented behavior. Reports describe past verification; rerun relevant checks before claiming current success.

## Architecture

- `lib/main.dart`, `lib/app.dart`: startup, Material app, localization, and providers.
- `lib/features/topics`: catalog, combined search/category filters, and navigation.
- `lib/features/matrix_input`: numeric editing, validation, and asynchronous solve flow.
- `lib/features/step_player`: Cubit state, playback controls, timeline, matrix scene, and calculation inspection.
- `lib/features/practice`: five-language five-question quiz and feedback.
- `lib/features/transform_visualizer`: coefficient controls, presets, and canvas.
- `lib/features/settings`: versioned local presentation preferences and configurable player shortcuts.
- `lib/core`: shared theme tokens, mathematical text, and input controls.
- `lib/l10n`: ARB sources and generated localization classes.
- `packages/matrix_engine`: independent Dart package; immutable matrices, BigInt rational arithmetic, solvers, and engine tests.
- `test/`: application, flow, animation, and responsive/accessibility regression tests.
- `tool/motion_benchmark_test.dart`: optional debug animation benchmark, excluded from the default test suite.

The app calculates locally. There is no application backend, account system, or persistent sensitive-data store. Do not introduce these or change preference persistence incidentally.

## Implementation boundaries

- Make focused changes using the existing feature structure and Cubit patterns. Avoid broad rewrites, new dependencies, and unrelated formatting.
- Keep Flutter/UI concerns out of `matrix_engine`. Preserve exact rational values, solver result types, and before/after snapshots. Never replace invalid input with zero.
- Most matrix operations accept sizes 1–5. Eigen analysis is limited to 2×2 and 3×3. Rational roots are exact: floating-point estimates only propose candidates, which are kept only when the characteristic polynomial vanishes in rational arithmetic; one rational 3×3 root deflates the cubic to a quadratic. Irrational roots are rounded to three decimals from exact rational brackets, complex pairs are reported to two decimals without eigenvectors, and coefficients too large for an estimate (beyond 1e12) fall back to an integer search with the spectrum labelled incomplete. Do not present it as a general numerical eigensolver. ResultAccuracy/ResultCompleteness label approximation and scope; repeated roots are partial because only representative eigenvectors are computed. Do not infer full numerical correctness from the existing green suites.
- Preserve the 32-character cell input bound, cell-specific errors, valid selection after resizing, and duplicate-solve protection.
- Change translations in all five `lib/l10n/app_*.arb` source files, then run `flutter gen-l10n`. Do not manually edit `lib/l10n/generated/`.
- Keep `pubspec.lock`, platform scaffolding, and `.metadata`. Do not edit generated build/plugin files to fix source problems.

## Playback invariants

- Guided solutions start automatically and advance on visible-operation completion; entering guided mode starts autoplay. Static-step and direct-result modes remain distinct. Instant results and static steps do not wait for animations; mode switches invalidate completion revisions. Predictions pause worked examples only. Local preference persistence does not include matrices or quiz history.

- `InstructionTimeline.forTransformation` defines adaptive source/operation/result reading intervals. Swaps take 4000 ms, elimination/scaling 7500 ms up to three columns plus 1200 ms per further column (the operation phase reveals one column at a time), and dot products/determinants allow 1400 ms per contribution plus preparation and review. Speed scales the entire timeline; spatial easing is separate from instructional time.
- The animation controller in `MatrixDisplayGrid` owns time. `PlayerCubit` advances only after completion for the active `animationRevision`. Do not add an independent periodic lesson timer.
- Preserve the distinction between automatic lesson progression (`isPlaying`) and active operation animation (`isAnimating`).
- Reject stale completion callbacks. Manual navigation, scrubbing, replay, and calculation inspection stop automatic progression. Pause/backgrounding freezes playback; speed and responsive layout changes preserve progress.
- Reduced motion removes spatial animation but preserves results, phase explanations, and reading time.
- Display exact mathematical contributions and discrete results, never arbitrary interpolated numbers. Reveal contributions progressively and leave them available after completion. Multiplication shows the actual row of A and column of B; never draw source beams on C. Keep cell/source/explanation caches bounded to the current step and invalidate them when dependencies change.
- The player passes one `MatrixLayoutHint` per solution so cell width, the operation reserve and the swap lane do not change between steps. Entries of a sum or product not computed yet are pending placeholders, never zeros.
- The step list selects lesson steps; the collapsed operation inspector contains scrubbing and replay. Preserve a single main play/pause control.
- Geometric presets must match their mathematical names: projection is idempotent and rotation preserves lengths. `TransformMatrix` handles interpolation from the visible frame; rotations interpolate by angle when both endpoints are rotations. The solver engine is unaffected. Coefficient fields accept finite decimals in [-1000, 1000], commit on submit/blur, retain invalid drafts, and do not silently apply zero.

## UI and accessibility

Use `AppTheme` tokens and shared controls. Prefer neutral surfaces, clear dividers, and blue actions; mathematical role colors carry instructional meaning. Follow the detailed rules in `docs/DESIGN_SYSTEM.md`.

- Adapt to available width: single column below 600 px, flexible at 600–959, side-by-side from 960 when text size permits. Short screens and large text must scroll.
- Respect system text scaling and reduced motion. Keep touch targets at least 44×44 logical pixels, visible focus, keyboard traversal, and localized semantic labels.
- Animated cell calculations may fit down to 14 logical pixels before system text scaling; results return to normal 18–22 px text. Longer exact expressions remain horizontally scrollable. Full calculation panels wrap at TeX operator boundaries. Keep full formulas in `MathText`; use `readableMathProse` only for the supported inline notation in prose.
- Keep primary playback controls unique. Show only relevant legends and explanations. Feedback must include text or an icon, not color alone.
- Rebuild changing animation layers instead of whole screens. Measure optimizations with the same scenario before and after; debug pump timing is not GPU frame time or a 60 FPS guarantee.

## Commands and validation

Run from the project root unless noted. Use the installed Flutter/Dart SDK; `pubspec.yaml` is the source of truth for SDK constraints. Do not hard-code a developer's local SDK path in project files.

```sh
flutter pub get
cd packages/matrix_engine
dart pub get
cd ../..
flutter gen-l10n
flutter analyze
flutter test
flutter run -d windows
# Or: flutter run -d chrome
```

Fresh setup requires both dependency-resolution steps above: root analysis also visits engine tests, and the engine has its own development dependencies. After deleting package caches, restore both before analyzing.

For engine changes, run from `packages/matrix_engine`:

```sh
dart pub get
dart analyze
dart test
```

For release verification on a supported host:

```sh
flutter build web --release
flutter build windows --release
```

Format changed Dart files with `dart format <paths>`. Add behavior-focused regression coverage when changing logic; preserve existing tests. Run relevant tests first, then the full suite for cross-cutting changes. Playback work should cover phase boundaries, pause/resume, replay, scrubbing, speed, stale completions, and disposal. Layout work should cover both themes/languages, 320–1440 px, 200% text, reduced motion, long signed fractions, and 5×5 matrices as relevant.

Optional benchmark: `flutter test tool/motion_benchmark_test.dart --reporter expanded`. Keep machine load comparable and report measurement limitations.

## Workspace hygiene and delivery

Put durable documentation in `docs/`, reusable development utilities in `tool/`, and disposable logs/screenshots in ignored `output/`. Do not add caches, build artifacts, browser session files, or backup archives to source control. Keep the entire Windows release directory together when distributing; the executable depends on its DLLs and data.

Do not delete source, tests, lockfiles, platform projects, user configuration, or release assets as incidental cleanup. Verify resolved paths before recursive deletion and restrict it to confirmed generated artifacts inside this project.

Summarize what changed, why, and what was actually verified. State unrun checks and release limits explicitly. Never claim device accessibility, production readiness, dependency safety, or performance based only on an unmeasured assumption. Android release signing still uses the debug configuration; the inspected Windows release executable is unsigned. Production identities and artifact verification belong to the release owner; do not fabricate signing credentials.
