# Comprehensive project review — 2026-09-07

## Outcome

The existing feature-based Flutter/Cubit structure and pure Dart engine should be retained. The highest product risk is truthful interpretation of eigen results, followed by release provenance and real-device validation. A new visual framework, backend or wholesale rewrite is not justified by this review. See [ROADMAP.md](ROADMAP.md) for sequenced, independently verifiable work.

## Scope and evidence

Reviewed current root/package manifests, documentation, architecture and source/test structure; numeric input/solve flow, timeline and playback state, practice locale/scoring, starter lessons, eigen algorithm branches, design tokens/rules and prior responsive/accessibility/performance evidence. Revisited saved catalog, player and mobile multiplication screenshots. The preceding same-day security review inspected permissions, signing, rendering boundaries and locked dependencies; its limits remain applicable.

The review separates source-confirmed findings, mathematical reproductions, screenshot-based design observations and untested device/research hypotheses. It is not a claim to have manually tested every control on every platform. No new live browser walkthrough, learner study, GPU trace or native screen-reader session was performed in this review.

## Important findings

1. Approximate 2×2 eigenvalues appear as exact Rational values and use exact-equality explanation templates. Reproduction for `[[0,2],[1,0]]`: ±707/500, with `A v - lambda v = [0,151/250000]`. Approximation is expected mathematically; its representation/wording is the issue.
2. The 3×3 root search can return a subset with successful status. `diag(1,30,40)` returns only the pair for 1. The documented search bound explains the omission, but explicit partial-result status is missing. Both cases were recorded in a probe log that is no longer retained, and are prioritized as A01.
3. Practice chooses Turkish when the explicit locale is unset, even if the resolved app locale is English; its language switch resets the quiz. These are current behavior contracts, not silently changed in this documentation task.
4. Large screen/widget files mix multiple concerns. Focused extraction is appropriate alongside feature work; size alone does not establish a bug or justify a rewrite.
5. Saved screenshots suggest avoidable desktop whitespace and mobile explanation length. These are hypotheses for live usability validation, not measured learning failures.
6. Signing, production hosting, low-end performance, complete eigenspace support, physical assistive technology and coherent learning progression remain explicit roadmap work.

## Fresh automated verification

| Check | Result | Evidence |
| --- | --- | --- |
| Root Flutter analysis | No issues | Log no longer retained |
| Application tests | 89 passed | Log no longer retained |
| Engine analysis | No issues | Log no longer retained |
| Engine tests | 34 passed | Log no longer retained |
| Eigen boundary probe | Two limitations reproduced | Log no longer retained |

The suites pass despite the newly identified eigen presentation/completeness gaps: existing green tests do not prove those cases are handled. Proposed regression tests belong to roadmap A01. No application or algorithm source was changed. Builds were not repeated for this documentation/metadata-only task; earlier web/Windows build passes remain historical. Package example and documentation link verification were also run before delivery.

## Changes in this review

- Added the English roadmap, review record and documentation index.
- Replaced the engine README scaffold with real capabilities, a runnable example and candid numerical boundaries; clarified the changelog without inventing a publication history.
- Corrected package description and removed commented template dependency/repository placeholders. No package dependency or version changed.
- Updated root README and AGENTS.md links and documented the known eigen certainty/completeness issue for future agents.
- Preserved historical reports and marked their evidence as historical.

## Cleanup

Removed 20 confirmed disposable files totaling 476,738 bytes: old browser page snapshots, superseded guided/review logs and screenshots, an older partial test log, and the temporary eigen probe script after retaining its output. Exact paths and sizes were recorded in a cleanup receipt that is no longer retained. Every resolved target was checked to remain inside the project before deletion; no recursive deletion was used.

Retained source, tests, lockfiles, platform projects, IDE/user configuration, active development caches, latest screenshots/logs, security evidence and the complete runnable release outputs. Their presence is useful working state, not evidence of dead source code. No unused source/dependency deletion was justified by this review. Generated artifacts remain ignored.

## Completion boundary

The requested review, roadmap, cleanup and English documentation update are delivered. Roadmap implementation is future work. Owner-controlled signing/hosting and real learner/device access are needed for some milestones; they do not prevent completing this review artifact.

---

# Topic verification and notation fixes — 2026-09-11

## Outcome

All 12 catalog topics were exercised in a running release web build and checked against independently computed arithmetic. The solver results were correct in every case tested; four defects were found in how those results are *presented* and all four were fixed. No algorithm, playback contract or architecture change was needed or made. The mathematical limits recorded in [MATHEMATICAL_CORRECTNESS.md](MATHEMATICAL_CORRECTNESS.md) are unchanged and remain correctly labelled in the interface.

## Scope and evidence

Two independent lines of evidence were used, deliberately not relying on the existing suites:

- **Independent arithmetic.** A throwaway harness implemented exact `BigInt` fractions, Laplace cofactor determinants, adjugate inverses and RREF from scratch, then cross-checked every solver over sizes 1–5 with integer, fractional, negative, singular and zero matrices, and over all 6561 integer 2×2 matrices in [−4, 4] for eigen. The same harness audited step structure: before/after snapshot chaining, the declared transformation actually reproducing its delta, cells badged `0` actually reaching zero, highlight bounds, and sub-calculation results matching the after snapshot. The harness was removed after the run; assertions worth keeping were re-expressed as permanent tests.
- **Live walkthrough.** Each topic was driven through `flutter build web --release` in a browser, reading the rendered accessibility tree and screenshots, with every displayed value compared against a hand calculation prepared in advance.

