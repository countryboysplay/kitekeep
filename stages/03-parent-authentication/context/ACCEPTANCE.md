# Acceptance criteria

- [ ] Parent PIN is never stored plaintext.
- [ ] Cryptographic verification uses a salted verifier and Android security facilities as designed.
- [ ] Failed attempts are rate limited.
- [ ] Parent authorization has testable interfaces for later policy stages.
- [ ] Unit tests cover success, failure, retry limits, reset boundaries, and persistence.

## Required validation commands

- `cd src; .\gradlew.bat test lint`
