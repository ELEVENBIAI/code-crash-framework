# Runbook: /sprint-run — run a whole sprint with `/goal`

> For operators who no longer want to steer a sprint story by story: `/sprint-run` prepares the sprint (pre-flight, specs, a worktree per story, subagent definitions, token budget) and hands execution to the native termination engine `/goal`. `/goal` orchestrates the stories in parallel as native subagents, fixes red gates, pauses on sensitive paths and terminates once the termination phrase is met. DE: [`sprint-run.md`](sprint-run.md).

> **History:** Up to v0.10.x, `/sprint-run` was a daemon loop (`/implement` per story); since v0.11.0/2.0.0 it uses the native `/goal` engine — see ADR-4.

## When this runbook?

You have a prioritized backlog of fully specified stories and want to run the sprint **in one go** — without manually kicking off the next story after each one. This is the **sprint automation** case. `/sprint-run` configures the sprint and calls `/goal`; the unattended run results from `/goal` running autonomously once the three safety preconditions plus the allowlist are satisfied — not from a skill-owned daemon.

Distinction:
- Ship **one** story deliberately → `/implement` directly (long stories can use `/goal` for termination).
- **Plan/prioritize** a sprint (not yet implement) → `/backlog`.
- **Wrap up** a sprint (lessons, metrics) → `/sprint-review`.

## The full skill chain

```
intent  →  ideation  →  backlog  →  sprint-run  →  /goal ( native subagents )*  →  sprint-review
  │           │            │            │                   │                          │
direction  story+spec   order +      configurator       termination engine          lessons +
+ why      + ADD        priority     + /goal wrapper      parallel stories            metrics
```

`/sprint-run` is the connective tissue: it consumes the prioritized list from `/backlog`, prepares a worktree + agent definition per story and hands execution to `/goal`. The termination loop (worker fixes → gate again → evaluator checks) belongs to `/goal`, not `/sprint-run`.

## Before the sprint — checklist

- [ ] **Backlog prioritized** — `/backlog` has run, order is set.
- [ ] **Specs complete** — every sprint story has `specs/<ISSUE>.md` (Schrader-complete, with `Execution Isolation` block: `execution_mode`, `worktree_strategy`, `write_scopes` — **and** a subagent section the agent definition is generated from).
- [ ] **Pre-flight green** — `/quality-gate-audit --trigger pre-sprint` passes with no `blind` gate (otherwise STOP).
- [ ] **Three safety preconditions met** — (1) allowlist with gate commands in `.claude/settings.local.json`, (2) `execution_isolation=worktree` in CONVENTIONS, (3) Layer-0 `pre-edit-bodyguard` hook live.
- [ ] **Tooling ready** — `git worktree` available, `gh` authenticated, `main` clean.

## Step 1 — example session (from intent to sprint)

```text
# 1. Set direction (once)
/intent        → capture product intent + why

# 2. Create stories (per idea)
/ideation      → story + spec (specs/BOO-XX.md, incl. subagent section) + ADD

# 3. Plan the sprint
/backlog       → prioritized order, dependencies resolved

# 4. Prepare the sprint + call /goal  ← this runbook
/sprint-run    → pre-flight, worktrees + agent definitions, token budget, then /goal

# 5. Wrap up (after /goal terminates)
/sprint-review → lessons + metrics
```

## Step 2 — invoke `/sprint-run`

Open Claude Code **in the project folder** and type `/sprint-run`. The skill works through its phases:

- **Phase A (preparation):** load environment + sprint context, sprint pre-flight (hard gate incl. `/quality-gate-audit --trigger pre-sprint`), check the three safety preconditions, plan the token budget (80% of the context window), then per story `git worktree add` + generate `.claude/agents/<story>-<agent>.md`.
- **Phase B (`/goal` call):** start `/goal` with a **termination phrase** that defines the sprint end machine-checkably:

