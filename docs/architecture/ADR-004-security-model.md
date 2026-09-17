# ADR-004: Launcher security model

Status: Accepted
Date: 2026-09-17

## Decision

The secure child-lock goal is implemented through Android dedicated-device capabilities, including Device Owner / DPC functionality and Lock Task Mode, rather than relying on ordinary screen pinning.

A parent PIN gates parent functions and unrestricted-device access. Sensitive PIN material is never stored in plaintext. The launcher is local-first and core operation must not require a cloud account.

## Non-negotiable product rule

When Child Mode is enabled, there must be no normal user-accessible path from KiteKeep into unrestricted Android without successful parent authorization, subject to the security boundaries Android itself exposes to a Device Owner app.
