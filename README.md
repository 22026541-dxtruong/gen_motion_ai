# gen_motion_ai

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Auth E2E Verify

Run from `gen_motion_ai`:

```powershell
pwsh -File scripts/verify-auth-e2e.ps1 -BaseUrl http://localhost:3000
```

Optional reset-password verification:

```powershell
pwsh -File scripts/verify-auth-e2e.ps1 -BaseUrl http://localhost:3000 -ResetToken "<token-from-email>"
```

Use the real reset token from email; placeholder values will be skipped.
