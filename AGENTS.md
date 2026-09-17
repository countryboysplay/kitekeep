# KiteKeep AI Development Contract

This file is authoritative for every AI coding agent working in this repository.

## Read order

1. Read `PROJECT_STATE.yaml`.
2. Read only the active stage's `stage.yaml`.
3. Read the active stage's `context/AGENT.md`.
4. Load only the persona files explicitly listed by the stage manifest.
5. Read the remaining files in the active stage's `context/` folder.
6. Read only source paths explicitly listed in the stage manifest or `context/FILES.md`.

## Context discipline

- Do not scan the entire repository.
- Do not scan `agents/` to discover personas. The manifest already identifies them.
- Do not read previous stage folders unless the active stage explicitly references one.
- Do not load project research or architecture documents unless the active stage references them.
- Prefer interfaces, contracts, and handoff summaries over unrelated implementation internals.
- If an undeclared file is truly required, document why in `context/HANDOFF.md` before reading it.

## Modification rules

- Modify only paths allowed by the active `stage.yaml` and `context/SCOPE.md`.
- Keep one authoritative application source tree under `src/`.
- Never create stage-specific source copies.
- Do not alter SDK baselines, package ID, architecture decisions, security boundaries, or repository workflow without an explicit approved ADR.
- Never commit secrets, signing keys, local SDK paths, parent PINs, real child data, device serial numbers, or machine-specific credentials.

## Agent roles

Both Claude Code and Codex are supported. A stage may assign either as implementation agent and the other as reviewer. The reviewer is read-only by default and may modify code only when explicitly assigned a correction task.

## Completion rules

An implementation is not complete because it compiles. Before requesting merge:

1. Run all stage validation commands.
2. Satisfy every item in `context/ACCEPTANCE.md`.
3. Store non-sensitive proof in the stage `evidence/` folder.
4. Update `context/HANDOFF.md` with changed files, decisions, known limitations, and next-stage contracts.
5. Run `scripts/stage/mark-stage-ready.ps1`.
6. Obtain review by the designated review agent.
7. Wait for explicit human approval before merging into `main`.

## Git rules

- Stage branches use `stage/<stage-name>`.
- `main` must remain the last approved integrated state.
- The stage scripts may create branches, validate state, commit stage-state transitions, and create completion tags.
- Stage scripts must never merge into `main` automatically.
- Completed stages are tagged `stage-XX-complete` after the manually approved merge is on `main`.
