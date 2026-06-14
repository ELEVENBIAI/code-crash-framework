# Runbook: /sprint-run — run a whole sprint fully automatically

> [!warning] Deprecated since v0.11.0 — see ADR-4 (sprint-run with `/goal`)
> This runbook describes the **daemon-loop model** (`/implement` per story), valid up to v0.10.x. As of **v0.11.0 (BOO-203, build-vs-buy pivot)**, `/sprint-run` is a **configurator + `/goal` wrapper** (native termination engine instead of an in-house loop). The authoritative sources are now: skill [`sprint-run`](../../sprint-run/SKILL.en.md) (v2.0.0), [`goal/README.en.md`](../../goal/README.en.md) and **HANDBUCH Appendix AD/AH**. The following remains a historical reference until the runbook is rewritten.

> For operators who no longer want to steer a sprint story by story: `/sprint-run` picks stories from the prioritized backlog, implements each via `/implement` in daemon mode (its own `git worktree` + branch), maintains Linear, waits for green CI, merges, cleans up and closes with `/sprint-review`. DE: [`sprint-run.md`](sprint-run.md).

## When this runbook?

You have a prioritized backlog of fully specified stories and want to run the sprint **in one go** — without manually kicking off the next story after each one. This is the **sprint automation** case.

Distinction:
- Ship **one** story deliberately → `/implement` directly.
- **Plan/prioritize** a sprint (not yet implement) → `/backlog`.
- **Wrap up** a sprint (lessons, metrics) → `/sprint-review` (which `/sprint-run` calls itself at the end).

## The full skill chain

```
intent  →  ideation  →  backlog  →  sprint-run  →  ( implement )*  →  sprint-review
  │           │            │            │               │                  │
direction  story+spec   order +      orchestrator    per story         lessons +
+ why      + ADD        priority     (daemon)        code + CI         metrics
```

`/sprint-run` is the connective tissue: it consumes the prioritized list from `/backlog`, calls `/implement` per story and hands off to `/sprint-review` at sprint end.

## Before the sprint — checklist

- [ ] **Backlog prioritized** — `/backlog` has run, order is set.
- [ ] **Specs complete** — every sprint story has `specs/<ISSUE>.md` (Schrader-complete, with `Execution Isolation` block: `execution_mode`, `worktree_strategy`, `token_estimate`).
- [ ] **Governance gates green** — `sensitive-paths.json` / `personal-data-paths.json` configured; you know the daemon **pauses** on hits.
- [ ] **Tooling ready** — `git worktree` available, `gh` authenticated, `main` clean.

## Step 1 — example session (from intent to sprint)

```text
# 1. Set direction (once)
/intent        → capture product intent + why

# 2. Create stories (per idea)
/ideation      → story + spec (specs/BOO-XX.md) + ADD

# 3. Plan the sprint
/backlog       → prioritized order, dependencies resolved

# 4. Run the sprint  ← this runbook
/sprint-run    → daemon loop over the top-N stories

# 5. Wrap up (triggered by the daemon at the 80% boundary)
/sprint-review → lessons + metrics
```

## Step 2 — invoke `/sprint-run`

Open Claude Code **in the project folder** and type `/sprint-run` (interactive, with sprint-plan approval) — or for the unattended run:

```text
/sprint-run --auto
```

The daemon first shows the sprint plan (stories, order, projected token budget), then runs per story: `git worktree add` → `/implement` (daemon) → `gh run watch` → merge (green only) → Linear → Done → `git worktree remove`. With `--auto` the plan approval is skipped — **except** at gate blocks, which always halt.

> **Both modes actually execute the sprint** (incl. merge to `main`); `--auto` only drops the one-time plan approval — there is no pure "check-only" mode. **Claude Code mode:** supervised → `acceptEdits`, unattended → `dontAsk` + allowlist; **not** plan mode (read-only, blocks execution). The sprint plan is the skill's plan, **not** the Claude Code plan mode. Details: HANDBUCH §6 "Claude Code mode".

## Typical failure scenarios + fixes

| Scenario | What the daemon does | What you do |
|---|---|---|
| Story without a spec | pre-flight drops it from the sprint (logged) | run `/ideation` or add the spec |
| Sensitive-paths hit | **pause** + notify (story ID + path) | review, then `review-ok: <name> - <comment>` |
| Personal-data hit | **pause** + notify (GDPR) | DPO review, then `privacy-ok: ...` |
| Remote CI stays red (3×) | no merge, escalation, story stays In Progress | check log (`gh run view --log-failed`), fix |
| `/implement` fails | story back to Backlog; `daemon_fail_policy` (stop/continue) | find the cause, re-schedule the story |
| Unjustified gate skip / missing `meta.json` (4.5b) | assertion fails → story back to Backlog + notify | check `meta.json`; run the gate or justify the override |
| 80% token boundary reached | end loop + `/sprint-review` + note | plan the next sprint |
| `main` not clean | STOP before merge | clean the working tree, restart |

## Safety & idempotency

- **Gate blocks are never bypassed automatically** — no bypass, no timeout resume; each approval covers exactly one block.
- **No merge without green remote CI** (BOO-148).
- **`.env`/secrets/local reports** never touched, never committed.
- **Worktrees** are removed after each story run; prune orphaned worktrees before the next run (`git worktree prune`).
- **Repeatable:** an aborted sprint can be restarted — already-merged stories are `Done`, the daemon picks up the next open ones.

## After

- Read the `/sprint-review` result (`journal/sprint-<date>.md`): lessons, metrics, token usage.
- Re-prioritize remaining stories for the next sprint (`/backlog`).

## References

`sprint-run/SKILL.md` (workflow) · `sprint-run/references/{orchestration-checklist,gate-block-handling,worktree-flow,token-boundary}.md` · HANDBUCH Appendix AD (chapter + sketches) · Appendix G (sprint sizing) · `bootstrap/references/framework-upgrade.md` · BOO-148 (remote-CI loop) · BOO-157 · [run a sprint unattended with tmux](sprint-unattended-tmux.en.md).
