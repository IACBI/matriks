# Security review — 2026-09-07

## Executive assessment

No critical or high-severity application vulnerability was verified in this review. Two distribution concerns remain: Android release uses debug signing, and the current Windows executable is unsigned. This is a scoped source/configuration and known-advisory review, not a penetration-test certification or a guarantee of safety.

## Scope and method

Inspected application entry points, imports, matrix input/state/solve flow, exact rational parsing, transformation coefficient validation, mathematical rendering, session settings, web bootstrap, Android manifest/signing, Apple permissions, and Windows artifact signing. Searched application/platform/engine source for network, process execution, unsafe DOM rendering, storage, and credential patterns. The available security skill has no Dart/Flutter-specific reference set; conclusions here are grounded in the inspected code and explicit checks.

A metadata-only credential scan read 189 UTF-8 text files up to 2 MB each. It checked private-key headers, AWS/GitHub token formats, quoted credential assignments, and common credential filenames. It found zero matches/candidate files. Excluded build, output, ephemeral, package/tool caches, IDE/browser state and Git directories. Binary files were not scanned. This does not establish that every possible secret format is absent. No matched sensitive values were emitted.

## Findings

### SEC-01 — Medium; Android public-release blocker: debug signing

Evidence: `android/app/build.gradle.kts:36` assigns the release signing configuration to `debug`. Development certificates do not establish the intended production publisher identity. Configure owner-managed release/upload signing before distribution, keep private keys outside source control, and verify the resulting artifact. No key was generated or existing private key opened. The Android APK/AAB was not built or inspected, so this is a source-configuration finding, not a claim that a released APK is debuggable.

Reference: [Android app signing](https://developer.android.com/studio/publish/app-signing).

### SEC-02 — Low; Windows distribution authenticity: unsigned executable

`Get-AuthenticodeSignature` returned `NotSigned` for `build/windows/x64/runner/Release/matriks.exe`. The current artifact does not provide an Authenticode publisher signature. This is not evidence of malware or remote code execution. Use the intended publisher identity and distribution channel when preparing public Windows releases; verify the signed artifact after packaging. No certificate purchase or signing identity was assumed.

## Existing protections verified

- No application backend, authentication/session tokens, remote data API or persistent sensitive-data store was found. Backend authorization, SQL injection and account-session CSRF are not applicable to the inspected architecture.
- `matrix_input_cubit.dart:58` bounds dimensions; `:158` onward restricts numeric keypad input and `:182` enforces 32 characters. Invalid fractions are rejected rather than replaced with zero. The engine deliberately retains arbitrary precision; its public parser is not a boundary for untrusted bulk inputs in a future server/import feature.
- `matrix_input_screen.dart:707` onward validates cells, prevents overlapping submission in the screen, catches solve failures and checks mounted state after asynchronous work. No worst-case resource exhaustion proof or browser CPU stress test was performed.
- `coefficient_field.dart:50-51` rejects nonfinite/out-of-range values and `:79` limits input length. Invalid drafts do not silently apply zero.
- Mathematical output is derived from numeric values and authored formulas; no user-controlled HTML/JavaScript execution path was found. `web/flutter_bootstrap.js:7-15` uses `textContent` for startup messages.
- Android main manifest requests no sensitive runtime permissions; INTERNET appears in development/profile manifests. The exported launcher activity is expected and no application intent-data processing was found. iOS configuration has no ATS relaxation; macOS release enables the app sandbox.
- Android ignores key.properties and keystore files. Local path configuration exists but was not printed or treated as a credential leak.

## Dependencies

Queried all 75 distinct hosted package/version pairs from root and engine lockfiles against the OSV Pub ecosystem batch endpoint on this review date. No advisories were returned; the response count matched the query count. This includes development dependencies; zero returned results does not imply that each package is independently audited. Only public package names and versions were submitted.

Evidence: `output/security-dependencies.json`, including query time, exact versions and response. Method: [OSV querybatch API](https://google.github.io/osv.dev/post-v1-querybatch/).

Flutter/Dart native runtime, operating system components, Gradle/Android toolchain, package archive integrity and transitive native binaries were not covered by this Pub advisory check. No dependency upgrades were made.

## Deployment checks still required

No production URL or hosting configuration was supplied. Actual TLS, HTTP security headers/CSP, framing policy, cache behavior and third-party runtime requests must be checked on the deployed web artifact; missing production headers were not asserted from a local development server. The source contains no CSP declaration, but the host may supply one. Test any policy against the actual Flutter runtime before enforcing it.

No Git history exists here to audit historical credentials. The scan excludes local generated logs/caches and does not scan the user's computer or external accounts. Native mobile security testing, OS permission behavior and artifact tampering tests were not performed.

## Verification and changes

- Fresh targeted Flutter run: **12 tests passed** across input regression and visualization correctness suites, including malformed numeric input, cell limits, supported dimensions and invalid transformation coefficients. The run log is no longer retained.
- Source scanner metadata: `output/security-source-scan.json`.
- Documentation only: this report and a pointer from the prior UX report. No application code, dependencies, credentials or signing configuration changed.
- Full analysis, full test suites and production builds were not rerun for this documentation-only review. Earlier UI build/test results are historical and are not substituted for security checks.
