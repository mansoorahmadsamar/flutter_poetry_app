---
description: Secret scan, dependency audit and tracked-secret check — real output only
---

Run, and report each with its real output:

1. **Secrets** — `gitleaks detect --source . --redact --log-opts="--all"` — full history, all branches, not just staged. Expect `no leaks found`: the secrets already in history are pinned by fingerprint in `.gitleaksignore` **pending rotation**. Report the baseline size (`grep -cE '^[0-9a-f]{40}:' .gitleaksignore`) and say that a baselined secret is still a live secret until rotated (see `poetry-backend/docs/SECURITY.md`). Also run `gitleaks protect --staged --redact`.
2. **Dependencies** — Dart/pub has no built-in vulnerability audit. Run `flutter pub outdated` and report packages with a newer *resolvable* version; say plainly that this is staleness, not a vulnerability audit.
3. **Tracked secret files** — `git ls-files | grep -Ei '(^|/)\.env($|\.)|\.p8$|\.pem$|key\.properties$|\.jks$|\.keystore$|service-account|adminsdk|client_secret|credentials.*\.json$|settings\.local\.json$'`. List **paths only**; never open or print the contents of a secret file.
4. **Signing material** — confirm `android/key.properties`, `*.jks`, `*.keystore`, `.github/*.base64` and service-account JSON are ignored: `git check-ignore -v <path>`. List paths only.

Then state whether the pre-commit hook is installed: `git config --get core.hooksPath` should print `.githooks`. Do **not** install it yourself — tell the owner the one-liner: `git config core.hooksPath .githooks`.

Be specific about severity. "1 critical, 4 high" with the package names is useful; "some vulnerabilities" is not. **Never print a secret value** — gitleaks runs with `--redact` for that reason.
