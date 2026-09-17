# Acceptance criteria

- [x] Setup script self-elevates when required.
- [x] Repeated setup runs do not intentionally duplicate installed tooling.
- [x] Git, Android Studio, Java, sdkmanager, ADB, emulator, API 28/31/34/36, and Build Tools 36.0.0 pass required verification.
- [x] At least the API 36 phone AVD can be created or a documented host limitation explains why it cannot.
- [x] Environment report is written without secrets or device serial numbers.

## Required validation commands

- `powershell -ExecutionPolicy Bypass -File scripts/verify-dev-environment.ps1`

## Evidence

All environment acceptance items are satisfied by environment-report.json, script-tests.txt, and repeatability.json. Stage readiness remains blocked by missing Git metadata and outstanding independent review; these checks do not authorize merging.

