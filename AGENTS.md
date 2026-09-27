# Agent Guide

## Purpose and starting points

Matriks is a Flutter app for learning linear algebra through exact matrix calculations, worked steps, quizzes, and 2D transformations. Preserve existing operations, all five languages (en/tr/zh/es/ru), and light/dark themes.

Before editing, read the relevant implementation and nearby tests. Use `README.md` for setup, `docs/README.md` as the documentation index, `docs/ROADMAP.md` for prioritized proposed work, and `docs/DESIGN_SYSTEM.md` for implemented interface rules. `docs/PROJECT_REVIEW.md` and `docs/SECURITY_REVIEW.md` record dated findings and limits. Roadmap items are not implemented behavior. Reports describe past verification; rerun relevant checks before claiming current success.

## Architecture

- `lib/main.dart`, `lib/app.dart`: startup, Material app, localization, and providers.
- `lib/features/topics`: catalog, combined search/category filters, navigation, the `TopicItem.pathOrder` learning path, per-topic `TopicGlyph` drawings, and completed/continue tracking.
- `lib/features/matrix_input`: numeric editing, validation, and asynchronous solve flow.
- `lib/features/step_player`: Cubit state, playback controls, timeline, matrix scene, calculation inspection, and independent result checks (`result_check.dart`, shown by `ResultChecks`).
- `lib/features/practice`: five-language quiz; a curated five-question round plus generated rounds (`models/quiz_generator.dart`) built from named misconceptions.
- `lib/features/transform_visualizer`: coefficient controls, presets, and canvas.
- `lib/features/settings`: versioned local presentation preferences, configurable player shortcuts, and the last opened topic and finished topic names.
- `lib/core`: shared theme tokens (including `AppTheme.symbolFallback`, the bundled `MatriksSymbols` font used for math glyphs the system font lacks), mathematical text (`MathText`, which also exposes a readable semantics label for screen readers), and input controls.
- `lib/l10n`: ARB sources and generated localization classes.
- `packages/matrix_engine`: independent Dart package; immutable matrices, BigInt rational arithmetic, solvers, and engine tests.
- `test/`: application, flow, animation, and responsive/accessibility regression tests.
- `tool/motion_benchmark_test.dart`: optional debug animation benchmark, excluded from the default test suite.
- `tool/build_symbol_font.py`: rebuilds `assets/fonts/MatriksSymbols-Regular.ttf` (a subset of DejaVu Sans, renamed as its Bitstream Vera license requires; see `assets/fonts/LICENSE-MatriksSymbols.txt`); needs `fontTools`.
- `tool/build_cjk_font.py`: rebuilds `assets/fonts/MatriksCJK-Regular.ttf` and `-Bold.ttf` (a Noto Sans SC subset of the CJK characters in `app_zh.arb` and the Dart sources, renamed; see `assets/fonts/LICENSE-MatriksCJK.txt`); needs `fontTools`. Rerun it whenever Chinese strings change; a test fails if a character is missing.

`web/offline_worker.js` makes the installed web app work offline after one online visit: network first for every same-origin GET (online users always get the latest deployment), the cache only when the network fails. The app calculates locally. There is no application backend, account system, or persistent sensitive-data store. Do not introduce these or change preference persistence incidentally.

## Implementation boundaries

- Make focused changes using the existing feature structure and Cubit patterns. Avoid broad rewrites, new dependencies, and unrelated formatting.
- Keep Flutter/UI concerns out of `matrix_engine`. Preserve exact rational values, solver result types, and before/after snapshots. Never replace invalid input with zero.
- Most matrix operations accept sizes 1–5. Eigen analysis is limited to 2×2 and 3×3, and it is exact: the app is used as an academic calculator, so no value is ever rounded. Rational roots are found completely (Sturm isolation, then the simplest fraction, verified exactly; no size limit); what remains is irreducible and written in closed form (square roots, Cardano with real cube roots, or cosines with angles in [0, π]); eigenvectors come from exact elimination in Q(λ), and repeated rational eigenvalues get their full eigenspace basis, with defective matrices stated as such. `ExactEigenvalue.approximate` exists for ordering, plotting and tests only and must never be displayed. See `packages/matrix_engine/README.md`. Do not present it as a general numerical eigensolver (larger sizes are unsupported), and do not reintroduce rounded output anywhere: the decimal view writes exact terminating or repeating (\overline) decimals and falls back to the fraction beyond 24 digits.
- Preserve the 32-character cell input bound, cell-specific errors, valid selection after resizing, and duplicate-solve protection.
- Change translations in all five `lib/l10n/app_*.arb` source files, then run `flutter gen-l10n`. Do not manually edit `lib/l10n/generated/`.
- Keep `pubspec.lock`, platform scaffolding, and `.metadata`. Do not edit generated build/plugin files to fix source problems.

