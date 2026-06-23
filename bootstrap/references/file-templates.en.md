# File templates for a new project

All templates use `{{PLACEHOLDERS}}` that must be filled with the project info collected in phase 0.

> **Note:** this file contains the English version of every template. The German original
> (`file-templates.md` in the same folder) has the complete content with German prose. When
> bootstrap generates project files, use whichever language matches the project's docs language.

---

## config.js

```javascript
// lib/config.js — Single Source of Truth
'use strict';

const VERSION = '{{VERSION_START}}';

// Documentation files — self-healing watches the version sync
const DOC_FILES = {
  'CLAUDE.md': {
    path: 'CLAUDE.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'CONVENTIONS.md': {
    path: 'CONVENTIONS.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'SYSTEM_ARCHITECTURE.md': {
    path: 'SYSTEM_ARCHITECTURE.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'ARCHITECTURE_DESIGN.md': {
    path: 'ARCHITECTURE_DESIGN.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'COMPONENT_INVENTORY.md': {
    path: 'COMPONENT_INVENTORY.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'DEVELOPMENT_PROCESS.md': {
    path: 'DEVELOPMENT_PROCESS.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'DEVELOPER_ONBOARDING.md': {
    path: 'DEVELOPER_ONBOARDING.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'GOVERNANCE.md': {
    path: 'GOVERNANCE.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  }
};

// Project-specific config (adapt)
const CONFIG = {
  PROJECT_NAME: '{{PROJECT_NAME}}',
  ISSUE_PREFIX: '{{ISSUE_PREFIX}}',
  GITHUB_REPO: '{{GITHUB_REPO}}',
};

module.exports = { VERSION, DOC_FILES, CONFIG };
```

---

## CLAUDE.md (minimum)

```markdown
# {{PROJECT_NAME}} — AI System Reference

<!-- {{PROJECT_TYPE_MARKER}} possible values: "> **PROJECT TYPE: ACTIVE** — code + deployment in this repo" or "> **PROJECT TYPE: GOVERNANCE REFERENCE** — docs/specs only, no coding" -->
{{PROJECT_TYPE_MARKER}}

**Version:** {{VERSION_START}} | **Updated:** {{TODAY}}
**Repository:** {{GITHUB_REPO}}

## Identity

{{PROJECT_DESC}}

## Session-start routine (lightweight SecondBrain, BOO-129)

At the start of every session, first establish — **where are we?**
1. Read the **PMO hub**: `docs/project/README.md` (or `{{PROJECT_NAME}} - PMO HUB.md`).
2. Read the **latest entries** in `docs/project/meetings/` (recent minutes) and `docs/project/decisions/` (recent ADRs).
3. Read the **latest daily note** in `journal/daily/` (where did we leave off yesterday? open items).
4. Summarize the **state** in 2-3 sentences (open action items, latest decision) and propose the next step.

## Session-end routine (daily note, BOO-139)

At the natural end of a session — or when the operator ends it — **actively offer**:

> "Shall I write the daily note so the next session knows where we are?"

On confirmation → `journal/daily/YYYY-MM-DD.md` (one file per day, chronologically sortable):
- **What was done** (bullets, per story/topic)
- **Decisions** — title only + reference to `docs/project/decisions/` (no duplication)
- **Open for next session** (action items)

**Write-back convention (record the state):**
- Daily log → `journal/daily/YYYY-MM-DD.md`
- Meeting minutes / action items → `docs/project/meetings/YYYY-MM-DD-<topic>.md`
- Decisions → `docs/project/decisions/` (ADRs)

This turns the markdown folders into a **lightweight SecondBrain** in the repo (no Obsidian): *start reads the state (PMO hub + meetings/decisions + latest daily note) → work → write daily note / minutes / decisions back.* Loop visualization: `docs/assets/boo-129-leichtgewicht-secondbrain.en.png`.

> Paths apply to `documentation_ssot = repo-docs`. For `obsidian`, analogously: PMO hub + `Meetings/` + `Decisions/` in the vault, daily notes in the vault daily folder. For `external-dms`: entry point per `docs/project/README.md`; daily notes still local in `journal/daily/`.

## Rules (NEVER)

1. **NEVER** change code without a Backlog Record or adapter story
2. **NEVER** change code without a spec file (`specs/{{PREFIX}}XXX.md`)
3. **NEVER** close a Backlog Record / adapter story without git push + changelog
4. **NEVER** put API keys in chat — user enters them directly into .env
5. **NEVER** create a Backlog Record without classification/labels/tags
6. **NEVER** bump `config.js` VERSION without updating all DOC_FILES
7. **NEVER** move a sub-task directly from Backlog → Done — always through "In Progress" first
8. **NEVER** create a new file without entering it in `ARCHITECTURE_DESIGN.md §References` + `INDEX.md`
9. **NEVER** close a Backlog Record / adapter story without an integration-test check (new component covered?)
10. [add project-specific rules]

## Governance hooks

- `.claude/hooks/spec-gate.sh` — blocks commits without spec file
- `.claude/hooks/doc-version-sync.sh` — blocks pushes on version drift
- `.claude/hooks/guard.sh` — blocks access to .env and key files
- `.claude/hooks/format.sh` — auto-formats on edit/write

## Skills available

[List of installed skills from bootstrap phase 2]

## System architecture

See `SYSTEM_ARCHITECTURE.md` and `ARCHITECTURE_DESIGN.md`.

## Model-Routing Policy (BOO-84)

Each skill declares a **recommended model tier** in its frontmatter (`recommended_model`). Tier-to-version mappings and pricing live centrally in `bootstrap/references/model-tiers.json` of INTENTRON.

| Tier | Model Class | Used For | Default Skills |
|------|-------------|----------|----------------|
| `haiku` | Claude Haiku | Iteration loops, lints, question generation, small smoke tests | `/implement` steps 6a/6a-bis/6a-tris/6a-quart, lint loops |
| `sonnet` | Claude Sonnet | Safe default for most skill tasks | `bootstrap`, `backlog`, `visualize`, `sprint-review`, `pitch`, `ideation`, `intent` |
| `opus` | Claude Opus | Architecture reviews, security findings, threat modeling | `architecture-review`, `cloud-system-engineer`, `/implement` step 6e (security findings) |

### Project-wide overrides

```yaml
model_overrides:
  # skill-name: desired tier (haiku | sonnet | opus)
  # example:
  # implement-iterations: sonnet   # instead of haiku (default), when iterations get more complex
```

### One-off overrides

Per invocation via CLI flag, e.g. `/implement --model opus`. Precedence: **CLI flag > CLAUDE.md `model_overrides:` > skill default**. Every override is recorded in `meta.json` under `override_audit` with skill, recommended tier, actual model, operator and timestamp.

### Mandatory Opus

Security-relevant skills (`architecture-review`, `cloud-system-engineer`, `/implement` step 6e) MUST NOT automatically downgrade to a weaker tier during a story run. Operator override is possible but logged in the audit trail.

## Native paths (ADR-2 / BOO-199)

Claude-Code-native features before framework-built equivalents. Overridable per project. The flags apply **only** when `runtime_target: claude-code` (switch A) — they are inactive for `codex`/`cross-tool`.

```yaml
native_paths:
  prefer_native_subagents: true   # /implement generates real .claude/agents/<story>-<agent>.md (own 200k window) instead of text-block briefings
  prefer_goal_termination: true   # /sprint-run uses /goal as the termination engine
  prefer_ultraplan: auto          # /architecture-review + /ideation suggest /ultraplan — auto | always | never
  complement_insights: true       # /sprint-review calls /insights and integrates a meta block
```

## Prompt Caching (BOO-84)

Prompt caching uses Anthropic's ephemeral cache markers for components with high reuse within a story iteration. Scope:

- **SKILL.md files** of all loaded skills
- `CONVENTIONS.md`, `SECURITY.md`, `ARCHITECTURE_DESIGN.md`
- Repo map (produced in `/implement` step 3)

Constraints:
- Minimum block size 1024 tokens (smaller blocks are ignored)
- Cache TTL 5 minutes
- Cache blocks must contain no secrets (no API key, no token)
- Cache hit rate is tracked in `meta.json` as a separate value
```

---

## CONVENTIONS.md (project-local contract)

```markdown
# {{PROJECT_NAME}} — Project Conventions

**Version:** {{VERSION_START}} | **Updated:** {{TODAY}}
**Framework:** INTENTRON
**Master specification:** `intentron/CONVENTIONS.md`

> This document is the project-local contract for governance mode, execution isolation and active gates. Skills read it before writing or implementing stories.

## 1. Governance mode

**Active mode:** `{{GOVERNANCE_MODE}}`

| Mode | When to use | Active minimum pieces |
|---|---|---|
| `lite` | throwaway scripts, learning projects, small private experiments | `CLAUDE.md`/`AGENTS.md`, `CONVENTIONS.md`, `specs/`, spec-gate, basic linting |
| `standard` | serious solo projects, small production services, client work | everything in `lite` plus security gates, issue guidelines, CI lint/SAST, sensitive-paths, learning loop L1 |
| `heavy` | regulated, revenue-critical, PII/payment/auth-heavy, long-lived systems | everything in `standard` plus coverage/performance gates, SonarQube, branch protection, audit trail, mandatory review, L2/L3 as appropriate |

### What this mode may deliberately leave out

| Area | `lite` | `standard` | `heavy` |
|---|---|---|---|
| CI/CD | optional, no branch protection | CI lint/SAST recommended/default when GitHub exists | branch protection + required checks |
| Security | baseline hygiene | SAST, sensitive paths | mandatory review + audit trail |
| Coverage/performance | advisory instead of hard gate | active when configured | expected as gates |
| Observability/SLO | only when needed | baseline docs when relevant | mandatory evidence for production-like systems |
| Learning | optional/L1 | L1 default | L2/L3 for long-running systems |
| Worktrees | not required | write scopes for sub-agents | `git-worktree` for agentic lanes |

`none` is not a governance mode; it is an execution-isolation value.

**Compliance doc gate (opt-in add-on):** `{{COMPLIANCE_DOC_GATE}}` (default `false`) — orthogonal to the governance mode. When `true`, the shared doc-drift checker (`scripts/doc-drift-check.sh`, BOO-229) turns a **FAIL** into a hard block in `/ideation`, `/architecture-review`, `/implement`; when `false` it stays a warning. Master spec: `intentron/CONVENTIONS.md` §Compliance doc gate.

## 2. Execution isolation

**Active isolation:** `{{EXECUTION_ISOLATION}}`

Rules:
- `sub-agents` requires `write-scope` or `git-worktree`.
- `agentic` requires `git-worktree`.
- Specs with `execution_mode: sub-agents` or `agentic` must declare `worktree_strategy` and `write_scopes`.
- Subagents must not revert edits made by others.
- Integration/merge is owned by the lead agent or operator.

## 3. Pipeline boundary

The framework is primarily a sequential engineering pipeline with quality gates, not a fully autonomous developer agent. Sub-agents are specialized execution helpers inside a controlled story. Claude, Codex or Hermes may use the framework agentically, but only within the conventions declared here.
```

---

## AGENTS.md (Codex runtime + review guidelines)

```markdown
# {{PROJECT_NAME}} — AGENTS.md (Codex Runtime Reference)

> Codex counterpart to CLAUDE.md. Repo rules, sandbox/scope notes, pointer to the project contract.
> Applied by the Codex review runner (3-level resolution, max 32 KiB).

## Project contract (required reading)
- `CONVENTIONS.md` — governance mode, execution isolation, active gates
- `ARCHITECTURE_DESIGN.md` — target architecture, ADRs, quality attributes, references
- `SECURITY.md` — security rules, secrets, threat surface, mandatory checks

## Sandbox / scope
- No secrets in code, logs, commits, chat. `.env` stays local + gitignored.
- Read a file before changing it. Use existing patterns and local helpers.
- Define the write scope per story (execution isolation, see CONVENTIONS §2).

## Review guidelines — independent code reviewer (BOO-239)
When Codex runs as a **reviewer** (no auto-fix, finding only):
- **Perspective:** senior developer — design, craft, edge cases, maintainability. NOT what the deterministic gates (Semgrep/Sonar/coverage) already cover.
- **Yardstick:** the diff **against** SECURITY.md, ARCHITECTURE_DESIGN.md and CONVENTIONS.md — not generic.
- **Output:** a **finding/report** with priority (P0/P1). **No patch, no merge** — Codex never changes code.
- **Findings flow:** real finding → triage → backlog story + spec → `/implement` → gates → human merge.
- **Dedup:** filter already-reported findings via `memory.md`.
- **Independence:** reviewer ≠ author (no conflict of interest). Setup paths (comfort GitHub-native / sovereignty CLI+Azure-EU): `docs/runbooks/codex-reviewer.en.md`.
```

---

## SYSTEM_ARCHITECTURE.md (skeleton)

```markdown
# {{PROJECT_NAME}} — System Architecture

**Version:** {{VERSION_START}}

## Components

| Component | File/Path | Purpose |
|-----------|-----------|---------|
| Config (SSoT) | `lib/config.js` | Central config, version, DOC_FILES |

## Data flow

[ASCII diagram or Mermaid showing data flow between components]

## External dependencies

| Service | Purpose | Key needed |
|---------|---------|------------|
| [name] | [purpose] | [key name] |

## Self-healing checks

| Check | What it verifies | On failure |
|-------|-------------------|-----------|
| M | Doc versions match config.js | Auto-sync via doc-sync.js |
| U | All documented files exist | Warning |
| P | All daemons running | Auto-restart with backoff |
```

---

## .env.example

```
# Project: {{PROJECT_NAME}}
# Fill these values and save as .env (.env is gitignored)

# Mandatory
LINEAR_API_KEY=lin_api_xxxxx

# Optional — alerts
TELEGRAM_BOT_TOKEN=7123456789:AAH...
TELEGRAM_CHAT_ID=123456789

# Optional — research
OPENROUTER_API_KEY=sk-or-xxx

# Optional — monitoring
GRAFANA_URL=https://yourorg.grafana.net
GRAFANA_API_KEY=glsa_xxx

# Optional — infrastructure
HOSTINGER_API_KEY=xxxxxxxxx
```

---

## .gitignore

```
# Secrets
.env
.env.local

# Node modules
node_modules/

# Logs
*.log
logs/
journal/self-healing.log

# IDE
.vscode/settings.local.json
.idea/

# OS
.DS_Store
Thumbs.db

# Claude Code local overrides
CLAUDE.local.md

# BOO-204: transient story-subagent definitions from /implement step 4b
# (generated per run as <STORY-ID>-<agent>.md, not part of the story diff).
# Precise to issue-prefixed files — persistent agents like lint-fixer.md stay tracked.
.claude/agents/*-[0-9]*-*.md

# Lock files (uncomment if multiple people work on the project)
# .*.pid
# *.lock

# BOO-36: local iteration outputs from /implement step 6
# (ESLint SARIF, test JUnit XML, coverage JSON, Semgrep SARIF, meta.json per run)
# NOT committed — /sprint-review aggregates them into journal/sprint-{date}.md.
journal/reports/local/

# BOO-151: enable ONLY for multi-user VPS (several people, one project) —
# daily notes are then personal per user -> local, not shared.
# For solo/single-operator, journal/daily/ stays committed (= SecondBrain log).
# journal/daily/
```

---

## journal/reports/local/<RUN_DIR>/meta.json (BOO-36 — implement-run metadata)

> Every `/implement` run writes this file at the end. Fixed schema, parseable by `/sprint-review`.

```json
{
  "story_id": "BOO-15",
  "started_at": "2026-04-27T14:30:00Z",
  "completed_at": "2026-04-27T14:34:00Z",
  "iterations": {
    "eslint": 3,
    "tests": 2,
    "semgrep": 1,
    "coverage": 1
  },
  "final_status": "passed",
  "environment": "mac",
  "pre_flight_warning": null
}
```

**Field convention:**

| Field | Type | Description |
|-------|------|-------------|
| `story_id` | string | Backlog Record / adapter issue key (e.g. `BOO-36`) |
| `started_at` | ISO-8601 UTC | Run start (`date -u +%Y-%m-%dT%H:%M:%SZ`) |
| `completed_at` | ISO-8601 UTC | Run end |
| `iterations.eslint` | int | Number of ESLint iterations (0 if gate skipped) |
| `iterations.tests` | int | Number of test iterations |
| `iterations.semgrep` | int | Number of Semgrep iterations |
| `iterations.coverage` | int | Number of coverage iterations |
| `final_status` | enum | `passed` \| `failed` \| `stopped_iteration_limit` |
| `environment` | enum | `mac` \| `vps` \| `ci` \| `unknown` (from `.claude/environment.json`) |
| `pre_flight_warning` | string \| null | Set by `/implement` step 0b (BOO-40) when the operator proceeded despite projection > 80%. Format: `"projection 90%, user proceeded"`. `null` for a normal run. `/sprint-review` evaluates this — if the session actually compacted, the lesson flows back to L3 for BOO-39 calibration. |

**Path convention:**
- Run directory: `journal/reports/local/{YYYY-MM-DD_HHMM}_{STORY-ID}/`
- Directory is gitignored (see `.gitignore` block above)
- Other files in the same directory:
  - `eslint-iter{N}.sarif` — per ESLint iteration
  - `tests-iter{N}.junit.xml` — per test iteration
  - `coverage-final.json` — coverage end state
  - `semgrep-final.sarif` — Semgrep end state

**Responsibility (BOO-36):**
- **Writes:** `/implement` (raw outputs + meta.json)
- **Reads + aggregates:** `/sprint-review` (into `journal/sprint-{date}.md`)
- **L3 DB write:** exclusively `/sprint-review` second phase into `journal/learnings.db` — implement does NOT write directly into the L3 DB.

---

## .claudeignore (context protection)

```
# Heavy directories Claude should not load into context
node_modules/
.git/
logs/
*.log
dist/
build/

# Secrets
.env
.env.*
secrets/
*.key
*.pem

# Large data
data/raw/
journal/*.jsonl
```

---

## API_INVENTORY.md (minimum)

```markdown
# {{PROJECT_NAME}} — API Inventory

**Version:** {{VERSION_START}} | **As of:** {{TODAY}}

> SSoT for all external and internal interfaces of the project. **Maintenance duty:** on every interface change (new/changed API) update this file — `/implement` reminds you (post-implement check).
> **NO secrets:** document only the auth *method* (type), never keys/tokens/passwords. Secrets belong in `.env` / a secret manager.

## External APIs (consumed)

| Interface | Purpose | Base URL / endpoint | Auth method (type) | Data classes | Owner | As of |
|---|---|---|---|---|---|---|
| [e.g. payment provider] | [payments] | [https://api.example.com] | [API key in header] | [payment data / PII] | [team/person] | {{TODAY}} |

## Provided APIs (own, exposed)

| Endpoint | Method | Purpose | Auth | Rate limit | Versioning | As of |
|---|---|---|---|---|---|---|
| [e.g. /v1/...] | [POST] | [...] | [Bearer / OIDC] | [100/min] | [/v1] | {{TODAY}} |

## Internal interfaces (service-to-service)

| From → To | Protocol | Purpose | Auth | As of |
|---|---|---|---|---|
| [svc-a → svc-b] | [REST / gRPC / queue] | [...] | [mTLS / workload identity] | {{TODAY}} |
```

---

## CHANGELOG.md (initial)

```markdown
# Changelog

All notable changes to this project are documented here.

## [{{VERSION_START}}] — {{TODAY}}

### Added
- Initial bootstrap — INTENTRON
- Documentation: CLAUDE.md, SYSTEM_ARCHITECTURE.md, ARCHITECTURE_DESIGN.md
- Governance hooks: spec-gate.sh, doc-version-sync.sh
- Skills installed: [list]
```

---

## specs/TEMPLATE.md

```markdown
---
story_id: {{ISSUE_PREFIX}}XXX
estimate: <SP, set by /ideation step 5b>
token_estimate: <absolute tokens, set by /ideation step 5b>
execution_mode: <linear | sub-agents | agentic, set by /ideation step 5b>
worktree_strategy: <none | write-scope | git-worktree, set according to CONVENTIONS.md>
codex_execution_hint: <single-agent | parallel-workers | worktree-required, optional>
write_scopes:
  - <path or glob, e.g. "src/auth/**">
estimation_basis: |
  <prose: file count, diff size, tests, docs, cross-skill, references, L3 factor>
---

# [STORY-XX] — [Title]

## Why
[Why is this being built? Business reason or technical necessity]

## What
- Deliverable: [what gets shipped]
- Done when: [verifiable criterion]

## Constraints
- MUST: [hard requirement]
- MUST NOT: [hard prohibition]
- Out of scope: [explicitly excluded]

## Current State
- `[file]` — [what it currently does]
- `[file]` — [what it currently does]

## Tasks
- T0 Pre-Flight:
  - [ ] Runtime instructions read (`AGENTS.md`, `CLAUDE.md`, or project-specific entry point)
  - [ ] Runtime details clarified: setup, tests, lint/SAST, local services, deployment notes
  - [ ] `DEVELOPER_ONBOARDING.md` or linked Developer Onboarding read
  - [ ] Project Hub / PMO Hub read
  - [ ] `ARCHITECTURE_DESIGN.md` and/or Target Architecture read
  - [ ] `SECURITY.md` read
  - [ ] Backlog matrix / story order read
  - [ ] Story blockers checked in the backlog tool or local backlog
  - [ ] Blockers named or documented as "none"
  - [ ] Local story spec, spec pack, or uplift matrix read
  - [ ] Local story spec or spec pack cross-checked against issue/backlog
- T1: [task] (files: [...]) — verify by [concrete check]
- T2: [task] (files: [...]) — verify by [concrete check]
- T3: [task] (files: [...]) — verify by [concrete check]
- T_last: Documentation + config (files: [`ARCHITECTURE_DESIGN.md`, `INDEX.md`, `DEVELOPER_ONBOARDING.md`, project hub, `CHANGELOG.md`, config SSoT]) — verify by documenting whether onboarding or hub updates were required

## Agent-Pattern
**Chosen pattern:** [Solo | Subagent | Parallel-Subagents | Agent-Team]
**Rationale:** [why this pattern]
**Team composition:** (only if Agent-Team) [Lead (Sonnet) + Explore (Haiku) + ...]

## Execution Isolation

> Required when `execution_mode` = `sub-agents` or `agentic`.

**Project convention:** see `CONVENTIONS.md`
**Worktree strategy:** [none / write-scope / git-worktree]
**Write scopes:**
- [path/glob + responsible agent]
- [path/glob + responsible agent]
**Integration rule:** [who integrates? Lead agent or operator]

## Rollout

> **REQUIRED for AI-generated stories — enforced by spec-gate.sh.**
> For documentation-only changes with no new code path: enter `**Feature-Flag:** n/a — [reason]`.

**Feature-Flag:** `flag.{{STORY_ID}}` — Default: `false`

**Implementation (project size):**
- Small project: env variable `FLAG_{{STORY_ID}}=true/false`
- Medium project: `config/flags.json` (hot-reloadable)
- Large project: external tool (LaunchDarkly / Unleash) — create ADR

**Stages:**
- [ ] Stage 1: 5% of users / 24h — success criterion: no errors in log
- [ ] Stage 2: 50% of users / 24h — success criterion: P95 ≤ Baseline × 1.05
- [ ] Stage 3: 100% of users — remove flag after 72h stable operation

**Rollback command:** `FLAG_{{STORY_ID}}=false` (config reload, no code change needed)

**AI marker:** All code paths added in this story get comment `// AI-generated: {{STORY_ID}}` (rollback identification, BOO-17).

---

## Summary
(filled after implementation by /implement step 8 — 3 paragraphs, plain language)
```

---

## spec-gate.sh (Hook template)

> Adapt: WORKSPACE path + ISSUE_PREFIX + CONTAINER_CMD (optional, only for agent systems).

```bash
#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  SPEC-GATE — Governance Hook
#  Blocks git commit when specs/{PREFIX}XXX.md is missing or Agent-Pattern is absent.
#
#  Claude Code PreToolUse Hook (Bash)
#  Input: JSON via stdin: {"tool_input": {"command": "..."}}
#  Exit 1 → Tool-Call blocked | Exit 0 → allowed
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

