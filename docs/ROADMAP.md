# Matriks product and engineering roadmap

Reviewed: 2026-09-07; evidence table refreshed 2026-09-24, including the later same-day "UI and learning-path pass" (see PROJECT_REVIEW.md). Status: proposed implementation backlog, not implemented functionality.

## Direction

Build a trustworthy teaching workspace for learners who need to understand matrix operations and for returning users checking calculations. Preserve Flutter/Cubit, exact arithmetic where supported, all existing operations, all five languages and both themes. Prioritize truthful mathematical results and release reproducibility before new visual effects or feature breadth. No backend, account system, new dependency or architectural rewrite is a prerequisite.

## Evidence and current assessment

| Area | Current evidence | Gap and consequence |
| --- | --- | --- |
| Mathematics | Separate exact Rational engine; ResultAccuracy/ResultCompleteness on every solution; 3×3 rational roots exact, irrational roots bracketed (2026-09-24) | Complex eigenvectors and eigenspace bases for repeated roots are not computed; 3×3 coefficients beyond 1e12 fall back to an integer search |
| Learning | Three starter lessons, phase explanations, progressive contributions, option-specific feedback, and (2026-09-24) a numbered `TopicItem.pathOrder` learning route with a "Continue where you left off" card | The route orders existing topics; it adds no prerequisite text, objective or next-action framing (see C01), and has not been evaluated with learners |
| Catalog | Search and categories combine correctly; topics are numbered along the learning path and show a `TopicGlyph` drawing and completion state (2026-09-24) | The introductory region and filters consume significant space in the saved desktop capture; novice versus returning-user priorities need validation |
| Player | One playback authority, revision guards, adaptive timing, reduced motion and scrubbing tests; (2026-09-24) rebuilt as a single centred stage column with a merged `Details` drawer, replacing the split desktop panel | Mobile multiplication still expands into several formula rows and requires scrolling; the new layout has not been checked live in a browser or on a device (see B02) |
| Input | Bounded dimensions and 32-character numeric entry, cell errors and duplicate-submit protection | No saved work or bulk paste flow; retain existing safety boundaries if either is added |
| Practice | Five authored questions in five languages, hints, misconception feedback and balanced answer positions; (2026-09-24) an additional generated round (`QuizGenerator`, four question kinds, named-misconception wrong options) for repeat value | System locale fallback forces Turkish; changing quiz language resets score/question. Generated coverage is four question kinds, not the full topic catalog |
| Transform | Correct projection/rotation presets, finite coefficient bounds, visible-frame retargeting | Real-device usability and reading of vector/determinant labels still need verification |
| Accessibility | Selected widths, themes, 200% text, keyboard/semantics and reduced-motion tests | No physical screen-reader audit or complete WCAG 2.2 AA verification |
| Performance | Local computation; static/dynamic rendering separation; historical debug and browser scheduling measurements | No release-mode low-end-device raster/memory baseline or sustained worst-input workload measurement |
| Architecture | Feature boundaries and pure engine are useful | Input screen 782 lines, practice 734, player screen 629 (down from 673 after 2026-09-24 moved caption/legend/drawer widgets into `matrix_display_grid.dart`, now 1339) and `step_card.dart`; large files are maintenance hotspots, not proof of defects |
| Security | Fresh scoped review: 75 Pub package/version queries with no returned advisories; bounded numeric inputs | Android debug signing and unsigned Windows artifact; production hosting and native toolchain remain unverified |
| Delivery | Git history and GitHub Actions CI (analysis, both suites, generated-localization check); main deploys to GitHub Pages, other branches publish a web preview artifact | Release signing, Windows packaging and rollback procedure are still unestablished |
| Documentation | English architecture/design/history documents | Engine README was a scaffold; this review replaces it and establishes a current documentation entry point |

Visual observations are from saved 7 September screenshots, not a fresh live interaction session. Source and tests provide current behavior evidence. No learner study or exhaustive platform audit is claimed.

## Priority definitions and execution order

P0 blocks an honest/public release. P1 makes the existing product dependable and usable. P2 expands value after those gates. Sizes are relative engineering effort (S: focused, M: several linked changes, L: multiple workstreams), not delivery-date promises. The owner selects release platforms; no store/account purchase is assumed.

### Stage 1 — Trust and reproducibility (P0)

**A01. Represent numerical certainty and completeness (M; owner: engine + UI).**

Evidence: `packages/matrix_engine/lib/src/algorithms/eigen.dart` rounds irrational 2×2 roots to three decimals and stores them as Rational. For `[[0,2],[1,0]]`, the solver returns ±707/500 with residual `[0,151/250000]`, while UI prose describes an eigenvector equation with equality. For `diag(1,30,40)`, it returns one pair and `isSuccess=true`; searching only -20…20 is documented, but the partial result has no explicit completeness metadata. A repeated eigenvalue may also have a multi-dimensional eigenspace while only one vector is returned; investigate and label scope rather than claiming a complete basis.

