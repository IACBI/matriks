# Automatic playback and readable cell calculations — 2026-09-10

## Implemented behavior

- Guided solutions start automatically and advance after each visible operation
  completes. Entering guided mode starts automatic playback too. Pause, manual
  navigation, replay, inspection and scrubbing retain their existing controls;
  static-step and direct-result modes remain distinct. Predictions still apply
  only to opted-in worked examples, not user-entered matrix solutions.
- Cell calculations remain inside the matrix during elimination, scaling,
  addition and multiplication. Multiplication reveals the accumulated exact
  products progressively. Results return to the normal 18–22 px text size.
- ReadableMathFit measures the rendered equation and scales it down only as
  needed, with a 14 px minimum before system text scaling. Common operation
  cells reserve at least 120 logical pixels of width. Extremely long exact
  expressions scroll rather than becoming illegibly small or being truncated.
- Matrix dimensions use available layout width and the longer numerator or
  denominator instead of the combined fraction string. Oversized matrices have
  a visible horizontal scrollbar and follow the active calculation column.
  Dragging the matrix pauses automatic playback.
- Full equations also remain in the explanation area. TeX break points allow
  them to wrap at operators while preserving fractions and grouped factors.
- Fixed double text scaling: MathText already applied the system TextScaler;
  flutter_math_fork then multiplied it again. A 200% setting now doubles rather
  than quadruples the rendered size. Error fallback text uses the same rule.

## Performance implementation

Cell and row widgets are cached by discrete column/term phases, not rebuilt
from matrix metadata on every animation frame. Caches remain per-step and are
invalidated for widget, dependency and layout changes. The scroll viewport stays
outside the animation builder. Exact values and the single instructional clock
are preserved; reading durations were not shortened to manufacture a speedup.

## Verification and limits

Regression tests cover automatic start and completion of every step, pause and
resume, bounded fitting and normal result size, exact expressions inside cells,
long-expression fallback, proportional text scaling, narrow numeric grids,
wrapped equations and automatic active-column visibility. Flow tests now pause
initial automatic playback explicitly when they need to inspect the first step.

The full Flutter suite also exercises five languages, both themes, reduced
motion, text scaling and the existing timing/resize/disposal invariants. The full suite passed **123 tests** after restoring in-cell operations. The
last viewport-only optimization additionally passed all **24** focused
readability/timeline tests. Final static analysis is clean (`dart analyze lib test tool`); evidence is
`output/autoplay-analysis-final.log`. The final web release build succeeded and
was launched in Chrome at `http://127.0.0.1:52147/`.

The same `tool/motion_benchmark_test.dart` 5×5 elimination workload produced
1,407 post-warmup samples per run, with no other test or build running during
measurement:

| Debug pump metric | Before | Final |
| --- | ---: | ---: |
| Median | 2.581 ms | 2.960 ms |
| p95 | 9.527 ms | 6.966 ms |

The p95 improved about 27%; the median increased about 15%. This is a mixed
result, not an across-the-board speedup. New fitting/wrapping and active-column
visibility perform additional work. Separate runs can also differ with host
load. Evidence: `output/autoplay-performance-before.log` and
`output/autoplay-performance-final.log`.

No numerical-engine, dependency, translation or signing changes were needed.
A debug pump benchmark measures test-harness CPU work, not GPU frame time or
real-device FPS. No unconditional 30/60 FPS or zero-stutter guarantee is made.
Windows native launch remains dependent on host plugin symlink support.


The browser inspection tool could not start during final verification because
of a Windows sandbox ACL error. Earlier browser screenshots do not represent
this version. Native Windows remains blocked by plugin symlink requirements.


## Playback speed controls and cleanup — 2026-09-10

The player now offers adjacent decrease/increase buttons in 0.25x increments,
clamped to 0.25x–4x. The preset menu also covers this range. Changing speed
continues to use the existing Cubit callback, preserving playback state and
animation progress. Both buttons have localized tooltips in all five languages
and 48-pixel minimum touch targets; controls disable at the corresponding limit.

Validation: 20 speed-control and timeline tests passed, including all five
languages at 320 pixels and 200% text scaling, button limits, preset selection,
and existing progress preservation tests. `dart analyze lib test tool` reported
no issues. The full suite was not rerun for this focused toolbar change.

Cleanup actually removed 125 generated or obsolete files (66,659,818 bytes):
test caches/assets, old output logs, disposable scripts, screenshots and browser
snapshots. Paths were verified inside the project without reparse points before
deletion, then checked for absence. `output/cleanup-receipt.json` records deleted
paths and byte counts. Older documentation references to removed output files
are historical; current validation and benchmark evidence was retained.
Source, tests, settings, lockfiles, platform projects and release assets remain.