WORKSPACE="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
ISSUE_PREFIX="{{ISSUE_PREFIX}}"  # e.g. "PROJ-"

# Parse JSON → extract command
INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null || echo "")

# Only check git commit commands
if ! echo "$CMD" | grep -qE 'git commit'; then
  exit 0
fi

# Extract {PREFIX}XXX from commit message (dynamic)
PREFIX_ESC=$(echo "$ISSUE_PREFIX" | sed 's/[-]/\\-/g')
ISSUE=$(echo "$CMD" | grep -oP "${PREFIX_ESC}[0-9]+" | head -1 || echo "")
if [ -z "$ISSUE" ]; then
  exit 0  # No issue referenced → no gate
fi

# Check spec file
SPEC_FILE="$WORKSPACE/specs/${ISSUE}.md"
if [ ! -f "$SPEC_FILE" ]; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  🚫  GOVERNANCE GATE: specs/${ISSUE}.md missing!            "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Commit referencing ${ISSUE} is BLOCKED."
  echo ""
  echo "  Next steps:"
  echo "  1. Read specs/TEMPLATE.md"
  echo "  2. Create + fill specs/${ISSUE}.md"
  echo "  3. git add specs/${ISSUE}.md && git commit -m 'docs: specs/${ISSUE}.md'"
  echo ""
  exit 1
fi

# Check Agent-Pattern — section present?
if ! grep -q "## Agent-Pattern" "$SPEC_FILE"; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  🚫  GOVERNANCE GATE: Agent-Pattern missing in spec!        "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Commit referencing ${ISSUE} is BLOCKED."
  echo ""
  echo "  Next steps:"
  echo "  1. Open specs/${ISSUE}.md"
  echo "  2. Add ## Agent-Pattern section from specs/TEMPLATE.md"
  echo "  3. Fill in the chosen pattern"
  echo ""
  exit 1
fi

# Check Agent-Pattern — not empty/TBD
PATTERN=$(grep "^\*\*Chosen pattern:\*\*" "$SPEC_FILE" | sed 's/\*\*Chosen pattern:\*\* //' | tr -d '[:space:]' || echo "")
if [ -z "$PATTERN" ] || [ "$PATTERN" = "TBD" ] || echo "$PATTERN" | grep -q "\["; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  🚫  GOVERNANCE GATE: Agent-Pattern not filled in!          "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Allowed values: Solo | Subagent | Agent-Team | Parallel-Subagents"
  echo ""
  exit 1
fi

# Agent-Team: check team composition
if echo "$PATTERN" | grep -qi "Agent-Team"; then
  TEAM=$(grep "^\*\*Team composition:\*\*" "$SPEC_FILE" | sed 's/\*\*Team composition:\*\* //' | tr -d '[:space:]' || echo "")
  if [ -z "$TEAM" ] || [ "$TEAM" = "n/a" ] || echo "$TEAM" | grep -q "\["; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  🚫  GOVERNANCE GATE: Team composition missing!             "
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "  Pattern 'Agent-Team' chosen but team composition is empty."
    echo "  Example: Lead (Sonnet) + Explore (Haiku) + Plan (Sonnet)"
    echo ""
    exit 1
  fi
fi

# Check Rollout section (BOO-17 — Feature Flag convention)
if ! grep -q "## Rollout" "$SPEC_FILE"; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  🚫  GOVERNANCE GATE: ## Rollout missing in spec!           "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Commit referencing ${ISSUE} is BLOCKED."
  echo ""
  echo "  Next steps:"
  echo "  1. Open specs/${ISSUE}.md"
  echo "  2. Add ## Rollout section from specs/TEMPLATE.md"
  echo "  3. Fill in feature flag name and rollout stages"
  echo "     (For doc-only stories: '**Feature-Flag:** n/a' is sufficient)"
  echo ""
  exit 1
fi

exit 0
```

---

## eslint.config.mjs (Node.js / Frontend / Full-stack)

**Industry-standard set since BOO-2 (2026-05-01):** ESLint Recommended + Airbnb Base + Security + SonarJS. All MIT-licensed, no cloud service, no licence cost.

**npm install:**
```bash
npm install --save-dev eslint @eslint/js eslint-config-airbnb-base \
  eslint-plugin-security eslint-plugin-sonarjs @eslint/compat
```

(`@eslint/compat` bridges configs that don't yet have a native flat-config form — e.g. eslint-config-airbnb-base. Projects that only use flat-config-native plugins can drop the package.)

```javascript
// eslint.config.mjs — ESLint v9+ flat config (industry standard, BOO-2)
import js from '@eslint/js';
import { FlatCompat } from '@eslint/compat';
import securityPlugin from 'eslint-plugin-security';
import sonarjsPlugin from 'eslint-plugin-sonarjs';

const compat = new FlatCompat();

export default [
  // Layer 1 — ESLint recommended (syntax, no-undef, no-unreachable, ...)
  js.configs.recommended,

  // Layer 2 — Airbnb Base (industry standard for code style + best practices)
  ...compat.extends('eslint-config-airbnb-base'),

  // Layer 3 — security plugin (eval, child_process, RegExp DoS, unsafe Buffer, ...)
  securityPlugin.configs.recommended,

  // Layer 4 — SonarJS (code smells, cognitive complexity, duplicate logic)
  sonarjsPlugin.configs.recommended,

  // House rules (override or extend the configs above on purpose)
  {
    files: ['**/*.js', '**/*.mjs'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'commonjs',
      globals: {
        require: 'readonly',
        module: 'readonly',
        exports: 'readonly',
        process: 'readonly',
        console: 'readonly',
        setTimeout: 'readonly',
        clearTimeout: 'readonly',
        setInterval: 'readonly',
        clearInterval: 'readonly',
        __dirname: 'readonly',
        __filename: 'readonly',
        Buffer: 'readonly',
      },
    },
    rules: {
      'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      'no-console': 'off',
      'semi': ['error', 'always'],
      'no-undef': 'error',
    },
  },
  {
    ignores: ['node_modules/**', 'dist/**', 'build/**'],
  },
];
```

**With React / frontend (TSX):** use `eslint-config-airbnb` instead of `eslint-config-airbnb-base` — pulls in React-specific rules plus `eslint-plugin-react` and `eslint-plugin-jsx-a11y` as peer dependencies.

**Additionally for `.tsx`/JSX (BOO-141, mandatory on stack b/c with React):** install the `globals` package and add a dedicated frontend block with browser **and** React globals. Without this block, `js.configs.recommended`'s `no-undef` rule throws `'React' is not defined` on every `.tsx` file with JSX (and `window`/`document`/`fetch` are undefined too), because the house-rules block above only knows Node globals:

```bash
npm install --save-dev globals
```

```javascript
// at the top of eslint.config.mjs (additional, React/frontend only)
import globals from 'globals';

// ... in the export array as a dedicated frontend block (after the layer configs,
//     alongside the Node house-rules block):
{
  files: ['**/*.ts', '**/*.tsx'],
  languageOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    globals: {
      ...globals.browser,   // window, document, fetch, ...
      React: 'readonly',    // classic JSX transform / React.* references
    },
  },
  rules: {
    'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    'no-undef': 'error',
  },
},
```

**Iteration in the implement skill:** `/implement` step 6a iterates declaratively over the ESLint output until 0 errors (max. 5 iterations, then stop with a hint). Compound engineering mechanism #1 per Schrader Code Crash.

---

## tsconfig.json (BOO-127)

Only on `LANG_VARIANT = ts` (stack a/b/c). Strict defaults — type safety is a gate, not decoration.

**npm install (in addition to eslint.config.mjs):**
```bash
npm install --save-dev typescript typescript-eslint
```

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2022"],
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noEmit": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules", "dist", "build"]
}
```

On `ts`, `eslint.config.mjs` additionally wires in `typescript-eslint`:

```javascript
// at the top of eslint.config.mjs (additional, TypeScript only)
import tseslint from 'typescript-eslint';
// ... in the export array after js.configs.recommended:  ...tseslint.configs.recommended,
// and extend the house rules / `files` to '**/*.ts','**/*.tsx'.
```

**Frontend/meta-framework (Next.js, Nuxt, SvelteKit ...):** set `module`/`moduleResolution` to `Bundler`, `jsx: "preserve"`, add `DOM` to `lib`; optionally extend a framework `tsconfig` (e.g. `next/tsconfig`) via `extends` — the operator confirms this as an ADR.

---

## tsc --noEmit Typecheck (BOO-127)

Only on `LANG_VARIANT = ts`. The bootstrap uses **path A** (step in `eslint.yml`); path B is optional.

**Path A — step in `eslint.yml` (default):** add after the ESLint step:
```yaml
      - name: TypeScript typecheck
        run: npx tsc --noEmit
```

**Path B — dedicated `.github/workflows/typecheck.yml`:**
```yaml
name: Typecheck
on: [push, pull_request]
jobs:
  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npx tsc --noEmit
```

Required status check (BOO-29): `typecheck` (path B) or the green `eslint` run incl. the tsc step (path A). Locally the pre-commit hook (phase 4.6) covers `tsc --noEmit`.

---

## .prettierrc (Frontend / Full-stack)

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 120,
  "arrowParens": "always",
  "endOfLine": "lf"
}
```

---

## pyproject.toml (Python)

```toml
[tool.black]
line-length = 100
target-version = ['py311']

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = [
  "E",  # pycodestyle errors
  "W",  # pycodestyle warnings
  "F",  # pyflakes
  "I",  # isort
  "B",  # flake8-bugbear
  "C4", # flake8-comprehensions
  "S",  # flake8-bandit (security)
]
ignore = []

[tool.ruff.lint.per-file-ignores]
"tests/*" = ["S101"]  # allow `assert` in tests
```

---

## .semgrep.yml (all stacks)

**SAST default set since BOO-3 (2026-05-06):** Three-layer setup — Layer 1 is universal baseline (security-audit, secrets), Layer 2 is language-specific (auto-detected from `package.json` / `pyproject.toml`), Layer 3 is optional for web projects (`p/owasp-top-ten`, manually uncomment). All packs from the Semgrep Registry, MIT-licensed, run locally.

> [!important] Manifest file, not a native Semgrep config
> `.semgrep.yml` here is a **manifest file** — Semgrep's native `include` key is actually for file patterns, not pack names. Pack loading only works via `--config p/...` CLI flags. The manifest is read by the BOO-4 pre-commit hook, which translates the `include:` list into corresponding `--config` flags. `--validate` passes (the file is YAML-conformant), a direct `--config=.semgrep.yml` run yields "No config given" — that is expected. Until BOO-4 is done, packs run manually via e.g. `semgrep --config p/security-audit --config p/secrets`.

**Requirement:** Semgrep CLI installed (`brew install semgrep` or `pip install semgrep`).

```yaml
# .semgrep.yml — SAST default for Governance v2 (BOO-3, v3.2.3)
# Consumed by pre-commit hook (BOO-4) and CI (planned).
rules: []
include:
  # Layer 1 — mandatory (all stacks)
  - p/security-audit
  - p/secrets

  # Layer 2 — language-specific (auto-detected from package.json / pyproject.toml)
  # - p/javascript        # for Node/frontend projects
  # - p/python            # for Python projects

  # Layer 3 — optional for web projects (uncomment manually)
  # - p/owasp-top-ten     # for web frontends, REST APIs, GraphQL
```

**Language auto-detection in auto-setup:** `migrate_boo_3()` enables `p/javascript` automatically when `package.json` exists at the repo root, `p/python` when `pyproject.toml` exists. Layer 3 always stays commented out — the operator decides deliberately per project.

**Iteration in the implement skill:** Planned for BOO-4 — `/implement` extends Step 6 with a Semgrep pass after the ESLint pass (same 5-iteration heuristic). Until BOO-4 is done, Semgrep runs only as a manual command `semgrep --config=.semgrep.yml`.

---

## .semgrep/custom-rules.yml (BOO-185 — custom-rule wiring + canary)

**Custom-rule wiring since BOO-185 (2026-06-11):** The `.semgrep/` directory holds project-owned Semgrep rules that are loaded **in addition** to the registry packs from `.semgrep.yml`. CI (Layer 3) and pre-commit (Layer 2) wire the directory in via `--config .semgrep/` as soon as it exists. That way the custom-rule layer is live from the start — not nominally present but blind.

> [!important] Lesson from the Semgrep incident — nominally configured does not mean active
> A custom-rule directory that exists but is never passed to the CLI via `--config` is **effectively blind** — the rules simply never run. That was exactly the finding behind the ADR "Semgrep Custom-Rule-Wiring — verification pattern for quality gates" (2026-06-11). The custom rule below is a **wiring canary**: it matches only the literal tripwire `QGAUDIT-CANARY-TRIPWIRE` in `.semgrep/test-fixtures/wiring-canary.py`. The registry packs (`p/security-audit`, `p/secrets`, …) would **not** report this literal — if the rule fires during the targeted audit scan, `--config .semgrep/` is provably active. The `quality-gate-audit` skill (BOO-183) uses this canary as wiring proof.

```yaml
# .semgrep/custom-rules.yml — projekt-eigene Semgrep-Regeln (BOO-185)
# DE: Wird via `--config .semgrep/` zusätzlich zu den Registry-Packs geladen.
# EN: Loaded via `--config .semgrep/` in addition to the registry packs.
rules:
  - id: qgaudit-wiring-canary
    languages: [python]
    severity: ERROR
    message: >
      QGAUDIT wiring canary fired — custom Semgrep rules are wired. Expected ONLY in
      .semgrep/test-fixtures/wiring-canary.py. If this fires elsewhere, remove the tripwire literal.
    patterns:
      - pattern: $X = "QGAUDIT-CANARY-TRIPWIRE"
```

**Why a real rule and not a comment:** Only an executable custom rule proves that `--config .semgrep/` takes effect. If the registry packs reported the tripwire, the proof would be worthless — they don't, so a hit is an unambiguous signal that the wiring is alive. Project-owned rules are added here alongside the canary.

---

## .semgrep/test-fixtures/wiring-canary.py (BOO-185 — verification canary)

**Verification tripwire since BOO-185 (2026-06-11):** This fixture file carries the literal tripwire that the custom rule `qgaudit-wiring-canary` matches on. As long as a **targeted** audit scan (`semgrep --config .semgrep/ .semgrep/test-fixtures/wiring-canary.py`) reports the canary, the custom-rule layer counts as **wired**; if it reports nothing, the layer is **blind** — and the `quality-gate-audit` skill raises the alarm.

> [!important] Canary not permanently red — excluded from the repo-wide scan via `.semgrepignore`
> The tripwire is an `ERROR`-severity rule. If it ran in the normal CI/pre-commit scan, the CI of new projects would be **permanently red**. That is why `.semgrep/test-fixtures/` is excluded in the `.semgrepignore` template (next block) — the canary is captured **only** by the targeted audit scan of the `quality-gate-audit` skill (BOO-183), never by the repo-wide scan.

```python
# QGAUDIT-CANARY-DO-NOT-REMOVE
# DE: Beweist, dass das Custom-Rule-Verzeichnis .semgrep/ in CI verdrahtet ist.
# EN: Proves the custom-rule directory .semgrep/ is wired into CI.
# Der quality-gate-audit-Skill scannt diese Datei gezielt mit `--config .semgrep/`
# und erwartet, dass die Regel `qgaudit-wiring-canary` feuert. NICHT löschen.
tripwire = "QGAUDIT-CANARY-TRIPWIRE"
```

**Lifecycle:** The file is deliberately minimal and must not be deleted — it is the only intended hit of the canary rule. If the tripwire disappears, the audit loses its proof that the wiring is alive.

---

## .semgrepignore (all stacks)

```
# .semgrepignore — default excludes for Governance v2 (BOO-3)
node_modules/
dist/
build/
journal/reports/
.venv/
__pycache__/
.semgrep/test-fixtures/
```

**Rationale:** `node_modules/` and `.venv/` are dependencies (not own code), `dist/` and `build/` are build artifacts (have their own lint stage). `journal/reports/` is generated by the self-healing loop (not source code). `__pycache__/` is Python bytecode cache. `.semgrep/test-fixtures/` holds the wiring canary (BOO-185) — an `ERROR` rule that should fire only for the targeted audit scan of the `quality-gate-audit` skill, never for the repo-wide scan (otherwise permanently red).

---

## .git/hooks/pre-commit (BOO-4 — Quality-Gate Layer 2)

**Locally blocking pre-commit hook since BOO-4 (2026-05-06):** Second stage of the three-layer quality-gate architecture (ADR from 2026-04-27). Layer 2 is the local hook, Layer 3 is the GitHub Action (`semgrep.yml`, next block). Both layers share the same manifest-reader logic — `.semgrep.yml` is the single source of truth for active packs.

> [!important] Manifest reader, not a native config run
> The hook reads `.semgrep.yml` (the BOO-3 manifest) line by line with `grep` + `sed`, extracts the active pack names (lines starting with `- p/`; commented `# - p/` lines are ignored) and constructs `--config p/...` flags from them. NO `yq`, no YAML parser — intentionally Bash-only so the hook runs without extra dependencies. Anyone bypassing the hook with `--no-verify` is caught in CI Layer 3 (next block).

**Requirement:** Semgrep CLI installed (`brew install semgrep` on Mac, `pip install semgrep` on Linux/VPS). Mac operators install manually, VPS operators get auto-install in BOO-44.

**Husky alternative:** Pure Node projects can use `.husky/pre-commit` instead of `.git/hooks/pre-commit` — content identical. The default is the native hook because it's language-agnostic.

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit — Quality-Gate-Architektur Layer 2 (lokal, blockierend)
# DE: Konsumiert eslint.config.mjs (BOO-2) und .semgrep.yml (BOO-3 Manifest).
# EN: Consumes eslint.config.mjs (BOO-2) and .semgrep.yml (BOO-3 manifest).
set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"

# --- ESLint-Gate (BOO-2) ---
if [[ -f "eslint.config.mjs" ]]; then
    CHANGED_JS=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(js|mjs|jsx|ts|tsx)$' || true)
    if [[ -n "$CHANGED_JS" ]]; then
        echo "[PRE-COMMIT] ESLint auf $(echo "$CHANGED_JS" | wc -l | tr -d ' ') Datei(en)"
        echo "$CHANGED_JS" | xargs npx eslint --max-warnings=0 || {
            echo "[PRE-COMMIT] ESLint-Gate BLOCKIERT. Findings beheben oder bewusste Ausnahme dokumentieren."
            exit 1
        }
    fi
fi

# --- Semgrep-Gate (BOO-4, Manifest-Reader-Logik) ---
if [[ -f ".semgrep.yml" ]]; then
    # Manifest-Reader: extrahiert aktive Pack-Namen (Layer 1 Pflicht + Layer 2/3 wenn nicht auskommentiert)
    PACKS=$(grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml | sed -E 's/^[[:space:]]*-[[:space:]]+//' || true)
    if [[ -n "$PACKS" ]]; then
        ARGS=""
        for pack in $PACKS; do
            ARGS="$ARGS --config $pack"
        done
        # BOO-185: Custom-Rule-Verzeichnis zusätzlich verdrahten
        if [[ -d ".semgrep" ]]; then
            ARGS="$ARGS --config .semgrep/"
        fi
        echo "[PRE-COMMIT] Semgrep mit Packs: $(echo "$PACKS" | tr '\n' ' ')"
        if ! command -v semgrep >/dev/null 2>&1; then
            echo "[PRE-COMMIT] Semgrep CLI nicht installiert — 'brew install semgrep' (Mac) oder 'pip install semgrep' (Linux)"
            exit 1
        fi
        # shellcheck disable=SC2086
        if ! semgrep $ARGS --error --quiet 2>&1; then
            echo "[PRE-COMMIT] Semgrep-Gate BLOCKIERT. High/Critical Findings beheben."
            exit 1
        fi
    else
        echo "[PRE-COMMIT] .semgrep.yml hat keine aktiven Packs — Gate uebersprungen"
    fi
fi

exit 0
```

**Two-layer logic:** Anyone bypassing with `--no-verify` is caught in CI Layer 3 (`.github/workflows/semgrep.yml`). Both layers read the same manifest — drift impossible.

**Clone portability (BOO-152):** `.git/hooks/` is **not** carried over by `git clone`. So every fresh clone gets the pre-commit gate, the bootstrap additionally stores the hook **versioned** under `.githooks/pre-commit` (same content) and `scripts/install-hooks.sh` activates it via `core.hooksPath`. A new team member only runs `bash scripts/install-hooks.sh` after `git clone`.

---

## scripts/install-hooks.sh (BOO-152 — activate git hooks per clone)

> `.git/hooks/` is not carried over by `git clone`. This script activates the **versioned** hooks from `.githooks/` via `core.hooksPath` — idempotent, one command per clone.

```bash
#!/usr/bin/env bash
# scripts/install-hooks.sh — activate the versioned git hooks for this clone (BOO-152)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

