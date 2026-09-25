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

---

# Quality pass: dead code, localization, colour and performance — 2026-09-11

## Outcome

A cleanup and quality review following the same-day topic verification above. Dead localization was removed, one genuine Turkish grammar defect was fixed, and the README was rewritten as a bilingual document. Colour, performance and security were measured rather than adjusted: none of the three produced a defect that justified changing working code, and nothing was changed to look busy. No algorithm, playback contract or architecture change was made.

## Scope and evidence

- **Dead code.** `dart analyze` and `flutter analyze` are clean, but they only report unreferenced *private* elements. A separate scan cross-referenced every ARB key, asset path and declared type against all Dart sources in `lib/`, `test/`, `tool/` and the engine. Its limit: it counts textual references with word-boundary matching, not compiler-grade reachability, so it can produce false positives — two of which it did (below).
- **Animation.** A new suite drives every topic to completion at every supported matrix size.
- **Colour.** WCAG contrast computed from the `AppTheme` tokens, first against a text threshold and then — after reading how each colour is actually applied — against the thresholds that match its real use.
- **Performance.** The existing `tool/motion_benchmark_test.dart` harness.
- **Security.** All 58 locked hosted package/version pairs queried against the OSV batch API on 2026-09-11, plus a staged-content credential scan before publishing.

Limits: web release build and test suites only. No Android, iOS, Linux or macOS run, no device screen-reader session, no GPU trace and no learner study.

## Changes in this review

1. **Removed 37 unreferenced ARB keys from all five locales** (185 entries). Each was confirmed absent from every Dart source, including the string-keyed resolver switches in `step_player_screen.dart` that reference message keys as literals.
2. **Localized the application title.** `appTitle` was translated in all five locales but never used, while `MaterialApp` hard-coded an English string — a localization gap rather than dead code. `MaterialApp` now resolves it through `onGenerateTitle`, and the `en`/`tr` values were normalized to the `Matriks · …` brand pattern that `es`, `ru` and `zh` already followed.
3. **Fixed Turkish suffix agreement.** Three strings attached a fixed suffix to an interpolated number — `Satır {row}'yi Sadeleştir`, `Satır {rowB}'yi Değiştir` and `Satır {target}'nin …`. In Turkish the suffix follows the number's pronunciation (1'i, 2'yi, 3'ü, 4'ü, 5'i), so a fixed suffix is correct only for 2, and every size from 1 to 5 occurs. The strings were reworded so the suffix falls on the following noun, matching the pattern `step_row_elimination_title` already used. Turkish was the only affected locale; `en`, `es`, `ru` and `zh` have no placeholder-adjacent suffixes. Both reworded titles were confirmed in the running application.
4. **Added `test/animation_quality_all_sizes_test.dart`** — 52 cases covering every topic at every supported size plus rectangular shapes, asserting each lesson reaches its last step unaided, skips no step, stops when finished, and throws nothing in either theme.
5. **Rewrote `README.md`** as a bilingual English/Türkçe document with symmetric sections, explicit numerical boundaries and an honest statement of which build targets are validated.

## Measurements that did not lead to a change

- **Colour.** An initial pass flagged nineteen accent/surface pairs as failing, but it compared them against the 4.5 text threshold. Reading `matrix_cell_widget.dart` showed the accents are never the cell's text colour: they are the cell **border** and the **badge fill**, with badge text chosen adaptively by luminance. Re-measured against the thresholds that apply, borders score 3.13–4.24 against the outer surface in both themes (non-text threshold 3.0) and badge text scores 4.61–5.76 against its fill (text threshold 4.5). Every combination passes and no colour was changed. Role colours are separated by hue rather than luminance (pairwise contrast 1.02–1.26), which is a deliberate equal-weight choice; role is additionally carried by badge text and by semantic labels, so it is never conveyed by colour alone.
- **Performance.** The 5×5 elimination benchmark measured 1407 samples, median 2.349 ms and p95 4.361 ms per test pump, against a historical p95 of 6.776 ms recorded in [GUIDED_UX_REVIEW.md](GUIDED_UX_REVIEW.md). This is debug-build widget rebuild cost on an uncontrolled machine, not GPU frame time and not a frame-rate guarantee. The player's per-step caches are already bounded and invalidated on dependency change; nothing was restructured.
- **Security.** OSV returned no advisories for any of the 58 locked packages. No keystore, `.env`, certificate or credential file is tracked; the content scan's only matches were prose such as "design tokens" and an unrelated `revision token` identifier. Android release still builds with the debug signing configuration, as previously recorded.