## Playback invariants

- Guided solutions start automatically and advance on visible-operation completion; entering guided mode starts autoplay. Static-step and direct-result modes remain distinct. Instant results and static steps do not wait for animations; mode switches invalidate completion revisions. Predictions pause worked examples only. Local preference persistence includes the last opened topic (`SettingsState.lastTopic`) and which topics were finished (`completedTopics`); it never includes matrices or quiz answers. A topic is recorded as finished when its lesson reaches the finished last step in guided or static-steps mode, when a practice round ends, or when a transformation is played.

- `InstructionTimeline.forTransformation` defines adaptive source/operation/result reading intervals. Swaps take 4000 ms, elimination/scaling 7500 ms up to three changing columns plus 1200 ms per further one (the operation phase reveals one changing column at a time; columns where the source row is 0 are skipped), and dot products/determinants allow 1400 ms per contribution plus preparation and review. Speed scales the entire timeline; spatial easing is separate from instructional time.
- The animation controller in `MatrixDisplayGrid` owns time. `PlayerCubit` advances only after completion for the active `animationRevision`. Do not add an independent periodic lesson timer.
- Preserve the distinction between automatic lesson progression (`isPlaying`) and active operation animation (`isAnimating`).
- Reject stale completion callbacks. Manual navigation, scrubbing, replay, and calculation inspection stop automatic progression. Pause/backgrounding freezes playback; speed and responsive layout changes preserve progress.
- Reduced motion removes spatial animation but preserves results, phase explanations, and reading time.
- Display exact mathematical contributions and discrete results, never arbitrary interpolated numbers. Reveal contributions progressively and leave them available after completion. Multiplication shows the actual row of A and column of B; never draw source beams on C. Keep cell/source/explanation caches bounded to the current step and invalidate them when dependencies change. The one exception is `MatrixDisplayGrid`'s cell cache, which carries the previous update's cells so a step change rebuilds only the entries it changes. Its key must therefore hold every input of a cell; add any new `MatrixCellWidget` input to the key.
- The player passes one `MatrixLayoutHint` per solution so cell width, the operation reserve and the swap lane do not change between steps. Entries of a sum or product not computed yet are pending placeholders, never zeros.
- Each step explains its operation once: do not repeat the phase explanation in the step description, per-cell calculation list, or legend. Mark only highlight roles the step actually has.
- The player is a single centred stage column (max width 880) at every screen width: matrix, a role legend under it, the phase caption (one sentence that fades between phases, with phase dots — not a "1 / 3" count), the solver's "why" note when the caption does not already say it, then one `Details` drawer (key `operation-inspector`) holding the rationale, per-cell calculations, and the scrub slider/replay. Opening the drawer pauses the lesson. Row-operation highlights use two hues only: amber for the row used (heavier border/fill for the pivot, thinner for the source) and cyan for the row that changes (target; a finished zero keeps its "0 ✓" badge, now cyan); the augmented-matrix divider uses the neutral outline color.
- The step list selects lesson steps; the collapsed `Details`/operation inspector contains scrubbing and replay. Preserve a single main play/pause control.
- Geometric presets must match their mathematical names: projection is idempotent and rotation preserves lengths. `TransformMatrix` handles interpolation from the visible frame; rotations interpolate by angle when both endpoints are rotations. The solver engine is unaffected. Coefficient fields accept integers, decimals and fractions in [-1000, 1000], hold the target exactly (`QuadraticSurd`, a + b√2, so the 45° rotation is ±√2/2), commit on submit/blur, retain invalid drafts, and do not silently apply zero. Displayed basis vectors and determinant are the target's exact values, never interpolated numbers; doubles are for drawing only.

## UI and accessibility

Use `AppTheme` tokens and shared controls. Prefer neutral surfaces, clear dividers, and blue actions; mathematical role colors carry instructional meaning. Follow the detailed rules in `docs/DESIGN_SYSTEM.md`.