```text
/goal "Sprint <id> closed: all Linear issues status:done, all quality gates green
(Semgrep, ESLint, Coverage>=80%, GitHub Actions), journal/sprint-<date>.md written,
no open subagent tasks"
```

From here `/goal` orchestrates: native subagents in parallel per story (worktree-isolated, `parallel_story_limit` from CONVENTIONS caps concurrent workers), gate-failure recovery, pause on sensitive paths, post-story gate assertion before each merge, termination when the phrase is met or at the 80% token boundary.

> **Claude Code mode:** supervised → `acceptEdits`; unattended → `dontAsk` + allowlist (`.claude/settings.local.json`). **Not** plan mode (read-only, blocks execution). The termination phrase contains **no** manual steps (approval pauses belong in the gate-block protocol, not in the phrase) — otherwise `/goal` never terminates.

## Typical failure scenarios + fixes

| Scenario | What `/goal` / pre-flight does | What you do |
|---|---|---|
| Story without a spec / without a subagent section | pre-flight (Phase A) drops it from the sprint or STOPs | run `/ideation` or add the spec |
| `blind` gate in the pre-sprint audit | pre-flight STOPs — `/goal` is not started | fix per the audit report hint, retry; override only deliberately (`--override-gate` / report frontmatter) |
| allowlist / worktree isolation / bodyguard missing | safety precondition not met → abort/pause before `/goal` | apply the `/bootstrap` template, set `execution_isolation=worktree`, wire the bodyguard hook |
| Sensitive-path hit | `/goal` **pauses** + notify (story ID + path) | review, then `review-ok: <name> - <comment>` |
| Personal-data hit | `/goal` **pauses** + notify (GDPR) | DPO review, then `privacy-ok: ...` |
| Quality gate red | worker agent fixes and re-runs the gate; evaluator sees "not yet met" → loop until green | nothing — intervene only on persistent red (`gh run view --log-failed`) |
| Unjustified gate skip / missing `meta.json` | post-story gate assertion fails → story not merged + notify | check `meta.json`; run the gate or justify the override |
| 80% token boundary reached | `/goal` terminates the sprint, open stories stay in the backlog | plan the next sprint (`/backlog`) |
| `main` not clean | pre-flight STOPs before `/goal` | clean the working tree, restart |

## Safety & idempotency

- **Gate blocks are never bypassed automatically** — no bypass, no timeout resume; each approval covers exactly one block.
- **No merge without green remote CI** and without a clean gate assertion (`meta.json`).
- **Worktree as safety boundary** — native subagents only write in parallel in worktree-isolated trees; without `execution_isolation=worktree`, `/goal` does not start. Prune orphaned worktrees before the next run (`git worktree prune`).
- **Layer-0 bodyguard** blocks secrets and sensitive paths before writing; if it is not live, `/goal` does not run.
- **`.env`/secrets/local reports** never touched, never committed.
- **Repeatable:** an aborted sprint can be restarted — already-merged stories are `Done`, `/goal` picks up the next open ones.

## After

- After `/goal` terminates, `/sprint-run` (or `/sprint-review`) aggregates `journal/reports/local/*/meta.json` into `journal/sprint-<date>.md` and emits the sprint report (story · status · token · gates · worktree, total tokens as % of budget, approval pauses, remaining stories).
- Optional cost snapshot (soft gate): `bash .claude/hooks/ccusage-capture.sh "/sprint-run <sprint>"` — if it fails, just warn.
- Read the `/sprint-review` result, re-prioritize remaining stories for the next sprint (`/backlog`).

## References

`sprint-run/SKILL.en.md` (workflow, v2.0.0) · `goal/README.en.md` (native termination engine) · `sprint-run/references/{orchestration-checklist,goal-termination-phrases,goal-e2e-protocol,gate-block-handling,gate-assertion,worktree-flow,token-boundary}.en.md` · HANDBUCH Appendix AD (chapter + sketches) · Appendix AH · Appendix G (sprint sizing) · [run a sprint unattended with tmux](sprint-unattended-tmux.en.md).
