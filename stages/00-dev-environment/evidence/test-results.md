# Stage 00 test results

Environment acceptance: PASS. Stage readiness: BLOCKED; no merge readiness claim.

- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-dev-environment.ps1`: PASS, 16 checks in Windows PowerShell 5.1. See script-tests.txt. Covers parsing, native stderr/exit handling, absent executables, real AVD configuration validation, elevation wait/exit propagation (static), non-overwriting creation (static), and the production PATH helper.
- `powershell -ExecutionPolicy Bypass -File scripts/verify-dev-environment.ps1`: PASS, all 12 required checks. The final setup runs also invoke the same verifier successfully. See environment-report.json.
- Corrected setup completed twice consecutively with exit 0. Both installed tooling and existing AVDs were reused. The second run left user PATH, phone/tablet config.ini contents, and command-line-tools directory count unchanged. See repeatability.json; only booleans and exit status are stored.
- Both API 36 phone and tablet AVDs exist. Emulator boot was not tested. Hardware virtualization is reported disabled; this is advisory for Stage 00 and may affect subsequent emulator execution.
- Environment-report schema/content inspected: fixed descriptions, no absolute local paths, raw native output, device serials, or credential fields.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/stage/verify-stage.ps1`: FAIL, absent Git metadata.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/stage/mark-stage-ready.ps1`: FAIL at the same verification boundary, before state mutation or commit. See stage-verification.txt.
- Independent review: outstanding; Codex implementation cannot self-review.

## Defects found and corrected

Baseline verification had extra closing parentheses and could not parse. Setup initially returned before its elevated child completed. Native stderr warnings caused failures under Windows PowerShell's stopping-error behavior, despite successful native commands. The command-line-tools package request also installed a redundant latest-2 directory alongside the bootstrapped tools. The corrected setup waits, checks native exit status, and no longer requests that self-installation. The existing extra directory is documented in HANDOFF.md; final repeated setup creates no additional copy.