## False positives caught before deletion

The reference scan reported two groups as unused that are not, and both were verified before anything was removed:

- The five `assets/flags/*.png` files are loaded through an interpolated path, `assets/flags/${entry.key}.png`, so no literal filename appears in source.
- Engine types such as `LinearSystemResult`, `LUResult` and `Eigenpair` have no call site in the application, which consumes the LaTeX result strings instead. They are the public API of a standalone package and are named in the engine boundaries in [../AGENTS.md](../AGENTS.md); deleting them would have removed documented library surface.

## Fresh automated verification

| Check | Result | Notes |
| --- | --- | --- |
| Root Flutter analysis | No issues | |
| Application tests | 255 passed | 203 before this pass |
| Engine analysis | No issues | |
| Engine tests | 49 passed | |
| Web release build | Built | used for the live Turkish confirmation |
| Dependency advisories | 0 for 58 packages | OSV batch API, 2026-09-11 |

## Remaining limits

- Carried forward unchanged from the verification pass above: eigen search and rounding boundaries, eigenvectors not reduced by their greatest common divisor, the keypad appending digits to a non-empty cell, and the repeated answer position across four of the five practice questions.
- The dead-code scan is textual. A public symbol referenced only through reflection, a generated binding or a string built at runtime would not be detected as used; the two false positives above show the failure mode, so any future removal should be verified the same way.
- Role colours remain hue-differentiated with near-equal luminance. This is acceptable because text and semantic labels carry the same information, but a future palette change should preserve that redundancy rather than rely on hue.

## Completion boundary

The cleanup, the localization fix, the animation suite and the README are delivered, verified by the full suites and confirmed in a rebuilt web application. Device, store and accessibility-hardware validation remain owner-controlled work tracked in [ROADMAP.md](ROADMAP.md).

# Publication: GitHub Pages, CI and repository metadata — 2026-09-11

## Outcome

The web build is published at <https://iacbi.github.io/matriks/> and rebuilt by a workflow on every push to `main`. Publishing it exposed a defect that every previous pass had missed, and that defect is the substantive result of this review — the infrastructure is the smaller half.

The repository was made public. It could not stay private and carry a site: GitHub Free covers "GitHub Pages in public repositories" only, and the attempt to enable Pages on the private repository returned `422 Your current plan does not support GitHub Pages for this repository`. A site published from a private repository would not have been private either — access control requires an organization on GitHub Enterprise Cloud — so the choice was between a paid plan and a public repository, and the owner chose public.

## The defect found by publishing

The eigenvector heading read `λ_1 = 1 için Özvektör` on the live site: a literal underscore where a subscript belongs.

The cause is that `eigen_vector_title` is `"λ_{index} = {lambda} için Özvektör"`, where the braces are an ICU placeholder rather than a TeX group. After localization the title is `λ_1`, which needs the same prose conversion as every other displayed string.

The earlier notation pass wrapped `StepCard`'s title in `readableMathProse`. Both layouts in `step_player_screen.dart` construct `StepCard` with `showTitle: false`, so that title is never drawn. The headings the reader actually sees are two separate `Text(title)` widgets in the screen, and neither was wrapped. The fix converts the title where it is resolved, which covers both headings, the card and the step list at once and leaves no fourth call site to forget.

`math_prose_regression_test.dart` could not have caught this. It exercises `readableMathProse` directly, and that function was correct throughout — it converts `λ_1` to `λ₁` when it is called. The gap was a display path that never called it. `rendered_prose_regression_test.dart` closes that gap by reading strings back out of the rendered widget tree for eight lessons in English and Turkish and rejecting backslash commands, brace groups and bare sub/superscripts in what is drawn. It was confirmed to fail in five places with the fix removed, including an explicit assertion that a real `λ₁` appears.

The general lesson is worth recording: a test that calls a conversion function proves the function, not the screen. The two earlier notation defects were found by looking at the running application, and so was this one.

## Diacritic-insensitive topic search

Noticed while driving the published site: typing `Ozdeger` found nothing, because the filter compared `toLowerCase()` on both sides and `ozdeger` is not a substring of `özdeğerler`.

Looking at it turned up a larger problem than the missing accents. `String.toLowerCase` applies the Unicode default mapping, which is not Turkish: `"IŞIK".toLowerCase()` is `işik`, while `ışık` is already lowercase and stays as it is. The same Turkish word typed in upper and lower case therefore did not match itself, in the application's own primary language.