Deliverable: explicit exact/approximate and complete/partial/unsupported distinctions, localized visible wording and approximation notation. Prefer backward-compatible metadata; do not replace exact arithmetic globally or implement a general eigensolver merely to remove a warning. Audit the other solvers' result/error contracts at the same boundary.

Acceptance: exact cases retain zero residual; approximate cases have declared precision/tolerance and never imply exact equality; the two examples above are regression tests; repeated-root, complex-root and out-of-range-root cases state their limitations. UI tests verify these distinctions in both languages. Dependencies: none.

**A02. Establish recoverable source history and repeatable validation (M; owner: engineering).**

Deliverable: local Git baseline after reviewing ignore rules, an owner-selected remote if desired, a portable validation entry point and CI on the chosen service. Keep source, tests, platform scaffolding and lockfiles; exclude generated evidence and credentials. No remote publication is part of this roadmap document.

Acceptance: a clean checkout resolves both root and engine dependencies; analysis and both suites pass; web and Windows jobs run on suitable hosts; failed checks fail the pipeline; artifacts identify source revision and SDK. Demonstrate restoring a previous source revision. Dependencies: repository/CI destination decision for hosted automation; local preparation can proceed first.

**A03. Close distribution security gaps (M; owner: release engineering + owner).**

Deliverable: owner-managed Android release signing, chosen Windows signing/distribution process, artifact verification and documented packaging. Configure and test web deployment policy on the actual host, including TLS, content/security headers and runtime asset origins. See SECURITY_REVIEW.md.

Acceptance: production Android artifact uses the intended certificate and release settings; Windows publisher verification matches the selected channel; full Windows package works on a clean machine; web starts and renders under its deployed policy. Document checksum/version and rollback procedure. Never add a private signing key to source. Dependencies: A02 and owner-controlled identities/hosting.

### Stage 2 — Usability and real-device quality (P1)

**B01. Validate the learning interaction before retiming it (M; owner: product/design).**

Run a small formative study with approximately five target learners, including beginners and returning students. Tasks: find a starter lesson, explain elimination's target/pivot coefficient, follow a swap, explain a multiplication contribution, enter/fix a fraction, pause/replay and answer a related question. Record task completion, misunderstandings, assistance and time without collecting unnecessary personal information. This sample discovers usability issues; it is not statistical proof of learning gains.

Acceptance: document observed problems with evidence and severity; each critical misunderstanding has an actionable change and retest. Compare before/after explanation accuracy using the same tasks. Do not optimize for animation speed alone. Dependencies: A01 for truthful examples.

**B02. Refine stage hierarchy and long-content behavior (M; owner: design + frontend).**

Test reducing desktop eye travel between operation, matrix and explanation; use excess stage space intentionally. On mobile keep source operands, current contribution and result relationship understandable as content scrolls. Consider a compact current-contribution view with accessible completed details, without hiding learning content or adding a second play control. Keep the existing visual tokens and semantic role colors.

Acceptance: live checks at 320/390/600/960/1440 widths, short landscape, both themes/languages, 200% text, 5×5 signed long fractions and reduced motion. No clipped actions, inaccessible horizontal content, duplicate playback controls or lost progress on resize. Retest B01 tasks. Dependencies: B01 findings.

Partially addressed 2026-09-24: the player is now one centred stage column (matrix, legend, caption, "why" note, a single `Details` drawer) at every width instead of a split desktop panel, removing the former side-by-side eye travel and collapsing two inspectors into one. Not yet verified against this acceptance criterion: no live check at the listed widths was run (see PROJECT_REVIEW.md "UI and learning-path pass"), and mobile multiplication still expands into several formula rows.

**B03. Resolve practice locale and reset semantics (S–M; owner: frontend/content).**

Choose and document a locale rule consistent with the resolved application locale, while retaining explicit quiz language choice. Changing language should preserve the equivalent question/score or clearly announce an intentional restart; current tests preserve older behavior and must be deliberately updated with the product decision.

Acceptance: system English/Turkish, explicit overrides and mid-question/mid-feedback switching have deterministic tests; translated questions share stable identities; scoring cannot duplicate. Dependencies: none.

**B04. Audit accessibility using assistive technology (M; owner: accessibility QA).**

Test keyboard-only completion and chosen native/browser screen readers; review spoken matrix coordinates, negative values/fractions, phase announcements, control names, focus restoration after sheets and error focus. Measure contrast for all interactive/semantic states rather than assuming shared tokens guarantee it.

Acceptance: documented device/browser/reader matrix and manual results, no keyboard traps, sensible reading order, non-color feedback, target sizes and reduced motion. Map issues to applicable WCAG criteria and retest fixes; do not advertise certification from widget tests. Dependencies: B02/B03 final layouts.

