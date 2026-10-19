# Rule — tracker first, before the work

Loaded every session. **This rule is the one most often forgotten**, so read it before starting anything.

## The rule

**Every request becomes granular tracker rows BEFORE the first tool call of the work.** Not after it lands, not at the end of the session.

```bash
TRACKER=sukhan python3 /Users/mansoorahmadsamar/Documents/Development/dolce-ict/tools/tracker.py add \
  --area Feed --task "..." --sub "Feature · App" \
  --prio P1 --status "In progress" --start today --due +2 \
  --notes "..."

TRACKER=sukhan python3 /Users/mansoorahmadsamar/Documents/Development/dolce-ict/tools/tracker.py set T-0NN status=Done release=Local
```

**`TRACKER=sukhan` is not optional.** The tool's default is the Dolce HR sheet (`TRACKER=hr`); Sukhan work written there makes both sheets wrong. Bugs use `--sub "Bug · App"`.

If a tracker call fails with a dropped connection, retry it.

## Why

The owner uses the tracker to justify his time and effort. One big row hides the real work, and rows added afterwards defeat the purpose — he needs them **as the time is spent**, not reconstructed later.

## The failure mode, so you can recognise it

**The trigger is a new request, not a new session.** The rule gets missed in long working sessions where each request feels like a continuation of the last, so rows never get added. In the Dolce projects it was missed on 30 September 2026: whole phases were built before any row existed, and 38 rows had to be backfilled.

If you find yourself thinking *"this is just a follow-up"* — that is the moment rows are due.

## What gets a row

- Every request, chunked small. "Chunk down to small so I can justify my time and effort."
- **Bugs found mid-work get their own rows.** They are real work and they go unrecorded otherwise.
- Documentation, configuration, QA and deployment changes too — not only features.

## Granularity

One row per shippable piece, not one row per request.

| Too coarse | Right |
|---|---|
| "Search improvements" | Roman couplet search returns nothing · couplet result has no poem id · autocomplete dedupe |
| "Engineering setup" | gitleaks config + baseline · pre-commit hook · .claude guardrails · SECURITY.md rotation list |
| "Feed fixes" | `"-"` colour crashes hashtag row · featured poets duplicated · expired-session error state |

## Areas

From the sheet's `Lists` tab: Auth, Feed, Discover, Search, Engagement, Poets, Poems & Couplets, Image Poetry, Creator Mode, Admin Portal, Website, Backend Platform, Data Quality, Performance, Security, Testing, CI/CD & Deployment, Documentation, Localization & Accessibility.

## Sheet

**Sukhan — Urdu Poetry & Literature Tracker** · `1FXP_Axrvcnw0xG7tv3Nka9V5kcS8l8gbNkKT0lmPZro`, pinned in `tracker.py` as `TRACKER=sukhan`.

Note: the service account has **zero Drive quota** — it can write to a shared sheet but can never create one. A new tracker always needs the owner to create it first.
