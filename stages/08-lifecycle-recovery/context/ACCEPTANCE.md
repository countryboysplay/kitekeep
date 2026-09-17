# Acceptance criteria

- [ ] Child state is restored after reboot when configured.
- [ ] Process death does not silently drop required restrictions.
- [ ] A documented parent recovery path exists for supported failures.
- [ ] Update and first-boot transitions are tested.
- [ ] Failure states generate useful non-sensitive diagnostics.

## Required validation commands

- `cd src; .\gradlew.bat test lint`
