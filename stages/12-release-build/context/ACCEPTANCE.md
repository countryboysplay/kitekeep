# Acceptance criteria

- [ ] Release build can be generated from documented commands.
- [ ] Signing configuration consumes external secrets only.
- [ ] Clean-device provisioning instructions are documented.
- [ ] Rollback and emergency recovery instructions are documented.
- [ ] Final release validation includes a real-device pass.

## Required validation commands

- `cd src; .\gradlew.bat test lint assembleRelease`
