# Next KiteKeep session

Continue Stage 00; do not begin Stage 01 until Stage 00 passes acceptance, independent review, and explicit human merge approval.

Treat the repository as authoritative. Before development:
1. Read `/AGENTS.md` and the entrypoint for your agent (`/CODEX.md` for Codex).
2. Read `/PROJECT_STATE.yaml` and identify the active stage.
3. Read only that stage's `/stage.yaml` and `/context/AGENT.md`.
4. Load only the persona files explicitly assigned by the active manifest.
5. Read the remaining active-stage `/context/` files, especially `HANDOFF.md`, `ACCEPTANCE.md`, `SCOPE.md`, and `FILES.md`.
6. Read only the source/documentation paths authorized there. Do not scan the repository or inspect other stages without explicit authorization.

Summarize the active stage, objective, dependencies, personas, permitted edits, acceptance criteria, and blockers concisely. Continue authorized work without unnecessary confirmation.

The preceding session implemented Stage 00 script repairs as Codex. Consult the handoff and evidence for current results; do not infer successful provisioning from passing regression checks. Resolve the Git bootstrap boundary before claiming branch validation. Do not publish the bootstrap commit to main without human approval. Independent review must use an agent different from the implementation agent.

At completion, run all required validation, save sanitized evidence in the active stage's evidence directory, update HANDOFF.md with implementation, decisions, changed files, tests, limitations, unresolved issues, and next-stage contracts, and run the repository stage verification/readiness tools. Obtain independent review. Stop before merging into main; human approval is required. Save the next opening prompt as `/NEXT_SESSION_PROMPT.md` using the repository session-prompt standard if it is available.

The session-prompt standard was not found through targeted filename searches or README/stage-tool references. This prompt is a provisional continuation prompt based on the user's explicit read-order and completion requirements, not a claim of compliance with an unavailable standard.

Follow-up: Git has now been initialized on stage/00-dev-environment, with no commits. Stage structure/branch verification passes. Consult the latest HANDOFF.md follow-up; earlier references to absent Git metadata are superseded. Initial baseline creation and independent review remain outstanding.

Publication follow-up: the user authorized the initial commit and GitHub push of stage/00-dev-environment to countryboysplay/kitekeep. Check the current Git history and upstream status; the earlier no-commits/initial-baseline note may now be superseded. No main merge is authorized by this push.

Review follow-up: Claude Code independently APPROVED implementation commit a96d33a. Read stages/00-dev-environment/evidence/independent-review.md and the latest handoff. Independent review is satisfied; explicit human approval to establish the initial main branch remains required. Do not repeat historical blocker claims or activate Stage 01 prematurely.
