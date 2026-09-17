# Agent instructions for 08-lifecycle-recovery

Objective: Make child-lock state resilient across reboot, process death, crashes, updates, power loss, and recoverable failure conditions.

Follow `AGENTS.md`. Load only the personas listed in this stage's `stage.yaml`. Do not scan the persona library, previous stages, or the complete `src/` tree unless an exact path is declared.

The implementation agent may edit only declared paths. The review agent begins read-only and must focus on the acceptance criteria and stage risks.
