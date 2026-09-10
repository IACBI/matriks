# Comprehensive review — 2026-09-09

This review covers UI/accessibility, animation correctness, performance,
security/input boundaries and unused code in the local project. Findings and
implemented fixes are below; external release/device limits are explicit.
This is a scoped engineering review, not a certification of all devices or
all possible mathematical inputs.

## Verified so far

- Added a regression test that focuses catalog search, switches destinations,
  attempts to focus the hidden search, then returns. The existing IndexedStack
  already prevents hidden focus; no shell change was needed.
- Matrix scene previously rebuilt each Row and its translation wrapper on every
  clock tick even when its cached cell widgets had not changed. Rows now reuse
  their widget while their cells are identical; translation remains only for
  spatial swaps. The per-row cache is bounded to the current matrix and cleared
  on widget/dependency changes. Swap wrappers stay stable through endpoints.
- Targeted animation, timeline and studio UI suite: 40 tests passed, including
  the new focus regression and five-language/two-theme layout cases.
- Same 5×5 debug elimination harness, 1,407 samples: before median 2,154 µs,
  p95 6,006 µs; after median 2,143 µs, p95 5,813 µs. No parallel build/test action
  ran during these measurements. The small difference is not evidence of a
  significant real-device speedup. GPU timing and memory remain unmeasured.

## Result integrity, security and dead-code follow-up

- Failed solutions no longer show an Exact badge or present the fallback matrix
  as a calculated result. Unsupported scope remains visible. A singular inverse
  regression verifies the localized error and absence of a result matrix.
- Removed three confirmed unused translations from the retired TR/EN quiz
  switch in all five ARB sources; regenerated localization classes. Other
  unreferenced-name candidates are not automatically treated as dead public APIs.
- Fresh OSV Pub batch query covered 89 distinct hosted package/version pairs;
  all responses were present and none contained advisories (2026-09-08 UTC).
  This does not audit native binaries or establish dependency safety.
- Credential-pattern metadata scan read 105 UTF-8 source/platform files up to
  2 MB in selected source folders. Private-key headers, GitHub token formats and
  AWS access-key IDs had no matches. No values were printed. Binary/generated
  artifacts, history, the user's other files and other secret formats were not
  covered. Evidence: output/audit-security-static.json.
- Rechecked matrix dimensions (1–5; eigen 2–3), 32-character numeric entry,
  parse validation before solving, duplicate-submit protection and mounted
  checks. Coefficient fields reject nonfinite values and values outside ±1000.
  Preferences decode through validated version/enums/speed/shortcut choices;
  Cubit catches storage failures and displays a recoverable settings error.
- Web bootstrap uses textContent, with no raw user HTML execution. Android
  release still explicitly uses debug signing; production keys/identity remain
  owner-managed. No release identity was fabricated or OS setting altered.

## Additional evidence and conclusions

- Import/export/part traversal from lib/main.dart reached all 43 application
  Dart files, including generated localization classes: no orphan Dart files.
  Analyzer found no unused-import/private-member or unreachable-code warnings.
  Name scanning found further unused translation candidates, but a name scan
  alone is not grounds to delete public engine APIs or dynamically selected text.
- Inspected single-clock ownership, revision checks and post-frame callbacks.
  The current animation/timeline tests cover completion, pause, replay, scrubbing,
  speed changes, reduced motion, disposal and resize preservation. Mode and
  prediction tests verify direct result transitions and pausing/skipping a question.
  Cached rows/cells/expressions/sources/explanations are per-grid, bounded by
  matrix positions and discrete phases, and cleared on widget/dependency changes.
- New optional tool/scene_stress_test.dart exercises eight successive 5×5
  multiplication steps, both integers and signed long fractions, on the same
  mounted scene, then disposes it. Both workloads passed without framework
  exceptions. Each measured 4,858 post-warmup pumps. Integers: median 2,585 µs,
  p95 4,958 µs. Fractions: median 2,022 µs, p95 4,803 µs. These are separate
  workloads, not a before/after optimization comparison.
- Process RSS across the integer workload rose from 248,324,096 to 279,973,888
  bytes, then was 278,532,096 after disposal. The following fraction workload
  ranged from 333,406,208 to 362,717,184 bytes and ended at 340,381,696 after
  disposal. RSS includes VM/JIT/renderer allocations and does not isolate live
  app objects; these measurements neither prove nor rule out a leak. They are
  a reproducible baseline, not a stable-memory guarantee or forced-GC heap audit.
- Fresh Chromium inspection of the release build covered 390×844 catalog and
  prediction/player views, and 1440×900 player layout. Skipping a question ran
  the operation and reached the next prediction. Pointer interaction worked;
  some Playwright semantic-locator clicks were intercepted by Flutter's
  semantics overlay, so observed screen coordinates were used for those clicks.
  No visual overflow was observed in those captures. This is not screen-reader
  certification. Captures were saved as ignored output/audit-*.png files that are no longer retained.
- The browser check exposed a disabled play control that still looked active.
  It now uses neutral disabled colors and zero elevation. The prediction test
  passed again after this focused visual change.
- Predictions previously suppressed all player shortcuts, including S, although
  the result and step-navigation buttons remained available. Navigation/result
  shortcuts now remain available during a prediction, while play/replay still
  wait for an answer or skip. A regression verifies Space cannot start the
  operation but S opens its result. Chromium reported zero console errors in
  the inspected session.

## Verification and release limits

- Full application suite: **111 tests passed** after the result, localization,
  control-color and shortcut fixes.
- Independent engine suite: **39 tests passed**, engine analysis clean.
- Application analysis clean; web release build successful. Logs used the
  output/audit-*-final.log names and are no longer retained. The optional
  stress tests both passed.
- Windows release was attempted again and blocked by disabled host symbolic-link
  support required by Flutter plugins. No generated plugin workaround was made.
- Android/iOS builds, production signing, real-device GPU/heap profiling,
  physical assistive technology and native-speaker terminology review were not
  performed. Production hosting headers/TLS cannot be audited without a deployed
  host. Android debug signing remains a documented public-release blocker.
- The small elimination timing difference is not a claimed speedup; no 60 FPS
  guarantee is made. Store publishing and owner credentials were outside this
  review. See YAYINLAMA.md for distribution preparation.
