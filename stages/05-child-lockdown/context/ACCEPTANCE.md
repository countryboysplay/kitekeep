# Acceptance criteria

- [ ] Child Mode enters Lock Task Mode on a correctly provisioned test device.
- [ ] Unauthorized normal escape paths are blocked to the extent supported by Android Device Owner APIs.
- [ ] Parent-authorized exit is separated from child navigation.
- [ ] Reboot expectations and unsupported OEM cases are documented.
- [ ] Security evidence records tested escape paths.

## Required validation commands

- `cd src; .\gradlew.bat test lint`