`foldForSearch` in `lib/features/topics/search_fold.dart` folds case and strips marks on both the query and the searched text. It covers the Turkish letters, the Spanish accents, the Latin ligatures, Russian ё, and combining marks in the U+0300–U+036F block so decomposed input folds the same as composed. It deliberately does not merge и and й: those are separate Cyrillic letters and folding them would return wrong topics, whereas ı and i folding together is what a reader typing on an English keyboard expects.

No dependency was added for this. `diacritic` would have done it, but a thirty-line table covering five supported locales does not justify one.

Coverage is split on purpose. Seven unit tests pin the folding rules, including the asymmetry that motivated the change, and four widget tests drive the topic list itself. Only the widget tests can see whether the screen actually uses the helper, and they are the two that fail when the wiring is reverted; the English test keeps passing, which is the point.

## Continuous integration

`.github/workflows/ci.yml` runs two jobs. `verify` resolves both packages, regenerates localizations and fails if `lib/l10n/generated` differs from the ARB sources, then analyzes and tests the application and the engine. `deploy` depends on it and runs only outside pull requests, so a failing analyzer or test cannot ship.

Two build decisions are deliberate:

- The base href comes from `configure-pages`' `base_path` output rather than a literal `/matriks/`, so renaming the repository or moving to a custom domain needs no edit.
- `--no-web-resources-cdn` is passed. The default web build fetches CanvasKit from `gstatic.com`, which contradicts the README's statement that the app makes no network calls. The build now serves it from the site itself.

One third-party request remains and is not removable at reasonable cost: CanvasKit fetches a Noto Sans face from `fonts.gstatic.com` for glyphs the bundled font does not cover. This is Flutter's own fallback mechanism, not application code. It is recorded here rather than described as zero.

## Verification actually performed

| Check | Result |
| --- | --- |
| Sub-path build served locally at `/matriks/` | Boots, navigates, animates; 31 resources, all same-origin except the font fallback; no console errors |
| Live site at `iacbi.github.io/matriks` | Same, confirmed in the browser; solving an eigen lesson there is what exposed the heading defect below |
| CI `verify` job on Ubuntu | Passed — analysis, 255 application and 49 engine tests, no l10n drift |
| CI `deploy` job | Passed |
| Application tests after the title fix | 272 passed, no regression |
| Application tests after the search fix | 283 passed, no regression |
| Topic search tests without the wiring | The two Turkish cases fail, the English case still passes |
| Rendered prose test without the fix | Fails in 5 places, as a regression test must |
| Live site after the fix | The heading reads `λ₁ = 1 için Özvektör`; the character is U+2081, read out of the accessibility tree rather than judged from a screenshot |

## Repository metadata

Description, 15 topics, the site URL, an Apache-2.0 `LICENSE` with the canonical text from the licences API rather than a retyped copy, `CONTRIBUTING.md`, `SECURITY.md`, a bug-report form and a pull request template. The README gained License and Lisans sections, the demo link and a licence badge in both languages.

`SECURITY.md` states the real surface — no backend, so reports concern dependencies, the input bounds, and the published site — and repeats the two known limits rather than implying there are none: Android release builds still use the debug signing configuration and the inspected Windows executable is unsigned.

A code of conduct was deliberately not added. For a single-maintainer project it would promise an enforcement process that does not exist, which is worse than its absence; it is a two-minute addition whenever that changes.

## Limits of this pass

- The commit history carries the maintainer's address in the author field. It was already visible in other public repositories of the same account, so publication added no exposure, but changing it for existing commits would require rewriting history and was not done.
- A social preview image can only be uploaded through the web interface and is still unset.
- No release is tagged. `pubspec.yaml` reads `1.0.0+1`; whether that constitutes a release is the owner's call.
- Publication is not a correctness claim. The numerical limits recorded in the sections above are unchanged, and the app states them in its own interface.


# Review and improvement pass — 2026-09-24

Branch `claude/keen-darwin-oettj2`. A full read of the application, engine, tests, CI and documentation, followed by fixes. The session container could not reach `storage.googleapis.com` or `pub.dev`, so no Flutter SDK ran locally; every check below ran in GitHub Actions on the branch through manual workflow runs. Localization output was regenerated with a script that first reproduced all six committed generated files byte for byte; CI's `flutter gen-l10n` diff then confirmed each change.

## Defects fixed