if [ -d .githooks ]; then
  git config core.hooksPath .githooks
  chmod +x .githooks/* 2>/dev/null || true
  echo "OK — core.hooksPath=.githooks set. Pre-commit gate active."
else
  echo "WARN — .githooks/ missing. Retrofit hooks via '/bootstrap' (merge mode) or 'migrate-to-v2.sh'." >&2
  exit 1
fi
```

> The Claude Code runtime hooks (`spec-gate`, `doc-version-sync`, `pre-edit-bodyguard`) already come committed with `.claude/` + `settings.json` (paths via `$CLAUDE_PROJECT_DIR`) — they do **not** need `install-hooks.sh`. Only the native git `pre-commit` (Quality-Gate Layer 2) is activated this way.

---

## .github/workflows/semgrep.yml (BOO-4 — Quality-Gate Layer 3)

**CI layer since BOO-4 (2026-05-06):** Third stage of the three-layer quality-gate architecture. Mirror of the pre-commit hook — same manifest-reader logic, same pack selection. Blocks merges through branch protection (see BOO-29 — required status check `Semgrep`).

**SARIF output:** The GitHub Action writes the result as SARIF to `.ci-reports/semgrep.sarif` and additionally uploads it as a CodeQL SARIF (GitHub Security tab) and as a workflow artifact (Hermes consumption in BOO-32).

**Husky note:** Husky only affects the pre-commit Layer 2 — the GitHub Action is independent of it.

```yaml
# .github/workflows/semgrep.yml — Quality-Gate Layer 3 (CI, blockiert Merge)
# DE: Liest dasselbe .semgrep.yml-Manifest wie der Pre-Commit-Hook.
# EN: Reads the same .semgrep.yml manifest as the pre-commit hook.
name: Semgrep
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  security-events: write

jobs:
  semgrep:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Semgrep
        run: pip install semgrep

      - name: Read manifest and run Semgrep
        run: |
          mkdir -p .ci-reports
          ARGS=""
          while IFS= read -r line; do
              pack=$(echo "$line" | sed -E 's/^[[:space:]]*-[[:space:]]+//')
              ARGS="$ARGS --config $pack"
          done < <(grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml)
          if [[ -z "$ARGS" ]]; then
              echo "::error::No active packs in .semgrep.yml"
              exit 1
          fi
          # BOO-185: Custom-Rule-Verzeichnis zusätzlich verdrahten (Registry-Packs + projekt-eigene Rules)
          if [[ -d .semgrep ]]; then
              ARGS="$ARGS --config .semgrep/"
          fi
          # shellcheck disable=SC2086
          semgrep $ARGS --error --sarif --output=.ci-reports/semgrep.sarif

      - uses: github/codeql-action/upload-sarif@v4
        with:
          sarif_file: .ci-reports/semgrep.sarif
        if: always() && hashFiles('.ci-reports/semgrep.sarif') != ''

      - uses: actions/upload-artifact@v4
        with:
          name: semgrep-report
          path: .ci-reports/semgrep.sarif
```

**Two sources, one Action (BOO-185):** The Action loads both sources — the registry packs from the `.semgrep.yml` manifest **and** the project-owned custom rules from `.semgrep/` (via `--config .semgrep/`, as soon as the directory exists). That way the custom-rule layer is actively wired in rather than only nominally present. The canary fixture `.semgrep/test-fixtures/` stays excluded from the repo-wide scan via `.semgrepignore` — it is captured only by the targeted audit scan (otherwise permanently red).

**Two-layer logic:** Both layers read `.semgrep.yml` and wire in `.semgrep/`. If the operator bypasses the hook with `--no-verify`, this Action blocks the merge. If the Action is stripped, the hook still blocks the commit locally. Belt-and-suspenders.

---

## .github/workflows/eslint.yml (BOO-28 — ESLint CI Gate)

**CI layer since BOO-28 (2026-05-12):** Third layer of the quality-gate architecture for linting (mirror of the Semgrep Action, different tool class). Created in phase 4.4 of the bootstrap flow for stacks `a) Node.js backend`, `b) Frontend`, and `c) Full-stack`. The Python counterpart is `ruff.yml` (next block).

**SARIF output (mandatory):** The Action writes the result as SARIF to `.ci-reports/eslint.sarif` and uploads it via `github/codeql-action/upload-sarif@v4` into the GitHub Security tab. SARIF output is mandatory — read by BOO-32 (CI output standardisation) for Hermes consumption.

**SARIF formatter:** `@microsoft/eslint-formatter-sarif` must be installed as a devDependency — `npm install --save-dev @microsoft/eslint-formatter-sarif`. It is installed automatically by the `npm ci` step once the devDependency is in `package.json`.

**Branch protection:** Required status check `eslint` is enabled in BOO-29 — without a green Action, no merge to `main`.

```yaml
name: ESLint
on: [push, pull_request]

permissions:
  contents: read
  security-events: write

jobs:
  eslint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npx eslint . --format=@microsoft/eslint-formatter-sarif --output-file=.ci-reports/eslint.sarif
      - uses: github/codeql-action/upload-sarif@v4
        with: { sarif_file: .ci-reports/eslint.sarif }
        if: always() && hashFiles('.ci-reports/eslint.sarif') != ''
```

**Two-layer logic:** The pre-commit hook (Layer 2, phase 4.6) blocks locally via `npx eslint --max-warnings=0`, this Action (Layer 3) blocks CI. Anyone bypassing the hook with `--no-verify` is caught in Layer 3.

---

## .github/workflows/ruff.yml (BOO-28 — Ruff CI Gate)

**CI layer since BOO-28 (2026-05-12):** Python counterpart to the ESLint Action (previous block). Created in phase 4.4 of the bootstrap flow for stack `d) Python`.

**SARIF output (mandatory):** Ruff has native SARIF support since version 0.5 via `--output-format=sarif`. The Action writes to `.ci-reports/ruff.sarif` and uploads via `github/codeql-action/upload-sarif@v4`. Read by BOO-32 for Hermes consumption.

**Branch protection:** Required status check `ruff` is enabled in BOO-29 (mirror of `eslint` for Node projects).

```yaml
name: Ruff
on: [push, pull_request]

permissions:
  contents: read
  security-events: write

jobs:
  ruff:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install ruff
      - run: |
          mkdir -p .ci-reports
          ruff check . --output-format=sarif --output-file=.ci-reports/ruff.sarif
      - uses: github/codeql-action/upload-sarif@v4
        with: { sarif_file: .ci-reports/ruff.sarif }
        if: always() && hashFiles('.ci-reports/ruff.sarif') != ''
```

**Two-layer logic:** Analogous to ESLint — the pre-commit hook (Layer 2) runs `ruff check` locally, this Action (Layer 3) blocks CI.

---

## hooks/dependency-check.sh (BOO-12 — slopsquatting protection)

**Third gate in the pre-commit hook since BOO-12 (2026-05-06):** Standalone Bash script under `.claude/hooks/dependency-check.sh`, invoked from the pre-commit hook (BOO-4) as the third gate after ESLint and Semgrep. Four-stage check on newly added dependencies: wordlist (offline block against known slopsquatting/typosquatting packages, BOO-197), existence (hallucination block), age (typosquatter warning), CVE (vulnerability block).

**Two layers since BOO-197:** the wordlist stage (`.claude/hooks/slopsquatting/wordlist.txt`, next block) is the **offline-capable first layer** — it blocks known malicious packages instantly via `grep`, with no registry round trip. The live registry query (existence/age/CVE) stays unchanged as the **second layer**; the wordlist does not replace it but catches documented slopsquatting hits before the network call. If the wordlist is missing the stage is skipped (no hard fail) — the registry query still applies.

> [!important] Schrader Code Crash ch. 3-4
> 19.7% of AI-recommended packages do not exist — slopsquatting is its own attack vector. Attackers register typosquatted or AI-hallucinated package names with malware. ESLint and Semgrep check code, not the supply chain — this hook closes that gap before the commit lands.

**Requirements:** `curl` is standard on Mac/Linux (always present). Optional: `npm` (Node projects — for faster existence/age lookup and CVE check), `pip-audit` (Python — for CVE check). When a tool is missing the script falls back to a curl call against the registry API. NO `yq`, NO `jq` — intentionally Bash-only with `grep`/`sed`/`awk`.

**Performance:** the hook only runs when `package.json`, `requirements.txt`, `pyproject.toml`, or `Cargo.toml` is in the staged diff. For pure code commits it exits immediately with `exit 0` — no registry round trip.

**Cargo status:** currently detection only with an operator hint (run `cargo audit` manually). Full Cargo support lands in a future iteration.

```bash
#!/usr/bin/env bash
# hooks/dependency-check.sh — Slopsquatting-Schutz (BOO-12, BOO-197)
# DE: Vier-Stufen-Check fuer neu hinzugefuegte Dependencies — Wordlist, Existenz, Age, CVE.
#     Schrader Code Crash Kap. 3-4: 19,7% der KI-empfohlenen Pakete existieren nicht.
# EN: Four-stage check for newly added dependencies — wordlist, existence, age, CVE.
#     Schrader Code Crash ch. 3-4: 19.7% of AI-recommended packages don't exist.
set -euo pipefail

# BOO-197: offline wordlist as the first layer (second layer = live registry query below)
WORDLIST=".claude/hooks/slopsquatting/wordlist.txt"

# --- Trigger detection: only runs if a manifest file is in the diff ---
CHANGED=$(git diff --cached --name-only --diff-filter=ACMR)
TRIGGERS_NPM=$(echo "$CHANGED" | grep -E '^package\.json$' || true)
TRIGGERS_PIP=$(echo "$CHANGED" | grep -E '^(requirements\.txt|pyproject\.toml)$' || true)
TRIGGERS_CARGO=$(echo "$CHANGED" | grep -E '^Cargo\.toml$' || true)

if [[ -z "$TRIGGERS_NPM" && -z "$TRIGGERS_PIP" && -z "$TRIGGERS_CARGO" ]]; then
    exit 0  # No manifest diff — skip the hook
fi

AGE_THRESHOLD_DAYS=30
BLOCKED=0

# --- Helper: extracts NEWLY added dependency names from the package.json diff ---
extract_new_npm_deps() {
    # POSIX-conformant (BSD-grep/sed-compatible): match only "+" lines with
    # "key": "version-value" — value must start with a version number
    # (optional ^, ~, >=, <= prefix). Filters out top-level "version" key.
    git diff --cached package.json 2>/dev/null \
        | grep -E '^\+[[:space:]]+"[^"]+":[[:space:]]*"[~^>=<]?[0-9]' \
        | sed -E 's/^\+[[:space:]]+"([^"]+)":.*/\1/' \
        | grep -vE '^(version)$' \
        || true
}

extract_new_pypi_deps() {
    # requirements.txt: extract NEWLY added lines (Package==version or Package>=version)
    if [[ -n "$TRIGGERS_PIP" ]] && echo "$TRIGGERS_PIP" | grep -q "requirements.txt"; then
        git diff --cached requirements.txt 2>/dev/null \
            | grep -E '^\+[a-zA-Z]' \
            | sed -E 's/^\+([a-zA-Z0-9_-]+).*/\1/' \
            || true
    fi
    # pyproject.toml: extract dependencies/optional-dependencies
    if [[ -n "$TRIGGERS_PIP" ]] && echo "$TRIGGERS_PIP" | grep -q "pyproject.toml"; then
        git diff --cached pyproject.toml 2>/dev/null \
            | grep -E '^\+[[:space:]]+"[a-zA-Z]' \
            | sed -E 's/^\+[[:space:]]+"([a-zA-Z0-9_-]+).*/\1/' \
            || true
    fi
}

# --- Check 0: wordlist (BOO-197 — offline-capable first layer) ---
# Checks <ecosystem>:<name> against the static slopsquatting wordlist.
# Hit = INSTANT BLOCK (return 1). Missing wordlist: skip (return 0).
check_wordlist() {
    local ecosystem="$1" pkg="$2"
    [[ -f "$WORDLIST" ]] || return 0  # no wordlist — skip stage, registry query still applies
    # Exact match on "ecosystem:name", comment/blank lines ignored.
    if grep -vE '^[[:space:]]*#' "$WORDLIST" 2>/dev/null \
        | grep -qiE "^[[:space:]]*${ecosystem}:${pkg}[[:space:]]*$"; then
        return 1  # in wordlist — malicious/typosquatted
    fi
    return 0
}

# --- Check 1: existence ---
check_npm_existence() {
    local pkg="$1"
    if command -v npm >/dev/null 2>&1; then
        if npm view "$pkg" name >/dev/null 2>&1; then
            return 0  # exists
        else
            return 1  # 404
        fi
    else
        # curl fallback
        if curl -fsSL --max-time 5 "https://registry.npmjs.org/$pkg" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    fi
}

