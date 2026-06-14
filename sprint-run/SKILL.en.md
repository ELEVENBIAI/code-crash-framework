---
name: sprint-run
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Sprint orchestrator: runs an entire sprint fully automatically. Selects stories from the
  prioritized backlog, calls `/implement` per story in daemon mode (own `git worktree`
  + branch), updates the Linear status, waits for green remote CI, merges, cleans up the
  worktree, and automatically triggers `/sprint-review` at the 80% token boundary. Pure
  orchestrator — `/implement`, `/backlog`, `/sprint-review` remain unchanged.
  Use when the operator says "run the sprint", "drive the sprint", "automation-cycle"
  or "/sprint-run". Also usable by the automation daemon (without human-in-the-loop).
version: 1.2.0
metadata:
  hermes:
    category: governance
    tags: [orchestration, sprint-automation, execution-isolation, token-boundary, gate-block-safety]
    requires_toolsets: [terminal, git, linear]
    related_skills: [backlog, implement, sprint-review, ideation]
---

# Sprint-Run

Orchestrates a complete sprint: from story selection out of the prioritized backlog,
through the fully automatic implementation of each story (`/implement` in daemon mode, each in its
own `git worktree`), to sprint completion (`/sprint-review`). `/sprint-run` writes
**no** product code of its own and does not change the orchestrated skills — it **chains**
them and takes over the sprint mechanics (ordering, worktrees, Linear status, CI wait,
token boundary, gate-block pause).

> **Distinction from `/implement`:** `/implement` implements **one** story. `/sprint-run` runs
> **N** stories as a sprint and calls `/implement` per story. Whoever wants to implement a single
> story uses `/implement` directly.

## Workflow (steps 0–7)

### Step 0: Load environment + sprint context

- Read `.claude/environment.json`: `thresholds.token_warn_threshold`, `token_hard_threshold`
  (default 70/80), `tools_available.{git,gh,linear}`, paths.
- Read `CONVENTIONS.md`: `backlog_adapter` (Linear/GitHub/none), `governance_mode`,
  `execution_isolation`, `worktree_strategy`.
- Detect mode: interactive (default) vs. daemon (`/sprint-run --auto` or webhook) —
  in daemon mode the operator approval in step 3 is dropped (analogous to `/implement` step 4).
- Fallback: if `environment.json` is missing, continue with defaults and warn (soft).

### Step 1: Sprint pre-flight ⛔ HARD GATE

Exactly once per sprint — the daemon must **not** start with an unclean sprint.
Check and, on violation, STOP with a concrete remediation hint:

- **Backlog prioritized?** `/backlog` delivers an ordered candidate list (status `Todo`/`Backlog`,
  ordered by priority). Empty → STOP.
- **Specs complete?** For **every** candidate story `specs/<ISSUE>.md` exists (spec gate),
  is Schrader-complete (Insight, Constraints, Success Criteria, Desired Outcome) and
  carries the `Execution Isolation` block (`execution_mode`, `worktree_strategy`, `write_scopes`).
  If something is missing → remove the story from the sprint or STOP (daemon: skip story + log it).
- **Governance gates green?** `governance_mode` from CONVENTIONS; active gates (sensitive-paths,
  personal-data) are configured and the daemon knows the pause behavior (step 4.4).
- **Tooling ready?** `git worktree` available, `gh` authenticated (for remote CI wait),
  working tree on `main` clean.
- **Quality gates wired?** (BOO-183) Call `/quality-gate-audit --trigger pre-sprint` — it checks
  whether the declared gates (Semgrep wiring, coverage, slopsquatting, Layer-0 bodyguard) are
  actually wired rather than only nominally configured. Engine: `quality-gate-audit/scripts/gate-checks.sh`,
  exit `0` = all `wired`/accepted-override, exit `1` = at least one gate `blind`.
  **At least one gate `blind` → STOP** with a pointer to the remediation hint in the audit report
  (`docs/audits/YYYY-MM-DD-quality-gate-audit.md`). Override only deliberately:
  `/quality-gate-audit --override-gate <name> --reason "..."` (transient) or report frontmatter
  `override_blind: true` + `reason` (persistent). In daemon mode (`--auto`) without override → abort.

> This gate is the prerequisite for the loop afterwards to run without follow-up questions.
> Details: [references/orchestration-checklist.en.md](references/orchestration-checklist.en.md).
> Cross-link: the pre-sprint trigger is defined in the [quality-gate-audit](../quality-gate-audit/SKILL.en.md) skill.

### Step 2: Plan the sprint token budget (BOO-38/40)

- Sprint = **80% of the context window** of the model used (token box instead of time box,
  HANDBUCH Appendix G). No burndown, no velocity.
- Project the sum of the `token_estimate` of all candidate stories against the 80% budget.
  Move stories that blow the budget to the next sprint (hint, no abort).
- Determine the order: dependencies (`blockedBy`) first, then priority.
- Result: ordered sprint list + projected budget. Details:
  [references/token-boundary.en.md](references/token-boundary.en.md).

### Step 3: Sprint plan + operator approval

