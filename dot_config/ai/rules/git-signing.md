# Git Commit Signing

Git commits are signed with a GPG key. The GPG passphrase is provided by KeePassXC via the D-Bus secret service. If KeePassXC is locked, the user must manually enter their master password — this can take 30–60 seconds or more, which may exceed the shell command timeout.

## Rules

- If a `git commit` or `git push` fails due to a signing/GPG error (e.g. "gpg failed to sign the data", "secret key not available", "No secret key", timeout, or cancelled), **do not assume this is a permanent error**. The user likely just needs more time to unlock KeePassXC.
- **Always ask the user** to unlock KeePassXC, then **retry** the command.
- **Never** push unsigned commits. If `commit.gpgSign` is configured, do not bypass it with `--no-gpg-sign` or `-n`.
- **Never** disable or reconfigure signing to work around a temporary failure.
- If signing still fails after a retry, **ask the user** what to do rather than proceeding without a signature or giving up.