check_pypi_existence() {
    local pkg="$1"
    if curl -fsSL --max-time 5 "https://pypi.org/pypi/$pkg/json" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# --- Check 2: age ---
check_npm_age() {
    local pkg="$1"
    local created
    if command -v npm >/dev/null 2>&1; then
        created=$(npm view "$pkg" time.created 2>/dev/null || echo "")
    else
        created=$(curl -fsSL --max-time 5 "https://registry.npmjs.org/$pkg" 2>/dev/null \
            | grep -oE '"created":"[^"]+"' | head -1 | sed -E 's/"created":"([^"]+)"/\1/' || echo "")
    fi
    [[ -z "$created" ]] && return 0  # no date — no warning
    local pkg_epoch
    pkg_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${created%.*}" +"%s" 2>/dev/null || \
                date -d "$created" +"%s" 2>/dev/null || echo "0")
    [[ "$pkg_epoch" == "0" ]] && return 0
    local now_epoch days
    now_epoch=$(date +"%s")
    days=$(( (now_epoch - pkg_epoch) / 86400 ))
    if (( days < AGE_THRESHOLD_DAYS )); then
        echo "[DEP-CHECK] WARNING: package '$pkg' is only $days days old — typosquatter risk, verify manually"
    fi
    return 0
}

# --- Check 3: CVE ---
check_npm_cve() {
    if command -v npm >/dev/null 2>&1 && [[ -f "package-lock.json" ]]; then
        local audit_output
        audit_output=$(npm audit --audit-level=high 2>&1 || true)
        if echo "$audit_output" | grep -qE 'high|critical'; then
            echo "[DEP-CHECK] BLOCK: npm audit reports High/Critical vulnerabilities. Run 'npm audit' for details."
            return 1
        fi
    fi
    return 0
}

check_pypi_cve() {
    if command -v pip-audit >/dev/null 2>&1; then
        local audit_output
        audit_output=$(pip-audit --strict 2>&1 || true)
        if echo "$audit_output" | grep -qiE 'vulnerability|cve'; then
            echo "[DEP-CHECK] BLOCK: pip-audit reports vulnerabilities. Run 'pip-audit' for details."
            return 1
        fi
    fi
    return 0
}

# --- Main run ---
echo "[DEP-CHECK] Slopsquatting protection active"
if [[ -f "$WORDLIST" ]]; then
    echo "[DEP-CHECK] Wordlist layer active: $WORDLIST"
else
    echo "[DEP-CHECK] NOTE: wordlist '$WORDLIST' missing — stage 0 skipped, live registry query only"
fi

if [[ -n "$TRIGGERS_NPM" ]]; then
    NEW_NPM=$(extract_new_npm_deps)
    for pkg in $NEW_NPM; do
        if ! check_wordlist "npm" "$pkg"; then
            echo "[DEP-CHECK] Package in slopsquatting wordlist — BLOCK: npm package '$pkg' is listed in $WORDLIST"
            BLOCKED=1
            continue  # known malicious — registry checks are moot
        fi
        if ! check_npm_existence "$pkg"; then
            echo "[DEP-CHECK] BLOCK: npm package '$pkg' does not exist in the registry — hallucination?"
            BLOCKED=1
        else
            check_npm_age "$pkg"
        fi
    done
    check_npm_cve || BLOCKED=1
fi

if [[ -n "$TRIGGERS_PIP" ]]; then
    NEW_PYPI=$(extract_new_pypi_deps)
    for pkg in $NEW_PYPI; do
        if ! check_wordlist "pypi" "$pkg"; then
            echo "[DEP-CHECK] Package in slopsquatting wordlist — BLOCK: PyPI package '$pkg' is listed in $WORDLIST"
            BLOCKED=1
            continue
        fi
        if ! check_pypi_existence "$pkg"; then
            echo "[DEP-CHECK] BLOCK: PyPI package '$pkg' does not exist — hallucination?"
            BLOCKED=1
        fi
    done
    check_pypi_cve || BLOCKED=1
fi

if [[ -n "$TRIGGERS_CARGO" ]]; then
    echo "[DEP-CHECK] NOTE: Cargo diff detected — Cargo check will be added in a future iteration. Operator: run 'cargo audit' manually."
fi

if (( BLOCKED == 1 )); then
    echo "[DEP-CHECK] Gate BLOCKED. Avoid slopsquatting risk — verify packages, then commit again."
    exit 1
fi

echo "[DEP-CHECK] Gate passed"
exit 0
```

**Three-layer architecture extended:** Quality-Gate Layer 2 (`.git/hooks/pre-commit`) gets a fourth invocation after ESLint and Semgrep with BOO-12: `bash .claude/hooks/dependency-check.sh`. Layer 3 (CI) stays unchanged — slopsquatting protection is intentionally pre-commit-only, because a hallucinated package should never land on a branch in the first place.

**Anti-patterns:**
- NO auto-install for `pip-audit` or `npm` — operator's responsibility. Hook stays language-neutral.
- NO mandatory dependency like `yq`/`jq` — Bash + `grep`/`sed`/`awk` + `curl` is enough. The wordlist stage (BOO-197) reads `wordlist.txt` purely via `grep` — no YAML/JSON parser.
- NO block on a Cargo diff — only a hint, because full Cargo support lands later.
- NO hard fail when the wordlist is missing — stage 0 is skipped, the live registry query stays active.

---

## .claude/hooks/slopsquatting/wordlist.txt (BOO-197 — slopsquatting wordlist)

**Offline layer since BOO-197 (2026-06-14):** static wordlist of known malicious/typosquatted packages under `.claude/hooks/slopsquatting/wordlist.txt`. It is the **first, offline-capable layer** of slopsquatting protection — the `dependency-check.sh` hook (previous block) checks every newly added dependency against this list via `grep` before it triggers the live registry query (second layer). A hit blocks instantly, with no network call. The wordlist does **not replace** the registry query — it catches documented slopsquatting/typosquatting names early and offline too.

> [!important] Schrader Code Crash ch. 3-4
> Slopsquatting only works while a malicious name slips through unnoticed. A project-local wordlist of known cases is the cheapest early detection: a `grep` instead of a registry round trip, and it works without a network (CI runner without egress, offline commit). The live query stays responsible for everything unknown.

**Format:** one line per package, schema `<ecosystem>:<package-name>` (`ecosystem` = `npm` | `pypi` | `cargo`). Comment and blank lines (`#`) are ignored. The header carries the field `# last_refreshed: YYYY-MM-DD`.

**90-day freshness criterion (anchor for `quality-gate-audit`, BOO-183):** the `quality-gate-audit` skill checks both existence **and** age of the wordlist — `last_refreshed` (or the file mtime) must not be older than 90 days. A stale wordlist surfaces in the audit, because the weekly refresh workflow (next block) is no longer running then.

```text
# .claude/hooks/slopsquatting/wordlist.txt — bekannte Slopsquatting-/Typosquatting-Pakete (BOO-197)
# last_refreshed: 2026-06-14
# Format: <ecosystem>:<package-name>   (ecosystem = npm | pypi | cargo)
# Auto-gepflegt vom Workflow .github/workflows/slopsquatting-refresh.yml (woechentlich).
# Manuelle Eintraege/Ausnahmen: .claude/hooks/slopsquatting/slopsquatting-override.yaml
pypi:colourama
pypi:requasts
npm:noblox.js-proxy
```

**Seed content:** the three seed entries are publicly documented cases (typosquats of `colorama`/`requests` and the well-known `noblox.js` typosquat). The list starts deliberately small — the weekly refresh workflow (next block) automatically adds new `malicious-package` entries from public advisory sources.

---

## .github/workflows/slopsquatting-refresh.yml (BOO-197 — weekly wordlist refresh)

**Refresh workflow since BOO-197 (2026-06-14):** GitHub Actions workflow that keeps the wordlist (`wordlist.txt`, previous block) current weekly. It pulls known malicious packages from public advisory sources, deduplicates them, diffs against the current wordlist, updates `last_refreshed`, and opens a PR with a diff description on change. The diff is **never** committed to `main` directly — a human merges the PR.

**Sources:** GitHub Advisory Database (GHSA, GraphQL — `MALWARE` type), OSV (osv.dev — `ecosystems` filter on `MAL-` IDs), OSSF package-analysis feed, npm advisory JSON. All sources are filtered to `malicious-package` entries. Where an API needs a token, the workflow uses `${{ secrets.GITHUB_TOKEN }}` (GHSA GraphQL) — the other sources are public without a token.

**Override:** `.claude/hooks/slopsquatting/slopsquatting-override.yaml` holds manual entries the refresh **never removes** (`never_remove`) or **never adds** (`never_add` — false positives, project-own packages with a similar name). The override is applied after merging the sources. Bash-only parsing via `grep`/`sed` — no `yq`.

> [!important] Token note
> `${{ secrets.GITHUB_TOKEN }}` is the built-in Action token (no PAT needed). If a source endpoint is not enough with the built-in token, the workflow documents the required secret as a comment — **never real secrets in the template**.

```yaml
# .github/workflows/slopsquatting-refresh.yml — woechentlicher Wordlist-Refresh (BOO-197)
# DE: Zieht bekannte malicious Pakete, diffed gegen wordlist.txt, oeffnet bei Aenderung einen PR.
# EN: Pulls known malicious packages, diffs against wordlist.txt, opens a PR on change.
name: Slopsquatting Wordlist Refresh
on:
  schedule:
    - cron: '0 6 * * 1'   # Monday 06:00 UTC
  workflow_dispatch: {}

permissions:
  contents: write
  pull-requests: write

jobs:
  refresh:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Refresh wordlist from public advisory sources
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          set -euo pipefail
          WORDLIST=".claude/hooks/slopsquatting/wordlist.txt"
          OVERRIDE=".claude/hooks/slopsquatting/slopsquatting-override.yaml"
          mkdir -p "$(dirname "$WORDLIST")"
          TMP_NEW="$(mktemp)"

          # --- Source 1: GitHub Advisory DB (GHSA, GraphQL, type=MALWARE) ---
          # Only needs the built-in GITHUB_TOKEN.
          gh api graphql -f query='
            query { securityAdvisories(first: 100, classifications: [MALWARE]) {
              nodes { identifiers { value }
                vulnerabilities(first: 10) { nodes { package { ecosystem name } } } } } }' \
            --jq '.data.securityAdvisories.nodes[].vulnerabilities.nodes[]?
                  | "\(.package.ecosystem|ascii_downcase):\(.package.name)"' \
            2>/dev/null >> "$TMP_NEW" || echo "::warning::GHSA source unavailable"

          # --- Source 2: OSV (osv.dev, malicious-package IDs start with MAL-) ---
          for eco in npm PyPI crates.io; do
            curl -fsSL --max-time 20 "https://api.osv.dev/v1/query" \
              -d "{\"package\":{\"ecosystem\":\"$eco\"}}" 2>/dev/null \
              | grep -oE '"id":"MAL-[^"]+"' >/dev/null 2>&1 || true
          done
          # The full OSV dump runs via the OSV bucket export (gs://osv-vulnerabilities),
          # kept here deliberately as a placeholder source — operator extends as needed.

          # --- Source 3: OSSF package-analysis feed (public, no token) ---
          curl -fsSL --max-time 20 \
            "https://raw.githubusercontent.com/ossf/package-analysis/main/examples/feeds/malicious-packages.txt" \
            2>/dev/null >> "$TMP_NEW" || echo "::warning::OSSF feed unavailable"

          # --- Normalize: ecosystem:name, lowercase, deduplicated ---
          NORM="$(mktemp)"
          grep -vE '^[[:space:]]*(#|$)' "$TMP_NEW" \
            | sed -E 's/[[:space:]]+//g' \
            | tr 'A-Z' 'a-z' \
            | sed -E 's/^pypi:/pypi:/; s/^crates.io:/cargo:/' \
            | grep -E '^(npm|pypi|cargo):[a-z0-9._@/-]+$' \
            | sort -u > "$NORM" || true

          # --- Apply override (bash-only, no yq) ---
          # never_add: remove lines from the fresh pull.
          # never_remove: guaranteed re-added at the end.
          if [[ -f "$OVERRIDE" ]]; then
            sed -n '/never_add:/,/never_remove:/p' "$OVERRIDE" \
              | grep -E '^[[:space:]]*-[[:space:]]' \
              | sed -E 's/^[[:space:]]*-[[:space:]]*//; s/[[:space:]]*$//' \
              | while read -r drop; do
                  [[ -n "$drop" ]] && sed -i "\#^${drop}\$#d" "$NORM"
                done
          fi

          # --- Merge existing (non-comment) entries ---
          MERGED="$(mktemp)"
          { grep -vE '^[[:space:]]*(#|$)' "$WORDLIST" 2>/dev/null || true; cat "$NORM"; } \
            | sort -u >> "$MERGED"

          # keep never_remove guaranteed
          if [[ -f "$OVERRIDE" ]]; then
            sed -n '/never_remove:/,$p' "$OVERRIDE" \
              | grep -E '^[[:space:]]*-[[:space:]]' \
              | sed -E 's/^[[:space:]]*-[[:space:]]*//; s/[[:space:]]*$//' >> "$MERGED"
          fi
          MERGED_SORTED="$(mktemp)"; sort -u "$MERGED" > "$MERGED_SORTED"

          # --- Write new wordlist with updated header ---
          TODAY="$(date -u +%Y-%m-%d)"
          {
            echo "# .claude/hooks/slopsquatting/wordlist.txt — bekannte Slopsquatting-/Typosquatting-Pakete (BOO-197)"
            echo "# last_refreshed: ${TODAY}"
            echo "# Format: <ecosystem>:<package-name>   (ecosystem = npm | pypi | cargo)"
            echo "# Auto-gepflegt vom Workflow .github/workflows/slopsquatting-refresh.yml (woechentlich)."
            echo "# Manuelle Eintraege/Ausnahmen: .claude/hooks/slopsquatting/slopsquatting-override.yaml"
            cat "$MERGED_SORTED"
          } > "$WORDLIST"

      - name: Open PR on change
        uses: peter-evans/create-pull-request@v6
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          branch: chore/slopsquatting-wordlist-refresh
          commit-message: 'chore(security): slopsquatting wordlist refresh (BOO-197)'
          title: 'chore(security): slopsquatting wordlist refresh'
          body: |
            Automatic weekly refresh of the slopsquatting wordlist (BOO-197).
            Sources: GHSA (MALWARE), OSV (MAL-), OSSF package-analysis feed.
            Review the diff below — override rules: .claude/hooks/slopsquatting/slopsquatting-override.yaml
          add-paths: |
            .claude/hooks/slopsquatting/wordlist.txt
```

**Override example** (`.claude/hooks/slopsquatting/slopsquatting-override.yaml`):

```yaml
# slopsquatting-override.yaml — manual control of the wordlist refresh (BOO-197)
# never_add:    NEVER add these names to the wordlist (false positives, own packages).
# never_remove: ALWAYS keep these names in the wordlist (manually verified cases).
never_add:
  - npm:my-internal-pkg
never_remove:
  - pypi:colourama
```

**Runnability & limits:** the workflow is runnable as built — `peter-evans/create-pull-request@v6` only opens a PR on an actual diff (no empty PR). The OSV stage is marked as a placeholder: the full `MAL-` dump runs via the OSV bucket export; the operator extends it per project. `${{ secrets.GITHUB_TOKEN }}` is enough for GHSA and PR creation — no PAT needed, no real secrets in the template.

---

## hooks/coverage-check.sh (BOO-15 — coverage gate >=80% for new code)

**Fourth gate since BOO-15 (2026-05-06), but NOT in the pre-commit hook:** standalone Bash script under `.claude/hooks/coverage-check.sh`, invoked from the `/implement` skill at step 6a-quart — not from the pre-commit hook, because a full test run would blow the hook's 10s budget. The script correlates the NEWLY added lines from `git diff --cached -U0` with coverage data from `coverage/coverage-final.json` (c8) or `coverage.json` (pytest-cov) and decides against three thresholds.

> [!important] Schrader Code Crash ch. 3 §Production Readiness — Gate 2
> Test coverage >=80% on new code, not total coverage. Total coverage on legacy repos is unfair: a well-tested feature can sink under the threshold because of a large untested legacy codebase. Diff coverage measures only what the current commit is responsible for.

**Requirements:** test tooling working — `npx c8 npm test` (Node) or `pytest --cov` (Python) must have run before the hook and produced JSON output. `python3` is used for JSON parsing (standard on Mac/Linux). NO `jq`, NO `yq`, NO npm/pip coverage dependency such as `@connectis/diff-test-coverage` or `diff-cover` — custom Bash parser plus a Python helper for JSON.

**Three thresholds (env-overridable):**
- `COVERAGE_PASS=80` — diff coverage >=80% passes, continue to 6b.
- `COVERAGE_WARN=60` — 60-80% warning, operator override with rationale in the Linear comment.
- `<60%` — gate BLOCKED, add tests or split the story.
- No test infra (no JSON coverage file): gate skipped with a hint to "/bootstrap to set it up".

**Performance:** script run <2 seconds even on larger diffs (serial per-file coverage lookups, cached per file). The test run itself can take several minutes — that is why it is intentionally outside the pre-commit hook.

**Configurable:** `COVERAGE_PASS=90 COVERAGE_WARN=70 bash .claude/hooks/coverage-check.sh` overrides the defaults per run.

> **Script body: single source since BOO-89.** The full script body lives canonically in
> `bootstrap/references/hooks/coverage-check.sh` (v2, incl. the BOO-88 denominator fix). Bootstrap renders it
> **verbatim from that file**; the migration (`migrate_boo_15`) copies it — no embedded heredoc anymore.
> **Do NOT maintain it inline here** (would drift). Consistency is checked by `bootstrap/scripts/check-hook-sources.sh`.

**Anti-patterns:**
- NO `@connectis/diff-test-coverage` as an npm dependency — custom Bash parser stays language-neutral.
- NO `diff-cover` as a Python dependency — same reason.
- NO call from the pre-commit hook (`.git/hooks/pre-commit`) — tests take too long, blow the 10s budget. Invoked exclusively from `/implement` step 6a-quart.
- NO block on test-only / config-only / doc-only diffs — gate skipped.

---

## hooks/anti-placeholder-check.py (BOO-177 — anti-placeholder check for test files)

**Fifth gate since BOO-177, in the `/implement` skill at step 6a-quint (after coverage), NOT in the pre-commit hook:** a targeted, deterministic check **on test files only** — it flags tests that lift the coverage number without testing anything. Same root problem as the sister story BOO-176 ("agent gamed the gate"), here at the test level.

> [!important] Test quality ≠ test quantity
> Coverage (BOO-15) measures *how much* code is touched by tests. Trivial/empty tests (`expect(true).toBe(true)`, `assert True`, empty body) and unjustified skips lift that number without asserting anything. The anti-placeholder check closes exactly this gap — deterministically, without a linter.

**NOT a linter:** ESLint/Ruff/PHPStan check style/types, not test meaningfulness. This is a **dedicated, targeted check** (Python AST like `raw-pii-guard.py` + JS/TS heuristic), not "all linters".

**Detects test files** by: `*.test.{js,ts,jsx,tsx,mjs,cjs}`, `*.spec.{js,ts,jsx,tsx,mjs,cjs}`, `test_*.py`, `*_test.py`, plus everything under `tests/**` / `__tests__/**` (Jest/Vitest and pytest conventions). Non-test files are ignored.

**Flags two classes:**
- **Trivial/empty tests** — `expect(true).toBe(true|toEqual|toBeTruthy)`, `assert(true)`, `assert True`, `assert 1 == 1` / `assert x == x` (same constant), empty test body (only `pass` / `...` / docstring).
- **Unjustified skips** — `it.skip`/`test.skip`/`describe.skip`/`xit`/`xdescribe`/`xtest`, `@pytest.mark.skip`/`@pytest.mark.skipif` **without** `reason=` (Python) or without a justifying comment on the same or the preceding line (JS/TS).

**Prerequisites:** `python3` stdlib only (`ast`, `re`) — NO `semgrep`, NO npm/pip dependency. Default = warning (exit 0); `--strict` or `STRICT=1` turns every hit into a hard fail (exit 1) — consistent with `raw-pii-guard.py` (BOO-93) and the Layer-0 bodyguard (BOO-86).

**Project allowlist** (optional) `.claude/anti-placeholder-check.local` — one glob per line, `#` comments; prefix `path:` declares additional test paths, otherwise the glob is **excluded** from the check.

> **Script body: single source.** The full script body lives canonically in
> `bootstrap/references/hooks/anti-placeholder-check.py`. Bootstrap/migration (`migrate_boo_177`)
> **copies it verbatim** to `.claude/hooks/anti-placeholder-check.py` — no embedded heredoc.
> **Do NOT maintain it inline here** (would drift) — same convention as `coverage-check.sh`
> and `raw-pii-guard.py` (BOO-89).

**Anti-patterns:**
- NOT a linter and NOT a linter rule — test meaningfulness is its own concern.
- NO call from the pre-commit hook — runs exclusively in the `/implement` skill (step 6a-quint).
- NO block on diffs without test files — gate skipped.
- NO generic patterns (e.g. every `expect`) — deliberately specific, low false-positive rate.

**Self-test:** `python3 .claude/hooks/anti-placeholder-check.py --self-test` (must print `SELF-TEST OK`).

---

## hooks/ccusage-capture.sh (BOO-189 — token/cost snapshot)

**Capture hook since BOO-189 — NOT a quality gate, but a measurement:** standalone Bash script under `.claude/hooks/ccusage-capture.sh` that **appends** a snapshot of token/cost consumption to `docs/financials/sprint-costs.md` at sprint/story boundaries. It blocks nothing and decides nothing — it persists an as-measured figure so token consumption is a documented number rather than a guess. The data source is [`ccusage`](https://github.com/ryoppippi/ccusage) (MIT), which reads the local Claude Code JSONL logs; invoked via `npx --yes ccusage@latest`.

> [!important] Schrader Code Crash — tokens are budget
> Token consumption is the real cost driver of an AI-assisted pipeline. "We think that was cheap" is not a number. The capture hook turns consumption per sprint/story into a persisted, verifiable measurement — the basis for any budget or ROI statement.

**When invoked:** as a **closing step** of `/sprint-run`, `/implement`, and `/sprint-review` (wiring it into those skills is a separate story). Manually: `bash .claude/hooks/ccusage-capture.sh "<label>"` — e.g. `"/sprint-run sprint-2"`. The label becomes the snapshot heading in the file.

**On a Max/Pro account** ccusage reports token consumption as a shadow price (what the same usage would have cost via API); on **API usage**, real cost in the project currency. Both are appended verbatim as a text block.

> [!warning] Sub-agent tokens may not be attributed cleanly
> ccusage currently does not reliably attribute sub-agent (Task tool) tokens to the triggering run — see ccusage issues #313, #806, #950. Snapshots from sub-agent-heavy runs may therefore under- or mis-attribute consumption. The number is an **approximation**, not a cent-accurate audit. (Detailed docs: HANDBUCH/README.)

**Requirements:** `npx` (Node) must be available — `npx --yes ccusage@latest` pulls the tool transiently when needed. No global install, no project dependency. If `npx` is missing, the hook writes a hint snapshot instead of failing.

**bash-only, no jq:** the hook parses **nothing**. It takes the **text output** of `ccusage daily` and appends it verbatim inside a code fence in the Markdown file — deliberately no `--json` + `jq`/`yq`. Same rationale as the other hooks: language-neutral, dependency-free, no JSON parser in a Bash hook. Whatever ccusage shows ends up in the snapshot.

**Complementary to `meta.json.token_tracking`** (implement/SKILL.md, BOO-84): the `token_tracking` schema is the **structured per-story estimate** per iteration/skill invocation, populated by the `/implement` run itself (pricing from `bootstrap/references/model-tiers.json`). ccusage is the **as-measured figure from the session logs** — collected independently, across all runs of a session. The two complement each other: `meta.json` = what the pipeline thinks it consumed per story, `sprint-costs.md` = what ccusage actually measured in the logs.

```bash
#!/usr/bin/env bash
# .claude/hooks/ccusage-capture.sh — Token-/Kosten-Snapshot nach Sprint/Story (BOO-189)
# DE: Haengt einen ccusage-Snapshot an docs/financials/sprint-costs.md an.
# EN: Appends a ccusage snapshot to docs/financials/sprint-costs.md.
# Aufruf: bash .claude/hooks/ccusage-capture.sh "<label>"   z.B. "/sprint-run sprint-2"
# bash-only: ccusage-Textausgabe wird verbatim angehaengt — KEIN jq/yq, kein JSON-Parsing.
# Limitation: Sub-Agent-Token (Task-Tool) evtl. nicht sauber attribuiert — ccusage #313/#806/#950.
set -euo pipefail

LABEL="${1:-manual}"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT="$ROOT/docs/financials/sprint-costs.md"
mkdir -p "$(dirname "$OUT")"

# Datei mit Header anlegen, falls noch nicht vorhanden (idempotent).
if [[ ! -f "$OUT" ]]; then
  printf '# Sprint-Kosten — Token-Verbrauch (ccusage, BOO-189)\n\n> Persistierte Snapshots des Token-/Kosten-Verbrauchs. Sub-Agent-Token werden von ccusage evtl. nicht sauber attribuiert (Issues #313/#806/#950).\n' > "$OUT"
fi

TS="$(date -u +%Y-%m-%dT%H:%MZ)"

# ccusage-Textausgabe holen (kein --json, kein Parsing). Bei Fehler: Hinweis statt Hard-Fail.
if command -v npx >/dev/null 2>&1; then
  SNAP="$(npx --yes ccusage@latest daily --since "$(date -u +%Y%m%d)" 2>/dev/null || echo '(ccusage-Aufruf fehlgeschlagen)')"
else
  SNAP="(npx/ccusage nicht installiert — npm i -g ccusage oder npx ccusage@latest)"
fi

# Snapshot verbatim als Code-Fence anhaengen.
{
  printf '\n## %s — %s\n\n```\n%s\n```\n' "$TS" "$LABEL" "$SNAP"
} >> "$OUT"

echo "[ccusage] Snapshot angehaengt: $OUT ($LABEL)"
```

**Anti-patterns:**
- NO `--json` + `jq`/`yq` — the text output is appended verbatim, deliberately no parser in the hook.
- NO forcing a global ccusage install as a project dependency — `npx --yes ccusage@latest` pulls it transiently.
- NO hard fail when `npx`/ccusage is missing — hint snapshot instead of abort; the hook must never block a run.
- NO interpreting the sub-agent numbers as exact — approximation (ccusage #313/#806/#950).

---

## docs/financials/budget.md (BOO-190 — project budget template)

**Template generator since BOO-190 — not a runtime calculator:** a lean project budget for the financials/ROI view. **Generated once** by `/bootstrap` (financials question), then maintained by the operator. It only holds the project assumptions (billing rate, geo/currency, optional token cost) and points to the two measurement/reference sources next to it (`worker-equivalent-baseline.md`, `sprint-costs.md`).

> [!important] Schrader Code Crash — ROI needs a documented rate
> The story double column (`effort_ai_hours` / `effort_human_equiv_hours`, BOO-193) only turns into a money ROI factor if a project-specific billing rate exists. `budget.md` is the single place that rate and its geo/currency live — everything else (actual cost, baseline) sits referenced next to it, not duplicated.

**Generation (byte-identical to the SSoT):** the heredoc below is the canonical template source and is **byte-identical** to `docs/financials/budget.md` in the framework repo (German data file — kept verbatim). `migrate_boo_190()` in `migrate-to-v2.sh` creates the file from it when missing in the target project (idempotent).

**The worker-equivalent baseline (`worker-equivalent-baseline.md`) belongs to this but is NOT a second full heredoc:** the baseline is **framework reference data** (per-geo defaults from the internal deep research, documented by the `financials` skill) — not a per-project data table. `migrate_boo_190()` only lays down a **short pointer stub** for it that keeps the active rate (section 1) local and refers to the skill reference for the geo defaults. This avoids triplicate maintenance of a ~60-line table.

```markdown
# Projekt-Budget — Worker-Equivalent & Kosten

> Schlankes Budget-Template für die Financials-/ROI-Sicht eines Projekts (BOO-190). Von `/bootstrap`
> (Financials-Frage) angelegt, danach vom Operator gepflegt. Verweist auf die zwei Mess-/Referenz-Quellen
> daneben — selbst hält diese Datei nur die Projekt-Annahmen.

## Projekt-Annahmen

```yaml
geo: <CH | DE | AT | US>
currency: <CHF | EUR | USD>
rate_per_hour: <Zahl>             # = aktiver Satz aus worker-equivalent-baseline.md Abschnitt 1
token_cost_assumption: <optional> # falls KI-Token-Kosten separat budgetiert werden
```

## Quellen daneben (nicht hier duplizieren)

| Quelle | Was sie liefert | Datei |
|--------|------------------|-------|
| Verrechnungssatz + Geo-Defaults | aktiver Satz (intern/market-research) + Fallback-Baseline | [`worker-equivalent-baseline.md`](worker-equivalent-baseline.md) |
| Ist-Token-/Kosten-Verbrauch | gemessene ccusage-Snapshots pro Sprint/Story (BOO-189) | [`sprint-costs.md`](sprint-costs.md) |
| Worker-Equivalent-Report pro Sprint | KI-Kosten / Mensch-Equiv / ROI / Wall-Clock (BOO-191) | `sprint-XX-worker-equivalent.md` |

## So rechnet die ROI-Sicht (Kurzform)

- **KI-Kosten** = gemessener Token-/Kosten-Verbrauch (`sprint-costs.md`).
- **Mensch-Equivalent-Kosten** = Σ `effort_human_equiv_hours` der Sprint-Stories × `rate_per_hour`.
- **ROI-Faktor** = Mensch-Equivalent-Kosten ÷ KI-Kosten.
- **Wall-Clock** = reale Sprint-Dauer aus dem Sprint-Log.

> Die Doppelspalte `effort_ai_hours` / `effort_human_equiv_hours` pro Story (BOO-193) ist die
> Datenquelle. ROI-Sprache bleibt vorerst intern, bis ≥3 Sprints Daten vorliegen (ADR-D §Offen).
```

**Anti-patterns:**
- NO second full heredoc for `worker-equivalent-baseline.md` — the ~60-line per-geo table is framework reference (skill `financials`), not per-project data. Generate a pointer stub only.
- NO FX cross-conversion — the rate stays native per geo (CH CHF / DE,AT EUR / US USD); on rate drift >5% just a user hint (primary source §2.3).
- NO overwriting an existing `budget.md` — `migrate_boo_190()` only creates when missing (idempotent, operator edits preserved).

---

## .claude/statusline.sh (BOO-205 — status line with worker-equivalent)

> Native Claude Code status line. **The SSoT is the real file `bootstrap/templates/statusline.sh`** — deliberately NO heredoc duplicate here (avoid triplicate maintenance, cf. `worker-equivalent-baseline.md`). `migrate_boo_205` installs it byte-identically as `.claude/statusline.sh` and wires it up. Active **only** when `runtime_target: claude-code` (switch A) — nothing is wired for `codex`/`cross-tool`/`unknown`.

The script reads the JSON Claude Code passes on stdin (`.model.display_name`, `.context_window.total_input_tokens`/`.context_window_size`, `.cost.total_cost_usd`, `.worktree.branch`) and enriches it with the **worker-equivalent** (`effort_ai_hours` / `effort_human_equiv_hours` from `specs/<story>.md`, BOO-193). Defensive: every field optional, always exits 0. Output (one line):

```
Sonnet 4.7 | 142k/200k ctx | Worker-Equiv: 2.5h / 16h | Story BOO-205 | $4.20
```

Wiring in `.claude/settings.json` (the native render path — Claude Code reads the status line exclusively from here, **not** from `environment.json`):

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash .claude/statusline.sh",
    "padding": 0
  }
}
```

`migrate_boo_205` additionally adds a manifest reference `"status_line": ".claude/statusline.sh"` to `.claude/environment.json` (AC#2 — the framework manifest knows the script; the render wiring stays in `settings.json`). Full documentation: HANDBUCH **Appendix AQ**.

---

## hooks/pre-edit-bodyguard.sh (BOO-86 — Layer-0 Edit-Bodyguard)

**Layer-0 gate since BOO-86:** a Claude Code **PreToolUse hook** on `Edit|Write` that
catches unsafe patterns (secrets, `eval`, disabled TLS verification, SQL concatenation)
**before** the AI writes them to disk — a sibling hook to `spec-gate.sh` (which fires on
`Bash`/`git commit`). Default is **warning** (low false-positive, no alarm fatigue);
hard-block via `BODYGUARD_STRICT=1`. Deliberately lightweight: a small, curated pattern
set — NOT a full Semgrep run per edit (depth stays at layer 2/3).

**Scaffold (all dependency-free, only bash + python3 stdlib):**

| File | Purpose |
|-------|------|
| `.claude/hooks/pre-edit-bodyguard.sh` | the hook (reads stdin JSON, matches patterns) |
| `.claude/hooks/bodyguard/patterns/_universal.yml` | secrets, language-agnostic |
| `.claude/hooks/bodyguard/patterns/gate-configs.yml` | quality-gate weakening (rule disable / threshold edit), language-agnostic — BOO-176 |
| `.claude/hooks/bodyguard/patterns/{python,javascript,java,c-cpp}.yml` | language-specific |
| `.claude/hooks/bodyguard/SOURCES.md` | origin/versions/maintenance convention |
| `.claude/bodyguard.local.yml` | **optional** project overlay (overrides base by `name`) |

Pattern schema (flat YAML subset, read by the mini-parser in the hook — no PyYAML needed):
`name` · `pattern` (Python regex) · `sprache` · `quelle` (CWE/OWASP/gitleaks/Semgrep — mandatory, audit evidence) · `action` (`block|warn`).

```bash
#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  PRE-EDIT-BODYGUARD — Layer-0 Governance Hook (BOO-86)
#  Faengt unsichere Muster ab, BEVOR die KI sie schreibt.
#
#  Claude Code PreToolUse Hook (Bash) — Matcher: Edit|Write
#  Input: JSON via stdin: {"tool_input": {"file_path": "...", "content"/"new_string": "..."}}
#  Exit 1 → Tool-Call blockiert | Exit 0 → erlaubt (Default: Warnung)
#  BODYGUARD_STRICT=1 → warn-Muster werden zu block (opt-in Hard-Block)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERN_DIR="${SCRIPT_DIR}/bodyguard/patterns"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
OVERLAY="${PROJECT_ROOT}/.claude/bodyguard.local.yml"
STRICT="${BODYGUARD_STRICT:-0}"

INPUT="$(cat)"

printf '%s' "$INPUT" | python3 -c "$(cat <<'PYEOF'
import sys, json, re, os
pattern_dir, overlay, strict = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
try:
    data = json.loads(sys.stdin.read())
except Exception:
    sys.exit(0)  # nicht parsebar → nicht blockieren
ti = data.get("tool_input", {}) or {}
file_path = ti.get("file_path", "") or ""
content = ti.get("content") or ti.get("new_string") or ""
if not content and isinstance(ti.get("edits"), list):
    content = "\n".join(e.get("new_string", "") for e in ti["edits"])
if not content:
    sys.exit(0)
ext = os.path.splitext(file_path)[1].lower()
lang_map = {".js":"javascript",".mjs":"javascript",".cjs":"javascript",".ts":"javascript",
            ".tsx":"javascript",".jsx":"javascript",".py":"python",".java":"java",
            ".c":"c-cpp",".h":"c-cpp",".cpp":"c-cpp",".cc":"c-cpp",".hpp":"c-cpp"}
lang = lang_map.get(ext)
def parse_patterns(path):
    out, cur = [], None
    if not os.path.isfile(path):
        return out
    for line in open(path, encoding="utf-8"):
        s = line.rstrip("\n")
        if not s.strip() or s.lstrip().startswith("#"):
            continue
        if s.lstrip().startswith("- "):
            if cur: out.append(cur)
            cur, s = {}, s.lstrip()[2:]
        if ":" in s and cur is not None:
            k, v = s.split(":", 1)
            cur[k.strip()] = v.strip().strip("'\"")
    if cur: out.append(cur)
    return out
files = [os.path.join(pattern_dir, "_universal.yml"),
         os.path.join(pattern_dir, "gate-configs.yml")]  # immer geladen (Quality-Gate-Schutz, BOO-176)
if lang: files.append(os.path.join(pattern_dir, lang + ".yml"))
files.append(overlay)  # Overlay zuletzt → uebersteuert per name
patterns, order = {}, []
for f in files:
    for p in parse_patterns(f):
        n = p.get("name")
        if not n or not p.get("pattern"): continue
        if n not in patterns: order.append(n)
        patterns[n] = p
blocks, warns = [], []
for n in order:
    p = patterns[n]
    try: rx = re.compile(p["pattern"])
    except re.error: continue
    if rx.search(content):
        action = (p.get("action") or "warn").lower()
        if strict and action == "warn": action = "block"
        msg = "  [%s] %s — %s" % (n, p.get("quelle","?"), file_path or "?")
        (blocks if action == "block" else warns).append(msg)
if warns:
    sys.stderr.write("[BODYGUARD] WARNUNG — unsichere Muster im neuen Code:\n" + "\n".join(warns) + "\n")
if blocks:
    sys.stderr.write("\n[BODYGUARD] BLOCKIERT — sicherheitskritische Muster:\n" + "\n".join(blocks) +
                     "\n  Bitte entfernen/ersetzen: Secret in env/Secret-Manager, parametrisierte Query, sichere API/TLS.\n")
    sys.exit(1)
sys.exit(0)
PYEOF
)" "$PATTERN_DIR" "$OVERLAY" "$STRICT"
```

**`bodyguard/patterns/_universal.yml`** (secrets, language-agnostic):

```yaml
# Bodyguard Layer-0 — universelle Muster (sprachunabhaengig)
# Schema: - name / pattern / sprache / quelle / action(block|warn)
- name: aws-access-key-id
  pattern: 'AKIA[0-9A-Z]{16}'
  sprache: alle
  quelle: 'gitleaks / CWE-798'
  action: block