- Show the plan: stories in order, each `token_estimate` + `execution_mode`, total budget,
  `daemon_fail_policy` (stop|continue).
- **Wait for operator approval** (human-in-the-loop).
- **Daemon mode (`--auto`): skip this step** — analogous to `/implement` step 4.

### Step 4: Daemon loop per story

For each story in the sprint order:

| # | Action |
|---|--------|
| 4.1 | Set **Linear → In Progress** (adapter from CONVENTIONS; with `none` log locally). |
| 4.2 | **Create worktree:** `git worktree add ../wt-<ISSUE> -b feat/boo-<n>-<slug>` (own branch per story). |
| 4.3 | Start **`/implement` in daemon mode** in the worktree as a **subprocess** — model + mode resolved (BOO-170, see below): `claude -p "/implement <ISSUE>" --model "$(python3 <skill-dir>/scripts/resolve-model.py implement --repo-root .)" --permission-mode dontAsk`. Step-4 approval skipped; operator `--model` override takes precedence. All `/implement` gates remain active. |
| 4.4 | **Gate-block pause** (see below) — on sensitive-paths/personal-data STOP: pause, notify operator, **never** bridge automatically. |
| 4.5 | **Remote CI wait (BOO-148):** `/implement` step 6h (`gh run watch --exit-status`). Red → max 3 fix iterations, otherwise escalation. |
| 4.5b | **Post-story gate assertion** (see below) — read the story run's `meta.json`; an unjustified `skipped_gates` entry **or** a missing `meta.json` → story fail. Merge only on green assertion. |
| 4.6 | **Merge only on green CI** → `main`; then `git worktree remove ../wt-<ISSUE>` + clean up branch. |
| 4.7 | **Linear → Done** (with AC evidence comment). On error: story back (`In Progress → Backlog`) + apply `daemon_fail_policy`. |
| 4.8 | **Token check:** current consumption against the 80% boundary. Exceeded → leave loop → step 6. |

### Step 4.3: Model/mode routing (BOO-170)

So that every story runs on the **recommended model** and in **unattended mode**, the daemon starts
`/implement` as its **own subprocess** with resolved flags — not inline in the loop's model:

```bash
MODEL="$(python3 <skill-dir>/scripts/resolve-model.py implement --repo-root .)"
claude -p "/implement <ISSUE>" --model "$MODEL" --permission-mode dontAsk
```

- **Model:** `scripts/resolve-model.py <skill>` resolves the chain `<skill>/SKILL.md recommended_model`
  (tier) → `bootstrap/references/model-tiers.json current_version` (version) — existing SSoT, no new
  config field. Fallback: `sonnet`. Example: `implement` → `claude-opus-4-7` (BOO-170: product code on
  the best model).
- **Permission mode:** constant **`dontAsk`** + allowlist in the daemon (unattended). `bypassPermissions`
  only in true isolation (container/VM). Matches HANDBUCH §6 row "Execute, unattended".
- **Override hierarchy preserved:** an explicit `--model` given to the daemon (or `CLAUDE.md`
  `model_overrides`) beats the skill default; the decision is logged in `meta.json` (`model_used`,
  `override_origin`).
- **Known limit — `implement` is multi-tier:** `implement` routes internally to haiku (iteration loops)
  and opus (security findings, step 6e). A single `--model` per subprocess does **not** capture this —
  it sets the top-level model (opus, for the code core). The finer loop/findings split requires
  implement-**internal** subagent routing (`model:` per subagent) and is a **follow-up story**.
- **Effort:** no CLI flag — stays a session/`/config` setting (not enforceable per story).
- **Daemon only (`--auto`):** this routing applies to the unattended run. **Interactively** the loop
  runs in your session's model/mode; there the §6 mapping is a **recommendation** (Shift+Tab), not a
  constraint — Claude Code cannot switch the running loop's model from within a skill.

### Step 4.4: Gate-block behavior ⛔ (security-critical)

If `/implement` triggers a **sensitive-paths gate** (step 5.5) or **personal-data gate**
(step 5.5b), the following **always** applies:

1. The daemon **pauses** immediately (no merge, no continue).
2. Operator notify with **story ID + reason** (which path, which gate).
3. Resume **only** after explicit `review-ok` (technical) or `privacy-ok` (legal, GDPR Art. 25).
4. **No** automatic bypass, **no** timeout resume. Even in `--auto` mode the
   daemon stops here.

Details: [references/gate-block-handling.en.md](references/gate-block-handling.en.md).

### Step 4.5b: Post-story gate assertion ⛔ (machine verification)

In step 6f-bis `/implement` writes a `journal/reports/local/<run>/meta.json` (BOO-36/84)
containing, among others, `skipped_gates`, `change_type`, `override_audit`. `/sprint-run` reads it
**after every story run** and verifies that no mandatory gate was **silently** skipped — the machine
complement to prompt-driven gate execution (layer 1) and to the remote CI gate (layer 2).

