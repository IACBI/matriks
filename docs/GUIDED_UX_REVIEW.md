# Guided UX and visualization follow-up

> Historical implementation record. For the latest review, cleanup status and proposed work, see [PROJECT_REVIEW.md](PROJECT_REVIEW.md) and [ROADMAP.md](ROADMAP.md).

This follow-up addresses the expert review of Matriks: teaching pace, contextual reasoning, control density, mathematical animation correctness, scalable arithmetic, catalog orientation, and useful practice feedback. The existing Flutter/Cubit architecture, exact matrix engine, Turkish/English support, themes, and solver operations are preserved. No dependency was added.

## Implemented changes and evidence

| Review finding | Result | Evidence |
| --- | --- | --- |
| Fixed timing gives complex calculations too little reading time | Adaptive source/operation/result profiles; 1400 ms per dot-product/determinant contribution; speed scales the whole timeline | `instruction_timeline.dart`, `player_timeline_test.dart`, `guided_learning_test.dart` |
| Generic explanations repeat the operation | Elimination explains target ÷ pivot; source, operation, and result prose follows the actual step. Dot-product/determinant rationale explains the rule without revealing the final answer early | `instruction_lesson.dart`, `visualization_correctness_test.dart` |
| Two exposed timelines compete for attention | One main play/pause control, named step list, collapsed operation inspector with scrubbing/replay. Inspection pauses automatic progress | `player_control_bar.dart`, `guided_learning_test.dart` |
| Arithmetic overlaps or is too small | Determinant paths carry no canvas text. Exact contributions appear as scalable math widgets. Player values use 20/24 px, with horizontal scrolling for long fractions | `determinant_lines_painter.dart`, `matrix_cell_widget.dart`, `instructional_animation_test.dart` |
| Multiplication highlights the wrong matrix | Show the actual row of A and column of B. Box corresponding factors in order; reveal C and its result badge only after all contributions | `multiplication_sources.dart`, `matrix_display_grid.dart`, `visualization_correctness_test.dart` |
| Geometric presets and transitions can mislead | Projection is idempotent; the 45° rotation uses full-precision coefficients. Rotation-to-rotation transitions preserve lengths. Retargeting starts at the visible frame; paused reverse playback resumes in the same direction | `transform_matrix.dart`, `visualization_correctness_test.dart` |
| Coefficient editing is restricted to steppers | Direct decimal entry and existing steppers, localized errors, finite range [-1000, 1000], submit/blur commit, preserved invalid drafts, explicit Custom state | `coefficient_field.dart`, transform and responsive tests |
| Catalog lacks a starting point | Three real worked starter lessons; compact search/categories and aligned topic rows remain available | `topics_screen.dart`, `guided_learning_test.dart` |
| Quiz feedback is generic | Each option has misconception-specific feedback in both languages; the ambiguous pivot question specifies a row swap. Options expose button, enabled, and selected semantics | `quiz_question.dart`, practice flow and guided learning tests |
| Repeated decoration and rendering work | Removed duplicate row annotations, intermediate cell arithmetic, and the unused multiplication beam painter. Step-bounded caches separate static math from changing animation layers | `matrix_display_grid.dart`, `tool/motion_benchmark_test.dart` |

The source-row transfer uses a light outline instead of duplicate, inaccessible ghost arithmetic. Completed formulas remain inspectable. Reduced motion shows the final matrix and all explanatory phases without spatial travel. Existing pause, speed, revision, resize, disposal, and background behavior remains covered by playback tests.

## Verification

Final verification on 7 September 2026, on the available Windows host:

| Check | Verified result |
| --- | --- |
| `flutter analyze` | No issues |
| `flutter test --reporter expanded` | 89 passed |
| Engine `dart analyze` and `dart test` | No issues; 34 passed |
| `flutter build web --release` | Passed; 168.6 s |
| `flutter build windows --release` | Passed; 67.7 s |
| Optional 5×5 motion benchmark | Passed; full 7500 ms timeline |
| Final browser console | 0 errors, 0 warnings |

