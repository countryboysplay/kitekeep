# Acceptance criteria

- [ ] Threat/escape checklist is executed on emulator and physical hardware where required.
- [ ] Confirmed findings are documented with severity and reproduction steps.
- [ ] Critical/high findings are remediated or explicitly block release.
- [ ] Regression tests are added for remediated bypasses where practical.
- [ ] Residual platform/OEM limitations are documented without overstating security.

## Required validation commands

- `cd src; .\gradlew.bat test lint connectedCheck`
