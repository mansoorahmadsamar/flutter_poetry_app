---
description: Run the local verification gate and report honestly what ran
---

Run each layer from the repo root and report the result:

1. **Static analysis** — `flutter analyze`. Report the issue count by severity (error / warning / info), not just "some issues".
2. **Tests** — `flutter test`. Report passed / failed / skipped counts from the summary line.
3. **Secrets** — `gitleaks detect --redact` (history, current branch) and `gitleaks protect --staged --redact`. Both must report `no leaks found`; existing secrets are baselined in `.gitleaksignore`.

Rules for how you report it:

1. **Name every layer** and its outcome, with the command you ran.
2. **Say plainly what was SKIPPED and why.** `integration_test/` and device/emulator runs are not part of this gate; if a change needs them, say they were not run. Never build an app bundle or IPA as part of verification — those are release artefacts (and denied).
3. **Never say "tests pass" without the commands and their output.** Show the real summary lines. If a layer did not run, the suite is not green — it is partially green, and you say which part.
4. If anything **failed**, show the actual failure output, not a summary of it. Then diagnose before proposing a fix.
5. Verification never touches production: no deploy, no push, no calls to the production API or database (see `rules/live-systems.md`).

If the user asks to verify only one part, pass `analyze`, `test` or `secrets` as the argument.
