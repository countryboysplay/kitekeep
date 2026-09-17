# KiteKeep

KiteKeep is a child-safe Android launcher and future educational game platform. The initial product goal is a locally managed Android launcher that can operate as the device Home experience, enter a parent-controlled child mode, and use Android dedicated-device capabilities to prevent normal escape into unrestricted Android without a parent PIN.

## Repository model

The Android application has one authoritative source tree under `src/`. Development is divided into narrow stages under `stages/`. Each stage contains only the context needed for that stage, while Git provides history and rollback instead of duplicated code snapshots.

AI coding agents must begin with `AGENTS.md`, then `PROJECT_STATE.yaml`, then the active stage's `stage.yaml`. Claude Code and Codex have thin entrypoint files that route them to the same rules.

## Current platform baseline

- Windows 11 development host
- Kotlin
- Jetpack Compose
- Gradle Kotlin DSL
- Application ID: `com.countryboysplay.kitekeep`
- Minimum Android: API 28 / Android 9
- Compile SDK: API 36 / Android 16
- Target SDK: API 36 / Android 16
- Phone and tablet layouts
- Portrait and landscape layouts
- Local-first data model

## First run on Windows 11

From an elevated or normal PowerShell terminal at repository root:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\setup-dev-environment.ps1
.\scriptserify-dev-environment.ps1
```

The setup script self-elevates when administrator rights are required.

## Initialize and push the GitHub repository

After the development environment is ready, run:

```powershell
.\scripts\bootstrap-repository.ps1
```

This initializes Git if needed, creates the initial scaffold commit, pushes `main`, creates `stage/00-dev-environment`, and pushes that stage branch. It never merges a stage automatically.

## Development stages

The active stage is declared in `PROJECT_STATE.yaml`. Do not begin a later stage until its declared dependencies are complete and the previous stage has passed review and manual merge approval.
