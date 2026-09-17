# Repository layout

```text
kitekeep/
├─ .github/
│  ├─ workflows/ci.yml
│  └─ PULL_REQUEST_TEMPLATE.md
├─ agents/
│  ├─ active/                 # only personas referenced by current stage system
│  ├─ source/agents.zip       # complete uploaded persona pack
│  └─ README.md
├─ config/examples/           # safe machine/secrets templates
├─ docs/
│  ├─ architecture/
│  ├─ product/
│  ├─ research/
│  └─ security/
├─ scripts/
│  ├─ setup-dev-environment.ps1
│  ├─ verify-dev-environment.ps1
│  └─ stage/
├─ src/                       # one authoritative Android source tree
├─ stages/
│  ├─ 00-dev-environment/
│  ├─ 01-project-foundation/
│  ├─ ...
│  └─ 12-release-build/
├─ templates/stage/
├─ AGENTS.md
├─ CLAUDE.md
├─ CODEX.md
├─ PROJECT_STATE.yaml
├─ prerequisites.txt
└─ README.md
```

The full persona archive is deliberately compressed so ordinary agent search does not surface 279 unrelated personas. Only the personas intentionally curated into `agents/active/` are directly readable during development.
