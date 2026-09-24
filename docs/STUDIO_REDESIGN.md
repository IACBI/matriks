# Matriks studio redesign — implementation notes

Superseded in part: the 2026-09-24 UI pass (see [PROJECT_REVIEW.md](PROJECT_REVIEW.md)) removed the accent-palette setting described below — one brand blue is used throughout, because the teal and purple choices collided with the row-operation role colors. The rest of this record (shell, phases, predictions, preferences, localization, shortcuts, eigen metadata, assets) still applies.

## Implemented behavior

- Shared studio surfaces and three accessible action palettes. Mathematical role colors remain separate from the chosen action palette. Comfortable/compact preference affects catalog spacing and shared list tiles.
- Adaptive four-destination shell: topics, practice, transformations and settings. Pages retain their state when navigating between destinations; hidden animation tickers are disabled.
- Source, operation and result remain the three instructional phases. Matrix cells show actual arithmetic expressions during the active contribution; completed values remain discrete. Elimination/scaling now expose all column calculations. Addition has a typed transformation with both operands.
- A single animation controller still owns lesson time. Guided, static-step and direct-result modes are distinct; mode changes invalidate prior completion revisions. Returning from result opens static steps at the retained lesson position.
- Optional worked-example predictions pause before elimination. Answers explain the factor; skip/continue resumes the lesson. Regular calculator input does not force a quiz.
- Versioned local preferences use SharedPreferencesAsync through an injectable repository. Writes are serialized; late restore cannot overwrite user changes. Read/write failures keep the app usable and are disclosed in Settings. Reset only resets this app's preferences.
- Turkish, English, Spanish, Russian and Simplified Chinese include the entire ARB catalog and authored quiz feedback. Question identities and scoring are independent of language; system locale falls back to English when unsupported.
- Player key assignments accept letters, Space and horizontal arrows; duplicates/reserved assignments are rejected. Page Up/Down and Home/End remain fixed navigation. Focused child controls retain their keys; text input is never intercepted by lesson shortcuts.
- Eigen result metadata reports exact/approximate and complete/partial/unsupported status. 2×2 irrational roots declare three-decimal rounding; complex displays declare two-decimal rounding and unsupported complex eigenvectors. Repeated roots conservatively report partial because only one representative vector is returned. 3×3 searches only integers −20…20; fewer than three distinct roots do not imply a complete eigenspace basis. Exact rational arithmetic is unchanged.
- ImageGen master icon is in assets/branding; tool/export_branding.py exports launcher sizes. Flag images are bundled; switching languages performs no network request.

## Asset provenance

Icon generated with built-in ImageGen for this project. Prompt: “Create the final production app icon for Matriks, a professional modern linear algebra learning studio. Square full-bleed opaque navy background (#111E32), no rounded outer corners baked in. Center a very bold clean geometric mark: two white matrix square brackets enclosing a stylized capital M constructed from a small grid of rounded square cells, one upper-right cell luminous turquoise (#39D6C4) to suggest a mathematical transformation. Flat precise graphic design, minimal subtle depth only, highly legible at 32px, generous 18 percent safe area on all sides, symmetrical balanced composition. No words, no numbers, no fine lines, no watermark, no mockup, no surrounding presentation. Output one 1024x1024 icon image.”

The service returned a 1254×1254 master. Launcher sizes are resampled from it. Web maskable variants add safe padding; Windows ICO includes 16–256 px representations. Flags were downloaded from FlagCDN (w80/tr.png, gb.png, cn.png, es.png, ru.png) and stored locally. These national flags identify the selected language variants, not the nationality of users.

## Validation limits

### Verified on 2026-09-08

- Flutter analysis and independent engine analysis: no issues.
- Application suite: 108 tests passed after the final Dart changes. Engine suite: 39 tests passed.
- Final web release build succeeded, including the default Wasm compatibility dry run. This is not a deployed-site or separately built Wasm runtime test.
- Chromium visual checks: 1440×900 desktop catalog, dark settings, 390×844 settings, direct result and return to static steps. Dark theme, teal palette and direct-result preference survived page reload and were confirmed in the app's storage entry.
- Windows release was attempted and blocked by the host's disabled symbolic-link support required by Flutter plugins. No OS settings or generated plugin files were altered. Android/iOS builds were not run.

The same debug 5×5 elimination harness collected 1,407 samples over a 7,500 ms instructional timeline before and after implementation. Before: median 1,320 µs, p95 4,018 µs. Final: median 2,318 µs, p95 7,380 µs. The richer arithmetic display increased debug pump cost; no speedup is claimed. The final measurement ran without another build/test/browser action in parallel. These are host-dependent widget pump measurements, not GPU frame times; the 16.7 ms device frame target is unverified. Comparable before/after memory measurements were not collected. A release/profile run on representative physical devices remains necessary.

Automated layout coverage includes five languages, both themes, 320/390/600/960/1440 widths and short landscape; narrow/landscape cases use 200% text and reduced motion. Separate existing cases cover signed long fractions, 5×5 matrices and timeline invariants. Widget coverage is not physical screen-reader certification.

Native-speaker review of Spanish, Russian and Chinese mathematical terminology remains recommended before public release. No learning study, low-end mobile GPU profile, Android/iOS native device test or production-host audit is claimed. Debug pump timing is not GPU raster timing and does not establish a 60 FPS guarantee. See YAYINLAMA.md for owner-managed distribution steps.