- Addition and multiplication cells carried their result as a LaTeX badge that was drawn as plain text (`\frac{7}{2}`). A completed zero drew two badges in the same corner.
- Uncomputed entries of a product or sum displayed `0`, which reads as a result. They now show a placeholder and are announced as not calculated.
- The decimal view rounded to two places through `double`: nonzero pivots such as 1/1000 read `0.00`, and values beyond the double range became NaN. It now rounds with integer arithmetic, is exact when the expansion terminates within four places, marks everything else with ≈ and switches to scientific notation instead of showing zero.
- 3×3 eigen analysis only tried the integers −20…20, so `diag(1, 30, 40)` was partial and fractional or irrational roots were missing. See MATHEMATICAL_CORRECTNESS.md.
- Pressing the sign key twice emptied the cell. Solve failures showed exception text. A preset's snackbar covered the player's controls after solving (found by the flow tests).
- The prediction card always placed the correct multiplier in the middle; quiz answers were B in four of five questions.
- The player's progress bar used the light-theme blue in dark mode (2.2:1 against the surface) and ignored the accent palette.

## Animation and interface changes

Stable per-solution geometry, column-scaled row-operation time (unchanged up to three columns), fade-through cell text, reflow-free multiplication operands, Sarrus with copied columns and faded finished diagonals, a static swap connector that no longer repaints every frame, phase announcements only while paused, a lesson-complete card, no play button in static steps, locale-formatted speeds, catalog entries that switch tabs instead of opening duplicate screens, expanded starter lessons, a bottom-navigation indicator that does not rely on colour, topic-aware random presets with undo, an explained B row lock, one key per keypad action, a transform canvas with the untransformed grid, fit-to-view zoom, eigenvector directions and matching colours, a speed setting saved on release, and a consistent informal register in Turkish. Details are in DESIGN_SYSTEM.md.

## Code changes

Topic titles, step texts and solver errors resolve through exhaustive switches in one place each; `SettingsState` has value equality; preferences load before the first frame; the bundled logo is 23 KB instead of 901 KB. Removed `TopicItem.color`, `MatrixInputState.errorMessage`, `QuizBank.questions`, `DeterminantCofactorTransformation`, four unused theme colours, two shadow helpers and the `solveError` string.

## Verification

| Check | Result |
| --- | --- |
| Baseline before changes (run 36034661200) | Passed |
| Final branch head `08547d0` (run 36037856873) | Generated localizations current; analysis: no issues; 301 application and 55 engine tests passed; web release built and uploaded as the `web-preview` artifact |
| Intermediate run 36037443385 | 3 failures, fixed in `08547d0`: two flow tests blocked by the preset snackbar, one test with a wrong starting value |
| New tests | `step_text_test.dart` resolves every step text of every solver branch in five languages; `improvement_regression_test.dart` covers the defects and behaviour above; engine tests cover exact, deflated, irreducible, complex and oversized 3×3 spectra and exact decimal text |

## Not done, and why

- The interface was not inspected on a device or in a browser in this pass; the web preview artifact exists for that review.
- The collapsed operation inspector still rebuilds its slider every frame: existing tests read playback progress from it. The saving was not measured.
- The prediction pause is still scheduled from `build`; moving it changes timing that tests pin, for an unmeasured benefit.
- Step texts are still string keys with untyped parameters. A sealed narrative type in the engine would make them compile-time checked; the new coverage test is the interim guard.
- No stricter analyzer rules were added: `strict-casts` would flag the untyped step parameters throughout.
- Guided multiplication of 5×5 matrices still takes several minutes at 1×; shortening later entries should follow the learner study in ROADMAP B01.

## Solution animation pass — 2026-09-24

Every solver's steps were replayed in code against what the player shows. Logic errors found and fixed:

- Row operations animated columns they cannot change (`0 − 2·0`) and spent 1.2 s on each. Only changing columns are animated and timed now.
- Determinant formula steps coloured cells as pivot/source/target and listed the same products three times (cell list, phase explanation, description). The closing step re-animated all diagonals although it only adds two totals; it is now a one-contribution recap.
- The 2×2 inverse jumped from A to adj(A) and to A⁻¹ with no visible operation. It now animates the adjugate (a and d swap, b and c change sign) and the 1/det scaling one entry at a time.
- LU eliminations showed only U; the multiplier written into L was never visible, and the result named only U. L is now shown beside U, and the result names P, L and U.
- Block inverse extraction showed A⁻¹ alone, so the step appeared to change the matrix. It now shows [I | A⁻¹] with the right block marked.
- Eigen, rank and linear-system summaries marked non-pivots as pivot or target. Only real pivots are marked; eigenvector steps state that the matrix shown is A − λI.
- Steps without a specific lesson showed empty source/operation/result phases; they now show only the description. The step description is hidden where the phase explanation already says the same thing.
- Three Turkish step titles did not say what the step does (swap, scale, eliminate); they now do.
- Rounded eigenvalues printed as fractions (λ ≈ 809/500 for 1.618); they now print as decimals, and exact values keep fractions. The eigenvector description substituted λ after a minus sign ("A − -4I"); all five languages now state λ separately.

