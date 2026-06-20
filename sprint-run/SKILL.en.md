---
name: sprint-run
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Sprint configurator with /goal engine: prepares an entire sprint (pre-flight, specs,
  worktrees per story, subagent definitions, token budget) and hands execution over to the
  native termination engine `/goal`. `/goal` orchestrates the stories in parallel as native
  subagents (worktree-isolated) and runs until the termination phrase is satisfied (all issues
  done, all quality gates green, sprint journal written). `/sprint-run` writes no product code
  and does not change the orchestrated skills — it configures the sprint and calls `/goal`.
  Use when the operator says "run the sprint", "drive the sprint", "automation-cycle"
  or "/sprint-run".
version: 2.1.0
metadata:
  hermes:
    category: governance
    tags: [orchestration, sprint-automation, goal-engine, execution-isolation, token-boundary, gate-block-safety]
    requires_toolsets: [terminal, git, linear]
    related_skills: [backlog, implement, sprint-review, ideation, goal, quality-gate-audit]
---

# Sprint-Run

Prepares a complete sprint and hands execution over to the native termination engine **`/goal`**.
`/sprint-run` is a **configurator + `/goal` wrapper**: it loads context, checks the pre-flight
gates, creates a `git worktree` per story, generates the `.claude/agents/` definitions from the
subagent sections of the specs, plans the token budget — and then calls `/goal` with a
**termination phrase**. `/goal` orchestrates the stories as native subagents in parallel
(worktree-isolated) and runs until the phrase is satisfied.

`/sprint-run` writes **no** product code of its own and does not change the orchestrated skills.
Story parallelization is done by **native subagents**, termination by **`/goal`** — no longer by
a skill-owned container/hybrid driver.

> **Distinction from `/implement`:** `/implement` implements **one** story. `/sprint-run`
> configures **N** stories as a sprint and lets `/goal` execute them. Whoever wants to implement a
> single story uses `/implement` directly.

