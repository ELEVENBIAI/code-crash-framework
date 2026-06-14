# Orchestration checklist — sprint pre-flight + pre-/goal checks

Reference for `/sprint-run` step 1 (sprint pre-flight, HARD GATE), step 2 (three safety
prerequisites) and step 4 (preparation per story). `/goal` may only be started once **all**
pre-flight points **and** all three safety prerequisites are green.

## Sprint pre-flight (step 1) ⛔

| Check | Pass criterion | On violation |
|---|---|---|
| Backlog prioritized | `/backlog` delivers ordered candidates (`Todo`/`Backlog`, order) | STOP — run `/backlog` first |
| Spec per story | `specs/<ISSUE>.md` exists (spec gate) | remove story from sprint / STOP |
| Schrader-complete | Insight, Constraints, Success Criteria, Desired Outcome each ≥20 chars | remove story from sprint |
| Execution-Isolation block | spec carries `execution_mode`, `worktree_strategy`, `write_scopes` | remove story from sprint |
| Subagent section | spec carries a subagent section (source of the agent definition, step 4.2) | remove story from sprint |
| Governance gates | `governance_mode` from CONVENTIONS; sensitive-paths/personal-data configured | clarify pause behavior |
| Quality gates wired | `/quality-gate-audit --trigger pre-sprint` exit 0 (BOO-183) | STOP — audit report remediation |
| Tooling | `git worktree` present, `gh` authenticated, `main` clean | STOP |

> The pre-flight is the condition for `/goal` to run without follow-up questions afterwards.

## Three safety prerequisites (step 2) ⛔

Directly before the `/goal` call. If one is missing → `/goal` is **not** started.

| Prerequisite | Pass criterion | On violation |
|---|---|---|
| Bash allowlist | `.claude/settings.local.json` has `permissions.allow` with `semgrep`/`eslint`/`pytest`/`gh run`/`git` | STOP — template from `bootstrap/references/file-templates.md` (BOO-203) |
| Worktree boundary | `execution_isolation=worktree` (CONVENTIONS) | **abort** — native subagents need worktree isolation |
| Layer-0 bodyguard | `pre-edit-bodyguard` hook in `.claude/settings.json` `hooks` + file present | **pause** — "Bodyguard not active" |

## Preparation per story (step 4)

- [ ] Worktree created: `git worktree add ../wt-<ISSUE> -b feat/boo-<n>-<slug>`
- [ ] Working tree in the worktree clean
- [ ] Subagent definition `.claude/agents/<story>-<agent>.md` generated from the spec subagent section
- [ ] (optional) Linear status set to `In Progress`

## What `/goal` takes over (no longer `/sprint-run`)

The following mechanic belongs to `/goal` since 2.0.0 (ADR-4), no longer to the skill:

- Spawning the native subagents per story (in parallel, up to `parallel_story_limit`)
- Gate-failure recovery (worker fixes → gate again → evaluator checks → loop until green)
- Remote CI wait + merge only on green CI
- Post-story gate assertion against `meta.json` (see `gate-assertion.en.md`)
- Sensitive-path/personal-data pause (see `gate-block-handling.en.md`)
- 80% token boundary as part of termination (see `token-boundary.en.md`)

## Anti-patterns

- **Taking a story without spec/subagent section into the sprint** — `/goal` cannot spawn a story
  subagent without an agent definition. Catch it in the pre-flight.
- **Starting `/goal` without a checked `execution_isolation=worktree`** — collision risk between
  parallel subagents (level 2, see `docs/kollisionsschutz-drei-ebenen.md`).
- **Wiring a container/Dockerfile for the sprint-run purpose** — removed since 2.0.0 (ADR-4).
- **Building a skill-owned daemon loop** — the execution loop now lives in `/goal`.