Verified in CI run 36045673392 on `fe3835b` (earlier: 36044859287 on `187a64d`): generated localizations current, analysis clean, all application and engine tests passed, web preview built. Two intermediate runs failed and were fixed: an eigen caption stored as TeX among the prose parameters (it printed `A - 1I`), and a value test that read the addition step before its animation had started. The new behaviour is covered by `packages/matrix_engine/test/step_semantics_test.dart` and `test/animation_logic_test.dart`. Not inspected on a device.

# UI and learning-path pass — 2026-09-24

## Outcome

Continuing on branch `claude/keen-darwin-oettj2` after the solution animation pass above: an independent property-based check of every solver, a redesigned step player (one centred stage instead of a split panel layout, two-hue role colours, a single `Details` drawer, one app bar menu), a simplified Settings screen with one brand colour, a learning-path catalog with topic glyphs and progress tracking, generated practice rounds, and an independent result check shown after solving. CI now also fails on unformatted Dart.

## Changes

- **Solver verification.** `packages/matrix_engine/test/solver_properties_test.dart` checks every solver on seeded random matrices (a third rank deficient) against independent reference implementations: cofactor determinant against every `DeterminantMethod`, A·A⁻¹ = A⁻¹·A = I, a schoolbook sum/product, a unique RREF and row-echelon/row-equivalence for REF, P·A = L·U with unit lower L and upper U, rank/nullity/pivot columns against an independent RREF, linear-system type by ranks and Ax = b for unique solutions, and eigenpairs Av = λv exactly or a sign change of the characteristic polynomial within ±0.0005 of a rounded eigenvalue. It also replays every row-operation step's before snapshot into its after snapshot, chained across a solution.
- **Player redesign.** The step player is a single centred stage column (max width 880) at every screen width instead of splitting side-by-side at ≥960 px. `MatrixDisplayGrid` now also hosts the scene formula, the role legend under the matrix, the phase caption (one sentence fading between phases, three phase dots instead of a "1 / 3 · phase" count), the solver's "why" note (only when the caption does not already say it), and one `Details` drawer (rationale, per-cell calculations, scrub slider, replay) that pauses the lesson when opened. Row-operation highlights use two hues: amber for the row used (heavier for the pivot, thinner for the source), cyan for the row that changes (target; a finished zero keeps a cyan "0 ✓" badge). Purple and green no longer mark roles, and `AppTheme.accentPurple` was removed. The app bar's result/mode/decimal controls are one overflow menu (`player-menu`).
- **Settings simplified.** The accent-palette setting and `AccentPalette` enum are gone — one brand blue, because the removed teal/purple collided with the role colours above. Language, theme, predictions and reduced motion stay in view; solution mode, speed, explanation level, number view and density move under a collapsed "More options". `SettingsState` persists the last opened topic and finished topic names (JSON stays version 1); `reset()` keeps that progress, `resetProgress()` clears it.
- **Learning path.** `TopicItem.pathOrder` orders and numbers the twelve topics (entry-wise operations, elimination, what elimination enables, eigenvalues, geometry, review); each shows a `TopicGlyph` drawing instead of a generic icon (`TopicItem.icon` was removed); finished topics get a check mark, a progress line, and a "Continue where you left off" card. A topic is recorded finished when its lesson reaches the last step (guided or static-steps mode, not when jumping to the result), a practice round ends, or a transformation is played.
- **Generated practice.** `QuizGenerator` builds five-question rounds from four kinds (2×2 determinant, the multiplier that zeroes an entry, entry (1,2) of A·A, 2×2 inverse), every kind once plus one random, with options and feedback shuffled together; each wrong option names a misconception. "New questions" in the completion dialog starts a round; a round rebuilds from its seed on language change.
- **Result checks.** `result_check.dart` recomputes each result independently in exact arithmetic (A·A⁻¹ = I; the determinant by the other kind of method; L·U = P·A; Ax = b; rank + nullity = n; Av = λv per exact eigenpair), and `ResultChecks` shows it on the result screen and after a finished lesson. A 2×2 eigen result also offers a link into the transform visualizer with the same matrix, when every entry is within [-1000, 1000].
- **CI.** `.github/workflows/ci.yml` runs `dart format` over every tracked Dart file except `lib/l10n/generated` as the last `verify` step, after tests and the web preview build, and fails on any diff.

