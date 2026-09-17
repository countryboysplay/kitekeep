# Acceptance criteria

- [ ] Gradle wrapper builds from `src/`.
- [ ] Application ID is com.countryboysplay.kitekeep.
- [ ] minSdk 28, compileSdk 36, and targetSdk 36 are enforced.
- [ ] Kotlin, Compose, and Kotlin DSL are configured.
- [ ] Module boundaries are documented in an ADR.
- [ ] CI runs build, unit tests, and lint.

## Required validation commands

- `cd src; .\gradlew.bat test lint`