- Adapt to available width: single column below 600 px, flexible at 600–959. The step player is one centred stage column at every width (wide screens only get more padding); `matrix_input` and `transform_visualizer` still switch to side-by-side layouts from 960 px when text size permits; the matrix editor also does on short landscape screens (wider than tall, under 500 px high, at least 600 px wide) so a phone held sideways sees Solve and the keypad beside the matrix. Short screens and large text must scroll.
- Respect system text scaling and reduced motion. Keep touch targets at least 44×44 logical pixels, visible focus, keyboard traversal, and localized semantic labels. `FocusRing` (in `app.dart`) outlines the focused control while the keyboard is in use, because Material's focus overlay alone changes a control by only about 1.3:1. `test/accessibility_guidelines_test.dart` runs Flutter's target-size, label and text-contrast guidelines over every tab, the editor and the player; keep it passing.
- Animated cell calculations reserve up to 120 px per operation cell, capped at the width actually available per column so a reserve never crowds a value off a narrow screen; a formula that still doesn't fit shrinks to a 14 logical-pixel floor (before system text scaling) and then scrolls. Results return to normal 18–22 px text. Longer exact expressions remain horizontally scrollable, and outside cells they show their scrollbar through `SidewaysScroll` (Flutter draws none for horizontal scroll views); a non-animating step scrolls its highlighted cells into view (pivot or badged cell first). Full calculation panels wrap at TeX operator boundaries. `MathText` sets fraction-bearing matrix entries in display style (`displayStyleMatrixCells`); flutter_math_fork parses neither `\\[gap]` nor `\arraystretch`, so the per-cell `\rule` strut is what keeps rows apart. Engine calculations bracket negative operands through `operandLatex`. Keep full formulas in `MathText`; use `readableMathProse` only for the supported inline notation in prose.
- Math glyphs outside the system font's coverage (arrows, sub/superscripts, ⟹, ∅, ✓, etc.) must render from the bundled `MatriksSymbols` font: pass `AppTheme.symbolFallback` as `fontFamilyFallback` on any new explicit `TextStyle` that can carry this notation, rather than letting Flutter fetch a fallback glyph at runtime. The Chinese interface renders from the bundled `MatriksCJK` subset, also part of `AppTheme.symbolFallback`, so no glyphs are fetched from `fonts.gstatic.com` and Chinese works offline; only characters a learner types outside the subset still fall back to Flutter's runtime download.
- Desktop screen readers (Windows UI Automation) build their tree from traversal-order children and reject an update with an orphaned node, after which they never update again. Wrap every `Slider` in `SliderWhileShown` (its value-indicator `OverlayPortal` is orphaned while the slider is hidden), keep drawers that hold one unmaintained and unanimated (`AnimationStyle.noAnimation`), and keep `test/semantics_tree_consistency_test.dart` passing. Give tappable containers the button role (`Semantics(button: true)`, `internalAddSemanticForOnTap: true` on `ExpansionTile`), or UI Automation exposes them as text that cannot be invoked.
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

Format changed Dart files with `dart format <paths>`. CI (`.github/workflows/ci.yml`) runs `dart format` over every tracked Dart file except `lib/l10n/generated` as its last `verify` step and fails on any diff, so an unformatted file fails the pipeline even if analysis and tests pass. Add behavior-focused regression coverage when changing logic; preserve existing tests. Run relevant tests first, then the full suite for cross-cutting changes. Playback work should cover phase boundaries, pause/resume, replay, scrubbing, speed, stale completions, and disposal. Layout work should cover both themes/languages, 320–1440 px, 200% text, reduced motion, long signed fractions, and 5×5 matrices as relevant.

Optional benchmark: `flutter test tool/motion_benchmark_test.dart --reporter expanded`. Keep machine load comparable and report measurement limitations.

## Workspace hygiene and delivery

Put durable documentation in `docs/`, reusable development utilities in `tool/`, and disposable logs/screenshots in ignored `output/`. Do not add caches, build artifacts, browser session files, or backup archives to source control. Keep the entire Windows release directory together when distributing; the executable depends on its DLLs and data.

Do not delete source, tests, lockfiles, platform projects, user configuration, or release assets as incidental cleanup. Verify resolved paths before recursive deletion and restrict it to confirmed generated artifacts inside this project.

Summarize what changed, why, and what was actually verified. State unrun checks and release limits explicitly. Never claim device accessibility, production readiness, dependency safety, or performance based only on an unmeasured assumption. Android release signing still uses the debug configuration; the inspected Windows release executable is unsigned. Production identities and artifact verification belong to the release owner; do not fabricate signing credentials.
