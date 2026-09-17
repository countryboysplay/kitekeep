# KiteKeep development stages

- `00-dev-environment`: Provision and verify the complete Windows 11 Android development and testing environment.
- `01-project-foundation`: Create the modular Kotlin/Compose Android project and establish build architecture, package conventions, and test foundations.
- `02-launcher-shell`: Build the custom Home launcher shell and responsive child-facing navigation without security lockdown.
- `03-parent-authentication`: Implement secure parent PIN authorization, retry throttling, and Parent Mode entry contracts.
- `04-device-owner`: Implement Device Admin/Device Owner foundations, local provisioning support, and the policy-controller abstraction.
- `05-child-lockdown`: Implement Child Mode lockdown using Lock Task Mode and Device Owner policies, then document the enforced security boundary.
- `06-app-management`: Implement installed-app discovery, parent-approved package allowlisting, child library presentation, and safe launch contracts.
- `07-parent-dashboard`: Build the parent dashboard for app management, child settings, device controls, and temporary parent access.
- `08-lifecycle-recovery`: Make child-lock state resilient across reboot, process death, crashes, updates, power loss, and recoverable failure conditions.
- `09-local-data-privacy`: Establish local-only storage, child profile/settings boundaries, retention rules, and privacy-safe foundations for future progress data.
- `10-automated-testing`: Create the comprehensive automated test harness for launcher, PIN, policy, navigation, lifecycle, and emulator workflows.
- `11-security-validation`: Perform adversarial security validation focused on PIN bypass, Child Mode escape, intents, overlays, allowlisted apps, and Device Owner policy gaps.
- `12-release-build`: Produce the signed release process, release APK workflow, provisioning guide, rollback instructions, and final validation package.

Only the active stage should be loaded into an AI coding agent context.