**Rule:** every entry in `skipped_gates` must be **legitimate**, otherwise → story fail (back to
`Backlog`) + operator notify (story ID + which gate). **If `meta.json` is missing entirely → fail** (no
"silently green"). Merge (step 4.6) only after a green assertion.

| Finding | Legitimate? | Action |
|---|---|---|
| `skipped_gates` empty | ✅ | continue |
| Skip covered by `change_type` (non-code 5.7: workflow/config/infrastructure/content) | ✅ | continue |
| Skip with an entry in `override_audit` (e.g. coverage override with justification) | ✅ | continue |
| Skip without coverage/override | ❌ | **story fail** → Backlog + notify |
| `meta.json` missing | ❌ | **story fail** |
| Non-code story: 6c/6d/6e without evidence | ❌ | **story fail** |

Details: [references/gate-assertion.en.md](references/gate-assertion.en.md).

### Step 5: Error handling

- **`/implement` fails:** story back to `Backlog`, remove the worktree per policy
  or keep it for diagnosis. `daemon_fail_policy`: `stop` (default — halt sprint,
  notify operator) or `continue` (next story).
- **CI stays red** after 3 iterations: no merge, story stays `In Progress`, escalation
  to operator with log excerpt (`gh run view --log-failed`).
- **Worktree conflict / dirty `main`:** STOP — never merge with an unclean tree.

### Step 6: Sprint boundary → `/sprint-review`

Trigger (one is enough): 80% token boundary reached · backlog empty · `stop-on-fail` triggered.

- Trigger `/sprint-review` — aggregates `journal/reports/local/*/meta.json` of the story runs
  into `journal/sprint-<date>.md` (metrics, learning loop).
- On token boundary: operator hint **"Sprint boundary reached"**.

### Step 7: Sprint report (mandatory output)

Final table:

| Story | Status | Token | CI | Worktree |
|---|---|---|---|---|
| BOO-XX | Done / Failed / Skipped | ~Xk | green/red | cleaned up |

Plus: total token consumption (% of budget), gate-block pauses, remaining backlog stories,
reference to the `/sprint-review` result.

## Daemon mode

**Default vs. `--auto` — both execute.** In the interactive default run, `/sprint-run` shows
the sprint plan in step 3 and waits **once** for approval; **afterwards** the loop (step 4) runs
through without further intermediate questions. `--auto` (webhook/daemon) skips **only** this one
approval — otherwise identical. There is **no** pure check mode; both actually execute the sprint.

Like `/implement`, `/sprint-run` knows a daemon mode (`--auto` / webhook): the
**operator approval in step 3 is skipped**, the loop runs without intermediate questions —
**except** at gate blocks (step 4.4), which **always** stop. All `/implement` gates
(spec gate, quality gates, CI loop) remain active in every story, and step 4.5b verifies
**by machine** against `meta.json` after every run that no gate was silently skipped.

> **Claude Code mode (don't confuse):** The "plan" in step 3 is the **skill's sprint plan**,
> **not** the Claude Code plan mode — that one is read-only and would block the execution.
> Recommendation: supervised → `acceptEdits`, unattended (`--auto`) → `dontAsk` +
> allowlist; never plan mode for execution. Details: HANDBUCH §6 "Claude Code mode".

## Integration with other skills

| Upstream | What is delivered | Downstream | What we deliver |
|----------|--------------------|------------|------------------|
| `ideation` | Stories + specs + ADD | `implement` (per story) | story ID, worktree, daemon trigger |
| `backlog` | Prioritized sprint list | `sprint-review` (sprint end) | aggregated story metrics (meta.json) |

Chain: `intent → ideation → backlog → sprint-run → ( implement )* → sprint-review`.

## Trigger phrases

- `/sprint-run`
- "run the sprint"
- "drive the sprint"
- "automation-cycle"

## Configuration

Fields (in `.claude/environment.json` or `CONVENTIONS.md`, plus per story in the spec `Execution Isolation` block):

| Field | Meaning | Default |
|---|---|---|
| `token_hard_threshold` | Sprint boundary in % of the context window | `80` |
| `daemon_fail_policy` | Behavior on story error: `stop` / `continue` | `stop` |
| `worktree_strategy` | Isolation per story | `git-worktree` |
| `parallel_story_limit` | Max. parallel story worktrees (1 = sequential) | `1` |

## File structure

```
sprint-run/
├── SKILL.md                                  ← Skill definition (1.1.0)
├── SKILL.en.md                               ← English mirror
├── README.md                                 ← German README (Version: 1.1.0)
├── README.en.md                              ← English README
├── overview.excalidraw / .png                ← Skill overview sketch (+ .en)
└── references/
    ├── orchestration-checklist.md            ← Sprint pre-flight + loop checks (+ .en.md)
    ├── gate-block-handling.md                ← Pause/resume protocol (+ .en.md)
    ├── gate-assertion.md                     ← Post-story gate assertion (meta.json) (+ .en.md)
    ├── worktree-flow.md                      ← Worktree per story: add → merge → remove (+ .en.md)
    └── token-boundary.md                     ← 80% boundary logic + sprint budget (+ .en.md)
```
