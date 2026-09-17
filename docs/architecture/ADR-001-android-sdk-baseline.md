# ADR-001: Android SDK baseline

Status: Accepted
Date: 2026-09-17

## Decision

KiteKeep uses:

- Application ID: `com.countryboysplay.kitekeep`
- `minSdk = 28`
- `compileSdk = 36`
- `targetSdk = 36`
- Kotlin and Jetpack Compose
- Gradle Kotlin DSL
- phone and tablet support
- portrait and landscape support

## Rationale

Android 9 / API 28 is the minimum supported version because the project depends on modern dedicated-device and lock-task workflows while avoiding unnecessary support for older Android releases. API 36 is the compile and target baseline for Android 16.

## Change control

An AI agent may not alter this baseline without a new approved ADR.
