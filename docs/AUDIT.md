# Product audit and implementation plan

> Historical implementation record. For the latest review, cleanup status and proposed work, see [PROJECT_REVIEW.md](PROJECT_REVIEW.md) and [ROADMAP.md](ROADMAP.md).

> Workspace cleanup, 2026-09-06: disposable logs, screenshots, browser recordings, backup archives, and old build caches referenced below were removed at the owner's request. Historical results are retained in this report; the underlying old artifacts are no longer included. The reusable benchmark is preserved at `tool/motion_benchmark_test.dart` (relative to the project root). Rerun checks to produce current evidence.

## Architecture and scope

Flutter Material application with Cubit state, two localized catalogs (English and Turkish), a custom numeric editor, step playback, a five-question practice flow, and a 2D transformation canvas. Twelve topics route to ten matrix operations or the two interactive features. The separate Dart matrix_engine package uses immutable matrices and BigInt rational arithmetic. There is no application backend, authentication, remote API, or persistent user-data storage in the inspected application code.

## Findings before implementation

- Input conversion silently replaces invalid fractions/decimals with zero. Resizing B does not constrain cell focus; resizing A constrains focus against A even when B is active.
- Input, practice, playback, and transform screens consume unrecognized keyboard events, interfering with Tab traversal.
- Solve has no pending state or duplicate-submission protection.
- Topic search ignores the selected category. Topic presentation repeats bordered, shadowed cards and saturated accent labels.
- Light/dark themes duplicate structure, lack a complete typography/input system, and use low-contrast muted text.
- Transform animation rebuilds the whole screen each frame and ignores reduced motion. Desktop layouts retain the vertical mobile arrangement.
- Eigen input permits unsupported dimensions. The 3x3 eigenvector calculation omits dependent coordinates. LU swap steps use an already-swapped matrix for both snapshots.
- Web metadata is template content and the manifest locks orientation despite responsive layouts.
- Android release currently uses debug signing. Actual production signing must be configured by the release owner; do not invent signing credentials.
- Existing quiz defaults intentionally differ from the app locale; preserve this behavior for regression compatibility during this pass.

## Sequence

1. Establish baseline analysis/tests and review engine, screens, shared widgets, platform configuration, and dependencies.
2. Consolidate a restrained light/dark design system: ink typography, warm neutral surfaces, blue actions, semantic instructional accents, clear focus, consistent controls.
3. Rework topic navigation as a readable catalog; refine the editor, playback explanation, quiz, and transform workspace.
4. Fix verified input, keyboard, asynchronous, mathematical, and motion issues with focused regression coverage.
5. Run application and engine analysis/tests, build web release, inspect representative responsive screens, then document remaining release limitations.

## Implementation and second audit

Completed a second pass over input boundaries, mathematical transformations, rendering, keyboard handling, responsive layouts, localization, platform configuration, and dependency versions.

### Correctness and UX fixes

- Invalid numeric strings no longer silently become zero. The UI identifies the matrix, row, and column needing correction; 32-character cell limits bound user-controlled BigInt work.
- Matrix resizing and focus selection remain within the active matrix. Eigen dimensions are constrained to the engine's supported sizes.
- Calculation displays a pending state, rejects duplicate submission, handles failures, and checks mounted state after asynchronous work.
- Already-reduced matrices now produce a viewable informational step instead of an empty player.
- Fixed dependent coordinates in 3×3 eigenvectors; tests assert `A v = lambda v` for a nondiagonal matrix.
- Fixed LU before/after snapshots and elimination factors. Tests reconstruct recorded transformations.
- Corrected reversed elimination signs in operation badges, ghost rows, and intermediate expressions; tests cover both factor signs.
- Restored ordinary keyboard traversal, paused playback during arithmetic inspection, removed inactive cell actions, and corrected duplicated input/keypad announcements.
- Added persistent topic search, combined category filtering, a recoverable empty state, theme-aware actions, localized keypad labels, and correct toggling from a system dark theme.
- Fixed input bracket height found in browser screenshots. Added scrollable short-screen input layouts and wrapping large-text controls and step titles.

### Design, motion, and performance

- Consolidated duplicated theme definitions into cached light/dark themes and a coherent typography, surface, border, input, and button system.
- Replaced repeated shadowed topic cards with a readable catalog. Reduced decorative cell glows while preserving mathematical highlighting and instructional animation.
- Isolated transformation animation to the changing canvas/readouts; static controls no longer rebuild on each animation frame.
- Expanded reduced-motion handling, corrected painter invalidation, and disposed temporary text painters.
- Added a branded startup message, loading failure/retry feedback, meaningful web metadata, and an orientation-flexible manifest.
- Retained the existing dependency set. Removing Cupertino icons produced a real release font warning, so that removal was reverted; the final build tree-shakes this font to 1472 bytes.

### Security assessment

No application authentication, authorization service, remote data API, or persistent sensitive-data storage exists in the inspected code. Account authorization and CSRF are therefore not applicable to the current local-computation architecture. User matrix input is parsed as numeric data, not executed as HTML or JavaScript. The custom bootstrap uses `textContent` for messages.

Queried 75 distinct locked public package/version pairs from the application and engine against the OSV batch API on 2026-09-05; no advisories were returned. The evidence file is no longer retained. This is a point-in-time known-advisory check, not a guarantee that dependencies are vulnerability-free. API documentation: https://google.github.io/osv.dev/post-v1-querybatch/.

### Verification

- Baseline: Flutter analysis clean; 20 application tests passed.
- Final Flutter analysis: no issues.
- Final application suite: 39 tests passed, including input boundaries, navigation, instructional signs, keyboard traversal, and all five main screens at 320×568 with 200% text in both themes/reduced motion.
- Separate engine: Dart analysis clean; 34 tests passed.
- Web release and Windows release builds succeeded during verification; final outputs and logs are in `build/` and `output-*.log`.
- Browser checks: catalog navigation, search, dark theme, editor, identity-matrix playback, transform layout, and zero-denominator validation. The checked release session reported zero console errors and warnings. Screenshots: `output/playwright/`.

### Remaining release boundaries

- Android release signing is still the existing debug signing configuration. Production signing requires the owner's key; no signing identity was fabricated.
- Android/iOS/macOS builds and physical-device screen readers were not tested here. This is not a certification of WCAG 2.2 AA, field Core Web Vitals, or native-store readiness.
- Eigen analysis retains documented approximation/root-search limits. Session settings retain their existing nonpersistent behavior, including the established default quiz language.
- The web app can calculate without a backend once loaded; a first visit still depends on hosted runtime assets. Full offline PWA installation and hosting security headers require deployment-specific verification.
- The workspace has no Git repository, so no commit or branch diff was produced.


## UI and instructional-motion follow-up — 2026-09-06

The accepted interface and animation plan has now been implemented across the catalog, editor, step player, transformation visualizer, and practice screens. The earlier verification counts above describe the first implementation stage. Current application validation is 75 passing tests and clean Flutter analysis; the unchanged engine has 34 passing tests and clean Dart analysis.

See [UI_MOTION_REVIEW.md](UI_MOTION_REVIEW.md) for the final build results, responsive and playback coverage, screenshot evidence, measured before/after debug animation costs, and remaining device/release limitations. Design rules are recorded in [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md). Its evidence directory is no longer retained.