## Verification

| Check | Result |
| --- | --- |
| Property tests (`bd21e951`) | CI run 36053895756 |
| Player redesign (`b28585f9`) | CI run 36054540964 |
| Settings simplification (`8f9ad552`) | CI run 36054969977 |
| Result checks and transform link (`32ce54b1`) | CI run 36055456517 |
| Final branch head `7e31202` (run 36057342430) | Generated localizations current; analysis: no issues; 320 application and 70 engine tests passed; web preview built; formatting check: 0 of 107 files changed |

## Not done, and why

- No browser or device inspection: this session's container could not reach `storage.googleapis.com`, `pub.dev`, `*.blob.core.windows.net` or GitHub Pages, so the interface was verified only by widget tests, not a running build.
- Completion is recorded per topic, not per matrix: replaying the same topic with different numbers does not change its "finished" state.
- Generated practice covers four question kinds, not the full topic catalog.

# Browser review — 2026-09-24

## Outcome

Continuing on branch `claude/keen-darwin-oettj2`, this pass did what the previous one could not: it drove a real, locally built release web app in a browser (Chromium via Playwright) rather than widget tests alone, in light and dark themes, at 1280 px and 390 px, in Turkish and English. It found and fixed thirteen defects, the most consequential being missing glyphs — boxes in place of arrows, sub/superscripts and math symbols (A⁻¹, R₂, ←, ⟹, ∅, ✓) used throughout step prose, because the web build's bundled Roboto does not include them and Flutter fetched a Google-hosted Noto face to cover the gap.

## Scope and evidence

`flutter build web --release` was built locally and driven with Playwright's Chromium. Every fix below was confirmed against the running build, not inferred from source reading alone. Limits: no physical device and no screen-reader session were used — the accessibility tree was read through Playwright, not through a native reader — and 200% text scaling was covered only by the existing widget tests in this pass, not re-driven in the browser.

## Fixes