Browser review covered the catalog and player at desktop/mobile widths, English dark-theme matrix input and multiplication, misconception feedback, geometric projection and its coincident-vector label, and the six-term Sarrus result with negative contributions. The final accessibility snapshot confirmed quiz buttons A–D and Turkish row/column/value labels. The final Windows Release application was launched for user inspection; this is launch verification, not a separate native-device accessibility audit.

Screenshots include `final-player.png`, `final-input-mobile-dark-en.png`, `final-multiplication-mobile-dark-en.png`, `final-practice-mobile-dark-en.png`, `final-projection-verified.png`, and `final-sarrus-verified.png` under `output/playwright/`. They document successive verification points; the later changes to quiz semantics do not alter those layouts. The latest browser reload specifically verified the final semantic changes. Flutter's web semantics overlay sometimes intercepted Playwright actionability checks; verified controls were then clicked at their coordinates using Playwright's force option. This is recorded as an automation limitation, not proof of physical screen-reader support.

Raw logs used the `output/continued-*` prefix and are no longer retained. Logs and screenshots were intentionally ignored local verification artifacts, not shipped application assets.

## Performance evidence

The reproducible debug harness runs the same 5×5 elimination step four times, excludes warm-up, and advances the complete 7500 ms instruction in 16 ms increments. The measured run produced 1407 samples: median **2.373 ms**, p95 **6.776 ms** per test pump. Command: `flutter test tool/motion_benchmark_test.dart --reporter expanded`; its log is no longer retained.

This is debug test-harness CPU cost, not GPU raster time, a device frame trace, or proof of 60 FPS. The older report used a shorter instructional timeline and different rendered content. Its historical before/after figures are not a valid percentage comparison for this follow-up. No new percentage speedup is claimed.

A separate 8-second browser `requestAnimationFrame` sample around a 3×3 starter elimination in the release web app yielded 924 intervals: median **7.0 ms**, p95 **13.9 ms**, with **12 intervals over 20 ms**. The page remained visible at 1280×900 and approximately 1× device pixel ratio. The sample includes navigation/startup and a short settled interval, and measures browser scheduling rather than Flutter raster work. It does not prove every frame meets the 16.7 ms budget or establish a before/after speedup. The raw sample log is no longer retained.

## Scope and release limits

- The five main screens retain their established responsive layout rules and shared theme tokens. Automated layout coverage includes 320×568 at 200% text in both themes, 600×800, 960×768, 1440×900, and short landscape with Turkish/English and reduced-motion cases. These are selected combinations, not exhaustive device certification.
- Exact rational arithmetic and engine result types are unchanged. Geometric drawing uses floating-point coefficients, separately from the exact solver engine. Existing eigen-analysis limits still apply.
- Preferences remain session-only. No account system, network API, persistent sensitive-data store, or new dependency was introduced. The prior security report remains historical evidence; this follow-up is not a fresh dependency vulnerability certification.
- A broad source-search command was blocked by an environment preflight rule that classified it as sensitive-file access. It was not retried. Review of the explicitly changed source and input-boundary tests continued; no comprehensive new security scan is claimed.
- Real-device screen readers, full WCAG 2.2 AA certification, field Core Web Vitals, and Android/Apple release builds remain unverified. Android production signing still requires the owner's identity. These limits are not silently treated as passed.
- Windows distribution requires the complete Release directory, including DLLs and data. The project has no Git repository, so no commit or PR was produced.

`AGENTS.md` and `DESIGN_SYSTEM.md` now describe the adaptive timelines, source operands, geometric invariants, editing boundaries, and verification workflow. Older reports remain historical snapshots.

## Subsequent security review — 2026-09-07

The earlier blocked scan above describes that UX session only. A newly authorized source/configuration review and fresh dependency advisory query are documented in [SECURITY_REVIEW.md](SECURITY_REVIEW.md), including scope, findings and limitations.