> **Breaking change (2.0.0, ADR-4):** Up to 1.x `/sprint-run` was a hybrid container orchestrator
> with its own daemon loop. From 2.0.0 the container logic (Dockerfile, `devcontainer.json`,
> volume mount, lazy build), the hybrid driver and the `/implement`-as-container-simulation loop
> are **gone** — replaced by native subagents under `/goal`. See section
> [„What is removed"](#what-is-removed-adr-4).

## `/goal` as termination engine

`/goal` is the **native Anthropic termination engine** (documented in the skill [`goal/`](../goal/SKILL.en.md)).
It takes a **termination phrase**, orchestrates native subagents and runs until an evaluator sees
the phrase as satisfied. `/sprint-run` gives `/goal` two things: the **prepared environment**
(worktrees, agent definitions, budget) and the **phrase** that defines sprint end by machine. The
loop mechanic (worker fixes → gate again → evaluator checks) belongs to `/goal`, no longer to
`/sprint-run`.

## Workflow

### Phase A — Preparation (configurator)

#### Step 0: Load environment + sprint context

- Read `.claude/environment.json`: `thresholds.token_warn_threshold`, `token_hard_threshold`
  (default 70/80), `tools_available.{git,gh,linear}`, paths.
- Read `CONVENTIONS.md`: `backlog_adapter` (Linear/GitHub/none), `governance_mode`,
  `execution_isolation`, `worktree_strategy`.
- Fallback: if `environment.json` is missing, continue with defaults and warn (soft).

#### Step 1: Sprint pre-flight ⛔ HARD GATE

Exactly once per sprint — `/goal` must **not** be started on an unclean sprint. Check and, on
violation, STOP with a concrete remediation hint:

- **Backlog prioritized?** `/backlog` delivers an ordered candidate list (status `Todo`/`Backlog`,
  ordered by priority). Empty → STOP.
- **Specs complete?** For **every** candidate story `specs/<ISSUE>.md` exists (spec gate),
  is Schrader-complete (Insight, Constraints, Success Criteria, Desired Outcome) and carries the
  `Execution Isolation` block (`execution_mode`, `worktree_strategy`, `write_scopes`) **plus a
  subagent section** (from which the agent definition in step 4 is generated). If something is
  missing → remove the story from the sprint or STOP.
- **Governance gates green?** `governance_mode` from CONVENTIONS; active gates (sensitive-paths,
  personal-data) are configured and the pause behavior (sensitive-path approval) is wired.
- **Tooling ready?** `git worktree` available, `gh` authenticated (for remote CI gates),
  working tree on `main` clean.
- **Quality gates wired?** (BOO-183, **PRESERVED**) Call `/quality-gate-audit --trigger pre-sprint`
  — it checks whether the declared gates (Semgrep wiring, coverage, slopsquatting, Layer-0
  bodyguard) are actually wired rather than only nominally configured. Engine:
  `quality-gate-audit/scripts/gate-checks.sh`, exit `0` = all `wired`/accepted-override, exit `1` =
  at least one gate `blind`. **At least one gate `blind` → STOP** with a pointer to the remediation
  hint in the audit report (`docs/audits/YYYY-MM-DD-quality-gate-audit.md`). Override only
  deliberately: `/quality-gate-audit --override-gate <name> --reason "..."` (transient) or report
  frontmatter `override_blind: true` + `reason` (persistent).

> This gate is the prerequisite for `/goal` to run without follow-up questions afterwards.
> Details: [references/orchestration-checklist.en.md](references/orchestration-checklist.en.md).
> Cross-link: the pre-sprint trigger is defined in the [quality-gate-audit](../quality-gate-audit/SKILL.en.md) skill.

#### Step 2: Three safety prerequisites (pre-/goal checks) ⛔

Before `/goal` is called, three safety prerequisites **must** be met. Each is a hard check — if one
is missing, `/goal` is **not** started:

1. **Bash permission auto-allow for gate commands.** So that `/goal` and its subagents can run the
   quality gates unattended, `.claude/settings.local.json` must carry an **allowlist**
   (`permissions.allow`) with the gate commands: `semgrep`, `eslint`, `pytest`, `gh run`, `git`.
   `/bootstrap` creates the template (see `bootstrap/references/file-templates.md`, block
   ".claude/settings.local.json (BOO-203)"). Missing allowlist → STOP with a pointer to the
   template (otherwise every gate execution blocks on a permission prompt).
2. **Worktree as safety boundary.** The skill checks `execution_isolation=worktree` (from
   CONVENTIONS) **before** the `/goal` call. If the isolation is **not** `worktree` → **abort**.
   Native subagents may only write in parallel in worktree-isolated working trees; without this
   boundary their changes collide.
3. **Layer-0 bodyguard active.** The skill checks via self-audit that the `pre-edit-bodyguard` hook
   is wired (entry in `.claude/settings.json` `hooks` + file present). If the bodyguard is **not
   live** → the skill **pauses** with "Bodyguard not active" and does not run `/goal`.

> The three prerequisites replace the former container boundaries (1.x): worktree instead of
> container volume, allowlist instead of container permissions, bodyguard instead of container
> sandbox.

#### Step 3: Plan the sprint token budget (BOO-38/40, **PRESERVED**)

- Sprint = **80% of the context window** of the model used (token box instead of time box,
  HANDBUCH Appendix G). No burndown, no velocity.
- Project the sum of the `token_estimate` of all candidate stories against the 80% budget.
  Move stories that blow the budget to the next sprint (hint, no abort).
- Determine order/dependencies: `blockedBy` first, then priority — as a hint for `/goal` (which
  stories must run sequentially instead of in parallel).
- Result: ordered sprint list + projected budget. Details:
  [references/token-boundary.en.md](references/token-boundary.en.md).

#### Step 4: Generate worktrees + subagent definitions

Per story of the planned sprint list:

| # | Action |
|---|--------|
| 4.1 | **Create worktree:** `git worktree add ../wt-<ISSUE> -b feat/boo-<n>-<slug>` (own branch per story, safety boundary from step 2.2). |
| 4.2 | **Generate subagent definition:** from the **subagent section** of the spec create a `.claude/agents/<story>-<agent>.md` (role, worktree path, `write_scopes`, story ID, gate list). `/goal` reads this file when spawning the story worker subagent. |
| 4.3 | **Linear → In Progress** (adapter from CONVENTIONS; with `none` log locally) — optional, `/goal` can also set this per story. |

Result of phase A: per story a worktree + an agent definition, a token budget, the checked safety
prerequisites. Details: [references/worktree-flow.en.md](references/worktree-flow.en.md).

### Phase B — `/goal` call

#### Step 5: Start `/goal` with a termination phrase

The skill calls the native termination engine `/goal` with a **termination phrase** that defines
sprint end by machine. Example:

```
/goal "Sprint <id> closed: all Linear issues status:done, all quality gates green
(Semgrep, ESLint, Coverage>=80%, GitHub Actions), journal/sprint-<date>.md written,
no open subagent tasks"
```

Phrase library (curated, tested phrases): [references/goal-termination-phrases.en.md](references/goal-termination-phrases.en.md).

#### Step 6: `/goal` orchestrates (belongs to `/goal`, not `/sprint-run`)

From here `/goal` takes over execution:

- **Native subagents in parallel per story** (worktree-isolated, agent definition from step 4.2).
  `parallel_story_limit` from CONVENTIONS bounds the concurrent workers.
- **Gate-failure recovery:** If a quality gate fails, the worker agent fixes it and calls the gate
  again; the evaluator sees "not yet satisfied" → loop until green. (This loop mechanic, which was
  the daemon loop in 1.x, now belongs to `/goal`.)
- **Approval need (sensitive path):** If a story touches a sensitive path or personal data, `/goal`
  **pauses**, the operator answers (`review-ok` / `privacy-ok`, also remote). **No** automatic
  bypass, **no** timeout resume. Protocol:
  [references/gate-block-handling.en.md](references/gate-block-handling.en.md).
- **Post-story gate assertion:** Before merging a story, `/goal` reads its
  `journal/reports/local/<run>/meta.json` and verifies by machine that no mandatory gate was
  **silently** skipped. Ruleset unchanged:
  [references/gate-assertion.en.md](references/gate-assertion.en.md).
- **Token boundary (BOO-38/40, PRESERVED):** The 80% token boundary is part of the termination
  logic — on reaching it `/goal` terminates the sprint even if stories are still open (they remain
  in the backlog). Details: [references/token-boundary.en.md](references/token-boundary.en.md).

### Phase C — Completion

#### Step 7: Aggregate the sprint journal

After termination by `/goal`, `/sprint-run` (or `/sprint-review`) aggregates the
`journal/reports/local/*/meta.json` of the story runs into `journal/sprint-<date>.md` (metrics,
learning loop). Optionally prepend an `/insights` meta block.

#### Step 8: Sprint report (mandatory output)

Final table:

| Story | Status | Token | Gates | Worktree |
|---|---|---|---|---|
| BOO-XX | Done / Failed / Skipped | ~Xk | green/red | cleaned up |

Plus: total token consumption (% of budget), `/goal` approval pauses, remaining backlog stories,
reference to the `/sprint-review` result.

#### Step 9: Cost snapshot (BOO-189, **PRESERVED**)

At sprint close, capture the **actual consumption** from the local Claude Code logs — as a measured
quantity, not a guess:

- Call: `bash .claude/hooks/ccusage-capture.sh "/sprint-run <sprint>"` (capture template from setup,
  internally `npx --yes ccusage@latest daily`). Appends a token/cost snapshot to
  `docs/financials/sprint-costs.md`.
- **Soft gate:** if the call fails (ccusage/npx not installed, no log), **only warn** and **do not
  abort** the sprint close — the report from step 8 stays valid.
- **Complementary to the estimate:** this actual value complements the `token_tracking` from the
  story `meta.json`; it does not replace it.
- **Known limitation:** ccusage does not attribute sub-agent tokens (Task tool) cleanly (issues
  #313/#806/#950) — in heavily sub-agent-driven `/goal` runs the reported consumption may be
  incomplete or charged to the parent.

## What is removed (ADR-4)

With 2.0.0 the following mechanisms from 1.x are **removed** — they are replaced by native
subagents under `/goal` and must **no longer** be wired:

| Removed (1.x) | Replacement (2.0.0) |
|---|---|
| Dockerfile + `devcontainer.json` for the sprint-run purpose | Worktree as safety boundary (step 2.2) |
| Container lifecycle / lazy container bootstrap | `/goal` spawns native subagents on demand |
| Hybrid driver approval mechanic | `/goal` pause on sensitive path (step 6) |
| Container volume mount | `git worktree` per story |
| `/implement`-in-daemon-mode per story as container simulation | native subagents under `/goal` |
| Skill-owned daemon loop (`--auto`) | termination loop belongs to `/goal` |

> In 2.0.0 there is **no** container and **no** skill-owned daemon loop anymore. `/sprint-run`
> configures and hands over; the execution loop lives in `/goal`.

## E2E validation

A real autonomous sprint cannot be run within the skill implementation. The **manual operator
validation protocol** (1-story sprint with `/goal`, incl. gate-failure recovery) lives in
[references/goal-e2e-protocol.en.md](references/goal-e2e-protocol.en.md). To play it through:
[references/goal-e2e-fixture.en.md](references/goal-e2e-fixture.en.md) sets up the throwaway test
project (trivial story + provoked gate failures), and
[references/goal-e2e-journal-template.en.md](references/goal-e2e-journal-template.en.md) is the
fill-in journal for the run (incl. BOO-203 DoD reconciliation).

## Integration with other skills

| Upstream | What is delivered | Downstream | What we deliver |
|----------|--------------------|------------|------------------|
| `ideation` | Stories + specs (incl. subagent section) | `goal` | termination phrase, worktrees, agent definitions, budget |
| `backlog` | Prioritized sprint list | `sprint-review` (sprint end) | aggregated story metrics (meta.json) |

Chain: `intent → ideation → backlog → sprint-run → /goal ( native subagents )* → sprint-review`.

## Trigger phrases

- `/sprint-run`
- "run the sprint"
- "drive the sprint"
- "automation-cycle"

## Configuration

Fields (in `.claude/environment.json` or `CONVENTIONS.md`, plus per story in the spec `Execution Isolation` block):

| Field | Meaning | Default |
|---|---|---|
| `token_hard_threshold` | Sprint boundary in % of the context window (part of `/goal` termination) | `80` |
| `execution_isolation` | Must be `worktree` (safety prerequisite step 2.2) | `worktree` |
| `worktree_strategy` | Isolation per story | `git-worktree` |
| `parallel_story_limit` | Max. parallel story subagents under `/goal` (1 = sequential) | `1` |

## File structure

```
sprint-run/
├── SKILL.md                                  ← Skill definition (2.0.0)
├── SKILL.en.md                               ← English mirror
├── README.md                                 ← German README (Version: 2.0.0)
├── README.en.md                              ← English README
├── overview.excalidraw / .png                ← Skill overview sketch (+ .en)
└── references/
    ├── orchestration-checklist.md            ← Sprint pre-flight + pre-/goal checks (+ .en.md)
    ├── goal-termination-phrases.md           ← Termination phrase library (+ .en.md)
    ├── goal-e2e-protocol.md                  ← Manual 1-story E2E protocol (+ .en.md)
    ├── goal-e2e-journal-template.md          ← Fill-in E2E journal (BOO-203 DoD reconciliation) (+ .en.md)
    ├── goal-e2e-fixture.md                   ← Throwaway test-project runsheet (story + gate failures) (+ .en.md)
    ├── gate-block-handling.md                ← /goal pause/resume on sensitive path (+ .en.md)
    ├── gate-assertion.md                     ← Post-story gate assertion (meta.json) (+ .en.md)
    ├── worktree-flow.md                      ← Worktree per story: add → merge → remove (+ .en.md)
    └── token-boundary.md                     ← 80% boundary as part of /goal termination (+ .en.md)
```
