# ADR-003: Claude Code and Codex workflow

Status: Accepted
Date: 2026-09-17

## Decision

KiteKeep supports Claude Code and Codex through one shared agent contract. `AGENTS.md` is authoritative. `CLAUDE.md` and `CODEX.md` are thin entrypoints only.

Each stage supports an implementation agent and a different review agent. The reviewer is read-only until explicitly assigned corrections. Stage branches require manual human merge approval.
