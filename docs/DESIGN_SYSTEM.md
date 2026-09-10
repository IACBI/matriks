# Matriks design system

Studio update: see [STUDIO_REDESIGN.md](STUDIO_REDESIGN.md) for the five-language adaptive shell, persisted presentation settings, solution modes and updated matrix contribution rendering. The timelines and single-controller invariants below still apply to guided playback; static steps and direct results do not wait for instructional intervals.

The interface is a mathematical workspace: the matrix, explanation, and next action take priority. The topic catalog uses aligned title, description, and operation columns on desktop, and wrapping rows on mobile. Color marks actions and mathematical roles, not arbitrary categories.

## Foundations

Canonical implementation: `lib/core/theme/app_theme.dart`.

| Token | Light | Dark |
| --- | --- | --- |
| Workspace | `#F5F7FA` | `#101A29` |
| Surface | `#FFFFFF` | `#182537` |
| Primary text | `#202938` | `#EEF2F7` |
| Secondary text | `#526174` | `#BCC7D6` |
| Action | `#2455B2` | `#AAC7FF` |

Typography uses the existing Flutter font stack, without a new font dependency. Headlines use 24–30 px, section titles 20 px, topic titles 16 px, body copy 14–16 px, and secondary labels 12 px. Body line heights are 1.4–1.5. Content width is capped at 1280 px. Spacing is primarily 8, 12, 16, 20, 24, and 48 px; corner radii are 8–20 px, with 24 px reserved for sheets.

## Interaction rules

- Preserve visible native focus states and standard Tab traversal. Global shortcuts consume only recognized keys and respect focused controls.
- Numeric input accepts integers, decimals, and fractions; invalid entries receive a localized, cell-specific error. Calculation has a pending state and prevents duplicate submissions.
- Search combines with category filters and offers an explicit reset when no topics match.
- Use borders and restrained fills for instructional states; keep pivot/source/target labels so color is not the sole explanation.
- Button labels wrap at large text sizes. The editor scrolls on short screens. Wide transformation screens place the canvas beside controls.
- Button state changes use 120 ms; ordinary state feedback uses 180 ms; feedback panels use 220 ms. Reduced motion disables implicit interpolation where motion is used.
- Instructional time is linear and adapts to the operation: swaps 1200/1100/1700 ms, elimination and scaling 1500/3600/2400 ms, dot products and determinants 1500 ms preparation + 1400 ms per contribution + 2600 ms review. Other steps use 1400/2200/2200 ms. Speed scales the complete timeline uniformly. Spatial easing is separate from reading time.
- Lesson navigation advances on the visible animation's completion, never on an independent periodic timer. Revision tokens reject stale completion callbacks. Manual navigation, scrubbing, replay, and arithmetic inspection stop automatic navigation.
- One primary play/pause control governs the active animation. The step-count button opens a named step list. The collapsed operation inspector contains the labeled progress slider and replay; opening either inspector pauses automatic progression.
- Reduced motion shows the final matrix, all three explanations, and all calculations; completion still waits for the reading interval. Backgrounding the app pauses playback.
- Cache discrete matrix-cell content per step and theme; rebuild the animation scene without rebuilding static math cells every frame. Keep caches bounded to the current step.
- Keypad and dimension controls have at least 44 px targets. Standard action buttons have a 48 px minimum. This is not a claim of comprehensive WCAG certification.
- Math text follows system text scaling. Wide values use horizontal scrolling rather than shrinking below the chosen type size. Repeated right-side row annotations are omitted; the operation formula remains above the matrix. Normal matrix cells are quiet, with role borders only where instructional meaning requires them. Player values adapt between 18 and 22 px using available layout width. During an operation, exact cell formulas fit down to a 14 px minimum (before system text scaling); results return to the normal size. Very long expressions remain scrollable. Guided operation cells reserve 120 px width and wide matrices follow the active column. Full calculation panels wrap at TeX operator boundaries.
- Below 600 px, use a single column. From 600–959 px, use flexible or scrolling layouts; the transform canvas can split in short landscape. At 960 px, editors and players use side-by-side layouts when text scale permits. Large text falls back to scrolling.
- Transform presets show selection; editing a coefficient sets Custom. The 2×2 coefficient grid supports direct decimal entry and steppers. Entries commit on Enter/blur; invalid drafts retain the previous valid transformation. The canvas transitions from its visible frame to the new target. Rotations preserve lengths when both endpoints are rotations; other intermediate frames are explicitly described as transitions. Basis vectors and target determinant are separately labeled. The target determinant is not rounded to one decimal, which could conceal small nonzero values.
- Show A’s source row and B’s source column above C during multiplication. Box each corresponding factor pair in sequence. Delay C’s result until all contributions are complete; avoid small canvas-drawn arithmetic labels.
- Phase explanations progressively reveal exact contributions; completed calculations remain available for inspection. The elimination rationale explains target ÷ pivot rather than duplicating the operation statement.
- Catalog starter lessons use real worked examples. Quiz feedback addresses the selected misconception in both languages and preserves the scoring/navigation flow.

## Verified layouts

Widget tests cover all five primary screens at 320×568 with 200% text in both themes, plus 600×800, 960×768, 1440×900 and 800×380 with 200% text. The additional cases cover Turkish and English and reduced motion. Tests also verify paused-progress preservation across layout changes, exact 5×5 long fractions, and error recovery. Browser evidence and profiling limitations are recorded in `UI_MOTION_REVIEW.md`.

Current follow-up evidence and remaining limits are recorded in `GUIDED_UX_REVIEW.md`. Earlier reports are historical snapshots.