**B05. Measure and optimize real workloads (M; owner: performance engineering).**

Profile release/profile builds on a representative low-end mobile device and desktop browser: cold start, longest 5×5 rational solve, complete multiplication/determinant playback, rapid navigation and repeated screen disposal. Record build identity, device, thermal/load state, dataset, frame build/raster times, memory and startup transfer. Check web solver scheduling directly; async syntax alone does not establish background execution.

Acceptance: reproducible baseline and same-scenario comparison for each optimization; aim for the 16.7 ms frame budget on tested 60 Hz devices and report missed frames/p95 honestly. Stable retained memory after repeated flows. Only add cancellation, isolate/worker work, caches or lazy loading when measurements justify them. Dependencies: A02; can run alongside B01.

### Stage 3 — Sustained learning value (P2)

**C01. Connect the existing starter lessons into a learning route (M; owner: content + frontend).**

Add prerequisite context, learning objective and next action around existing topics. Include an optional prediction checkpoint before selected operations and explain the final mathematical meaning. Acceptance: novice can finish one coherent route without knowing operation names in advance; free catalog access remains available; both languages receive equivalent content. Dependencies: B01, A01.

Partially addressed 2026-09-24: `TopicItem.pathOrder` gives the catalog a suggested order and numbering, and a "Continue where you left off" card resumes the last topic, but the route still has no prerequisite text, learning objective or next-action framing per topic — the acceptance criteria above are not yet met.

**C02. Expand practice with authored, validated content (L; owner: mathematical content + engineering).**

Build a question catalog with stable IDs, topic, difficulty and misconception tags. Start with curated coverage of core operations before generated questions. Add missing-value or next-operation interactions only after accessible interaction design. Acceptance: every answer/rationale reviewed mathematically, invariant checks where applicable, reproducible selection, empty/unavailable content handling, scoring/navigation regression tests and translation parity. Dependencies: B03, C01 content model.

Partially addressed 2026-09-24, in the opposite order this item recommends: `QuizGenerator` (see PROJECT_REVIEW.md) adds seed-reproducible generated questions across four kinds, each wrong option tagged to a named misconception, before the curated catalog was expanded. It has no difficulty tagging and does not cover the full topic list; the curated five-question round is unchanged and still shown first.

**C03. Restore work locally (M; owner: frontend).**

Persist chosen preferences and an opt-in or clearly explained last-work session, with versioned local data and a reset/delete action. Avoid accounts/cloud synchronization initially. Acceptance: restart restores a valid selection/matrix; corrupt, old, unavailable or quota-limited storage recovers safely; restored data passes existing dimensions/length/number validation; users can remove saved data. Dependencies: stable input/state schema, privacy wording decision.

Partially addressed 2026-09-24: `SettingsState` now persists the last opened topic and finished topic names, with a "Reset progress" action to clear them. Matrices and quiz answers are deliberately never persisted (see AGENTS.md), so "restart restores a valid selection/matrix" remains undone by design, not oversight.

**C04. Add interoperable input/export only when validated by usage (M–L; owner: product + engineering).**

Prioritize matrix paste and shareable worked results if learners request them. Define accepted formats first. Acceptance: bounded size/content, explicit parse errors and atomic import; export marks approximations/partial solutions and includes readable math. No arbitrary HTML interpretation, formula execution or silent numeric substitution. Dependencies: A01; user demand evidence.

### Stage 4 — Maintainability and release discipline (ongoing)

**D01. Extract components at demonstrated seams (M, incremental).**

Separate input validation/solve orchestration, quiz state and reusable explanation/control sections when touching those areas. Preserve feature boundaries and engine independence. Do not split files solely to meet a line-count target or rebuild state architecture. Acceptance: smaller focused review diffs, unchanged behavior tests, no added frame rebuilds or circular feature imports. Depends on the relevant feature work, not a big-bang rewrite.

**D02. Keep evidence and documentation current (S, each release).**

Update README, agent invariants and design rules with implementation changes; append dated validation results rather than presenting historical counts as current. Run advisory checks at release time, maintain a changelog tied to real releases, and record device/platform gaps. Delete superseded generated evidence only after durable conclusions are recorded. Acceptance: documentation links resolve and commands/examples work; source and guide agree; no template claims, invented release dates or hidden failed gates.

## Release gate

A public release requires A01–A03, passing automated suites/builds for selected targets, and documented B04/B05 findings with no unresolved release-blocking issues. Learning enhancements C01–C04 can ship incrementally after the core is trustworthy. Unsupported platforms remain explicitly unsupported until tested. No exact completion date is credible before the target platforms, signing identities and learner-study access are known.

## Intentionally deferred

A general numerical eigensolver, backend/accounts, cloud sync, analytics collection, AI tutor, new animation framework, wholesale architecture rewrite and dependency upgrades for their own sake. Revisit only with demonstrated learner need and a separate scope/security review.
