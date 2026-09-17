# Android source root

`src/` is the one authoritative Android project source tree.

Stage 01 creates the Gradle project here. No development stage may create a private copy of application source code.

Planned module families:

- `app`
- `core/common`
- `core/model`
- `core/ui`
- `core/data`
- `core/security`
- `feature/child-home`
- `feature/parent`
- `feature/device-policy`
- `feature/app-management`
- `feature/settings`

The exact module graph is finalized in Stage 01 and recorded in an ADR.