1. **Missing glyphs.** The bundled `assets/fonts/MatriksSymbols-Regular.ttf` (57 KB, a DejaVu Sans subset renamed as its Bitstream Vera license requires — `assets/fonts/LICENSE-MatriksSymbols.txt`, registered in `lib/main.dart` via `LicenseRegistry`) is declared in `pubspec.yaml` and used as `AppTheme.symbolFallback` (`fontFamilyFallback`) across the text theme and explicit theme styles. `tool/build_symbol_font.py` rebuilds it and needs `fontTools`. In the en/tr build, no request to `fonts.gstatic.com` was observed. Chinese text (and the language menu's 中文 label) still makes Flutter download CJK glyphs from Google Fonts — recorded in a `.github/workflows/ci.yml` comment rather than presented as fixed, since a bundled CJK font would add megabytes. The zero badge's check mark is now an `Icon` instead of a glyph that needed the same fallback.
2. The phase caption (`InstructionExplanation`) is start-aligned like its phase dots and calculations, via an `AnimatedSwitcher` layout builder; it previously centred while its neighbours were start-aligned.
3. Calculations bracket only a negative operand (`5 - 2 · 2 = 1`, `5 - (-2)`); the elimination operation label reads `R₂ ← R₂ − 2R₁` with no brackets around the factor; a diagonal/Sarrus product omits a leading factor of 1 and starts at the first real product, and its timeline now counts the same number of lines it draws.
4. Wrapped formulas (`MathText(wrapLines: true)`) now split at top-level ` + `, ` - `, ` = `, ` \approx ` via a new `splitTexTerms` helper (respecting brace groups and `\left…\right`) and prefix each later piece with `{}` so TeX keeps its operator spacing, replacing an earlier `texBreak` that could split inside a group.
5. `MathText` exposes a readable semantics label, `mathSemanticsLabel` (built on `readableMathProse`), so a screen reader hears "1/2" instead of a run of glyphs.
6. At 390 px, a 3×3 elimination hid its third column: the 120 px operation reserve per cell is now capped at the width actually available per column, never below the value's natural width; a formula that still does not fit shrinks to 14 px and then scrolls inside its cell instead of pushing a column off-screen.
7. **Result screen** (`widgets/solution_summary.dart`): the matrix grid is now shown only when the result actually is a `Matrix` (inverse, RREF/REF, sum, product); the TeX result line is shown only for other results, split at `\quad` into parts that wrap. Previously the inverse repeated the matrix with overlapping fractions, and LU/eigen results showed an unlabelled final matrix underneath the answer.
8. The eigen check now reads "= v₁" / "= -v₁" / "= 2 v₁" — coefficients of 1 and −1 are omitted rather than printed literally.
9. The transform view opened from a 2×2 eigen result now plays into the transformed matrix immediately, instead of opening on the untransformed frame.
10. The player menu's "Show result" item now has a leading icon, so it aligns with the checked mode items beside it.
11. **Every input topic now opens on a small worked example instead of the identity matrix** (`lib/features/matrix_input/matrix_input_cubit.dart`, `_example`), whose steps and eigenvalues taught little: eigen `[[4,1],[2,3]]` (eigenvalues 2, 5), inverse `[[1,2,3],[0,1,4],[5,6,0]]` (determinant 1), a linear system with solution (5, 3, −2), and small 2×2 pairs for multiplication/addition.
12. Settings' "More options" `ExpansionTile` is now wrapped in `Semantics(container: true)`; in the web build its tap target had merged into the whole "Learning & playback" card, making the row unreachable as its own control.
13. Two Turkish quiz explanation typos were fixed: "1 dir" → "1'dir", "2 dir" → "2'dir" (Turkish suffix agreement, the same family of defect recorded in the 2026-09-11 quality pass above).

## Verification

New coverage: `test/ui_review_regression_test.dart` (9 tests) pins the fixes above at the widget level.

| Check | Result |
| --- | --- |
| Local run, Flutter 3.47.1 | Generated localizations current; analysis: no issues; 329 application and 70 engine tests passed; `dart format` reported 0 files changed |
| CI run 36061622424 on `04921ed` | Green |
| CI, final branch head `cd0c343` | run 36062536242: every step passed (localizations current, analysis, app and engine tests, web preview build, formatting check) |

## Remaining limits

- No physical device or native screen-reader session was used; the accessibility tree was read through Playwright's automation API.
- Chinese text still triggers a Google Fonts (`fonts.gstatic.com`) request for CJK glyphs — recorded, not fixed, since bundling a CJK font would add megabytes to the web build.
- 200% text scaling was exercised only by the existing widget test suite in this pass, not re-driven against the live browser build at 1280/390 px.

## Completion boundary

The thirteen fixes above and their regression coverage are delivered and verified against a rebuilt release web app and the full test suites. Native screen-reader, physical-device and further text-scaling verification in the browser remain open, as stated above.

# Local review on a developer machine — 2026-09-25

## Outcome

Branch `claude/keen-darwin-oettj2`, checked on Windows 11 with Flutter 3.47.1 where the cloud sessions could not run anything. The release web build (`flutter build web --release --no-web-resources-cdn`) was served locally and driven with Playwright in the installed Chrome; the Windows release build and an Android release APK on an emulator (Pixel-class, 1080×2400, 420 dpi) were also run. Fourteen defects were found and fixed, each with a regression test in `test/local_review_regression_test.dart` that fails on the previous code.

## What was checked, and how

- **Every tab and one full lesson per topic** (addition, multiplication, REF, RREF, linear system, determinant, inverse, rank, LU with and without a row swap, 2×2 eigen) in guided mode, static steps and the result view, in the browser at 1280 px, with screenshots of every step.
- **Widths** 320, 600, 960 and 1440 px in light and dark themes; **200% text** (root font size 32 px, which Flutter web reads as its text scale) at 320 and 1280 px; **reduced motion** (Chrome's `prefers-reduced-motion`).
- **All five languages** on the home screen and a lesson; requests to other origins were logged, and Chinese was reloaded with `fonts.gstatic.com` blocked.
- **Keyboard only**: Tab order on the home screen, input by keyboard, player shortcuts (Space, arrows, Home/End, R, S), practice (A–D, Enter) and transformation (P) shortcuts.
- **Accessibility trees**, not a screen reader: the web semantics DOM (roles, labels, `aria-description`), the Windows UI Automation tree read through `UIAutomationCore`, and the Android tree through `uiautomator dump`.
- **Behaviour**: pause/resume, Next while paused (plays one step, does not resume), scrubbing and replay in Details (opening it pauses), speed change and a 1280→390→1280 px resize mid-lesson (position kept), the continue card and completion marks after a reload, New questions, and See it as a transformation from the 2×2 eigen result.
- **Mathematics by hand**: the 3×3 inverse of [[1,2,3],[0,1,4],[5,6,0]] = [[−24,18,5],[20,−15,−4],[−5,4,1]]; det [[2,−1,3],[1,4,0],[5,2,1]] = −45 (Sarrus 14 − 59); LU of [[0,1,1],[1,2,1],[2,7,9]] with P swapping rows 1 and 2, L = [[1,0,0],[0,1,0],[2,3,1]], U = [[1,2,1],[0,1,1],[0,0,4]]; eigenpairs of [[4,1],[2,3]]: λ = 5, v = (1, 1) and λ = 2, v = (1, −2); the linear system's solution (5, 3, −2); a generated 2×2 inverse question. All matched the app.

## Defects fixed

1. The speed read "Speed: 1××" in Settings, the speed menu and its tooltip: the ARB strings and `formatSpeed` both appended ×.
2. The result's Exact/Complete chips were announced as unchecked checkboxes on the web (`RawChip` sets `checked` on web); they are now plain labelled text.
3. Consecutive elimination steps had identical titles ("Eliminate Entry in Row 3" twice in the step list); titles now name the pivot row ("… using Row 1").
4. The four size buttons were all "Decrease/Increase dimension"; they now say "Remove a row", "Add a column", etc.
5. Screen-reader labels of formulas kept TeX: `\det(A)`, `A_2,2`, `A^-1`, `(1 & 0 & 0, …)`. `mathSemanticsLabel` now reads operator names, comma subscripts, signed superscripts, matrix rows and general fractions; a test sweeps every formula rendered across all lessons and results.
6. "1 free columns" and "(1 Free Variables)" in English and Spanish, "1 свободных переменных" in Russian, now use ICU plurals.
7. The "0 ✓" zero-result badge also marked target-row entries that were already 0 and did not change; only a zero the operation produced is marked.
8. An eigen result repeated "A only stretches v: Av equals λv." once per eigenpair.
9. Every eigen result said a full eigenspace basis is not computed, beside a "Complete" label, even for distinct eigenvalues; the note now appears only when an eigenvalue is repeated.
10. Quiz options were announced only as "A", "B", …: the formula sat in a horizontal scroll view outside the button's label.
11. Bottom navigation labels broke inside words at 320 px ("Transformati/ons") and all of them at 200% text; a label now shrinks to fit on one line.
12. Chinese category chips on the Topics screen were faded along the bottom. A diagnostic build showed the label had room but reported an overflow: it had been laid out before the CJK fallback font arrived, and the chip's `TextOverflow.fade` kept the stale result. Chip labels no longer fade.
13. Tab alternated between the navigation rail and the page by vertical position; each is now its own focus traversal group.
14. Topic rows were exposed to Windows UI Automation as text without an invoke action; they are now buttons.

## Verification

Local: generated localizations current, `flutter analyze` clean, 344 application tests and 70 engine tests pass, `dart format` reports no changes. Fixes 1–5 and 7–13 were re-checked in a rebuilt release web app, 14 in the Android accessibility tree.

## Not checked, or left as is

- No screen reader (NVDA, Narrator, TalkBack) was run; only the accessibility trees above were read.
- Windows desktop: launch, home screen, dark theme following the system, and the UI Automation tree were observed; lessons could not be driven there without taking over the mouse. The navigation rail's destinations are still exposed to UI Automation as text: that comes from Flutter's `NavigationRail`, not the app.
- No physical phone was used; Android was checked on an emulator only.
- Offline, Chinese renders as empty boxes: its glyphs still come from `fonts.gstatic.com` at runtime (14 Noto Sans SC slices on the home screen). Bundling a subset of the characters the Chinese strings use would fix this; it was not done without a decision on the added asset.
- An augmented 3×6 matrix ([A | I]) scrolls horizontally on phones (320–411 px) instead of fitting.
- With the shrink-to-fit fix, "Transformations" at 320 px and every label at 200% text are smaller than the other text in the bar.
- Blue "selected" outlines (the solution column, the A − λI diagonal, the extracted inverse) have no legend entry.