Limits of this pass: the browser pane did not sustain `requestAnimationFrame` while backgrounded (measured 0 fps), so continuous playback was advanced frame by frame rather than observed in real time; timing-dependent behaviour was therefore verified against a deterministic widget clock, not wall-clock playback. Only the web release build and the test suites were exercised. No Android, iOS or Windows run, no device screen-reader session and no learner study were performed.

## Corrected findings

1. **The eigen topic printed raw TeX in its step explanations.** `readableMathProse` did not convert `\begin{pmatrix}`, `\mathbf`, `\text`, `^n`, `\pm`, `\implies`, `\approx`, `\emptyset`, `\quad` or subscripts on non-ASCII letters, so a learner saw literally `For (A − 1I)v = 0, one representative eigenvector is \mathbf{v} = \begin{pmatrix}1 \\ 0\end{pmatrix}.` Twenty-one parameter values leaked across every eigen path — exact, irrational, complex, repeated and both 3×3 branches. The defect was confined to eigen: rank and LU also build TeX parameters, but their ARB messages do not interpolate them. `readableMathProse` now handles this notation; the same string renders as `… one representative eigenvector is v = (1, 1).`
2. **Eigen step titles bypassed that conversion entirely.** `StepCard` converted the description but rendered `localizedTitle` raw, as did the step-list mapping, so titles showed `Eigenvector for λ_1 = 5` — and, for irrational roots, an unconverted `\frac{809}{500}` in the title parameter. Both render sites now convert titles the same way descriptions were already converted.
3. **The 2×2 determinant conclusion left a negative operand unbracketed.** `det_2x2_final_desc` interpolated `{main} - {anti}`, producing `195 - -2 = 197`, while its own Sarrus counterpart already produced `(44) - (-16) = 60`. Both placeholders are now bracketed in all five ARB sources.
4. **Addition, multiplication and the Sarrus sums had the same defect.** Driving Matrix Addition in the browser surfaced `Added corresponding elements: 3 + -15 = -12.`; writing the regression for it exposed `-12 + -10 + 6 = -16` in the 3×3 Sarrus steps. `MatrixArithmeticSolver` and `DeterminantSolver` now bracket negative operands through a small `_operand` helper, matching the convention the elimination, LU, `InstructionLesson` and animated-cell formulas already followed. Confirmed live as `1 + (-1) = 0` and `(1 · (-2)) + ((-5) · 7) = -37`.

Findings 3 and 4 are one defect family — a negative value placed directly after a binary operator — and are covered by a single regression that rejects `+ -n`, `- -n` and `· -n` in both sub-calculations and prose across addition, multiplication, 2×2 and 3×3 determinants, elimination and LU.

## Fresh automated verification

| Check | Result | Notes |
| --- | --- | --- |
| Root Flutter analysis | No issues | |
| Application tests | 203 passed | 131 before this pass |
| Engine analysis | No issues | |
| Engine tests | 49 passed | |
| Web release build | Built | `flutter build web --release`, used for the live walkthrough |

Added suites: `test/math_prose_regression_test.dart` (no solver parameter survives prose conversion as TeX; the bracketing family above; 2×2 determinant wording in five locales), `test/playback_behaviour_regression_test.dart` (autoplay advancing only on animation completion, pause/resume, mid-operation speed change, speed clamping, manual navigation, stale-revision completions, rapid navigation, scrubbing, replay, end-of-lesson, mode switches, cell inspection, disposal), `test/topic_player_overflow_test.dart` (every topic's player at four widths in both themes, plus wide content in five languages at 320 px) and `test/rendered_topic_values_test.dart` (addition and REF values read back from the rendered widget tree).

Two of the new playback assertions initially failed against correct behaviour: a single long `pump` misattributed when a step's controller starts, because a step begins on the frame after its widget rebuilds. The tests were corrected to tick uniformly; measured step spacing is the nominal 7500 ms plus roughly 300 ms of post-frame restart latency, with no step skipped.

## Remaining limits

- Eigen boundaries are unchanged: the 3×3 search covers integer roots in [−20, 20] only, so rational non-integer eigenvalues of fractional matrices are not found; irrational 2×2 roots are rounded to three decimals with approximate vectors; complex spectra are unsupported; repeated roots yield one representative vector. Each is labelled in the result surface.
- Eigenvectors are still not divided by their greatest common divisor, despite a code comment in `EigenSolver._simplifyVector` claiming otherwise. Cosmetic; left unchanged.
- The numeric keypad appends digits to a non-empty cell, so tapping a cell holding `1` and pressing `3` yields `13`. This is the documented input contract and was not changed.
- Four of the five practice questions have the same answer position, which is guessable. Not a correctness defect; out of scope for this pass.

## Completion boundary

Verification, the four fixes and their regressions are delivered and were re-confirmed in the running application after rebuilding. Device, store and accessibility-hardware validation remain owner-controlled work already tracked in [ROADMAP.md](ROADMAP.md).
