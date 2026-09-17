# Acceptance criteria

- [ ] Parent can view safe launchable application candidates.
- [ ] Only explicitly approved packages appear to the child.
- [ ] Approved packages are synchronized with lock-task policy as required.
- [ ] Dangerous/system package filtering has tests.
- [ ] Returning Home from an approved app returns to KiteKeep where Android permits.

## Required validation commands

- `cd src; .\gradlew.bat test lint`