- name: private-key-block
  pattern: '-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----'
  sprache: alle
  quelle: 'gitleaks / CWE-321'
  action: block
- name: slack-token
  pattern: 'xox[baprs]-[0-9A-Za-z-]{10,}'
  sprache: alle
  quelle: 'gitleaks / CWE-798'
  action: block
- name: github-token
  pattern: 'gh[pousr]_[0-9A-Za-z]{36,}'
  sprache: alle
  quelle: 'gitleaks / CWE-798'
  action: block
- name: generic-secret-assignment
  pattern: '(?i)(api[_-]?key|secret|token|passwd|password)\s*[:=]\s*[\x27"][^\x27"]{8,}[\x27"]'
  sprache: alle
  quelle: 'gitleaks / CWE-798'
  action: warn
```

**`bodyguard/patterns/python.yml`**:

```yaml
- name: python-subprocess-shell-true
  pattern: 'subprocess\.(run|call|Popen|check_output)\([^)]*shell\s*=\s*True'
  sprache: python
  quelle: 'CWE-78 / Bandit B602'
  action: block
- name: python-requests-verify-false
  pattern: 'verify\s*=\s*False'
  sprache: python
  quelle: 'CWE-295'
  action: block
- name: python-eval
  pattern: '\beval\s*\('
  sprache: python
  quelle: 'CWE-95 / Bandit B307'
  action: warn
- name: python-yaml-load-unsafe
  pattern: 'yaml\.load\s*\((?![^)]*SafeLoader)'
  sprache: python
  quelle: 'CWE-20 / Bandit B506'
  action: warn
- name: python-sql-fstring
  pattern: '(?i)(execute|executemany)\s*\(\s*f[\x27"]'
  sprache: python
  quelle: 'CWE-89'
  action: warn
```

**`bodyguard/patterns/javascript.yml`** (also applies to TypeScript):

```yaml
- name: js-tls-reject-unauthorized-false
  pattern: 'rejectUnauthorized\s*:\s*false'
  sprache: javascript
  quelle: 'CWE-295'
  action: block
- name: js-node-tls-env-0
  pattern: 'NODE_TLS_REJECT_UNAUTHORIZED\s*=\s*[\x27"]?0'
  sprache: javascript
  quelle: 'CWE-295'
  action: block
- name: js-eval
  pattern: '\beval\s*\('
  sprache: javascript
  quelle: 'CWE-95 / eslint no-eval'
  action: warn
- name: js-child-process-exec
  pattern: '(?i)child_process[\s\S]{0,20}\bexec\s*\('
  sprache: javascript
  quelle: 'CWE-78'
  action: warn
- name: js-sql-string-concat
  pattern: '(?i)(query|execute)\s*\(\s*[`\x27"][^`\x27"]*\+'
  sprache: javascript
  quelle: 'CWE-89'
  action: warn
```

**`bodyguard/patterns/java.yml`**:

```yaml
- name: java-runtime-exec
  pattern: 'Runtime\.getRuntime\(\)\.exec\s*\('
  sprache: java
  quelle: 'CWE-78'
  action: warn
- name: java-deserialize
  pattern: 'new\s+ObjectInputStream\s*\('
  sprache: java
  quelle: 'CWE-502'
  action: warn
- name: java-sql-concat
  pattern: '(?i)(createStatement|executeQuery)\s*\([^)]*\+'
  sprache: java
  quelle: 'CWE-89'
  action: warn
```

**`bodyguard/patterns/c-cpp.yml`**:

```yaml
- name: c-gets
  pattern: '\bgets\s*\('
  sprache: c-cpp
  quelle: 'CWE-242'
  action: block
- name: c-strcpy
  pattern: '\bstrcpy\s*\('
  sprache: c-cpp
  quelle: 'CWE-120'
  action: warn
- name: c-system
  pattern: '\bsystem\s*\('
  sprache: c-cpp
  quelle: 'CWE-78'
  action: warn
- name: c-sprintf
  pattern: '\bsprintf\s*\('
  sprache: c-cpp
  quelle: 'CWE-120'
  action: warn
```

**`bodyguard/patterns/gate-configs.yml`** (quality-gate weakening — language-agnostic, always loaded, BOO-176):

These patterns flag **suspicious rule disables / threshold edits** in the new content — the hook
only sees the NEW content (no old/new comparison), so it does not say "lowering detected" but
"you are editing a quality threshold / disabling a rule — that is an operator decision, not an
agent workaround". The real old→new threshold comparison is done by the post-story gate assertion
(another cluster), not by this hook.

```yaml
# Bodyguard Layer-0 — Quality-Gate-Aufweichung (sprachunabhaengig)
# Schema: - name / pattern / sprache / quelle / action(block|warn)
# Immer geladen (wie _universal.yml), weil Gate-Configs auf vielen Datei-Endungen leben.
- name: eslint-disable-file-wide
  pattern: '/\*\s*eslint-disable\s*\*/'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: ts-nocheck
  pattern: '@ts-nocheck'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: python-bare-noqa
  pattern: '#\s*noqa(?!\s*:)'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: python-bare-type-ignore
  pattern: '#\s*type:\s*ignore(?!\[)'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: pytest-mark-skip
  pattern: '@pytest\.mark\.skip\b'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: js-suite-skip
  pattern: '\b(describe|it|test|xit)\.skip\s*\(|\bxit\s*\('
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: phpstan-level-edit
  pattern: '(?m)^\s*level:\s*\d'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: coverage-threshold-edit
  pattern: '(?i)(fail_under|coverageThreshold|minimum_coverage)\s*[:=]'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
```

> **Note:** Default is `warn` — these patterns alert the operator, they do not hard-block
> (false-positive-light: a legitimate `# noqa` without a code is rare but possible). To hard-block
> gate edits, run the hook with `BODYGUARD_STRICT=1`. The actual review block on gate-config
> *files* additionally comes from `.claude/sensitive-paths.json` (see there, group
> "Gate-Config / Quality-Threshold").

**`bodyguard/SOURCES.md`** (origin + maintenance convention):

```markdown
# Bodyguard-Muster — Quellen & Pflege (BOO-86)

Die Muster sind **kuratiert aus anerkannten Katalogen**, nicht erfunden. Jedes Muster
traegt im `quelle`-Feld seinen Beleg.

| Quelle | Wofuer |
|--------|--------|
| CWE (Common Weakness Enumeration) | kanonische Schwachstellen-IDs pro Muster |
| OWASP (Top 10, ASVS, Cheat Sheets) | Priorisierung/Begruendung |
| gitleaks (open source) | Secret-Muster (`_universal.yml`) |
| Semgrep Registry / Bandit / eslint-plugin-security | sprachspezifische Unsafe-Code-Muster |
| BOO-176 (Quality-Gate-Integritaet) | Quality-Gate-Aufweichung (`gate-configs.yml`): Regel-Deaktivierung / Schwellen-Edit |

## Pflege-Konvention
- **Kuratiert + klein halten** — wenige Muster mit hoher Trefferquote. Lieber 30
  wasserdichte als 300 nervige (sonst Alarm-Muedigkeit → Hook wird abgeschaltet).
- **Basis** kommt mit Framework-Versionen (dieses Template). **Projekt-Overlay**
  `.claude/bodyguard.local.yml` ist kundeneigen und ueberlebt Updates.
- Optionales `sync-bodyguard-patterns.sh` gleicht gegen Upstream ab und **schlaegt** Muster
  **vor** — Mensch entscheidet, KEIN Auto-Merge (Supply-Chain-Schutz).
- Default-Schweregrad ist `warn`; `block` nur fuer eindeutige, kontextunabhaengige Treffer
  (Secrets, abgeschaltete TLS-Pruefung, `gets`). Die `gate-configs.yml`-Muster bleiben bewusst
  `warn` (Operator-Alarm bei Gate-Aufweichung), der harte Review-Block kommt aus `sensitive-paths.json`.
```

**`.claude/bodyguard.local.yml`** (optional project overlay — overrides/extends the base):

```yaml
# Projekt-eigene Bodyguard-Muster — uebersteuert die Framework-Basis per `name`.
# Ueberlebt Framework-Updates. Gleiches Schema wie patterns/*.yml.
# Beispiel: internen Legacy-Endpoint verbieten
# - name: no-legacy-internal-api
#   pattern: 'https?://legacy-intern\.example\.local'
#   sprache: alle
#   quelle: 'projekt-policy'
#   action: block
```

**Anti-patterns:**
- NO full Semgrep/SAST run in the hook — that is layer 2/3. Layer 0 is a fast reflex.
- NO regex comment/statement detection with heuristics — only direct pattern matches.
- NO auto-merge of external patterns into the active hook.
- NO hard-block as default — `warn` is the default, `BODYGUARD_STRICT=1` is opt-in.

---

## .claude/environment.json (BOO-34 — skill environment awareness)

**Single source of truth for environment, tooling and paths since BOO-34 (2026-05-06):** one manifest per project, every skill reads it in a step-0 lookup instead of re-running detection logic itself. Three environments (`mac` | `vps` | `ci`), one tool-availability matrix (eslint, semgrep, test framework, SonarQube), default paths for journal/reports/lessons/specs.

> [!important] Why one file instead of per-skill detection?
> Before BOO-34 every skill (implement, sprint-review, breakfix, ...) called `uname` / `command -v` itself — duplicated logic, inconsistently maintained. With `.claude/environment.json` the skill only asks `cat .claude/environment.json | grep '"semgrep"'`. Generated once by the bootstrap skill in phase 4.4e, can be re-run with `--force` whenever the environment changes (e.g. mac operator pushes to a new VPS for the first time, tooling reinstalled).

**Schema (single source of truth for fields and values):**

```json
{
  "environment": "mac",
  "tools_available": {
    "eslint": true,
    "semgrep": true,
    "tests": "vitest",
    "sonarqube_ide_plugin": false,
    "sonarqube_cloud": true
  },
  "paths": {
    "journal": "journal/",
    "reports_local": "journal/reports/local/",
    "reports_ci": "journal/reports/ci/",
    "lessons_l1": "journal/learnings.md",
    "lessons_l2_dir": "journal/",
    "lessons_l3": "journal/learnings.db",
    "specs": "specs/",
    "architecture_design": "ARCHITECTURE_DESIGN.md",
    "conventions": "CONVENTIONS.md",
    "intents": "intents/",
    "pitches": "pitch/"
  },
  "governance": {
    "mode": "standard",
    "execution_isolation": "write-scope",
    "worktree_required_for": ["agentic"],
    "write_scope_required_for": ["sub-agents"],
    "compliance_doc_gate": false
  },
  "thresholds": {
    "architecture_doc_freshness_days": 30,
    "token_warn_threshold": 70,
    "token_hard_threshold": 80
  },
  "metadata": {
    "created_at": "2026-05-06T14:30:00Z",
    "bootstrap_version": "3.3.0",
    "stack": "node-typescript"
  },
  "llm_proxy_url": null
}
```

**Fields:**

| Field | Type | Values / description |
|------|-----|---------------------|
| `environment` | string | `mac` (Darwin), `vps` (Linux without `$CI`), `ci` (env var `CI` set — any value) |
| `tools_available.eslint` | bool | true if `command -v eslint` OR locally in `node_modules` (via `npm ls eslint`) |
| `tools_available.semgrep` | bool | true if `command -v semgrep` |
| `tools_available.tests` | string\|null | `"vitest"` / `"jest"` / `"mocha"` / `"pytest"` / `null` — detected from `package.json` or `pyproject.toml` |
| `tools_available.sonarqube_ide_plugin` | bool | Default `false`. Cannot be detected via CLI — operator manually flips to `true` when SonarLint VS Code plugin is active. |
| `tools_available.sonarqube_cloud` | bool | Hardcoded `true` — cloud API is reachable from anywhere. Only signals "is the skill allowed to call SonarCloud?". Flip to `false` manually if the project does not use SonarCloud. |
| `paths.*` | string | Default paths relative to the project root. Skills read via these keys instead of hardcoded strings. |
| `governance.mode` | string | `lite` / `standard` / `heavy` — from `CONVENTIONS.md`; controls which gates are mandatory. |
| `governance.execution_isolation` | string | `none` / `write-scope` / `git-worktree` — from `CONVENTIONS.md`; controls whether parallel agents need worktrees or disjoint write scopes. |
| `governance.compliance_doc_gate` | bool | Default `false`. Opt-in add-on (BOO-229), mirrored from `CONVENTIONS.md`. `true` → the shared doc-drift checker (`scripts/doc-drift-check.sh`) blocks `/ideation`/`/architecture-review`/`/implement` on FAIL (a registered file is missing) instead of only warning. Orthogonal to `governance.mode`. |
| `thresholds.architecture_doc_freshness_days` | int | Default `30`. Maximum age (in days) of `ARCHITECTURE_DESIGN.md` before `/ideation` step 0a shows a soft pre-flight reminder. Fast-evolving systems: 14. Stable systems: 90. |
| `thresholds.token_warn_threshold` | int | Default `70`. Percentage of the context window above which `/implement` step 0b shows a soft hint ("one small story may still fit"). |
| `thresholds.token_hard_threshold` | int | Default `80`. Percentage above which `/implement` step 0b recommends sprint close (the sprint-box limit per HANDBUCH Appendix G). The operator may proceed with a conscious decision — the override is recorded in `meta.json.pre_flight_warning`. |
| `metadata.created_at` | string | ISO-8601 UTC, set on first generator run. |
| `metadata.bootstrap_version` | string | Active bootstrap version at generator time. |
| `metadata.stack` | string | `node-typescript` / `node-javascript` / `python` / `mixed` / `unknown` — analogous to BOO-3 stack detection. |
| `llm_proxy_url` | string\|null | **Optional (BOO-71).** Default `null` = direct LLM call. When set: HTTP(S) endpoint of an operator-side proxy server (anonymisation, logging, sovereignty routing). The framework does NOT perform the routing itself — the value is only read and recorded in `meta.json.llm_routing` as an audit trail. Details: HANDBUCH Appendix Q (Sovereignty Stack + LLM Proxy Hook). |

**Order of `environment` detection matters:** CI check FIRST, then mac, then VPS — a CI runner can be Linux **or** mac. If the skill checked for Darwin first, a mac CI job would be incorrectly flagged as `mac`.

