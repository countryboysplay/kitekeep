# Acceptance criteria

- [ ] Unit and instrumentation suites cover critical contracts.
- [ ] Emulator test scripts are repeatable.
- [ ] Reboot/lifecycle test procedures are automated where practical.
- [ ] Failures produce evidence that identifies the failed requirement.
- [ ] CI remains deterministic enough for stage gating.

## Required validation commands

- `cd src; .\gradlew.bat test lint connectedCheck`
