# Rule — Sukhan is live

Loaded every session. Sukhan (Jahan-e-Sukhan) is in production on Google Play, the App Store, the admin portal and jahanesukhan.com, with real users and **no staging environment**. Full detail in [../../AGENTS.md](../../AGENTS.md).

**This repo:** pushing to `develop` **or** `main` runs `.github/workflows/play-store-release.yml`, which builds a signed app bundle and uploads it to Google Play. `firebase-app-distribution.yml` sends builds to testers. Neither runs without the owner's explicit OK. `flutter build appbundle` / `ipa` are denied locally — release builds for QA use `flutter build apk --release` or `flutter run --release` only when the owner has asked for prod testing.

## The production database

- **One database, and it is production:** `poetry-db` on `134.199.243.167:5432`.
- **Never write to it** — no `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, DDL, `VACUUM FULL`, `REINDEX`, sequence resets, or a migration/seed script pointed at it. Not "just one row", not to fix data you just found broken: a data fix is a proposal to the owner, with the exact SQL, and he runs it.
- **Read-only `SELECT`s are allowed for diagnosis.** Make it structurally read-only where you can — prefer the read-only role, and wrap ad-hoc queries: `PGOPTIONS='-c default_transaction_read_only=on' psql ...` or `BEGIN READ ONLY; SELECT ...; ROLLBACK;`. Bound every query (`LIMIT`, indexed predicates): ~1.6M couplets and ~3.6M verse rows share that server with live traffic.
- **Say exactly what you ran** — the full SQL and the host — in your report.
- `psql` / `docker run ... psql` against `134.199.243.167` cannot be pattern-matched for write intent in settings, which is why this is a rule: **you** are the gate.

## Production servers and endpoints

- The production droplets are `134.199.243.167` and `157.230.203.194`. `ssh`/`scp`/`rsync` to either are denied in `.claude/settings.json`; if the owner asks you to look at one, he runs the command or grants it explicitly for that task.
- **Never call a production endpoint that changes data** to "test" something — anything `POST`/`PUT`/`PATCH`/`DELETE`, and `GET`s with side effects: `/api/poets/sync`, `/api/dictionary/sync`, admin reindex, bulk-status, delete, analytics/event ingestion.

## Push, merge, deploy

- **Never push, merge, open a PR into `main`, re-run a deploy workflow, or deploy by any route without the owner's explicit OK** — given for that specific change, in this conversation. An earlier OK does not carry over.
- Deploy triggers across the system: backend `main` → `deploy.yml` (production API); app `develop`/`main` → `play-store-release.yml` (Google Play); admin `main` → `deploy-production.yml` (production admin); website → manual Bluehost upload.

## Testing against production

- **Debug builds of the app point at `10.0.2.2:8081`** (the local backend from the Android emulator). Testing against production is done **only with a release build**, and only when the owner has asked for it.
- QA on production has side effects even when it only reads. **Report every one**: analytics events, view counts, search-query logs (they feed trending searches), engagement/feed signals, push-token registrations, accounts or sessions created, images generated. "I only browsed" is not "no side effects".

## When unsure

Stop and ask. On a live system with no staging, a question costs a minute; a wrong write costs users.