**Consumed by:** all sub-skills via a step-0 read (rollout in BOO-34 sub-agent #2). Example pattern for a skill:

```bash
# Step 0: read environment
ENV_FILE=".claude/environment.json"
if [[ -f "$ENV_FILE" ]]; then
    HAS_SEMGREP=$(grep '"semgrep"' "$ENV_FILE" | grep -oE 'true|false')
    REPORTS_DIR=$(grep '"reports_local"' "$ENV_FILE" | sed -E 's/.*: "([^"]+)".*/\1/')
fi
```

**Anti-patterns:**
- NO `jq` as a hard dependency — `grep` + `sed` are enough for the few reads a skill needs. `jq` is not guaranteed on VPS/CI, on mac `brew install jq` has to run. (The handbook mentions `jq` as optional reader convenience.)
- NO auto-refresh on every skill run — the file is only written by bootstrap and manual `--force`. Skills are read-only.
- NO writes from sub-skills — single source of truth stays the generator. Sub-agent #2 only adds reads.

---

## .claude/generate-environment-json.sh (BOO-34)

**Bash generator for the environment manifest, BSD- and Linux-compatible.** Called by the bootstrap skill in phase 4.4e, can be re-run manually with `--force`. Idempotent: only writes if the file is missing or `--force` is set.

> [!important] No external dependencies
> Only `bash`, `uname`, `command`, `cat`, `grep`, `sed`, `date` (POSIX standard) — explicitly NO `jq`, NO `yq`, NO `python3`. JSON is written via heredoc. Result: the generator runs on every mac operator machine and every VPS/CI Linux without setup.

**BSD compatibility (MANDATORY):** `[[:space:]]+` instead of `\s+`, `[[:digit:]]` instead of `\d`, `grep -E` instead of `grep -P`, `sed` without `-i` (we write a temp file via heredoc instead of in-place edit). Runs on macOS Darwin **and** Linux.

```bash
#!/usr/bin/env bash
# .claude/generate-environment-json.sh — Environment-Awareness-Generator (BOO-34)
# DE: Erzeugt .claude/environment.json mit Detection von Mac/VPS/CI, verfuegbaren
#     Tools (eslint, semgrep, Test-Framework) und Standard-Pfaden. BSD- und
#     Linux-kompatibel, ohne Abhaengigkeiten ausser bash, uname, command, cat,
#     grep, sed, date.
# EN: Generates .claude/environment.json with Mac/VPS/CI detection, available
#     tools (eslint, semgrep, test framework) and default paths. BSD- and
#     Linux-compatible, no deps beyond bash, uname, command, cat, grep, sed, date.
set -euo pipefail

# --- CLI flags ---
FORCE=0
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        --help|-h)
            cat <<'HLP'
Usage: bash .claude/generate-environment-json.sh [--force]
  --force   Overwrite existing .claude/environment.json
HLP
            exit 0 ;;
    esac
done

OUT=".claude/environment.json"
mkdir -p .claude

if [[ -f "$OUT" && $FORCE -eq 0 ]]; then
    echo "[ENV] $OUT already exists — skip (use --force to overwrite)."
    exit 0
fi

# --- environment: ci > mac > vps ---
# CI check FIRST: a CI runner can be Linux OR mac.
if [[ -n "${CI:-}" ]]; then
    ENVIRONMENT="ci"
elif [[ "$(uname -s)" = "Darwin" ]]; then
    ENVIRONMENT="mac"
else
    ENVIRONMENT="vps"
fi

# --- tools_available ---
# eslint: command -v OR locally in node_modules
HAS_ESLINT="false"
if command -v eslint >/dev/null 2>&1; then
    HAS_ESLINT="true"
elif [[ -f "package.json" ]] && command -v npm >/dev/null 2>&1; then
    if npm ls eslint --silent >/dev/null 2>&1; then
        HAS_ESLINT="true"
    fi
fi

# semgrep: only via command -v (PATH)
HAS_SEMGREP="false"
if command -v semgrep >/dev/null 2>&1; then
    HAS_SEMGREP="true"
fi

# tests: detect from package.json (vitest/jest/mocha) or pyproject.toml (pytest)
TESTS="null"
if [[ -f "package.json" ]]; then
    if grep -q '"vitest"' package.json 2>/dev/null; then
        TESTS='"vitest"'
    elif grep -q '"jest"' package.json 2>/dev/null; then
        TESTS='"jest"'
    elif grep -q '"mocha"' package.json 2>/dev/null; then
        TESTS='"mocha"'
    fi
fi
if [[ "$TESTS" = "null" && -f "pyproject.toml" ]]; then
    if grep -qE '(pytest|^\[tool\.pytest)' pyproject.toml 2>/dev/null; then
        TESTS='"pytest"'
    fi
fi

# sonarqube_ide_plugin: not detectable via CLI — default false, operator flips manually on mac.
SONAR_IDE="false"

# sonarqube_cloud: cloud API is reachable from anywhere — hardcoded true.
SONAR_CLOUD="true"

# --- metadata.stack: analogous to BOO-3 semgrep stack detection ---
HAS_PKG=0
HAS_PY=0
[[ -f "package.json" ]] && HAS_PKG=1
[[ -f "pyproject.toml" ]] && HAS_PY=1

if [[ $HAS_PKG -eq 1 && $HAS_PY -eq 1 ]]; then
    STACK="mixed"
elif [[ $HAS_PKG -eq 1 ]]; then
    # TS vs JS: tsconfig.json or "typescript" as devDep
    if [[ -f "tsconfig.json" ]] || grep -q '"typescript"' package.json 2>/dev/null; then
        STACK="node-typescript"
    else
        STACK="node-javascript"
    fi
elif [[ $HAS_PY -eq 1 ]]; then
    STACK="python"
else
    STACK="unknown"
fi

# --- metadata.created_at: ISO-8601 UTC ---
CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# --- metadata.bootstrap_version: current bootstrap version ---
BOOTSTRAP_VERSION="3.3.0"

# --- JSON via heredoc (no jq required) ---
cat > "$OUT" <<EOF
{
  "environment": "${ENVIRONMENT}",
  "tools_available": {
    "eslint": ${HAS_ESLINT},
    "semgrep": ${HAS_SEMGREP},
    "tests": ${TESTS},
    "sonarqube_ide_plugin": ${SONAR_IDE},
    "sonarqube_cloud": ${SONAR_CLOUD}
  },
  "paths": {
    "journal": "journal/",
    "reports_local": "journal/reports/local/",
    "reports_ci": "journal/reports/ci/",
    "lessons_l1": "journal/learnings.md",
    "lessons_l2_dir": "journal/",
    "lessons_l3": "journal/learnings.db",
    "specs": "specs/",
    "architecture_design": "ARCHITECTURE_DESIGN.md",
    "conventions": "CONVENTIONS.md",
    "intents": "intents/",
    "pitches": "pitch/"
  },
  "governance": {
    "mode": "standard",
    "execution_isolation": "write-scope",
    "worktree_required_for": ["agentic"],
    "write_scope_required_for": ["sub-agents"],
    "compliance_doc_gate": false
  },
  "thresholds": {
    "architecture_doc_freshness_days": 30,
    "token_warn_threshold": 70,
    "token_hard_threshold": 80
  },
  "metadata": {
    "created_at": "${CREATED_AT}",
    "bootstrap_version": "${BOOTSTRAP_VERSION}",
    "stack": "${STACK}"
  }
}
EOF

echo "[ENV] $OUT written (environment=${ENVIRONMENT}, stack=${STACK})."
```

**Test note:** the script must run on macOS Darwin **and** Linux without external deps beyond `bash`, `uname`, `command`, `cat`, `grep`, `sed`, `date`. **No** `jq` (not installed everywhere) — JSON is written via heredoc.

**Re-generation:** when the tooling situation changes (e.g. `brew install semgrep` was added later, test framework switched from jest to vitest), run `bash .claude/generate-environment-json.sh --force`. The file itself should be committed — `metadata.created_at` is the audit trail for "when did this project work with which tooling assumption".

**Anti-patterns:**
- NO automatic re-run on every skill invocation — the file is a snapshot, not live detection.
- NO `git add` from inside the generator — operator decides consciously whether to commit or gitignore.
- NO project-specific path overrides in the generator — defaults are defaults; if a project needs custom paths, the operator edits the file after the first generate.

---

## observability.md (BOO-14 — observability skeleton)

**Central observability documentation in the project root**, one section per service. Defines the logging schema, metrics endpoint convention, alert rules directory and concrete examples for Node.js and Python. Created once during bootstrap and extended whenever a new service is added.

> [!important] Why one central file?
> Operator and skills need a single place where "what is logged, what is metricked, what alerts" lives. Per-service sections instead of scattered READMEs in each service folder — otherwise the schema drifts apart as soon as two services are allowed to differ ("that is just how it is here"). Single source of truth, readable by the `architecture-review` skill and the operator alike.

**Stack scope:** Node.js and Python only. Frontend has no server-side metrics endpoint — frontend logs flow through the backend (or Sentry / similar) and are not documented in `observability.md` as a separate service. See note in the template below.

```markdown
---
purpose: Observability skeleton (logging, metrics, alerts) per service
services: [auth-service]
last_updated: {{TODAY}}
metrics_port_base: 9091
logging_schema_version: 1
---

# Observability — {{PROJECT_NAME}}

This file documents the observability skeleton: **logging schema**, **metrics endpoint convention** and **alert rules** per service. One section per service — schema stays identical across all services.

> [!note] Frontend
> Frontend apps have **no** server-side metrics endpoint. Frontend errors and events flow through the backend (structured logs with `service: "<frontend-app>"` plus `client_session_id`) or through an external error tracker (Sentry, Bugsnag, ...). Frontend is therefore **not** tracked here as its own per-service section.

---

## Logging schema (mandatory fields)

Every log entry (Node.js or Python) is **structured JSON** with the following mandatory fields:

| Field | Type | Description |
|------|-----|-------------|
| `timestamp` | string (ISO 8601) | UTC, millisecond precision (`2026-05-07T14:30:00.123Z`) |
| `level` | string | `debug` \| `info` \| `warn` \| `error` \| `fatal` |
| `service` | string | service name from the architecture block (e.g. `auth-service`) |
| `trace_id` | string | UUID v4 OR W3C Trace Context trace ID — constant per request |
| `message` | string | short, human-readable summary (no stacktrace) |
| `context` | object | structured JSON object with extra fields (user_id, request_path, error_code, ...) |

**Example output (one line, formatted here):**

```json
{
  "timestamp": "2026-05-07T14:30:00.123Z",
  "level": "error",
  "service": "auth-service",
  "trace_id": "550e8400-e29b-41d4-a716-446655440000",
  "message": "Login failed: invalid credentials",
  "context": {
    "user_id": "u_42",
    "request_path": "/api/login",
    "error_code": "INVALID_CREDENTIALS",
    "ip": "203.0.113.5"
  }
}
```

> [!important] No plain-text logs
> Loggers are **never** configured with `console.log` / `print` / unstructured format — aggregation and search collapse otherwise. Mandatory: pino (Node) or structlog (Python) with JSON renderer (see stack examples below).

---

## Metrics endpoint (port convention)

Each service exposes a Prometheus-compatible metrics endpoint at `GET /metrics`. **Port convention:** `9090 + N`, where N is incremented per service.

| Service | Port | Metrics URL |
|---------|------|-------------|
| (first service) | `9091` | `http://localhost:9091/metrics` |
| (second service) | `9092` | `http://localhost:9092/metrics` |
| (n-th service) | `9090 + n` | ... |

> [!note] Operator hint
> When a new service is added, take the next free port from the table and keep this row up to date. Prometheus `scrape_configs` reads this table as the single source of truth.

**Mandatory metrics per service:**

| Metric | Type | Labels | Purpose |
|--------|------|--------|---------|
| `{service}_up` | Gauge (0/1) | — | Liveness heartbeat — `1` if the service process is running, `0` otherwise. |
| `{service}_requests_total` | Counter | `method`, `route`, `status` | HTTP request counter by method, route template (not full URL) and status code. |
| `{service}_request_duration_seconds` | Histogram | `method`, `route` | Request duration with default buckets `[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10]`. |
| `{service}_errors_total` | Counter | `error_type` | Error counter by type (`validation`, `db`, `upstream_timeout`, `internal`, ...). |

`{service}` is the service name in `snake_case` (e.g. `auth_service`, not `auth-service`) — Prometheus convention.

---

## Alert rules (mandatory alerts)

Three mandatory alerts per service, in `observability/alerts/<service>.yml` (see template). All alerts are **routing-agnostic** — severity labels drive Alertmanager routing (see `observability/.env.observability`).

| Alert | Condition | `for:` | Severity |
|-------|-----------|--------|----------|
| `{service}_down` | `up{service="..."} == 0` | `2m` | `critical` |
| `{service}_error_rate_high` | `rate(errors_total[5m]) / rate(requests_total[5m]) > 0.05` | `5m` | `warning` |
| `{service}_p95_slow` | `histogram_quantile(0.95, rate(request_duration_seconds_bucket[5m])) > 1` | `5m` | `warning` |

PromQL examples and rule skeleton: see `observability/alerts/<service>.yml` (template further down in this file).

> [!important] Validation
> All alert rule files must pass promtool validation:
> ```bash
> promtool check rules observability/alerts/*.yml
> ```
> The CI job should run this check — bootstrap only creates the rules, it does not auto-wire the CI hook (operator decision, depending on CI provider).

---

## Per-service section (template)

One section per service — duplicate and fill in when a new service is added. Example here: `auth-service`.

### auth-service

- **Language / stack:** Node.js (TypeScript)
- **Metrics endpoint:** `http://localhost:9091/metrics`
- **Alert rules:** `observability/alerts/auth-service.yml`
- **Logger:** pino with JSON renderer (`level: 'info'` in production, `'debug'` locally)
- **Trace propagation:** W3C Trace Context header (`traceparent`) — `trace_id` from header or freshly generated
- **Service label for Prometheus:** `auth_service` (snake_case)
- **Known error_type values:** `validation`, `db`, `upstream_timeout`, `internal`

---

## Stack examples

### Node.js — pino + prom-client

`package.json` dependencies (current major):

```json
{
  "dependencies": {
    "pino": "^9",
    "prom-client": "^15"
  }
}
```

Logger setup (`src/lib/logger.ts`):

```typescript
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  base: { service: 'auth-service' },
  timestamp: pino.stdTimeFunctions.isoTime,
  formatters: {
    level: (label) => ({ level: label }),
  },
});

// Usage
logger.error(
  { trace_id, context: { user_id, error_code: 'INVALID_CREDENTIALS' } },
  'Login failed: invalid credentials'
);
```

Metrics setup (`src/lib/metrics.ts`):

```typescript
import { Counter, Gauge, Histogram, register } from 'prom-client';

export const up = new Gauge({
  name: 'auth_service_up',
  help: '1 if auth-service is running, 0 otherwise',
});
up.set(1);

export const requests = new Counter({
  name: 'auth_service_requests_total',
  help: 'HTTP requests',
  labelNames: ['method', 'route', 'status'] as const,
});

export const requestDuration = new Histogram({
  name: 'auth_service_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route'] as const,
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
});

export const errors = new Counter({
  name: 'auth_service_errors_total',
  help: 'Errors by type',
  labelNames: ['error_type'] as const,
});

// /metrics endpoint (Express)
// app.get('/metrics', async (_req, res) => {
//   res.set('Content-Type', register.contentType);
//   res.end(await register.metrics());
// });
```

### Python — structlog + prometheus_client

`pyproject.toml` dependencies (current major):

```toml
[project]
dependencies = [
  "structlog>=24",
  "prometheus_client>=0.20",
]
```

Logger setup (`app/logger.py`):

```python
import logging
import structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso", utc=True, key="timestamp"),
        structlog.processors.JSONRenderer(),
    ],
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
)

logger = structlog.get_logger().bind(service="auth-service")

# Usage
logger.error(
    "Login failed: invalid credentials",
    trace_id=trace_id,
    context={"user_id": user_id, "error_code": "INVALID_CREDENTIALS"},
)
```

Metrics setup (`app/metrics.py`):

```python
from prometheus_client import Counter, Gauge, Histogram, start_http_server

up = Gauge("auth_service_up", "1 if auth-service is running, 0 otherwise")
up.set(1)

requests_total = Counter(
    "auth_service_requests_total",
    "HTTP requests",
    ["method", "route", "status"],
)

request_duration = Histogram(
    "auth_service_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "route"],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10),
)

errors_total = Counter(
    "auth_service_errors_total",
    "Errors by type",
    ["error_type"],
)

# Expose /metrics on configured port (9091 for auth-service)
# start_http_server(9091)
```

---

## Validation

```bash
# Validate Prometheus rules (mandatory before merge)
promtool check rules observability/alerts/*.yml
```

If `promtool` is not available locally: run via Docker (`docker run --rm -v "$PWD/observability/alerts:/rules" prom/prometheus promtool check rules /rules`) or in the CI job. Operator decides where the check lives — bootstrap creates the rules, the check itself is part of the quality gate.
```

**Anti-patterns:**
- NO plain-text / `console.log` / `print` logs in production-grade code — JSON renderer is mandatory.
- NO full URL path as label (e.g. `/users/12345`) — explodes cardinality. Use a route template (`/users/:id`) instead.
- NO `service` labels with hyphens in Prometheus metric names — Prometheus only allows `[a-zA-Z_][a-zA-Z0-9_]*`. Service name in logs `auth-service`, in metric names `auth_service`.
- NO frontend apps as their own per-service section — frontend logs through backend or external error tracker.

---

## observability/alerts/<service>.yml (BOO-14)

**Prometheus alert rule template per service.** Three mandatory alerts (`{service}_down`, `{service}_error_rate_high`, `{service}_p95_slow`) with severity labels and annotations. Routing-agnostic — Alertmanager decides via the severity labels where the alert goes (see `.env.observability`).

> [!important] Replace the service name
> `{{SERVICE_NAME}}` is the heredoc variable and must be replaced by the bootstrap skill (or manually on creation) with the service name in `snake_case` — e.g. `auth_service`. The filename stays `auth-service.yml` (kebab-case for the filesystem); the metric prefixes inside use `snake_case`.

```yaml
# observability/alerts/{{SERVICE_NAME_KEBAB}}.yml
# Prometheus alert rules for service {{SERVICE_NAME}} (snake_case for metric names).
# Validation: promtool check rules observability/alerts/*.yml
groups:
  - name: {{SERVICE_NAME}}_alerts
    rules:
      - alert: {{SERVICE_NAME}}_down
        expr: {{SERVICE_NAME}}_up == 0
        for: 2m
        labels:
          severity: critical
          service: {{SERVICE_NAME}}
        annotations:
          summary: "{{SERVICE_NAME}} is down"
          description: |
            Service {{SERVICE_NAME}} reports up == 0 for more than 2 minutes.
            Check process, container or scrape target.

      - alert: {{SERVICE_NAME}}_error_rate_high
        expr: |
          (
            sum(rate({{SERVICE_NAME}}_errors_total[5m]))
            /
            sum(rate({{SERVICE_NAME}}_requests_total[5m]))
          ) > 0.05
        for: 5m
        labels:
          severity: warning
          service: {{SERVICE_NAME}}
        annotations:
          summary: "{{SERVICE_NAME}} error rate above 5%"
          description: |
            Error rate (errors_total / requests_total over 5m) is above 5%
            for more than 5 minutes. Inspect recent deploys and upstream
            dependencies.

      - alert: {{SERVICE_NAME}}_p95_slow
        expr: |
          histogram_quantile(
            0.95,
            sum(rate({{SERVICE_NAME}}_request_duration_seconds_bucket[5m])) by (le)
          ) > 1
        for: 5m
        labels:
          severity: warning
          service: {{SERVICE_NAME}}
        annotations:
          summary: "{{SERVICE_NAME}} p95 latency above 1s"
          description: |
            95th percentile request duration is above 1 second for more
            than 5 minutes. Check DB, upstream calls or recent code changes.
```

**Severity convention:**
- `critical` — service is unreachable (down, crashed). Pager / Telegram / immediate action.
- `warning` — service is up but degraded (errors high, latency high). Slack / email / non-blocking.

**Anti-patterns:**
- NO removal of the mandatory alerts — dropping `_down` means no alarm when the service dies.
- NO "softer" alert thresholds without a justification in the spec — `> 0.05` and `> 1s` are conservative defaults; whoever changes them documents the why.
- NO routing-specific detail in the rule file (Telegram channel IDs, Slack webhooks, ...) — that belongs in the Alertmanager config, not in the rule.

---

## observability/.env.observability (BOO-14)

**Routing config for Alertmanager receivers.** Lists the generic receiver configuration plus **Telegram as a concrete example**. Slack, Discord, email, PagerDuty are configured analogously — see Alertmanager docs.

> [!warning] Secrets — must be in `.gitignore`
> This file contains bot tokens, webhook URLs, API keys. **Never** commit. The bootstrap skill auto-adds `.env.observability` to `.gitignore`. An `.env.observability.example` without real values may be committed if the operator chooses.

```bash
# observability/.env.observability
# Alertmanager receiver routing for {{PROJECT_NAME}}.
# NEVER commit this file — it contains tokens and webhooks.
# Telegram is shown here as one concrete example; Slack, Discord,
# email, PagerDuty are configured analogously (see Alertmanager docs).

# --- Generic receiver routing (mandatory) ---
# Which receiver should receive alerts? Must be defined in alertmanager.yml
# as `receivers[].name`.
ALERTMANAGER_RECEIVER="default"

# URL where Alertmanager is reachable (Prometheus side).
ALERTMANAGER_URL="http://localhost:9093"

# --- Telegram (example routing — one of many) ---
# Bot token from @BotFather (https://core.telegram.org/bots#botfather).
TELEGRAM_BOT_TOKEN=""

# Chat ID to send alerts to (negative for groups).
TELEGRAM_CHAT_ID=""

# --- Other receiver types (placeholders) ---
# Slack: SLACK_WEBHOOK_URL=""
# Discord: DISCORD_WEBHOOK_URL=""
# Email: SMTP_HOST="", SMTP_USER="", SMTP_PASS=""
# PagerDuty: PAGERDUTY_INTEGRATION_KEY=""
#
# Configuration of all receivers: see Alertmanager docs:
# https://prometheus.io/docs/alerting/latest/configuration/#receiver
```

**Anti-patterns:**
- NO commit of this file — `.gitignore` entry is mandatory.
- NO plain-text token in the repo, not even "just to test quickly".
- NO hardcoding of Telegram as the only receiver in skills or hooks — `.env.observability` and the Alertmanager config are the single source of truth for routing, not a skill.

---

## Performance baseline gate (BOO-16 — P95 + 20% regression alarm)

Second arm of the performance pillar. BOO-14 already established the **production alarm** (`{service}_p95_slow` via Prometheus, fires when the live service runs p95 > 1s). BOO-16 adds the **pre-production gate**: before a PR merges, the service is benchmarked in CI against a **living baseline**. If p95 climbs more than 20 % above the baseline, the gate blocks the merge — the operator can pull a documented override, otherwise the regression must be resolved before merge.

> [!important] Schrader, Code Crash, chap. 3 §Production Readiness (Gate 3: Performance Baseline)
> Performance is not a "we'll measure later" — it is a gate. No baseline, no comparison; no comparison, no visible regression. BOO-16 stores the baseline as a versioned architecture artifact in the repo, not as a transient test output.

**Stack scope:** Node.js (a/c) and Python (d). Frontend (b) has no server endpoint — frontend performance runs separately via Lighthouse CI (follow-up issue, not BOO-16 scope). Stack `e (other)`: operator decides; the tool must produce JSON output with p50/p95/p99.

**Four artifacts (created in this order):**

1. `journal/perf-baseline.json` — living baseline per service (committed)
2. `bench/<service>.bench.js` (Node) OR `bench/<service>_bench.py` (Python) — service benchmark
3. `.github/workflows/perf.yml` — CI gate, compares the current bench run against the baseline
4. `journal/reports/perf/overrides.log` — append-only operator override trail (only created on the first override)

---

## journal/perf-baseline.json (BOO-16 — living performance baseline)

**Living baseline, one entry per service.** Created at bootstrap with `services: []` and filled in manually by the operator after the first successful bench run. Updated on every release after operator approval — never auto-overwritten.

> [!important] Baseline is an architecture artifact, not a test output
> This file is committed and reviewed like any other architecture decision. Replace values manually per release — the CI gate reads, never writes back. Whoever raises the baseline must justify it as an ADR-style note in the commit message ("baseline raised because the new persistence layer adds +15%, accepted because X").

**Schema (one entry per service):**

| Field | Type | Description |
|-------|------|-------------|
| `service` | string | Service name in kebab-case, identical to the `observability.md` section |
| `p50_ms` | number | Median latency in milliseconds |
| `p95_ms` | number | 95th-percentile latency in milliseconds (see anti-patterns: with autocannon, approximated via p97_5) |
| `p99_ms` | number | 99th-percentile latency in milliseconds |
| `req_per_sec` | number | Mean throughput during the bench run |
| `recorded_at` | string (ISO 8601) | UTC timestamp of the measurement |
| `commit_sha` | string | Git commit SHA (40 chars) under which the baseline was measured |
| `bench_tool` | string | `autocannon` \| `pytest-benchmark` \| `other` |

```json
{
  "$schema_version": 1,
  "services": [
    {
      "service": "auth-service",
      "p50_ms": 12.4,
      "p95_ms": 38.7,
      "p99_ms": 84.2,
      "req_per_sec": 2150.0,
      "recorded_at": "2026-05-07T14:30:00Z",
      "commit_sha": "a1b2c3d4e5f6789012345678901234567890abcd",
      "bench_tool": "autocannon"
    },
    {
      "service": "api-gateway",
      "p50_ms": 8.1,
      "p95_ms": 22.3,
      "p99_ms": 51.0,
      "req_per_sec": 3400.0,
      "recorded_at": "2026-05-07T14:32:00Z",
      "commit_sha": "a1b2c3d4e5f6789012345678901234567890abcd",
      "bench_tool": "autocannon"
    }
  ]
}
```

> [!note] Initial population
> At bootstrap, the skill writes `services: []`. While the baseline is empty, the perf workflow **skips** its benchmarks via a prerequisite check (BOO-143) and the gate stays **green** — a fresh repo no longer fails at the perf gate. Once the operator, after a first bench run, downloads the `journal/reports/perf/<service>-bench-<sha>.json` artifact, copies the p50/p95/p99/req_per_sec values into the baseline, and commits them as "BOO-16: initial baseline for <service>", the gate runs normally from the next run on (comparison against baseline).

**Anti-patterns:**
- NO automatic overwrite of the baseline by CI — operator only. Otherwise the gate is meaningless (the baseline drifts up with every regression).
- NO baseline without a `commit_sha` — the SHA is the audit trail; without it, nobody can reconstruct later which code state was measured.
- NO averaging across multiple runs without documentation — if the baseline comes from 3 runs, name it in the commit message ("avg of 3 runs, stddev=Xms").

---

## bench/<service>.bench.js (BOO-16 — Node.js service benchmark with autocannon)

**Service benchmark for Node.js services using autocannon (programmatic API).** Writes a JSON report to `journal/reports/perf/<service>-bench-<sha>.json` with the same schema as one entry in `perf-baseline.json` — the comparator step in `perf.yml` reads it without conversion.

**Devdep:**

```bash
npm install --save-dev autocannon
```

(autocannon 7.x — generic programmatic API, see `mcollina/autocannon` README).

> [!important] No native p95 in autocannon
> autocannon's `result.latency` is an `hdr-histogram-percentiles-obj` and exposes the percentiles `p2_5, p50, p75, p90, p97_5, p99, p99_9, p99_99, p99_999` — **there is no direct `p95`**. We use `p97_5` as a conservative approximation (worst-case bias upward — a real regression is still detected, harmless fluctuations may appear slightly larger). This is an explicit operator choice, documented in the baseline as `bench_tool: "autocannon"`.

**Naming conventions:**
- File: kebab-case, identical to the service name — `bench/auth-service.bench.js`
- Service name in JSON output: kebab-case (`"service": "auth-service"`) — identical to `observability.md`
- Report path: `journal/reports/perf/<service>-bench-<short-sha>.json` (short-sha = first 7 chars of the git SHA)

```javascript
// bench/{{SERVICE_NAME_KEBAB}}.bench.js
// BOO-16 service benchmark — runs in CI via .github/workflows/perf.yml.
// Prerequisite: service listens on {{PORT}} at {{PATH}} (see README).

const autocannon = require('autocannon');
const fs = require('node:fs');
const path = require('node:path');
const { execSync } = require('node:child_process');

const SERVICE_NAME = '{{SERVICE_NAME_KEBAB}}';
const TARGET_URL = process.env.BENCH_URL || 'http://localhost:{{PORT}}{{PATH}}';
const CONNECTIONS = Number(process.env.BENCH_CONNECTIONS || 10);
const DURATION = Number(process.env.BENCH_DURATION || 30); // seconds

async function main() {
  // Warmup: 5 seconds, result discarded — guards against JIT/cache effects in the measurement.
  await autocannon({ url: TARGET_URL, connections: CONNECTIONS, duration: 5 });

  const result = await autocannon({
    url: TARGET_URL,
    connections: CONNECTIONS,
    duration: DURATION,
  });

  // autocannon has no native p95 — p97_5 is the next available percentile (>=95).
  // Conservative approximation, documented in journal/perf-baseline.json -> bench_tool: "autocannon".
  const sha = execSync('git rev-parse HEAD').toString().trim();
  const shortSha = sha.slice(0, 7);

  const report = {
    service: SERVICE_NAME,
    p50_ms: result.latency.p50,
    p95_ms: result.latency.p97_5, // approximation, see comment above
    p99_ms: result.latency.p99,
    req_per_sec: result.requests.average,
    recorded_at: new Date().toISOString(),
    commit_sha: sha,
    bench_tool: 'autocannon',
  };

  const outDir = path.join('journal', 'reports', 'perf');
  fs.mkdirSync(outDir, { recursive: true });
  const outPath = path.join(outDir, `${SERVICE_NAME}-bench-${shortSha}.json`);
  fs.writeFileSync(outPath, JSON.stringify(report, null, 2));

  console.log(`[BOO-16] bench report: ${outPath}`);
  console.log(JSON.stringify(report, null, 2));
}

main().catch((err) => {
  console.error('[BOO-16] bench failed:', err);
  process.exit(1);
});
```

> [!note] Service start is operator choice
> The bench script expects a running service on `BENCH_URL`. Whether the service is started in CI via `npm run start:{{SERVICE_NAME}} &`, via Docker Compose, or via `node dist/server.js &` is decided per project. In the workflow template (see `perf.yml` below) the service start is marked as a placeholder with a comment.

**Anti-patterns:**
- NO microbench tools (`tinybench`, `benchmark.js`) as HTTP service bench — they measure in-process function latency, not the full stack including network, serialization and middleware.
- NO bench runs without warmup — JIT compilation and cache effects skew the first seconds by a factor of 2-5.
- NO 1-second measurements — the statistic is unstable; p95 swings by +/-50%. At least 30s, better 60s.
- NO bench runs against production URL from CI — leads to DDoS suspicion and cost explosion. Service must be started locally in the runner.

---

## bench/<service>_bench.py (BOO-16 — Python service benchmark with pytest-benchmark)

**Service benchmark for Python services using pytest-benchmark + httpx.** pytest-benchmark measures function latency with sound statistics (multiple rounds, median, stddev); we wrap an HTTP call against the local service.

**Devdeps (`pyproject.toml`):**

```toml
[project.optional-dependencies]
test = [
  "pytest>=8",
  "pytest-benchmark>=5",
  "httpx>=0.27",
]
```

> [!important] pytest-benchmark measures latency, not throughput
> By default pytest-benchmark exports `min, max, mean, stddev, median, iqr, outliers, rounds, iterations` — i.e. distribution statistics, not true quantiles. We map `p50 = median` directly. For `p95` there are two paths:
> - **Operator choice A (default, recommended):** approximation `p95 ≈ mean + 1.645 * stddev` (normal distribution assumption). Fast, robust on homogeneous latencies, biased upward on long-tail distributions.
> - **Operator choice B:** record your own histogram inside the test function (see snippet below) — true quantiles, but more boilerplate. Recommended when the service is known to have long-tail latencies (e.g. DB queries with cache-miss spikes).
>
> The choice is documented in `journal/perf-baseline.json` via `bench_tool: "pytest-benchmark"`. Operators using choice B record `bench_tool: "pytest-benchmark+histogram"` instead.

**Throughput caveat:** pytest-benchmark measures one function execution per round — `req_per_sec` can only be **synthetically** derived (`1000 / mean_ms`). For real concurrent throughput (multiple connections in parallel), use a separate tool like `locust` or `wrk` — deliberately out of BOO-16 scope, possibly follow-up issue BOO-XX.

```python
# bench/{{SERVICE_NAME_SNAKE}}_bench.py
# BOO-16 service benchmark — runs in CI via .github/workflows/perf.yml.
# Invocation: pytest bench/ --benchmark-json=journal/reports/perf/{{SERVICE_NAME_KEBAB}}-bench.json

import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path

import httpx
import pytest

SERVICE_NAME = "{{SERVICE_NAME_KEBAB}}"
TARGET_URL = os.environ.get("BENCH_URL", "http://localhost:{{PORT}}{{PATH}}")


@pytest.fixture(scope="module")
def client():
    with httpx.Client(timeout=10.0) as c:
        # Warmup: 50 requests, result discarded.
        for _ in range(50):
            c.get(TARGET_URL).raise_for_status()
        yield c


def test_request_latency(benchmark, client):
    """Measures latency per HTTP call. p50 = median, p95 via approximation (see header)."""
    result = benchmark(lambda: client.get(TARGET_URL).raise_for_status())
    # pytest-benchmark writes stats automatically via --benchmark-json.
    # The comparator step in perf.yml converts stats -> p50/p95/p99 (see perf.yml).
    return result


# Optional: operator choice B — record your own histogram for true quantiles.
# Activate by uncommenting and adjusting the conversion path in perf.yml.
#
# def test_request_latency_with_histogram(client):
#     import time
#     samples_ms: list[float] = []
#     for _ in range(1000):
#         t0 = time.perf_counter()
#         client.get(TARGET_URL).raise_for_status()
#         samples_ms.append((time.perf_counter() - t0) * 1000)
#     samples_ms.sort()
#     report = _build_report(
#         p50=samples_ms[len(samples_ms) // 2],
#         p95=samples_ms[int(len(samples_ms) * 0.95)],
#         p99=samples_ms[int(len(samples_ms) * 0.99)],
#         req_per_sec=1000.0 / (sum(samples_ms) / len(samples_ms) / 1000),
#     )
#     _write_report(report, bench_tool="pytest-benchmark+histogram")


def _build_report(p50: float, p95: float, p99: float, req_per_sec: float) -> dict:
    sha = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()
    return {
        "service": SERVICE_NAME,
        "p50_ms": p50,
        "p95_ms": p95,
        "p99_ms": p99,
        "req_per_sec": req_per_sec,
        "recorded_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "commit_sha": sha,
        "bench_tool": "pytest-benchmark",
    }


def _write_report(report: dict, bench_tool: str = "pytest-benchmark") -> None:
    report["bench_tool"] = bench_tool
    out_dir = Path("journal/reports/perf")
    out_dir.mkdir(parents=True, exist_ok=True)
    short_sha = report["commit_sha"][:7]
    out_path = out_dir / f"{SERVICE_NAME}-bench-{short_sha}.json"
    out_path.write_text(json.dumps(report, indent=2))
```

> [!note] Conversion step
> The default path (choice A) produces a pytest-benchmark JSON output (`--benchmark-json=...`). The comparator step in `perf.yml` then converts `stats.median -> p50_ms`, `stats.mean + 1.645*stats.stddev -> p95_ms`, `stats.max -> p99_ms` (approximation: max is a conservative upper bound for p99 with small sample sizes). With choice B the test writes the baseline schema directly and skips the conversion.

**Anti-patterns:**
- NO pytest-benchmark for throughput measurements — `rounds` are sequential, not concurrent. `req_per_sec` derived from mean latency is a single-connection approximation, not multi-connection capacity.
- NO pytest-benchmark against production URL — see Node.js anti-pattern; service must run inside the runner.
- NO test functions with `assert response.status_code == 200` *and* `benchmark()` together — the assert runs N times and pollutes the measurement. Use `raise_for_status()` inside the lambda instead.

---

## .github/workflows/perf.yml (BOO-16 — CI performance gate)

**Pre-production gate**, runs on every PR against `main` plus manually via `workflow_dispatch`. Three thresholds, one override mechanic, bench output as artifact.

> [!important] GitHub-hosted runner variance
> GitHub-hosted runners are shared hardware with noisy-neighbor effects. Empirical measurements show +/- 30% variance between identical runs. The **20% threshold** in BOO-16 is intentionally generous to absorb that noise — a real regression only stands out above 20%. Recommended follow-up issue (BOO-XX): **self-hosted runners** with reserved CPU/memory; on those the threshold can be tightened to 10%. Until then the 20% threshold is the pragmatic default.

**Thresholds (comparator logic, ratio = current_p95 / baseline_p95):**

| Ratio | Outcome | Mechanic |
|-------|---------|----------|
| `<= 1.05` | PASS | green output, exit 0 |
| `> 1.05 && <= 1.20` | WARNING | PR comment via `actions/github-script@v7`, exit 0 |
| `> 1.20` | FAIL | exit 1 — unless operator override (see below) |
| baseline missing | FAIL | exit 1, hint "baseline missing — copy values from bench output manually + operator approval" |

**Override mechanic (two paths, both log into `journal/reports/perf/overrides.log`):**
- Set PR label `perf-override` (web UI, fast path)
- Commit message trailer `Perf-Override: <reason>` (audit-friendly, visible in git history)

```yaml
# .github/workflows/perf.yml
# BOO-16 performance baseline gate — compares the current bench run against
# journal/perf-baseline.json. Thresholds: <=5% PASS, 5-20% WARNING, >20% FAIL.

name: Performance

on:
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  bench:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        # Operator maintains the service list here — kept in sync with observability.md.
        service: [auth-service]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # --- Prerequisite check (BOO-143): empty/missing baseline => skip benchmarks, gate stays green ---
      # A fresh project has journal/perf-baseline.json with services: [] — without this check
      # the first CI run aborts at service start/bench. Once the baseline is filled, the gate runs normally.
      - name: Check prerequisites
        id: prereq
        run: |
          if [ ! -f journal/perf-baseline.json ]; then
            echo "INFO: journal/perf-baseline.json missing — skipping benchmarks (gate green)."
            echo "skip=true" >> "$GITHUB_OUTPUT"
            exit 0
          fi
          SERVICES=$(python3 -c "import json; print(len(json.load(open('journal/perf-baseline.json')).get('services', [])))" 2>/dev/null || echo 0)
          if [ "$SERVICES" = "0" ]; then
            echo "INFO: baseline still empty (services: []) — skipping benchmarks until the baseline is filled (gate green)."
            echo "skip=true" >> "$GITHUB_OUTPUT"
          else
            echo "skip=false" >> "$GITHUB_OUTPUT"
          fi

      # --- Stack setup: one of the two, depending on the stack choice (block A) ---
      - name: Setup Node.js
        if: ${{ hashFiles('package.json') != '' }}
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Setup Python
        if: ${{ hashFiles('pyproject.toml') != '' }}
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install deps (Node)
        if: ${{ hashFiles('package.json') != '' }}
        run: npm ci

      - name: Install deps (Python)
        if: ${{ hashFiles('pyproject.toml') != '' }}
        run: pip install -e '.[test]'

      # --- Start the service — operator adapts the command per project ---
      # Assumption: service listens on port 8080. For multi-service projects
      # use one workflow job per service with its own port.
      - name: Start service (background)
        if: steps.prereq.outputs.skip == 'false'
        run: |
          # TODO operator: enter the start command for ${{ matrix.service }} here.
          # Examples:
          #   Node:   npm run start:${{ matrix.service }} &
          #   Python: python -m {{MODULE}} &
          echo "Operator: enter start command for ${{ matrix.service }} here" && exit 1

      - name: Wait for service
        if: steps.prereq.outputs.skip == 'false'
        run: |
          for i in $(seq 1 30); do
            if curl -sf http://localhost:8080/health > /dev/null; then
              echo "Service ready"; exit 0
            fi
            sleep 1
          done
          echo "Service did not start within 30s"; exit 1

      # --- Run the bench (one of the two) ---
      - name: Run bench (Node)
        if: ${{ steps.prereq.outputs.skip == 'false' && hashFiles('package.json') != '' }}
        env:
          BENCH_URL: http://localhost:8080/
          BENCH_DURATION: '30'
        run: node bench/${{ matrix.service }}.bench.js

      - name: Run bench (Python)
        if: ${{ steps.prereq.outputs.skip == 'false' && hashFiles('pyproject.toml') != '' }}
        env:
          BENCH_URL: http://localhost:8080/
        run: |
          mkdir -p journal/reports/perf
          pytest bench/ \
            --benchmark-json=journal/reports/perf/${{ matrix.service }}-bench-raw.json

      # --- Comparator: ratio current_p95 / baseline_p95 ---
      - name: Compare against baseline
        id: compare
        if: steps.prereq.outputs.skip == 'false'
        env:
          SERVICE: ${{ matrix.service }}
          PR_LABELS: ${{ toJson(github.event.pull_request.labels.*.name) }}
          COMMIT_MSG: ${{ github.event.pull_request.title }}
        run: |
          set -euo pipefail
          SHORT_SHA=$(git rev-parse --short HEAD)
          REPORT_PATH="journal/reports/perf/${SERVICE}-bench-${SHORT_SHA}.json"

          # Python stack: convert stats -> baseline schema (operator choice A).
          if [ -f "journal/reports/perf/${SERVICE}-bench-raw.json" ] && [ ! -f "$REPORT_PATH" ]; then
            python3 - <<PY
          import json, subprocess
          from datetime import datetime, timezone
          raw = json.load(open("journal/reports/perf/${SERVICE}-bench-raw.json"))
          stats = raw["benchmarks"][0]["stats"]
          sha = subprocess.check_output(["git","rev-parse","HEAD"]).decode().strip()
          mean_ms = stats["mean"] * 1000
          stddev_ms = stats["stddev"] * 1000
          report = {
            "service": "${SERVICE}",
            "p50_ms": stats["median"] * 1000,
            "p95_ms": mean_ms + 1.645 * stddev_ms,
            "p99_ms": stats["max"] * 1000,
            "req_per_sec": 1000.0 / mean_ms if mean_ms > 0 else 0.0,
            "recorded_at": datetime.now(timezone.utc).isoformat().replace("+00:00","Z"),
            "commit_sha": sha,
            "bench_tool": "pytest-benchmark",
          }
          json.dump(report, open("${REPORT_PATH}","w"), indent=2)
          PY
          fi

          if [ ! -f "$REPORT_PATH" ]; then
            echo "FAIL: bench report missing: $REPORT_PATH"; exit 1
          fi

          CURRENT=$(python3 -c "import json; print(json.load(open('$REPORT_PATH'))['p95_ms'])")
          BASELINE=$(python3 -c "
          import json, sys
          data = json.load(open('journal/perf-baseline.json'))
          for s in data.get('services', []):
              if s['service'] == '${SERVICE}':
                  print(s['p95_ms']); sys.exit(0)
          sys.exit(2)
          " || echo "MISSING")

          if [ "$BASELINE" = "MISSING" ]; then
            echo "FAIL: baseline for ${SERVICE} missing in journal/perf-baseline.json."
            echo "Bench output: $REPORT_PATH — copy values manually + operator approval."
            exit 1
          fi

          RATIO=$(python3 -c "print(${CURRENT} / ${BASELINE})")
          echo "ratio=${RATIO}" >> "$GITHUB_OUTPUT"
          echo "current=${CURRENT}" >> "$GITHUB_OUTPUT"
          echo "baseline=${BASELINE}" >> "$GITHUB_OUTPUT"

          PASS=$(python3 -c "print('1' if ${RATIO} <= 1.05 else '0')")
          WARN=$(python3 -c "print('1' if ${RATIO} > 1.05 and ${RATIO} <= 1.20 else '0')")
          FAIL=$(python3 -c "print('1' if ${RATIO} > 1.20 else '0')")

          if [ "$PASS" = "1" ]; then
            echo "PASS: p95 ratio ${RATIO} (<= 1.05)"; exit 0
          fi
          if [ "$WARN" = "1" ]; then
            echo "WARNING: p95 ratio ${RATIO} (5-20% above baseline)"
            echo "outcome=warning" >> "$GITHUB_OUTPUT"
            exit 0
          fi
          # FAIL path — check override
          if echo "$PR_LABELS" | grep -q '"perf-override"' \
             || git log -1 --pretty=%B | grep -qi '^Perf-Override:'; then
            echo "FAIL overridden by operator. Logging to overrides.log."
            mkdir -p journal/reports/perf
            REASON=$(git log -1 --pretty=%B | grep -i '^Perf-Override:' | head -1 || echo "via PR label")
            echo "$(date -u +%FT%TZ) | ${SERVICE} | ratio=${RATIO} | sha=$(git rev-parse HEAD) | ${REASON}" \
              >> journal/reports/perf/overrides.log
            exit 0
          fi
          echo "FAIL: p95 ratio ${RATIO} > 1.20 (no override)"
          exit 1

      - name: Comment on PR (warning only)
        if: steps.compare.outputs.outcome == 'warning' && github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const ratio = '${{ steps.compare.outputs.ratio }}';
            const current = '${{ steps.compare.outputs.current }}';
            const baseline = '${{ steps.compare.outputs.baseline }}';
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `BOO-16 perf warning: \`${{ matrix.service }}\` p95 ratio **${ratio}** ` +
                    `(current ${current} ms vs baseline ${baseline} ms). ` +
                    `Below 1.20 FAIL threshold but above 1.05 PASS threshold — review recommended.`
            });

      - name: Upload bench artifact
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: perf-bench-${{ matrix.service }}
          path: journal/reports/perf/
          retention-days: 30
