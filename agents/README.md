# Agent persona library

KiteKeep uses the uploaded specialized persona pack without allowing coding agents to scan the full library during normal work.

- `active/` contains the curated personas currently referenced by development stages.
- `source/agents.zip` preserves the complete uploaded persona pack as its source archive.
- `cache/` is optional local extraction space and is ignored by Git.

A stage must load only the persona files named in its `stage.yaml`. Do not search `active/` or extract the source archive to decide which persona to use.

If a future stage requires a persona that is not yet curated, extract that single persona from `source/agents.zip`, place it under `active/`, and update the stage manifest in the same approved change.
