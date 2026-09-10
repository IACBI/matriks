# Cleanup and motion follow-up — 2026-09-10

## Changes

- Transform playback now stops at the visible frame when its TickerMode is
  disabled or the app leaves the resumed lifecycle state. It remains paused
  until the user resumes it. Previously both cases skipped to the finished
  transform after two seconds away; regression tests reproduced both failures.
- Narrow layouts with at least 500 logical pixels of available height and text
  scaling at or below 150% keep the canvas above independently scrolling
  controls. A 390×844 regression previously lost the visible canvas when
  scrolling to Scale. Short screens and larger text retain full scrolling.
- Each canvas rebuild evaluates the interpolated matrix once instead of four
  times. Removed the painter's unused progress parameter and identity
  interpolation, and the badge helper's unused theme parameter. TransformMatrix
  remains the sole owner of interpolation, including angle-based rotations.

## Verification

- Targeted visualization, transform and accessibility suites: 44 passed.
- Full application suite: 114 passed, including five languages, both themes,
  responsive layouts and existing player timing tests.
- Independent engine analysis clean; all 39 engine tests passed.
- Final application/source analysis (`dart analyze lib test tool`) is clean.
  The deprecated TickerMode lookup found by Flutter analysis was replaced with
  the installed SDK's `TickerMode.valuesOf(context).enabled` API.
- All 10 visualization tests passed again after that API update. Final
  `flutter build web --release` succeeded. The app was launched locally in
  Chrome at `http://127.0.0.1:52147/`; the Turkish dark-theme catalog and
  desktop transformation layout were visually checked.
- Three new regressions cover background pause/resume, hidden ticker pause and
  mobile canvas visibility. Existing reverse, rapid retargeting, input validation
  and reduced-motion tests still pass.
- OSV query on 2026-09-09 covered 89 hosted package/version pairs; no advisories
  returned. The scoped credential-pattern scan read 105 text files and found no
  matching private-key headers, GitHub tokens or AWS access-key IDs. This is not
  a guarantee of dependency or application security. Evidence remains in
  `output/audit-security-static.json`.

## Limits and cleanup status

File deletion was blocked by automatic command policy, including the safer
non-recursive attempt limited to old output logs and PNGs. No old files or
directories were deleted. Source, lockfiles, platform projects, configuration
and release assets remain intact. The dead-code changes above were completed.

After the user explicitly renewed deletion authorization, a further attempt
was also blocked before execution. The verified candidates comprise 114 files
(66,468,240 bytes): old output artifacts and migration scripts, browser captures,
and generated test caches/assets. The exact target inventory was saved in a
candidate list that is no longer retained; it was a candidate list, not a
deletion receipt.
Latest cleanup test/build logs and the current security scan are excluded.

No dependency upgrades, numerical-engine changes or signing changes were needed
for the confirmed defects. Android development signing remains a release limit.
No real-device GPU/FPS measurement or performance improvement percentage is
claimed. Physical screen-reader and native mobile release checks were not run.
The workspace has no Git repository, so no commit or diff against a Git baseline
is available.

Windows launch was attempted on 2026-09-10 and failed because the host lacks
the symbolic-link support required by Flutter plugins. No host security or
developer-mode setting was changed.