```

> [!warning] Override log is an append-only audit trail
> `journal/reports/perf/overrides.log` is appended by the CI job and committed (manually by the operator on merge — the CI job cannot push back into the PR). Whoever pulls an override is visible in the log forever. That is intentional: overrides may be easy, but never invisible.

**Anti-patterns:**
- NO bench runs in a container without reserved resources (standard GitHub-hosted runners are shared) without correspondingly generous thresholds — otherwise the gate flickers between PASS and FAIL on identical code.
- NO thresholds below 5% on hosted runners — the noise floor alone is 10-30%.
- NO override mechanic without logging — otherwise the gate decays into a "skip if annoying" gesture and the baseline silently drifts upward.
- NO automatic baseline update by the comparator step — see `perf-baseline.json` section. Baseline updates are always operator decisions with ADR-style justification.
- NO bench runs against production URL from CI — service must run locally in the runner.

---

## lighthouserc.json (BOO-45 — frontend performance budgets)

Generated by `/bootstrap` A.1b when `LIGHTHOUSE_CHOICE=yes` and `STACK_CHOICE` is `b` or `c`.
Counterpart to BOO-16 `perf-baseline.json`, but for browser apps instead of backend services.

```json
{
  "ci": {
    "collect": {
      "url": ["http://localhost:3000/"],
      "numberOfRuns": 3,
      "settings": {
        "preset": "desktop",
        "throttlingMethod": "simulate"
      }
    },
    "assert": {
      "preset": "lighthouse:recommended",
      "assertions": {
        "categories:performance": ["error", {"minScore": 0.9}],
        "categories:accessibility": ["error", {"minScore": 0.9}],
        "categories:best-practices": ["warn", {"minScore": 0.9}],
        "categories:seo": ["warn", {"minScore": 0.9}],
        "largest-contentful-paint": ["error", {"maxNumericValue": 2500}],
        "cumulative-layout-shift": ["error", {"maxNumericValue": 0.1}],
        "total-blocking-time": ["error", {"maxNumericValue": 300}]
      }
    },
    "upload": {
      "target": "filesystem",
      "outputDir": "journal/reports/ci/lighthouse-out"
    }
  }
}
```

**Operator tasks at setup (manual, documented in HANDBUCH Appendix H):**
- Set `ci.collect.url` per environment (preview deploy, staging, prod) — the default `http://localhost:3000/` is for the first smoke test only
- Pick `ci.collect.settings.preset`: `desktop` (no throttling) vs. `mobile` (Lighthouse default 3G-slow + 4× CPU throttle)
- Tune performance budgets: defaults are industry-typical, but with heavy third-party code (analytics, ads) 2.5s LCP is tight. Operator decides `minScore` + `maxNumericValue` per project reality
- Switch `ci.upload.target` if a Lighthouse-server backend is desired (default `filesystem` writes to `journal/reports/ci/lighthouse-out/`)

---

## .github/workflows/lighthouse.yml (BOO-45 — Lighthouse CI frontend performance gate)

```yaml
name: Lighthouse CI

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }

      - name: Install dependencies
        run: npm ci

      - name: Build frontend
        run: npm run build

      - name: Start preview server in background
        run: |
          # Operator: adapt to your build output — e.g. 'npx serve dist' or 'npm run preview'
          npx serve -s dist -l 3000 &
          # wait for server
          npx wait-on http://localhost:3000 --timeout 60000

      - name: Run Lighthouse CI
        run: |
          npm install -g @lhci/cli@0.14.x
          lhci autorun --config=./lighthouserc.json
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}

      - name: Collect reports for Hermes (BOO-32)
        if: always()
        run: |
          mkdir -p journal/reports/ci/run-${{ github.run_id }}
          cp -rf journal/reports/ci/lighthouse-out/* journal/reports/ci/run-${{ github.run_id }}/ 2>/dev/null || true
          # aggregated score summary as lighthouse.json
          if [ -f "journal/reports/ci/lighthouse-out/manifest.json" ]; then
            cp -f journal/reports/ci/lighthouse-out/manifest.json journal/reports/ci/run-${{ github.run_id }}/lighthouse.json
          fi

      - name: Upload reports as artifact
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ci-reports-${{ github.run_id }}
          path: journal/reports/ci/run-${{ github.run_id }}/
          retention-days: 30
```

**Operator tasks (in HANDBUCH Appendix H):**
- Adjust the build command per stack — `npm run build` is the default, but Vite/Astro/Next produce different outputs
- Adjust the preview-server command (line `npx serve -s dist -l 3000`) — Next.js uses `npm run start`, etc.
- For static hosting (deploy to Netlify/Vercel), the step can be removed and Lighthouse runs against the preview deploy URL directly
- `LHCI_GITHUB_APP_TOKEN` secret is optional — only for Lighthouse-CI server status checks (filesystem reports work without it)

**Hermes consumption:** `lighthouse.json` is the aggregated score summary (`manifest.json` from Lighthouse-CI), `journal/reports/ci/lighthouse-out/*.json` are the raw reports per URL+run.

---

## Reliability skeleton (BOO-25 — 5 invariants idempotency/retry/circuit-breaker/graceful-degradation/SLO)

Sixth pillar of the Schrader model: reliability as an architectural property, not a hope. The pillar consists of five invariants every productive service should meet:

1. **Idempotency** — write endpoints can be repeated without harm (Idempotency-Key middleware).
2. **Retry with backoff + jitter** — transient errors are retried in a bounded way, no thundering herd.
3. **Circuit breaker / bulkhead** — external dependencies fail fast, instead of blocking the caller.
4. **Graceful degradation** — under partial failure the service offers a reduced but defined behaviour.
5. **SLO + error budget** — the reliability expectation is measured, not promised.

> [!important] Schrader, Code Crash, Ch. 4 §Run the System (Pillar 6 Reliability)
> Reliability is the difference between "it ran on launch day" and "it still runs in month two". It does not happen by luck, but by four code patterns plus one measurement manifest. Skip them and you build a demo, not a system.

**Stack scope:** Node.js (a/c) and Python (d) get four concrete skeleton files (idempotency, retry, circuit breaker, SLO). Frontend (b) has no server-side idempotency / retry / breaker layer — the backend handles that. Stack `e (other)`: operator choice, but the SLO manifest stays mandatory (tool-agnostic).

**Four artefacts (created in this order):**

1. `docs/SLO.md` — Service Level Objective manifest (committed, all stacks).
2. `lib/idempotency.{js,py}` — Idempotency-Key middleware for write endpoints.
3. `lib/retry.{js,py}` — retry helper with backoff + jitter.
4. `lib/circuit-breaker.{js,py}` — circuit-breaker wrapper, one breaker per external dependency.

> [!note] Optionality
> Not every service needs all four skeletons from day 0. A pure read-only lookup service does not need an idempotency layer. Phase 4.4h in bootstrap asks per skeleton — see `SKILL.en.md` phase 4.4h. Recommendation for backend services with external dependencies: install all four.

---

## docs/SLO.md (BOO-25 — Service Level Objective Manifest)

**Reliability expectation as a versioned architectural artefact.** Describes three SLIs (Service Level Indicators) per service and the corresponding SLOs (Objectives), including an error-budget table per quarter with a consumption tracker. Reviewed monthly in `/sprint-review` — the remaining budget decides whether the next slot goes to reliability work or to features.

> [!important] SLO is an architectural artefact, not a marketing promise
> Writing "99.99% availability" into a contract without multi-region or active-passive failover is dishonest — the math does not allow it on single-region hardware. Default recommendations: **99.9%** for single-region (43.8 min downtime/month), **99.95%** with documented failover (21.9 min/month), **99.99%** only with multi-region + regular chaos tests (4.4 min/month). Higher is a lie until proven otherwise.

**Measurement method:** the three SLIs read from the Prometheus metrics endpoint that BOO-14 (`observability.md` §metrics endpoint) already established. No separate measurement tools — single source of truth.

```markdown
# SLO — {{SERVICE_NAME}}

> Architectural artefact per BOO-25 (pillar 6 reliability). This document
> defines the measured reliability expectation. Changes are ADR-bound and
> justified in the commit message ("SLO raised from X to Y because ...").

## Service

- **Name:** {{SERVICE_NAME}}
- **Owner:** {{OWNER}}
- **Stack:** {{STACK}}
- **Metrics endpoint:** `/metrics` (port {{PORT}}) — see `observability.md`
- **Status:** draft | active | deprecated

## Service Level Objectives

| SLI | Measurement (PromQL) | Target (SLO) | Window |
|-----|----------------------|--------------|--------|
| **Availability** | `(1 - rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])) * 100` | >= 99.9 % | rolling 30d |
| **Latency P95** | `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))` | < 1.0 s | rolling 30d |
| **Error rate** | `rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100` | < 0.5 % | rolling 30d |

## Error-budget table

At an SLO of 99.9% availability = 0.1% error budget = **43.8 min downtime / 30 days**.

| Quarter | Total budget | Consumed | Remaining | Status |
|---------|--------------|----------|-----------|--------|
| Q1 {{YEAR}} | 131.4 min | 0 min | 131.4 min | green |
| Q2 {{YEAR}} | 131.4 min | — | — | — |
| Q3 {{YEAR}} | 131.4 min | — | — | — |
| Q4 {{YEAR}} | 131.4 min | — | — | — |

**Consumption tracker:** every incident that pushes availability below the SLO target is recorded here — date, duration, root cause, ADR link.

| Date (UTC) | Duration | Root cause | ADR / postmortem |
|------------|----------|------------|------------------|
| — | — | — | — |

## Review cadence

- **Monthly** in `/sprint-review` — read budget consumption against the target.
- **At budget < 25% remaining:** reserve the next sprint slot for reliability work (no features).
- **At budget < 0:** feature freeze until the budget recovers — see Schrader, Code Crash, Ch. 4 §Run the System.

## History / changes

- {{YYYY-MM-DD}} — initial setup via `/bootstrap` phase 4.4h.
```

**Anti-patterns:**
- NO SLO without an error budget — the SLO number alone is marketing, the budget is the lever.
- NO SLO without a measurement method (PromQL/query) — otherwise the value is felt, not measured.
- NO 99.99% SLO without multi-region and chaos tests — the hardware math does not yield that on a single region.
- NO auto-update of the consumption table from monitoring — incident entries need an operator review (root cause + ADR link). Auto-append turns the manifest into a log nobody reads.

---

## lib/idempotency.{js,py} (BOO-25 — Idempotency-Key middleware)

**Protect write endpoints against repetition.** Reads header `Idempotency-Key` (UUID v4), persists request hash + response in Redis (default) or Postgres (fallback) with a 24h TTL. On repeat with the same key: cached response (no second write). On same key + different body: HTTP 422 (conflict — client has a bug).

> [!important] Idempotency is for write endpoints only
> Apply on POST / PUT / PATCH / DELETE. NOT on GET — GET is idempotent per HTTP spec, a layer is overhead without benefit. Also not globally for all routes — only where side effects happen (database writes, external API calls, money movement).

**Stack scope:** Node.js (a/c) as Express middleware, Python (d) as FastAPI dependency. Frontend (b) has no server endpoint — backend handles it. Stack e: operator choice, port the same logic to your framework.

