# Agent instructions for 11-security-validation

Objective: Perform adversarial security validation focused on PIN bypass, Child Mode escape, intents, overlays, allowlisted apps, and Device Owner policy gaps.

Follow `AGENTS.md`. Load only the personas listed in this stage's `stage.yaml`. Do not scan the persona library, previous stages, or the complete `src/` tree unless an exact path is declared.

The implementation agent may edit only declared paths. The review agent begins read-only and must focus on the acceptance criteria and stage risks.
