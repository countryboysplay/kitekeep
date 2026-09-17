# ADR-002: One source tree with staged AI context

Status: Accepted
Date: 2026-09-17

## Decision

KiteKeep keeps one authoritative Android source tree under `src/`. Development stages never duplicate application source. Git commits and completion tags provide snapshots.

Each stage receives a small self-contained context package and may read only the source paths and persona files explicitly declared for that stage.

## Rationale

This structure reduces AI context size, token use, accidental cross-stage edits, stale duplicate code, and unnecessary repository scanning.