### Node.js — `lib/idempotency.js`

**Devdep:**

```bash
npm install redis
```

(redis 5.x — official Node client, see `redis/node-redis` README.)

```javascript
// lib/idempotency.js
// BOO-25 Idempotency-Key middleware for Express.
// Register ONLY on write routes (POST/PUT/PATCH/DELETE),
// not globally. Example: app.post('/orders', idempotency(), createOrder)

const crypto = require('node:crypto');
const { createClient } = require('redis');

const TTL_SECONDS = 24 * 60 * 60; // 24h
const KEY_PREFIX = 'idem:';
const UUID_V4_REGEX =
  /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

let _redis;
async function getRedis() {
  if (!_redis) {
    _redis = createClient({ url: process.env.REDIS_URL || 'redis://localhost:6379' });
    _redis.on('error', (err) => console.error('[idempotency] redis error', err));
    await _redis.connect();
  }
  return _redis;
}

function hashBody(body) {
  return crypto
    .createHash('sha256')
    .update(JSON.stringify(body || {}))
    .digest('hex');
}

function idempotency() {
  return async function idempotencyMiddleware(req, res, next) {
    const key = req.header('Idempotency-Key');
    if (!key) {
      return res.status(400).json({
        error: 'idempotency_key_required',
        message: 'Idempotency-Key header is required for write operations',
      });
    }
    if (!UUID_V4_REGEX.test(key)) {
      return res.status(400).json({
        error: 'idempotency_key_invalid',
        message: 'Idempotency-Key must be UUID v4',
      });
    }

    const redis = await getRedis();
    const storeKey = `${KEY_PREFIX}${key}`;
    const bodyHash = hashBody(req.body);
    const cached = await redis.get(storeKey);

    if (cached) {
      const entry = JSON.parse(cached);
      if (entry.bodyHash !== bodyHash) {
        return res.status(422).json({
          error: 'idempotency_key_conflict',
          message: 'Same Idempotency-Key used with different request body',
        });
      }
      // Replay cached response.
      res.status(entry.status).set(entry.headers).send(entry.body);
      return;
    }

    // Capture response to cache after handler runs.
    const originalSend = res.send.bind(res);
    res.send = function captureSend(body) {
      // Persist async, do not block response.
      redis
        .setEx(
          storeKey,
          TTL_SECONDS,
          JSON.stringify({
            bodyHash,
            status: res.statusCode,
            headers: res.getHeaders(),
            body: typeof body === 'string' ? body : JSON.stringify(body),
          }),
        )
        .catch((err) => console.error('[idempotency] store error', err));
      return originalSend(body);
    };

    next();
  };
}

module.exports = { idempotency };
```

### Python — `lib/idempotency.py`

**Devdep:**

```toml
# pyproject.toml
[project]
dependencies = [
  "redis>=5.0",
  "fastapi>=0.110",
]
```

(redis-py >=5.0 — official Python client with asyncio support.)

```python
# lib/idempotency.py
# BOO-25 Idempotency-Key dependency for FastAPI.
# Bind ONLY to write routes (POST/PUT/PATCH/DELETE), not globally.
# Example:
#     @app.post("/orders", dependencies=[Depends(idempotency)])
#     async def create_order(...): ...

import hashlib
import json
import os
import re
from typing import Any

import redis.asyncio as redis_asyncio
from fastapi import HTTPException, Request

TTL_SECONDS = 24 * 60 * 60  # 24h
KEY_PREFIX = "idem:"
UUID_V4_REGEX = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
    re.IGNORECASE,
)

_redis: redis_asyncio.Redis | None = None


async def _get_redis() -> redis_asyncio.Redis:
    global _redis
    if _redis is None:
        url = os.environ.get("REDIS_URL", "redis://localhost:6379")
        _redis = redis_asyncio.from_url(url, decode_responses=True)
    return _redis


def _hash_body(body: Any) -> str:
    payload = json.dumps(body, sort_keys=True, default=str).encode()
    return hashlib.sha256(payload).hexdigest()


async def idempotency(request: Request) -> None:
    """FastAPI dependency. Raises HTTPException on conflict, replays on hit."""
    key = request.headers.get("Idempotency-Key")
    if not key:
        raise HTTPException(
            status_code=400,
            detail={
                "error": "idempotency_key_required",
                "message": "Idempotency-Key header is required for write operations",
            },
        )
    if not UUID_V4_REGEX.match(key):
        raise HTTPException(
            status_code=400,
            detail={
                "error": "idempotency_key_invalid",
                "message": "Idempotency-Key must be UUID v4",
            },
        )

    body_bytes = await request.body()
    try:
        body_json = json.loads(body_bytes) if body_bytes else {}
    except json.JSONDecodeError:
        body_json = {"_raw": body_bytes.decode(errors="replace")}
    body_hash = _hash_body(body_json)

    r = await _get_redis()
    store_key = f"{KEY_PREFIX}{key}"
    cached = await r.get(store_key)

    if cached:
        entry = json.loads(cached)
        if entry["bodyHash"] != body_hash:
            raise HTTPException(
                status_code=422,
                detail={
                    "error": "idempotency_key_conflict",
                    "message": "Same Idempotency-Key used with different request body",
                },
            )
        # Replay: stash cached response on request.state — handler reads it.
        request.state.idempotency_replay = entry
        return

    # First seen — handler runs; response capture happens in middleware/wrapper.
    request.state.idempotency_key = store_key
    request.state.idempotency_body_hash = body_hash


async def store_response(request: Request, status: int, body: Any) -> None:
    """Call from a response middleware after the handler returns."""
    store_key = getattr(request.state, "idempotency_key", None)
    body_hash = getattr(request.state, "idempotency_body_hash", None)
    if not store_key or not body_hash:
        return
    r = await _get_redis()
    await r.setex(
        store_key,
        TTL_SECONDS,
        json.dumps({
            "bodyHash": body_hash,
            "status": status,
            "body": body if isinstance(body, str) else json.dumps(body),
        }),
    )
```

**Anti-patterns:**
- NO idempotency layer for GET — GET is idempotent per HTTP spec, the layer is overhead without benefit.
- NO global layer for all routes — only on write endpoints with side effects (DB writes, external calls, money). Otherwise cache pollution and 422 conflicts on harmless read replays.
- NO storage in process memory (`Map`, `dict`) — lost on restart, does not scale across multiple instances. Redis or Postgres, otherwise nothing at all.
- NO TTL > 7 days — keys would be stored forever, memory grows monotonically. 24h is the default, max 7d with justification.
- NO server-side UUID generation — the Idempotency-Key comes from the client; otherwise the whole idea breaks (the client cannot tell whether a retry is a new or repeated call).

---

## lib/retry.{js,py} (BOO-25 — retry helper with exponential backoff + jitter)

**Transient errors are retried in a bounded way.** Default: max 3 retries, exponential backoff (factor 2), jitter to avoid thundering herd. **Hard constraint:** retry ONLY on transient errors (5xx, timeout, connection reset). NO retry on 4xx (client errors), 422 (validation), or idempotency conflicts — repetition does not improve them.

> [!important] Retry policy is status-code specific
> A 500 deserves a retry (server hiccup). A 400 does not (client bug — same request fails again). A 422 even less (validation error — the body is wrong, not the network). The wrapper below filters explicitly what is retryable.

### Node.js — `lib/retry.js`

**Devdep:**

```bash
npm install p-retry
```

(p-retry 8.x — wrapper around `retry` with AbortSignal support. ESM-only, so in Node.js projects with `import` or dynamic `require`.)

```javascript
// lib/retry.js
// BOO-25 retry wrapper with exponential backoff + jitter.
// Default: 3 retries, factor=2, minTimeout=100ms, maxTimeout=10000ms, randomize=true.
// HARD CONSTRAINT: only transient errors get retried — see shouldRetry().

// p-retry is ESM-only — in CommonJS via dynamic import.
const TRANSIENT_STATUS = new Set([408, 429, 500, 502, 503, 504]);

function isTransientError(err) {
  // Network / timeout
  if (err && (err.code === 'ECONNRESET' || err.code === 'ETIMEDOUT' || err.code === 'ENOTFOUND')) {
    return true;
  }
  // HTTP-status-coded errors (axios/fetch wrapper convention)
  const status = err?.response?.status ?? err?.status;
  if (typeof status === 'number') {
    return TRANSIENT_STATUS.has(status);
  }
  // Unknown -> conservative: do not retry, surface immediately.
  return false;
}

async function withRetry(fn, options = {}) {
  const { default: pRetry, AbortError } = await import('p-retry');
  const opts = {
    retries: options.retries ?? 3,
    factor: options.factor ?? 2,
    minTimeout: options.minTimeout ?? 100,
    maxTimeout: options.maxTimeout ?? 10000,
    randomize: options.randomize ?? true, // jitter
    onFailedAttempt: options.onFailedAttempt,
  };

  return pRetry(async () => {
    try {
      return await fn();
    } catch (err) {
      // Non-transient -> AbortError stops retry loop immediately.
      if (!isTransientError(err)) {
        throw new AbortError(err);
      }
      throw err;
    }
  }, opts);
}

module.exports = { withRetry, isTransientError };
```

### Python — `lib/retry.py`

**Devdep:**

```toml
# pyproject.toml
[project]
dependencies = [
  "tenacity>=9.0",
]
```

(tenacity >=9.0 — see `jd/tenacity` README, current major line.)

```python
# lib/retry.py
# BOO-25 retry wrapper with exponential backoff + jitter via tenacity.
# Default: 3 attempts, exponential with multiplier 0.1s, max 10s.
# HARD CONSTRAINT: only transient errors get retried — see is_transient().

import logging
from typing import Any, Callable

import httpx
from tenacity import (
    retry,
    retry_if_exception,
    stop_after_attempt,
    wait_random_exponential,
)

log = logging.getLogger(__name__)
TRANSIENT_STATUS = {408, 429, 500, 502, 503, 504}


def is_transient(exc: BaseException) -> bool:
    """True if the exception represents a retryable, transient failure."""
    # Network / timeout layer
    if isinstance(exc, (httpx.ConnectError, httpx.ReadTimeout, httpx.WriteTimeout)):
        return True
    # HTTP-status-coded layer
    if isinstance(exc, httpx.HTTPStatusError):
        return exc.response.status_code in TRANSIENT_STATUS
    # Unknown -> conservative: do not retry.
    return False


def with_retry(
    fn: Callable[..., Any] | None = None,
    *,
    attempts: int = 3,
    multiplier: float = 0.1,
    max_wait: float = 10.0,
):
    """Decorator factory: retry transient failures with exponential backoff + jitter."""
    decorator = retry(
        stop=stop_after_attempt(attempts),
        wait=wait_random_exponential(multiplier=multiplier, max=max_wait),
        retry=retry_if_exception(is_transient),
        before_sleep=lambda rs: log.warning(
            "retry attempt=%s waiting=%.2fs reason=%s",
            rs.attempt_number,
            rs.next_action.sleep if rs.next_action else 0,
            rs.outcome.exception() if rs.outcome else None,
        ),
        reraise=True,
    )
    if fn is None:
        return decorator
    return decorator(fn)
```

**Anti-patterns:**
- NO infinite retry — default is 3 attempts, hard-bounded. "Retry until it works" turns a 30-second outage into a 3-hour outage and blocks the caller.
- NO retry without jitter — all clients retry in sync, the recovering backend gets an N-times load spike (thundering herd).
- NO retry on 4xx/422 — client errors are not improved by repetition. The status-code filter is mandatory.
- NO retry on idempotency-key conflicts (HTTP 422 from `lib/idempotency.{js,py}`) — the server explicitly says "different body with same key", repetition makes nothing worse but also fixes nothing.
- NO retry wrapper around non-idempotent operations without an Idempotency-Key — otherwise the first retry creates the duplicate charge / duplicate booking. Retry and idempotency are a pair.

---

## lib/circuit-breaker.{js,py} (BOO-25 — circuit-breaker wrapper per external dependency)

**External dependencies fail fast instead of slow.** A circuit breaker around every call to DB / external API / message bus. Three states: **Closed** (normal), **Open** (failure detected — immediate fail without call), **Half-Open** (after reset timeout: probe requests to see if the dependency is back).

> [!important] One breaker per external dependency
> NO global breaker for "everything external". If the DB is slow and auth is fast, auth must not fail along with DB just because DB opens the global breaker. Pattern: `dbBreaker`, `paymentApiBreaker`, `s3Breaker` — separate instances with their own thresholds. Tune thresholds per dependency: DB may be allowed to be slower than auth.

> [!note] Bulkhead pattern as a follow-up
> One breaker per dependency is the light variant of a bulkhead — dependencies are isolated from each other. The full bulkhead pattern (separate thread pools / connection pools per dependency) is a step beyond and not part of BOO-25 — follow-up issue when the service warrants multiple parallel pools.

### Node.js — `lib/circuit-breaker.js`

**Devdep:**

```bash
npm install opossum
```

(opossum 9.x — see `nodeshift/opossum` README, current major line.)

```javascript
// lib/circuit-breaker.js
// BOO-25 circuit-breaker wrapper. One instance per external dependency.
// Example:
//   const dbBreaker = createBreaker(callDb, { name: 'db', timeout: 2000 });
//   const result = await dbBreaker.fire(query);

const CircuitBreaker = require('opossum');

const DEFAULTS = {
  timeout: 3000,                  // ms — if a call takes longer, it counts as a failure
  errorThresholdPercentage: 50,   // % failures -> Open
  resetTimeout: 30000,            // ms in Open, then Half-Open
  volumeThreshold: 10,            // min calls before failure rate counts
};

function createBreaker(fn, options = {}) {
  const name = options.name || fn.name || 'anonymous';
  const breaker = new CircuitBreaker(fn, { ...DEFAULTS, ...options });

  breaker.on('open', () =>
    console.warn(`[circuit-breaker] OPEN dependency=${name}`));
  breaker.on('halfOpen', () =>
    console.info(`[circuit-breaker] HALF_OPEN dependency=${name}`));
  breaker.on('close', () =>
    console.info(`[circuit-breaker] CLOSED dependency=${name}`));
  breaker.on('reject', () =>
    console.warn(`[circuit-breaker] REJECT dependency=${name} (open, fail-fast)`));

  // Fallback is operator choice — set per breaker if graceful degradation is possible.
  // Example: dbBreaker.fallback(() => cachedResult);
  return breaker;
}

module.exports = { createBreaker };
```

### Python — `lib/circuit-breaker.py`

**Devdep:**

```toml
# pyproject.toml
[project]
dependencies = [
  "pybreaker>=1.0",
  # For asyncio stacks alternatively: "aiobreaker>=1.2" (separate wrapper required)
]
```

(pybreaker 1.x — see `danielfm/pybreaker` README. For pure asyncio workloads, `aiobreaker` is a separate library with a compatible API; operator choice.)

```python
# lib/circuit_breaker.py
# BOO-25 circuit-breaker wrapper. One instance per external dependency.
# Example:
#     db_breaker = create_breaker(name="db", fail_max=5, reset_timeout=30)
#
#     @db_breaker
#     def query_db(...): ...

import logging
from typing import Iterable

import pybreaker

log = logging.getLogger(__name__)


class _Listener(pybreaker.CircuitBreakerListener):
    def __init__(self, name: str) -> None:
        self.name = name

    def state_change(self, cb, old_state, new_state):
        log.warning(
            "circuit_breaker dependency=%s old=%s new=%s",
            self.name,
            getattr(old_state, "name", old_state),
            getattr(new_state, "name", new_state),
        )

    def failure(self, cb, exc):
        log.info("circuit_breaker dependency=%s failure=%r", self.name, exc)


def create_breaker(
    name: str,
    *,
    fail_max: int = 5,
    reset_timeout: int = 30,
    exclude: Iterable[type[BaseException]] = (),
) -> pybreaker.CircuitBreaker:
    """One breaker per external dependency. Tune thresholds per dependency."""
    return pybreaker.CircuitBreaker(
        fail_max=fail_max,
        reset_timeout=reset_timeout,
        exclude=list(exclude),
        listeners=[_Listener(name)],
        name=name,
    )
```

**Graceful degradation as a fallback hook:** when the breaker is `Open`, every call goes straight into the fallback. The fallback is operator choice per dependency:

- **Cache read** instead of DB read (stale data ok briefly).
- **Default value** instead of an external API (e.g. empty recommendations instead of 500).
- **Queue + async processing** instead of a sync call (deliver the request later).
- **HTTP 503 + `Retry-After` header** if no other strategy fits — at least signal it to the client.

**Anti-patterns:**
- NO global breaker for all external calls — see header callout. One instance per dependency.
- NO breaker for in-process function calls — breakers protect against slow external calls, not against local failures. Local failures are bugs and must be visible immediately.
- NO single shared config for all breakers — DB may be allowed to be slower than auth. Thresholds per dependency, documented in code.
- NO breaker without logging — state transitions (Closed -> Open -> Half-Open) must show up in logs, otherwise the breaker is a black box. Logging via Pino (Node) / structlog (Python) per BOO-14.
- NO breaker without a fallback and without a 503 response — otherwise "Open" is indistinguishable from "service broken" for the client. At minimum return 503 with `Retry-After`.

---

## Self-healing & doc-sync templates

See `self-healing-template.js` and `doc-sync-template.js` in the same folder for the
JavaScript implementation templates. Those files contain executable code; language-neutral
content (mostly English code + comments).

---

## For full German prose

The German original (`file-templates.md`) contains all templates with German-language
prose and comments for users who prefer to generate project files in German. Both versions
produce functionally equivalent project scaffolding.

### `.claude/sensitive-paths.json (BOO-18 — Mandatory Human Review)`

Created by `/bootstrap` Phase 4.4i when the operator configures sensitive paths.
Placement: `.claude/sensitive-paths.json` (NOT in `.gitignore` — commit explicitly for the audit trail).

```json
{
  "patterns": [
    "auth/**",
    "authn/**",
    "authz/**",
    "payment/**",
    "billing/**",
    "**/*credential*",
    "**/*personal*",
    "**/*pii*",
    "**/*gdpr*",
    "n8n/**",
    "workflows/**/*.json",
    "infra/**",
    "**/*.tf",
    "**/*.tfvars",
    "config/production/**",
    ".env.production",

    "**/eslint.config.*",
    "**/.eslintrc*",
    "**/ruff.toml",
    "**/pyproject.toml",
    "**/.semgrep.yml",
    "**/.semgrep.yaml",
    "**/phpstan.neon",
    "**/phpstan.neon.dist",
    "**/.coveragerc",
    "**/jest.config.*",
    "**/vitest.config.*",
    "**/sonar-project.properties"
  ],
  "review_required_by": ["{{OPERATOR_NAME}}"],
  "human_review_reminder": "This story touches sensitive paths — please review line by line, not just approve the plan."
}
```

**Replace placeholders:**
| Placeholder | Value |
|-------------|-------|
| `{{OPERATOR_NAME}}` | GitHub handle or name of the responsible reviewer |

> **Group "Gate-Config / Quality-Threshold" (BOO-176):** the last 12 patterns
> (`**/eslint.config.*` … `**/sonar-project.properties`) are **gate-config files** — they define
> the quality threshold (linter rules, coverage threshold, PHPStan level, Semgrep rules). **Any**
> change to them triggers a human-review block (`review-ok`): gate configs define the quality
> threshold — change only with operator approval (BOO-176). The agent fixes code ✅ — it does not
> lower the bar ❌. In addition the `gate-configs.yml` bodyguard flags suspicious rule disables
> already at write time.

**Note:** The pattern list is a minimal default. The non-code patterns (`n8n/**`, `workflows/**/*.json`, `infra/**`, `**/*.tf`, `**/*.tfvars`, `config/production/**`, `.env.production`) were added with BOO-68 — they are mandatory when the project expects non-code stories (workflow / infrastructure / config). The gate-config patterns (`**/eslint.config.*` … `**/sonar-project.properties`) were added with BOO-176 — mandatory for JS/TS and Python stacks (the covered stacks); non-covered stacks add their gate configs via the stack runbook (BOO-178). The operator extends with project-specific sensitive paths (e.g. `src/api/**` for critical API endpoints, `stripe/**` for payment integration).

### `.claude/personal-data-paths.json (BOO-69 — Personal-Data-Paths-Gate)`

Created by `/bootstrap` Phase 4.4n when the operator has activated the Privacy add-on.
Placement: `.claude/personal-data-paths.json` (analogous to sensitive-paths.json, NOT in `.gitignore` — audit-trail obligation).

```json
{
  "patterns": [
    "**/user*",
    "**/customer*",
    "**/profile*",
    "**/*pii*",
    "**/auth/profile/**",
    "**/billing/**",
    "**/onboarding/**",
    "**/consent/**",
    "**/tracking/**",
    "**/analytics/**",
    "db/migrations/*personal*",
    "db/migrations/*user*",
    "**/email-templates/**"
  ],
  "review_required_by": ["{{OPERATOR_NAME}}"],
  "privacy_review_reminder": "This story touches personal data — DPO REVIEW mode recommended (`/dpo --mode review`), or manual check with `privacy-ok`.",
  "dpo_skill_path": "~/.claude/skills/dpo/"
}
```

**Replace placeholders:**

| Placeholder | Value |
|-------------|-------|
| `{{OPERATOR_NAME}}` | GitHub handle or name of the responsible reviewer (may be identical to `sensitive-paths.json`) |

**Note:** The pattern list is a minimal default. The operator extends with project-specific personal-data paths (e.g. `src/auth/**` for PII-handling auth, `webhooks/stripe/**` for payment data, `crm/**` for customer data). On overlap with `sensitive-paths.json` (e.g. `**/*pii*` appears in both): both gates trigger — first `review-ok`, then `privacy-ok`. Double confirmation is intentional because security and privacy check different disciplines.

---

## .claude/settings.local.json (BOO-203 — Bash auto-allow for sprint-run gates)

Created by `/bootstrap` when the operator wants to use the autonomous sprint run (`/sprint-run` 2.0.0 with the `/goal` engine). Placement: `.claude/settings.local.json` (local, **non**-committed operator settings — belongs in `.gitignore`).

**Purpose:** `/sprint-run` checks this allowlist as the **first of the three safety prerequisites** before the `/goal` call. `/goal` and its native subagents run the quality gates unattended — without the allowlist every gate execution blocks on a permission prompt. The entries follow the real Claude Code format: `permissions.allow` is a list of `Bash(<pattern>)` tools with prefix match (`:*` = arbitrary arguments).

```json
{
  "permissions": {
    "allow": [
      "Bash(semgrep:*)",
      "Bash(npx semgrep:*)",
      "Bash(eslint:*)",
      "Bash(npx eslint:*)",
      "Bash(pytest:*)",
      "Bash(python -m pytest:*)",
      "Bash(ruff:*)",
      "Bash(gh run watch:*)",
      "Bash(gh run view:*)",
      "Bash(gh run list:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(git worktree:*)",
      "Bash(git merge:*)",
      "Bash(git branch:*)"
    ]
  }
}
```

**Safety notes:**

- **NO secrets** in this file — it contains only Bash pattern allowlists, no tokens/keys.
- **Deliberately narrow:** Only the gate and git-mechanic commands from the sprint run. **No** `Bash(*)` wildcard — that would make the allowlist pointless and is an anti-pattern.
- **`git push`** is included because the story subagent must push the feature branch (remote CI). The merge to `main` runs via `git merge` / PR — `main` stays protected by the pre-flight checks (clean tree) and the gate assertion.
- **Local, not committed:** `settings.local.json` is operator-specific (allowlist tolerance can vary per machine) and belongs in `.gitignore`. The committed `.claude/settings.json` carries only the project-wide hooks (spec-gate, doc-version-sync, pre-edit-bodyguard).
- **Stack adaptation:** Python-only projects can drop the ESLint lines, Node-only the `pytest`/`ruff` lines. The `semgrep`, `gh run` and `git` lines are mandatory across stacks.
