---
name: bootstrap
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
version: 3.48.0
language: en
description: Sets up a new project with a governance framework — interactive 4-block interview flow, docs architecture with automatic hub linking, optional learning loop L1/L2/L3. Use when the operator wants to set up a new project or says "/bootstrap".
tools: [Read, Write, Edit, Bash, Glob, Grep]
metadata:
  hermes:
    category: governance
    tags: [setup, project-init, governance-config]
    requires_toolsets: [terminal, git, github, obsidian]
    related_skills: []
---

# Bootstrap — Set up a new project (v3.0)

Sets up a new project with a governance framework. The flow is structured in **4 blocks (A–D)** — each block has a clear focus, no question batches.

> **Scope note:** This setup establishes governance for a **sequential, controlled development flow** — not an autonomously running agent system. The chosen AI tools (Claude, Codex) are adapters onto the story contract, not the governance itself.

References:
- `references/info-gathering.en.md` — core questions (block A)
- `references/existing-infra-check.en.md` — existing infrastructure (block B)
- `references/project-documentation-ssot.en.md` — project documentation SSoT, Project Hub and Developer Onboarding
- `references/doc-architecture-proposal.en.md` — docs architecture (block C)
- `references/optional-components.en.md` — self-healing / docsync / daemon / learning loop (block D)
- `references/learning-loop.en.md` — L1/L2/L3 design
- `references/file-templates.en.md` — file scaffolds
- `references/skills-setup.en.md` — pulling skills from GitHub
- `references/global-registry-update.en.md` — SecondBrain integration
- `references/hooks-setup.en.md` — governance hooks
- `references/provider-postflight.en.md` — external providers, monitoring, Research, Visualize/Miro
- `references/framework-upgrade.en.md` — upgrade mode for existing projects

---

## Phase 0: Briefing + pre-flight gate (before any questions)

### 0.1 Briefing

Inform the operator first:

```
Bootstrap v3.0 — I'll walk you through 4 blocks:

  Block A — Project core          (10 questions, ~4 min)
  Block B — Existing infra        (6 questions, ~4 min)
  Block C — Docs architecture     (proposal + review)
  Block D — Optional components   (targeted yes/no questions at the end)

After that I'll scaffold the project. Total ~15 min.

Note: I set up governance + configs (scaffold-only). I do NOT install
tools/CLIs — you provide those up front (see pre-flight).
```

### 0.2 Pre-flight gate (BOO-114) — check prerequisites, else abort

**Before** any scaffolding, ask for the core prerequisites:

```
Pre-flight — are these prerequisites met? [yes / no / unsure]
  1. Prep questionnaire `docs/onboarding/bootstrap-prep.md` completed?
  2. Toolchain ready? (Node 18+, Git, Claude CLI; with GitHub scope also `gh` +
     `gh auth status` ok; for container: image built) — the bootstrap installs nothing (scaffold-only).
  3. API keys / access available? (ANTHROPIC_API_KEY; depending on scope a
     GitHub token or SSH key, backlog-tool key, external providers)
  4. Target directory decided + (if GitHub is in scope) empty repo/remote ready?
```

**Evaluation:**
- All items `yes` → continue to `Ready?` and phase 1.
- At least one `no/unsure` → **controlled abort, no scaffold:**

```
⛔ Pre-flight not passed — I'm not creating anything yet.

Open: <the items marked no/unsure>.

Next steps:
  → Work through the prep questionnaire: docs/onboarding/bootstrap-prep.md (16 questions).
  → Prerequisite details: HANDBUCH §3 "Prerequisites and preparation"
    + Appendix A "Checklist before the first bootstrap".
  → Tools missing? The bootstrap won't install them (scaffold-only); install
    guides: HANDBUCH Appendix Y.2 (direct install) or container profile (BOO-81).
    On the next run I'll point you to the matching deeplinks (BOO-115).

Run `/bootstrap` again once the prerequisites are in place.
```

Only after a passed pre-flight:

```
Ready? [yes / later]
```

Wait for `yes`.

---

## Phase 1: Block A — Project core

Read `references/info-gathering.en.md` for the full question list. Ask the questions **individually or in small groups** (max 3 per exchange), not as a batch.

### A.1 Stack question (first)

```
What do you want to build?
  a) Node.js / TypeScript backend (API, CLI, daemon)
  b) Frontend (React, Vue, Svelte, vanilla)
  c) Full-stack — incl. meta-frameworks (Next.js, Nuxt, SvelteKit, Remix, Astro)
  d) Python (AI/ML, scripts, FastAPI, Django)
  e) Something else / not decided yet  → guided discovery (A.1a)
```

Remember the answer as `STACK_CHOICE`. The options are **framework-aware**: a meta-framework project (Next.js etc.) belongs under `c)`, **not** `a)` — that was the most common mis-pick (stack mismatch).

**TypeScript is first-class.** For `a/b/c`, ask directly:

```
TypeScript or JavaScript? [ts / js]   (default: ts)
```

Remember `LANG_VARIANT = ts | js`. On `ts`: additionally scaffold `tsconfig.json` + `typescript-eslint` + a `tsc --noEmit` CI gate (phase 4.4), `metadata.stack = node-typescript`. On `js`: `node-javascript`. (For `d) Python` and `e)` the question is skipped.)

| Choice | LANG_VARIANT | Linter config | Formatter | Typecheck |
|--------|--------------|---------------|-----------|-----------|
| a) Node.js/TS backend | ts (default) / js | `eslint.config.mjs` (+ `typescript-eslint` on ts) | — | `tsc --noEmit` (on ts) |
| b) Frontend | ts (default) / js | `eslint.config.mjs` + `.prettierrc` (+ `typescript-eslint` on ts) | Prettier | `tsc --noEmit` (on ts) |
| c) Full-stack / meta-framework | ts (default) / js | both (+ `typescript-eslint` on ts) | Prettier | `tsc --noEmit` (on ts) |
| d) Python | — | `pyproject.toml` (Ruff + Black) | Black | — |
| e) Other | — | free-text follow-up (below, BOO-116) or guided discovery (A.1a) — **no** silent ESLint default | — | — |

**On `e) Other`, ask first (BOO-116) — don't silently assume ESLint:**

```
Which technology / language? (e.g. Go, Rust, Java, PHP, Ruby — or "not decided yet")
```

- **Known tech → matching linter hint** (no JS default):

  | detected tech | linter/format hint |
  |---------------|--------------------|
  | Go | `golangci-lint` (+ `gofmt`) |
  | Rust | `clippy` (+ `rustfmt`) |
  | Java / Kotlin | `Checkstyle` / `ktlint` + `SpotBugs` |
  | PHP | `PHPStan` / `Psalm` + `PHP-CS-Fixer` |
  | Ruby | `RuboCop` |
  | other | operator names the linter |

  `STACK_CHOICE` stays `e`; the linter/tooling setup follows the hint (operator sets it up), **not** the ESLint default. Record the decision as an ADR in `docs/domain/adrs/`. For the concrete integration (the 5 places + verification + copy templates) → HANDBUCH chapter "Integrating a stack linter" (§8d-bis) + runbook `docs/runbooks/stack-linter-integrieren.md`.
- **"not decided yet"** → mark it explicitly as open (no JS default) **or** use guided discovery (A.1a) to derive a proposal from a source/description.

### A.1a Guided stack discovery (BOO-127 — on `e)` or uncertainty)

If the operator picks `e)` or is unsure: **don't make them guess** — derive a stack **suggestion**.

```
Unsure which to pick? I can suggest the stack:
  (a) Analyze a source — existing repo / intent file / existing docs
      (uses the existing-source import from A.2b, BOO-117)
  (b) Describe the plan in 1-2 sentences → I derive language, framework, and TS/JS
```

Form a suggestion from the source or description, e.g.: "I detect **Next.js + TypeScript + Tailwind** → suggestion: `STACK_CHOICE = c) Full-stack`, `LANG_VARIANT = ts`. Accept / adjust / pick yourself?"

- The operator **confirms or overrides** — the suggestion is never binding.
- Record the chosen stack decision as an **ADR** in `docs/domain/adrs/` (same mechanism as the other stack defaults, §4.4f). On `e)` **without** a detectable stack: mark it explicitly as "still open", **don't** silently assume JS.
- **Order:** A.1 runs before A.2 — a source analyzed here (A.1a) is **not re-read** by A.2b; it **reuses** the result for `PROJECT_DESC` (no double read, no double question).

### A.1b Lighthouse CI for frontend performance (BOO-45, only when STACK_CHOICE = b or c)

If `STACK_CHOICE = b` (frontend) or `c` (full-stack with frontend portion), follow-up question:

```
Enable Lighthouse CI for web performance?
  Counterpart to BOO-16's performance gate for backend services, but against the browser URL.
  Measures LCP, FID, CLS + bundle size + accessibility and blocks merges on budget violations.
  [yes / later]
```

On `yes`:
- Render `lighthouserc.json` with performance budgets (LCP <2.5s, CLS <0.1, TBT <300ms, mobile throttling 3G-slow) — template in `references/file-templates.en.md` §`lighthouserc.json (BOO-45)`
- Render `.github/workflows/lighthouse.yml` (treosh/lighthouse-ci-action@v12, on every push + PR) — template in `references/file-templates.en.md` §`.github/workflows/lighthouse.yml (BOO-45)`
- Both files write reports to `journal/reports/ci/run-${{ github.run_id }}/lighthouse.json` (BOO-32 convention)
- HANDBUCH §Lighthouse integration (Appendix H) explains the manual operator tasks: enter the frontend URL per environment, tune performance budgets, pick the mobile throttling profile

On `later`: no templates are scaffolded. The operator can catch up via `migrate_boo_45()`.

Remember `LIGHTHOUSE_CHOICE = yes | later` for Phase 4.

### A.1c Target runtime / tool adapter (BOO-53/54)

```
Which AI runtime should the project primarily use?
  a) Claude Code — AGENTS.md as optional Codex entry, CLAUDE.md is the active runtime file
  b) Codex — AGENTS.md is the active entry, CLAUDE.md remains a compatibility bridge
  c) Cross-tool — both entries active, CONVENTIONS.md is the hard adapter contract
  d) unclear — scaffold the cross-tool baseline, tighten later in CONVENTIONS.md
  Default: claude-code (ADR-2: Claude-Code-first — native paths active; inactive for codex/cross-tool)
```

**Remember:** `RUNTIME_TARGET = claude-code | codex | cross-tool | unknown`

Roles:
- `AGENTS.md` = Codex entry with repo rules, sandbox/scope notes, and a pointer to `CONVENTIONS.md`.
- `CLAUDE.md` = Claude Code entry and compatibility bridge for existing Claude workflows; it must not be the sole truth for tool-neutral rules.
- `CONVENTIONS.md` = adapter contract: runtime, backlog adapter, governance mode, execution isolation, active gates, and postflight status.

For `codex`, `cross-tool`, or `unknown`, always scaffold `AGENTS.md`. For `claude-code`, `AGENTS.md` may still be scaffolded as a portable Codex entry; skip it only on explicit operator request.

For `RUNTIME_TARGET = claude-code`, the native **status line** is also rolled out (script `bootstrap/templates/statusline.sh` → installed as `.claude/statusline.sh`, wired via the `statusLine` key in `.claude/settings.json`). It shows the model, token budget, worker-equivalent (h/h), and story budget live. No separate question — activation follows from the Switch-A choice `claude-code`. Inactive for `codex`, `cross-tool`, or `unknown`. Details: HANDBOOK appendix AQ "Status Line"; existing projects pick it up via `migrate_boo_205`.

### A.2 Project identity (3 questions)

```
1. Project name? (e.g. MyAnalytics)
2. One-sentence description: what does the system do?
3. Starting version? (default 0.1.0)
```

### A.2b Existing-source import (optional, BOO-117)

Before the operator types everything by hand: check whether a source already exists that project info can be derived from. That source is **read for content** and produces **suggestions** (never a silent take-over).

```
Is there already a source I can pull project info from?
  a) Intent file (e.g. intents/*.md from the intent skill)
  b) Existing repo / directory (README, package.json, pyproject.toml, code)
  c) Other doc (concept, spec sheet, pitch, Notion/Confluence export ...)
  d) No — I'll describe it myself
  Default: d
```

For `a/b/c`: read the source (path/URL from the operator) and **derive + suggest**:
- `PROJECT_DESC` (one-sentence description) — the main purpose of this step
- optionally `PROJECT_NAME`, a `stack_hint` (correction suggestion for A.1 / guided discovery BOO-127), detectable add-ons

Show the suggestion to the operator, e.g.: "Derived from `<source>`: `PROJECT_DESC = '…'` (and the stack looks like `…`). Accept, adjust, or discard?" → operator confirms or overrides.

**Remember:** `SOURCE_IMPORT = {type: intent|repo|doc|none, ref: <path/url>, derived: {project_desc, stack_hint, ...}}`.

Cleanly optional — no coercion, no breakage:
- On `d`, a missing, empty, or unreadable source: continue normally with the A.2 inputs, `SOURCE_IMPORT.type = none`.
- A.1 (stack) was already asked; a `stack_hint` derived here is only offered as a correction, never forced.
- If the same source was already analyzed in A.1 (guided discovery, BOO-127): **reuse it here**, don't re-read or re-ask.

### A.3 Backlog (2 questions)

```
4. Issue prefix? (default derived from project name, e.g. "MA-" for MyAnalytics)
5. Primary language for docs? (de / en, default: de)
```

### A.3b Backlog adapter (BOO-54)

```
Which backlog system should be used as the primary adapter?
  a) Linear
  b) GitHub Issues  (recommended standard — lean, native to the repo, no OAuth tunnel)
  c) Jira
  d) Azure DevOps Boards
  e) Microsoft Planner
  f) none — backlog record as Markdown/file only, no external tool
  Default: none  (with a GitHub repo, recommendation: b)
```

**Remember:** `BACKLOG_ADAPTER = linear | github | jira | azure-devops | planner | none`

Bootstrap creates a neutral **Backlog Record** as the contract shape. External tools are adapters onto it, not the framework's source:
- Required fields: `id`, `title`, `status`, `priority`, `estimate`, `intent`, `acceptance_criteria`, `links`, `adapter`.
- `id` follows the issue prefix (`{ISSUE_PREFIX}XXX`) even when the external tool has its own IDs.
- Linear is a supported adapter, but not a prerequisite.

### A.4 Architecture dimensions + add-ons (1 question)

```
7. Standard dimensions (always on): Reliability, Data Integrity, Security,
   Performance, Observability, Maintainability, Testability, Scalability, AI-Readiness.

   Activate additional add-ons (multi-select)?
   [ ] Privacy / GDPR — for voice assistants, personal data, tier models
   [ ] Cost Efficiency — for LLM-heavy / SaaS-subscription projects
   [ ] Signal Quality — for ML / analytics / signal systems
   [ ] Compliance — for regulated industries (health, finance, legal)
   [ ] EU AI Act — for solutions with an AI component that process (customer) data (AI-Act documentation duties)
```

Each activated add-on extends the architecture dimensions in `ARCHITECTURE_DESIGN.md` + the corresponding section in `SECURITY.md` / `GOVERNANCE.md`.

> **Privacy add-on (BOO-69):** On `[x] Privacy / GDPR`, bootstrap additionally installs the `dpo` skill as standalone (analogous to `security-architect`), renders `PRIVACY.md` from `references/privacy-template.en.md`, creates `personal-data-paths.json` template, and sets backlog label `privacy`. The operational setup phase is 4.4n (Privacy Setup, analogous to 4.4i Sensitive Paths). DPO runs with three modes (ASSESS in `/ideation` Step 0e, REVIEW in `/implement` Step 5.5b, AUDIT in `/sprint-review` Step 7c). Details: HANDBUCH Appendix O.

> **EU AI Act add-on (BOO-101/105):** On `[x] EU AI Act`, bootstrap copies the catalogue `dpo/controls/optional/eu-ai-act.yml` into the project overlay `.claude/dpo/controls/` and renders `AI_SYSTEM.md` from `dpo/references/ai-system-template.md`. Operational phase: **4.4n-bis**. Requires the Privacy add-on. **Strictly opt-in** — the catalogue lives under `controls/optional/` and is loaded by the dpo runner ONLY once copied into the project (no noise in non-AI projects). No legal advice; judgment items = REVIEW-NEEDED.

> **Financials / ROI-tracking add-on (BOO-190):** Optional, operator-activated, mirroring the Privacy add-on pattern (Yes/No → template generation → follow-up question). Bootstrap asks a dedicated Yes/No question **at the end of Block A** (not as an architecture dimension, but as a Financials activation): *"Activate Financials / ROI tracking?"* On **yes**, bootstrap generates the templates `docs/financials/budget.md` + `docs/financials/worker-equivalent-baseline.md` and asks the **follow-up question for the internal billing rate** (with the four geo defaults as a visible choice). The operational setup phase is **4.4o (Financials Setup, analogous to 4.4n Privacy Setup)**. On **no**, nothing happens — no template, no follow-up. Details: HANDBUCH Appendix AK.

**Remember:** `ADDONS = [...activated]`, `FINANCIALS = yes | no`

### A.5 Governance intensity (BOO-51)

```
8. Governance intensity for this project?
   a) Lite/Light — small experiments/scripts: core context, CONVENTIONS.md, spec-gate, basic linting; no heavy CI/audit/performance gates
   b) Standard — serious solo/client projects: security gates, CI lint/SAST, sensitive paths, learning loop L1
   c) Heavy — regulated/revenue-critical systems: coverage, performance, SonarQube, branch protection, audit trail, mandatory review
   Default: Standard
```

**Remember:** `GOVERNANCE_MODE = lite | standard | heavy`

### A.6 Execution isolation / worktrees (BOO-52)

```
9. Isolate parallel agent work?
   a) none — linear work only, no parallel agents
   b) write-scope — parallel subagents only with clearly separated file/module scopes
   c) git-worktree — each parallel agent gets its own Git worktree/branch
   Default: write-scope
```

**Remember:** `EXECUTION_ISOLATION = none | write-scope | git-worktree`

Rules:
- If `GOVERNANCE_MODE = lite`, default `EXECUTION_ISOLATION = none`.
- If `GOVERNANCE_MODE = standard`, default `EXECUTION_ISOLATION = write-scope`.
- If `GOVERNANCE_MODE = heavy`, default `EXECUTION_ISOLATION = git-worktree`.
- `agentic` execution is only allowed when `EXECUTION_ISOLATION = git-worktree`.
- `none` is not a governance mode; it is only an execution-isolation value without parallel-agent protection.

### A.7 Deployment scenario (BOO-70)

```
10. Deployment scenario?
    a) Solo-Mac (default — ~80% of operators)
    b) other → see HANDBUCH Appendix P (Solo-VPS / Multi-User VPS coding factory / Team-with-coding-server)
```

**Remember:** `DEPLOYMENT_SCENARIO = solo-mac | other`

**Derive the install default (BOO-115):** `INSTALL_DEFAULT = system` on `solo-mac`; `INSTALL_DEFAULT = docker` (golden image / container profile) on `other` (Solo-VPS / Multi-User-VPS coding factory / team server). The operator can override the default at any time. Used in the tool-install guidance (phase 7.3b).

- On `a)` the existing bootstrap path continues unchanged — Solo-Mac is the default, no extra setup logic. (Solo hint: if you work in parallel in **two sessions on the same clone**, use `git worktree` instead of the same working tree twice — collision protection level 2, `docs/kollisionsschutz-drei-ebenen.en.md`.)
- On `b)` bootstrap only prints a hint block and does not fork the interview:

  ```
  You picked "other". INTENTRON itself does not ship scenario-specific
  setup automation — read HANDBUCH Appendix P, pick your scenario
  (Solo-VPS / Multi-User-VPS / Team-server) and walk through the steps
  described there once. After that, bootstrap continues unchanged.
  ```

- **For multi-user VPS** (several people, one project): additionally the runbook `docs/runbooks/multi-user-vps.en.md` (team-member checklist — once VPS / once GitHub / once Claude / per repo) + Appendix P §3. Each user gets their **own clone** (no shared working tree), `journal/daily/` is local per user (`.gitignore`). Concept: `docs/kollisionsschutz-drei-ebenen.en.md` (level 1).
- Consequence for phases 4 / 5: `DEPLOYMENT_SCENARIO` is recorded in `metadata.deployment_scenario` inside `.claude/environment.json` and, since BOO-115, drives the **install default** (system vs. Docker) in the tool-install guidance (phase 7.3b). Otherwise no interview fork.

> **Issue reference:** BOO-70. Source: HANDBUCH Appendix P (Deployment Scenarios). Migration for existing projects: `references/migration-checklist-v1-to-v2.en.md` §BOO-70.

### A.8 Machine context (BOO-145)

At the end of Block A — the stack answer from A.1 is available — write the **machine context** automatically into the global `~/.claude/CLAUDE.md`. **Idempotent + no separate operator step:** first read `~/.claude/CLAUDE.md`; if a `## Machine context` section is already present, **do nothing** (do not overwrite). If the file is missing, create it.

Determine the values:

- **Type:** `uname -s` → `Darwin` = `macOS`, `Linux` = `Linux` (fallback `$OSTYPE`).
- **Framework version:** latest release tag of the intentron repo via `git -C <intentron-repo> describe --tags --abbrev=0` (e.g. `v0.8.1`); fallback: `bootstrap` skill version from the SKILL.md frontmatter.
- **Stack preference:** from `STACK_CHOICE` + `LANG_VARIANT` (A.1), in plain text (e.g. "Node.js / Next.js / TypeScript").
- **Available skills:** `ls ~/.claude/skills/` (comma-separated on one line).

Append the section (only if `## Machine context` is missing):

```markdown
## Machine context
- Type: <macOS | Linux>
- Framework: intentron <VERSION> — skills under ~/.claude/skills/ + per project
- Stack preference: <stack from A.1>
- Available skills: <ls ~/.claude/skills/>
```

Do not write any secret. Write/read format + idempotency rule: `references/global-registry-update.en.md §Machine context`. Related: `PROJECTS_ROOT` (BOO-138, Block B) — together they form the machine-level context of the global `~/.claude/CLAUDE.md`.

### A.9 Financials / ROI tracking (BOO-190, optional)

Optional, operator-activated question — exactly the activation pattern of the Privacy add-on (Yes/No → template generation → follow-up). On `no`, nothing happens.

**Question (a) — activation:**

```
Activate Financials / ROI tracking?

What this does: creates two budget/reference templates under docs/financials/
(budget.md + worker-equivalent-baseline.md) and asks for your internal billing
rate. This lets the framework later derive a money-denominated ROI factor from
the story dual column (effort_ai_hours / effort_human_equiv_hours, BOO-193) —
AI cost vs. human-equivalent cost.

Recommended: when you want to express the value of AI work in money (internal, ROI).
Solo experiment without a budget view: not needed — can be added later via Phase 4.4o.

Activate now?
  [yes]  Templates are generated, the billing rate is asked (follow-up)
  [no]   (default) — no template, no follow-up
```

**Remember:** `FINANCIALS = yes | no`. On `no` → end A.9, no follow-up.

**Question (b) — internal billing rate (only on `yes`):**

The four geo defaults are shown as a **visible choice** — they come from the primary default set (external freelance/contract **P50**, opportunity-cost basis) of the internal deep research (Owlist GmbH, survey data 2025). Source reference: `docs/financials/worker-equivalent-baseline.md` section 2 (with confidence + sources per geo; it also lists the **conservative internal fully-loaded rate** as an alternative).

```
Internal billing rate per hour?

Enter your own internal rate — or press Enter to take the market-research
default for your geo:

  CH  CHF 137 / h   (external freelance P50)
  DE  EUR  95 / h   (external freelance P50)
  AT  EUR  85 / h   (external freelance P50)
  US  USD 120 / h   (external contract  P50)

Source of the defaults: docs/financials/worker-equivalent-baseline.md §2
(incl. conservative internal fully-loaded rate per geo as an alternative).
Native currency per geo — no FX cross-conversion.

Your internal rate (Enter = take default): ____
```

**Evaluation rule (mirrored from the baseline template):**

- **Input present** → `source: intern`, `erhebungsjahr` = year of the internal rate.
- **Question skipped** (Enter) → take the geo default, `source: market-research-2026`, `erhebungsjahr: 2025`, `basis: freelance-p50`.
- **Internal precedence (final, ADR-D):** if an entered internal rate exists, it beats the market-research default **always**. No mixing.

**Remember:** `FINANCIALS_GEO`, `FINANCIALS_CURRENCY`, `FINANCIALS_RATE`, `FINANCIALS_SOURCE`. The values are written in Phase **4.4o (Financials Setup)** into `docs/financials/worker-equivalent-baseline.md` section 1.

> **Issue reference:** BOO-190. Consumers of the baseline: worker-equivalent report (`/sprint-review`, BOO-191) + sprint forecast (`/backlog`, BOO-192), data source dual column (BOO-193). HANDBUCH background: Appendix AK (Financials & Worker-Equivalent), dual column: Appendix G.

### A.10 Compliance doc gate (BOO-229, optional)

Optional, operator-activated yes/no question — add-on pattern like privacy / EU-AI-Act. On `no` (default) nothing happens; the standard behavior (doc drift = WARN) stays.

```
Enable the compliance doc gate?

What it does: the shared doc-drift checker (scripts/doc-drift-check.sh, BOO-229) checks,
before /ideation, /architecture-review and /implement, whether the doc map
(ARCHITECTURE_DESIGN.md §References + INDEX.md) still matches reality.

  Standard   (default) — a drift finding is a WARNING, the skill continues.
  Compliance (on)      — a FAIL (a registered file is missing) BLOCKS the skill
                         until the drift is resolved. In the autopilot the story
                         pauses (worker self-heals safe drift, asks only on local != remote).

Recommended: only for audit-bound projects (ISO 27001 / DORA / PCI / SOC 2),
where doc consistency is an evidence obligation. Otherwise leave it on standard.

Enable now?
  [yes]  compliance_doc_gate = true
  [no]   (default) — compliance_doc_gate = false (standard, warn-only)
```

**Remember:** `COMPLIANCE_DOC_GATE = true | false` (default `false`). The value fills the `{{COMPLIANCE_DOC_GATE}}` placeholder in `CONVENTIONS.md` (§3 Active gates) and is mirrored to `.claude/environment.json` under `governance.compliance_doc_gate`. **Orthogonal** to `governance_mode` — a `lite` project may turn it on, a `heavy` project may leave it off. SSoT is `CONVENTIONS.md`; on a `--force` regen of environment.json, re-set the value (like `governance.mode`) if customized.

> **Issue reference:** BOO-229. Consumers: `/ideation`, `/architecture-review`, `/implement` (pre-flight FAIL severity), autopilot `sprint-run`→`/goal` (`sprint-run/references/gate-block-handling.md`, token `doc-drift-ok`). HANDBUCH background: Appendix AS.

Phase 1 checkpoint: print a short confirmation of the answers.

---

## Phase 2: Block B — Existing infrastructure

Read `references/existing-infra-check.en.md` for the full dialog flow.

The skill respects existing infrastructure — it doesn't re-create everything.

**Standard project path (`PROJECTS_ROOT`, BOO-138):** Before question 1 is asked, the skill checks whether a `PROJECTS_ROOT` is recorded in the global operator `~/.claude/CLAUDE.md`:

- **Recorded** (machine already set up): question 1 is pre-filled with the default `<PROJECTS_ROOT>/<project-name>` — the operator confirms with Enter or supplies a different path (override always possible).
- **Not recorded** (first project on this machine): the skill asks **once** for the standard project path (`Where should projects live by default on this machine? [default: ~/projects]`) and records it — after operator confirmation — in `~/.claude/CLAUDE.md`. This way every further project lands at the same place without path typing.

Write/read format + operator confirmation: `references/global-registry-update.en.md §Standard project path`. No cockpit/dashboard — the daily state emerges when opening the respective project (PMO hub + latest `journal/daily/` note, BOO-139).

```
Do you already have the following? (answer each individually)

1. Project directory?
   [a] Yes + absolute path
   [b] No, create it — where? (absolute path)
       Default (if PROJECTS_ROOT is set): <PROJECTS_ROOT>/<project-name>
       → Enter confirms the default, a custom path overrides

2. GitHub repo?
   [a] Yes + URL
   [b] No, create later (no remote for now)
   [c] No GitHub wanted

3. Project documentation SSoT?
   [a] Obsidian Vault + absolute vault path
   [b] Repo docs — project docs under docs/project/
   [c] External DMS — Notion / Confluence / SharePoint / other + URL/path
   [d] Undecided — repo fallback docs/project/ + TODO
   [e] Repo docs + personal vault harvest (team with Obsidian users) — BOO-75

   > Note — Obsidian is a solo tool, not an enterprise tool:
   > - Solo / 1 person → [a] Obsidian vault as SSoT is ideal.
   > - Team / multiple people → [b] repo docs (or [c] external DMS). An Obsidian
   >   vault is personal; there is no shared vault for the team.
   > - Team WITH Obsidian users who want cross-project insights in their own vault
   >   → [e] repo docs + personal vault harvest (Stefan's Git scenario: docs live
   >   in the repo, a git post-merge hook mirrors selected docs/ one-way into each
   >   operator's personal vault). Details: HANDBUCH Appendix R Layer 3
   >   (vault-harvest pattern).

4. Backlog system / adapter?
   [a] Linear + team slug
   [b] GitHub Issues + repo
   [c] Jira + project key
   [d] Azure DevOps Boards + project
   [e] Microsoft Planner + plan
   [f] None / Markdown-only

5. API keys for the project?
   [a] Already exist in .env
   [b] .env.example is enough, keys later

6. Developer handover?
   [a] Standard: create Developer Onboarding and keep it current
   [b] Only link it, it already exists in the documentation SSoT
```

**Merge mode:** If a folder/repo/vault exists and already contains files, **before overwriting** ask:

```
Warning: {PROJECT_PATH} already contains files.
  [a] Create backup + continue bootstrap
  [b] Only add missing governance files (merge)
  [c] Abort
```

**Remember:** `EXISTING_INFRA = {...}`, `DOCUMENTATION_SSOT = {type, path_or_url, project_path, fallback, status}` and `PROJECTS_ROOT = {path, source}` (`source = claude-md` if read from `~/.claude/CLAUDE.md`, `newly-set` if asked + written for the first time in this run) for the following phases. On choice `[e]`, `type = repo-docs-plus-vault-harvest`.

> **Choice [e] Repo docs + personal vault harvest (BOO-75/77):**
> Bootstrap sets up the vault harvest fully with the **framework-native engine** (BOO-77):
> 1. sets the documentation SSoT to `docs/project/` (like `[b]`),
> 2. copies the engine files from `references/vault-sync/` into the project:
>    - `scripts/vault-sync.py` (one-way sync engine repo→vault, Python stdlib),
>    - `.claude/hooks/post-merge.sh` (hook wrapper, fires after `git pull`),
>    - `scripts/install-vault-sync.sh` (interactive per-operator init),
>    - `.vault-sync/tracked-paths.json` (versioned team contract, 4 defaults),
> 3. adds `.vault-sync/local.json` to `.gitignore` (personal config, never committed),
> 4. sets **Block D DocSync = no** (vault harvest and DocSync would otherwise overlap — DocSync is solo/bidirectional, harvest is team/one-way),
> 5. adds a setup step to `DEVELOPER_ONBOARDING.md`: "optionally enable the vault harvest per operator: `bash scripts/install-vault-sync.sh` (creates `.vault-sync/local.json` + symlinks the hook). Default mode `dry-run` — verify first, then switch to `auto`."
>
> **Security:** the engine writes one-way ONLY into the vault (never into the repo), checks path containment (no writing outside `vault_path`), and exits silently with `exit 0` when an operator has no `local.json` (zero friction). Details: HANDBUCH Appendix R Layer 3 + `references/vault-sync-pattern.md`.

Phase 2 checkpoint: print a summary.

### B.6 Prepare provider and platform postflight (BOO-58)

Read `references/provider-postflight.en.md`. Bootstrap must separate local skill installation from external provider verification.

Additional questions after Block B:

```
Is there an existing monitoring/logging platform?
  a) Yes, use the central platform
  b) No, prepare a project-owned monitoring setup
  c) Not clear yet, document as an architecture question
```

```
Should the Research skill be installed or connected?
  Source: Framework / companion / globally installed / do not install
  Provider: Perplexity MCP / Perplexity API / OpenRouter / no provider
```

```
Visualization:
  - Install visualize skill?
  - Use Miro as diagram target?
  - Is Miro MCP available and should it be checked?
  - Fallback: Excalidraw / Mermaid / none?
```

**Remember:** `PROVIDER_POSTFLIGHT = {...}` for the closing report and optional `docs/MONITORING.md`.

---

## Phase 3: Block C — Docs architecture proposal

Read `references/doc-architecture-proposal.en.md` for the full rationale.
Also read `references/project-documentation-ssot.en.md`. Block C must first operationalize the project documentation SSoT selected in Block B:

- `obsidian`: create or confirm the project folder in the vault; Obsidian is the best-practice path, not a framework prerequisite.
- `repo-docs`: create `docs/project/` as the authoritative project documentation SSoT.
- `external-dms`: create a local reference file in `docs/project/` and point runtime artifacts to the URL/path.
- `undecided`: create `docs/project/` as a fallback, add TODO "decide final documentation SSoT" and mark postflight as `WARN`.

Regardless of target location, Project Hub, Developer Onboarding, Project Governance, Target Architecture, Backlog, Decisions, Meetings, Research, Assets and Archive must exist or be clearly linked.

Based on the stack choice (A.1) and infra status (block B), present a concrete docs structure proposal:

```
Proposal: 3-layer docs with ARCHITECTURE_DESIGN.md as central hub

  Layer 1 — Story specs (repo)
    Path:    {PROJECT_PATH}/specs/<PREFIX>XXX.md
    Purpose: One spec per story, git-versioned
    Trigger: Required before any code change (spec-gate.sh)

  Layer 2 — Component docs (Obsidian)
    Path:    {OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Components/*.md
    Purpose: Living doc per component (stack, status, open questions)
    Trigger: Update on every /implement (T_last requirement)
    Component proposal (based on stack): {STACK_SUGGESTION}

  Layer 3 — Architecture guidelines (Obsidian)
    Path:    {OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Architektur-Vorgaben.md
    Purpose: Consolidated guiding principles, stack decisions, rejected alternatives
    Trigger: Update on ADR changes

  Hub (repo)
    Path:    {PROJECT_PATH}/ARCHITECTURE_DESIGN.md
    Purpose: Entry point for /ideation, /architecture-review, /implement
    §9 References links automatically to all the files above

Does this work? [yes / adjust / skip Obsidian layer]
```

**Component proposal (STACK_SUGGESTION) per A.1:**
- Node.js backend → `api.md`, `db.md`, `background-jobs.md`, `auth.md`
- Frontend → `ui.md`, `state.md`, `routing.md`, `api-client.md`
- Full-stack → `frontend.md`, `backend.md`, `api.md`, `db.md`
- Python → `cli.md`, `core.md`, `integrations.md`, `data.md`
- Other → asks the operator for component names

Operator can adjust components or enter their own.

**On `yes`:**
- Component skeletons get scaffolded in phase 4
- `ARCHITECTURE_DESIGN.md §9 References` is initially populated
- Optional `orphan-check.sh` hook gets installed in phase 4 (explicit ask: "Hook that checks every new `*.md` is registered in the hub? [yes, recommended / no]")

**On `adjust`:** dialog asks which layers + paths are wanted.

**On `skip Obsidian layer`:** all docs in the repo (`docs/components/`), no SecondBrain part.

Phase 3 checkpoint: confirm the docs structure.

---

## Phase 4: Scaffold base structure

### 4.1 Directory structure

```bash
mkdir -p {PROJECT_PATH}/{lib,agents,.claude/skills,.claude/hooks,.codex,specs,docs,docs/financials,journal,intents,pitch}
```

### 4.2 Initialize git repo (if not yet present)

```bash
cd {PROJECT_PATH}
git init
# Set remote only if B.2 == yes + URL
git remote add origin {GITHUB_REPO}
```

Create `.gitignore` from `references/file-templates.en.md` — since BOO-36 the template contains the block `journal/reports/local/` (iteration outputs from `/implement` step 6 — these live only locally and are NOT committed, because they are produced fresh on every run and are re-creatable. `/sprint-review` aggregates them into `journal/sprint-{date}.md`, which is committed). Counterpart: `journal/reports/ci/` is reserved for GitHub Actions runs (separate path, independent decision).

### 4.3 Render core files from templates

From `references/file-templates.en.md`, populate with block A values:

| File | Template section |
|------|------------------|
| `lib/config.js` | config.js |
| `AGENTS.md` | AGENTS.md (Codex entry; required for runtime `codex`/`cross-tool`/`unknown`) |
| `CLAUDE.md` | CLAUDE.md (Claude Code entry + compatibility bridge, with hub rule) |
| `CONVENTIONS.md` | CONVENTIONS.md (adapter contract: runtime, backlog adapter, governance mode, execution isolation, active gates) |
| `SYSTEM_ARCHITECTURE.md` | SYSTEM_ARCHITECTURE.md |
| `ARCHITECTURE_DESIGN.md` | ARCHITECTURE_DESIGN.md (hub with §9 References) |
| `INDEX.md` | INDEX.md |
| `COMPONENT_INVENTORY.md` | COMPONENT_INVENTORY.md |
| `.env.example` | .env.example |
| `CHANGELOG.md` | CHANGELOG.md |
| `specs/TEMPLATE.md` | specs/TEMPLATE.md |

> **AI architecture block (BOO-24):** the `ARCHITECTURE_DESIGN.md` template already contains the mandatory block "AI architecture principles + anti-patterns" in §2 (Design Rationale). Reference: `intentron/references/ki-architektur-prinzipien.md`. The block is populated automatically during template rendering — no manual step needed. `/architecture-review` (BOO-7) reactively checks all 8 checks on every story.

> **CONVENTIONS.md (BOO-51/52/53/54):** this document is the project-local adapter contract between all skills and runtimes. `/ideation` reads `runtime_target`, `backlog_adapter`, `governance_mode`, and `execution_isolation`; `/implement` uses it as the pre-flight for worktree/write-scope requirements and active gates; `/sprint-review` later checks drift against the selected governance intensity.

> **Baseline rule for governance modes (BOO-61):** Lite/Standard/Heavy must not destroy the skill or artifact baseline. Always scaffold at least `AGENTS.md`/`CLAUDE.md` according to runtime, `CONVENTIONS.md`, `ARCHITECTURE_DESIGN.md`, `GOVERNANCE.md`, `SECURITY.md`, `specs/TEMPLATE.md`, `journal/`, a Backlog Record template, and the selected skill baseline. The modes only control gate strictness, defaults, and required evidence.

From `references/governance-template.en.md`:
- `GOVERNANCE.md` with project name + prefix + activated add-ons

From `references/issue-writing-guidelines-template.md` (version 3.1, BOO-30):
- `.claude/ISSUE_WRITING_GUIDELINES.md` with ISSUE_PREFIX
- Contains since v3.1 the mandatory section `## Definition of Done (Required)` as a 5-item checklist (local gates, PR merge, required status checks, no "QA Failed", spec file update) — 1:1 from BOO-30
- Operator note: workflow states (`Backlog`, `In Progress`, `In Review`, `QA Failed`, `Done`, `Cancelled`) are described in the neutral Backlog Record. External adapters map them onto Linear/GitHub/Jira/Azure DevOps/Planner — see phase 4.4l.

Plus skeletons:
- `DEVELOPMENT_PROCESS.md` — reference to GOVERNANCE.md
- `SECURITY.md` — minimal skeleton (add-on sections: privacy/compliance if activated)
- `API_INVENTORY.md` — minimal skeleton from `references/file-templates.en.md` §`API_INVENTORY.md (minimum)` (external + internal interfaces; **no secrets**). SSoT for interfaces; `/implement` keeps it current via the post-implement check. Referenced in `ARCHITECTURE_DESIGN.md §6`.

> **CORE RULE in the runtime entry (`AGENTS.md`/`CLAUDE.md`):** every new file MUST be registered immediately in `ARCHITECTURE_DESIGN.md §9 References` AND `INDEX.md` — before `git commit`.

### 4.3a Set the project-type marker (BOO-148)

When populating `CLAUDE.md` (template `references/file-templates.en.md` §`CLAUDE.md (minimum)`), set the placeholder `{{PROJECT_TYPE_MARKER}}` — the marker sits as the first line after the H1 title and controls whether deployment/CI gates apply to this repo. Decision rule:

- **Active project** (code + deployment here) → ACTIVE marker:

  ```markdown
  > **PROJECT TYPE: ACTIVE** — code + deployment in this repo
  ```

- **Docs/specs only / governance reference** (no coding) → GOVERNANCE REFERENCE marker:

  ```markdown
  > **PROJECT TYPE: GOVERNANCE REFERENCE** — docs/specs only, no coding
  ```

**Default = ACTIVE** — when in doubt, do not ask; set ACTIVE (~80% of cases). Only set GOVERNANCE REFERENCE for unambiguous docs/specs repos (e.g. a governance book, a pure reference collection).

> **Issue reference:** BOO-148. Migration for existing projects: `references/migration-checklist-v1-to-v2.en.md` §BOO-148 (`migrate_boo_148`).

### 4.3b Seed CONTEXT.md — Ubiquitous Language (BOO-91)

Seed `CONTEXT.md` in the project root from `references/context-base.md` (DE) or `references/context-base.en.md` (EN, per the `documentation` language from A.3): pre-filled **canonical vocabulary** + **forbidden list** (compliance + governance, every term with its source) plus an empty section `## Project domain (operator to fill)` for project-specific terms. The AI reads `CONTEXT.md` while writing and uses the canonical terms consistently — **default guidance, no hard gate** (no block, only guidance).

- Seed only when `CONTEXT.md` is missing — never overwrite an existing operator overlay (idempotent, analogous to `migrate_boo_91()`).
- The generated `CLAUDE.md` (and `AGENTS.md`) **points to `CONTEXT.md`** as the binding vocabulary for all write actions.
- Register `CONTEXT.md` in `ARCHITECTURE_DESIGN.md §9 References` + `INDEX.md`.

> **Issue reference:** BOO-91. Enforcement (dpo control "vocabulary follows CONTEXT.md", Layer-0 bodyguard `warn` on forbidden terms) is deliberately a **later, opt-in expansion** — this stage ships only the guidance layer. Details: CONVENTIONS.md §Ubiquitous Language.

### 4.4 Linting configuration

Based on `STACK_CHOICE` — see `references/file-templates.en.md`:
- Node.js / Full-stack / Other → `eslint.config.mjs` (ESLint v9 flat config)
- Frontend / Full-stack → additionally `.prettierrc`
- Python → `pyproject.toml` (Ruff + Black)
- **TypeScript** (`LANG_VARIANT = ts` for a/b/c, BOO-127) → additionally `tsconfig.json` (template `references/file-templates.en.md` §`tsconfig.json (BOO-127)`); `eslint.config.mjs` wires in `typescript-eslint`; plus a `tsc --noEmit` typecheck gate (see CI table below).
- **React / frontend with JSX** (stack b/c, BOO-141) → `eslint.config.mjs` additionally gets a frontend block with `...globals.browser` **and** `React: 'readonly'` (package `globals` as a devDep). Mandatory — otherwise `no-undef` throws `'React' is not defined` on every `.tsx` file. Template: `references/file-templates.en.md` §`eslint.config.mjs` → "With React / frontend (TSX)".
- **Next.js / meta-framework `package.json` `lint` script** (stack b/c, BOO-140) → if `create-next-app` or similar already created a `"lint": "next lint"` in `package.json`, rewrite the script idempotently to `"lint": "eslint ."` (operator confirmation as an ADR). Reason: `next lint` does not understand the ESLint v9 flat config (`eslint.config.mjs`) and aborts with `Invalid project directory ... /lint`; CI uses `npx eslint .` anyway (BOO-28). For existing projects: `migrate_boo_140()`.

Additionally a stack-dependent **CI lint workflow (BOO-28)** — only created when `B.2 == yes` (GitHub repo present). Mirror of the Semgrep CI Action (phase 4.4c) — same Layer-3 mechanism, different tool class (lint instead of SAST):

| STACK_CHOICE | CI workflow file | Source |
|--------------|------------------|--------|
| a) Node.js backend | `.github/workflows/eslint.yml` | `references/file-templates.en.md` §`.github/workflows/eslint.yml (BOO-28 — ESLint CI Gate)` |
| b) Frontend | `.github/workflows/eslint.yml` | see above |
| c) Full-stack | `.github/workflows/eslint.yml` | see above |
| d) Python | `.github/workflows/ruff.yml` | `references/file-templates.en.md` §`.github/workflows/ruff.yml (BOO-28 — Ruff CI Gate)` |
| e) Other | none — operator decides manually | — |

Both workflows write SARIF to `.ci-reports/` (mandatory — read by BOO-32 for Hermes consumption and by BOO-29 as the required status check `eslint` / `ruff`) and upload via `github/codeql-action/upload-sarif@v4` into the GitHub Security tab.

If `B.2 == no/c` (no GitHub wanted): skip the BOO-28 step; only Layer 2 (pre-commit hook, phase 4.6) covers linting locally.

> **TypeScript typecheck gate (BOO-127):** On `LANG_VARIANT = ts` (a/b/c) the bootstrap adds a `tsc --noEmit` step to `eslint.yml` (or a dedicated `.github/workflows/typecheck.yml`) — template `references/file-templates.en.md` §`tsc --noEmit Typecheck (BOO-127)`. The gate is referenceable in BOO-29 as the required status check `typecheck`. Locally, the pre-commit hook (phase 4.6) covers `tsc --noEmit` as well.

### 4.4b SAST configuration (Semgrep — all stacks)

From `references/file-templates.en.md` §.semgrep.yml + §.semgrepignore:

- `.semgrep.yml` — Three-layer default ruleset:
  - **Layer 1 (mandatory, all stacks):** `p/security-audit`, `p/secrets`
  - **Layer 2 (language-specific, auto-detected):** `p/javascript` if `package.json` is present, `p/python` if `pyproject.toml` is present
  - **Layer 3 (optional, commented out):** `p/owasp-top-ten` — operator decides per web project
- `.semgrepignore` — default excludes (`node_modules/`, `dist/`, `build/`, `journal/reports/`, `.venv/`, `__pycache__/`)

Language detection happens in the existing-project migration path via `migrate_boo_3()` — for a new project (bootstrap flow), the matching Layer 2 line is inserted directly active based on `STACK_CHOICE`:

| STACK_CHOICE | Layer 2 activation |
|--------------|-------------------|
| a) Node.js backend | `p/javascript` active |
| b) Frontend | `p/javascript` active |
| c) Full-stack | `p/javascript` active |
| d) Python | `p/python` active |
| e) Other | both commented out (operator decides manually) |

For frontend / full-stack projects also surface a hint when creating the file:

```
Recommendation: for a web app also enable Layer 3 (p/owasp-top-ten) in .semgrep.yml.
Uncomment via: sed -i '' 's/^  # - p\/owasp/  - p\/owasp/' .semgrep.yml
```

Consumed by the pre-commit hook (Layer 2, see phase 4.6) and the GitHub Action (Layer 3, see phase 4.4c).

**Custom-rule directory + wiring canary (BOO-185):** Additionally, bootstrap rolls out the `.semgrep/` directory — project-owned rules that CI (Layer 3) and the pre-commit hook (Layer 2) load via `--config .semgrep/` **in addition** to the registry packs, as soon as the directory exists. It holds `.semgrep/custom-rules.yml` with the rule `qgaudit-wiring-canary` and the fixture `.semgrep/test-fixtures/wiring-canary.py` (tripwire literal `QGAUDIT-CANARY-TRIPWIRE`). `.semgrep/test-fixtures/` is excluded in `.semgrepignore` so the CI does not go permanently red — the canary is picked up only by the targeted audit scan. **Verification practice:** a configured custom-rule directory is provably active only once `semgrep --config .semgrep/ .semgrep/test-fixtures/wiring-canary.py` reports the canary rule — if the scan stays silent, the gate is blind (anchor for the `quality-gate-audit` skill, BOO-183). Content from `references/file-templates.en.md` §`.semgrep/custom-rules.yml`, §`.semgrep/test-fixtures/wiring-canary.py`, and §`.semgrepignore`.

### 4.4c CI layer (Semgrep, BOO-4)

If `B.2 == yes` (GitHub repo created), `.github/workflows/semgrep.yml` is additionally created from `references/file-templates.en.md` §`.github/workflows/semgrep.yml (BOO-4 — Quality-Gate Layer 3)`.

The Action reads the same `.semgrep.yml` manifest as the pre-commit hook (Layer 2, phase 4.6) — same manifest-reader logic, same pack selection. Blocks merges into `main` via the required status check `Semgrep` (branch protection is enabled in BOO-29).

| Layer | Where | When | What |
|-------|-------|------|------|
| Layer 2 | `.git/hooks/pre-commit` | on `git commit` | locally blocking, ESLint + Semgrep |
| Layer 3 | `.github/workflows/semgrep.yml` | on `push`/`pull_request` to `main` | CI-blocking, Semgrep with SARIF output to `.ci-reports/` |

**Important:** Both layers read `.semgrep.yml`. Anyone bypassing the hook locally with `--no-verify` is caught in Layer 3 — belt-and-suspenders.

If `B.2 == no/c` (no GitHub wanted): skip phase 4.4c — only Layer 2 (the hook) is installed in phase 4.6.

### 4.4d Test setup (BOO-15)

Prerequisite for the coverage gate (BOO-15) inside the `/implement` skill (step 6a-quart). Without JSON coverage output the gate is skipped with a hint. Stack-dependent:

- **Node (a/b/c):** install `c8` as a devDependency — `npm install --save-dev c8` — and add a coverage test script in `package.json`:
  ```json
  "scripts": {
    "test:coverage": "c8 --reporter=json --reporter=text-summary npm test"
  }
  ```
  Coverage output lands in `coverage/coverage-final.json`.

- **Python (d):** add `pytest-cov` to `pyproject.toml` as a test dependency, run with `pytest --cov --cov-report=json --cov-report=term-missing`. Coverage output lands in `coverage.json`.

- **Other (e):** operator decides manually — pick a stack-appropriate coverage tool with JSON export.

Test directory convention: `tests/` (Python), `__tests__/` or `test/` (Node) — the filter logic inside the hook recognises these paths automatically and excludes test files themselves from the diff coverage calculation.

Coverage output paths (the hook expects):
| Stack | Path |
|-------|------|
| Node (c8) | `coverage/coverage-final.json` |
| Python (pytest-cov) | `coverage.json` |

Note: the coverage gate itself is installed in phase 4.6 (`coverage-check.sh`), but is NOT called from the pre-commit hook.

### 4.4e Environment awareness (BOO-34)

Prerequisite for downstream skills (implement, sprint-review, breakfix, ...) reading their mac/VPS/CI awareness from a **single source of truth** instead of running detection themselves. The single source of truth is `.claude/environment.json` (manifest), produced by the bundled bash generator.

From `references/file-templates.en.md` §`.claude/environment.json (BOO-34 — skill environment awareness)` and §`.claude/generate-environment-json.sh (BOO-34)`:

- `.claude/generate-environment-json.sh` — bash generator (~120 lines, BSD- and Linux-compatible, idempotent: only writes when the file is missing or `--force` is passed). No deps beyond `bash`, `uname`, `command`, `cat`, `grep`, `sed`, `date`.
- First run right after creation: `bash .claude/generate-environment-json.sh`
- Result: `.claude/environment.json` with `environment` (mac/vps/ci, CI check first), `tools_available` (eslint, semgrep, test framework, SonarQube), `paths` (journal/reports/lessons/specs), `metadata` (created_at, bootstrap_version=3.3.0, stack).

> **Detection order matters:** CI check (env var `$CI`) BEFORE mac/VPS — a CI runner can be Linux OR mac. Otherwise a mac CI job would be incorrectly marked as `mac`.

`metadata.stack` is set analogously to BOO-3 stack detection:

| Indicator | stack value |
|-----------|-------------|
| `package.json` + (`tsconfig.json` OR `"typescript"` in deps) | `node-typescript` |
| `package.json` without TypeScript | `node-javascript` |
| `pyproject.toml` | `python` |
| Both (`package.json` + `pyproject.toml`) | `mixed` |
| Neither | `unknown` |

Consumed by **all** sub-skills via a step-0 read (rollout in BOO-34 sub-agent #2). Example pattern:

```bash
ENV_FILE=".claude/environment.json"
if [[ -f "$ENV_FILE" ]]; then
    HAS_SEMGREP=$(grep '"semgrep"' "$ENV_FILE" | grep -oE 'true|false')
fi
```

When tooling changes (e.g. semgrep installed later) regenerate the file with `bash .claude/generate-environment-json.sh --force`. The file gets committed — `metadata.created_at` is the audit trail.

### 4.4f Observability skeleton (BOO-14)

Prerequisite that every project ships from day 0 with a **structured logging, metrics, and alerting convention** — not retrofitted later. Schrader Code Crash chap. 3 §Production Readiness §Observability + chap. 4 §Run the System (pillar 3 observability): "deploy without observability and you fly blind."

From `references/file-templates.en.md` §`observability.md (BOO-14 — observability skeleton)`, §`observability/alerts/<service>.yml (BOO-14)` and §`observability/.env.observability (BOO-14)`:

- `observability.md` (project root) — central skeleton with three mandatory sections:
  - **Logging schema** — structured JSON logs with required fields (`timestamp`, `level`, `service`, `trace_id`, `message`, `context`)
  - **Metrics endpoint** — `/metrics` in Prometheus format per service, port convention `9090+N` (auth=9091, api=9092, ...)
  - **Alert rules** — three mandatory alerts per service: `{service}_down` (`up == 0` for >2 min, severity critical), `{service}_error_rate_high` (errors/requests >5% for 5 min, severity warning), `{service}_p95_slow` (p95(request_duration_seconds) >1s for 5 min, severity warning)
- `observability/alerts/<service>.yml` — one Prometheus alert-rules file per service from block C.
- `observability/.env.observability` — routing config (Telegram/Slack/Email webhooks). **Gitignored**, only `.env.observability.example` is committed.
- `.gitignore` entry: `observability/.env.observability`.

**Block C coupling:** for each service from block C (`STACK_SUGGESTION` — e.g. `api.md`, `db.md`, `auth.md` for Node.js) `observability.md` gets a `### Service: <name>` section + a file `observability/alerts/<name>.yml` with the three required alerts.

**Stack defaults** (proposal — operator can override, document as ADR):

| Stack | Logger lib | Metrics lib |
|-------|-----------|-------------|
| Node.js (a/b/c) | `pino` | `prom-client` |
| Python (d) | `structlog` | `prometheus_client` |
| Frontend (b) | Note: browser logs go via a backend service, not directly to Prometheus |
| Other (e) | Operator decides — document as ADR under `docs/domain/adrs/` |

**Validation (optional — only if `promtool` is installed locally):**

```bash
promtool check rules observability/alerts/*.yml
```

If `promtool` is not installed: skip with a hint. Recommendation: `brew install prometheus` (mac) or `apt install prometheus` (VPS) when the first service grows real alert rules.

> **Issue reference:** BOO-14, Schrader Code Crash chap. 3 §Production Readiness §Observability and chap. 4 §Run the System (pillar 3 observability).

### 4.4g Performance baseline (BOO-16)

Prerequisite for catching performance regressions **before** merge — not in production. BOO-14 already established the production alarm `{service}_p95_slow`; BOO-16 adds the pre-production gate: CI bench against a living baseline, blocks merge when p95 > baseline +20 %. Schrader Code Crash chap. 3 §Production Readiness (Gate 3: Performance Baseline) — no baseline, no visible regression.

From `references/file-templates.en.md` §`Performance baseline gate (BOO-16 — P95 + 20% regression alarm)` with the four sub-sections:

- `journal/perf-baseline.json` (project root, committed) — living baseline with `p50_ms`, `p95_ms`, `p99_ms`, `req_per_sec`, `recorded_at`, `commit_sha`, `bench_tool` per service. Created at bootstrap with `services: []`; the operator fills it after the first green CI run.
- `bench/<service>.bench.js` (Node stack) OR `bench/<service>_bench.py` (Python stack) — service benchmark with autocannon (Node, 30s run, 10 connections, 5s warmup) or pytest-benchmark + httpx (Python, approximation `p95 ≈ mean + 1.645*stddev`).
- `.github/workflows/perf.yml` — CI gate (`pull_request` against `main` + `workflow_dispatch`), thresholds `<=1.05` PASS / `1.05-1.20` WARNING (PR comment) / `>1.20` FAIL. Override via PR label `perf-override` OR commit trailer `Perf-Override: <reason>`, append-only into `journal/reports/perf/overrides.log`.
- `journal/reports/perf/overrides.log` — created on the first override; append-only audit trail.

**Block C coupling:** for each service from block C (`STACK_SUGGESTION`) a bench file is created plus an entry in the workflow matrix `service: [...]`. Service names identical to `observability.md` (kebab-case).

**Stack defaults** (operator can override — document as ADR):

| Stack | Bench tool | Bench file | bench_tool value in baseline |
|-------|-----------|-----------|------------------------------|
| Node.js (a/c) | autocannon (devDep) | `bench/<service>.bench.js` | `autocannon` |
| Python (d) | pytest-benchmark + httpx (test dep) | `bench/<service>_bench.py` | `pytest-benchmark` |
| Frontend (b) | Lighthouse CI (separate issue) | — | excluded from BOO-16 scope |
| Other (e) | operator choice with JSON output (p50/p95/p99) | — | `other` |

> [!important] autocannon has no native p95
> autocannon's `result.latency` exposes `p2_5, p50, p75, p90, p97_5, p99, ...` — no `p95`. We use `p97_5` as a conservative approximation (worst-case bias upward — a real regression is detected, harmless fluctuations may appear slightly larger). This is explicitly documented in the baseline via `bench_tool: "autocannon"`. Details see template section.

> [!important] GitHub-hosted runner variance
> Standard runners are shared hardware with +/- 30 % variance between identical runs. The 20% FAIL threshold is intentionally generous — it catches real regressions, not noise. Follow-up issue (after BOO-16): self-hosted runners with reserved CPU/memory; on those the threshold can be tightened to 10%.

> [!note] Initial baseline population
> Fresh repo state: `services: []`. The first CI run fails with "baseline missing". The operator downloads the bench artifact, copies the values manually into `perf-baseline.json` and commits with a justification — only then does the gate run green. Auto-population would be an anti-pattern: every regression would automatically become the new baseline.

> **Issue reference:** BOO-16, Schrader Code Crash chap. 3 §Production Readiness (Gate 3: Performance Baseline). Counterpart to the production alarm `{service}_p95_slow` from BOO-14.

### 4.4h Reliability skeleton (BOO-25)

Sixth pillar of the Schrader model: reliability as an architectural property. Whoever just deploys and hopes builds a demo. BOO-25 lands five invariants as concrete skeleton files: idempotency, retry+backoff, circuit breaker, graceful degradation, and SLO+error budget. Schrader Code Crash ch. 4 §Run the System (pillar 6 reliability) — the difference between "it ran on day one" and "it still runs in month two".

From `references/file-templates.en.md` §`Reliability skeleton (BOO-25 — 5 invariants idempotency/retry/circuit-breaker/graceful-degradation/SLO)` with the four sub-sections:

- `docs/SLO.md` (project root, committed) — Service Level Objective manifest with three SLIs (Availability / Latency P95 / Error Rate), PromQL measurement method (reads from the `/metrics` endpoint introduced in BOO-14), error-budget table per quarter with consumption tracker, review cadence in `/sprint-review` (monthly).
- `lib/idempotency.{js,py}` — Idempotency-Key middleware (Express middleware or FastAPI dependency). Reads header `Idempotency-Key` (UUID v4), persists request hash + response in Redis for 24h TTL. Repeat with same key: cached response. Same key + different body: HTTP 422.
- `lib/retry.{js,py}` — retry wrapper with exponential backoff + jitter. Default: 3 attempts, factor 2, jitter on. **Hard constraint:** only transient errors (5xx, timeout, connection reset) are retried — NO retry on 4xx or 422.
- `lib/circuit-breaker.{js,py}` — circuit-breaker wrapper, **one instance per external dependency** (DB, external API, message bus). Three states (Closed/Open/Half-Open), logging via Pino/structlog (BOO-14), fallback as operator choice (cache / default value / 503 + `Retry-After`).

**Phase 4.4h is OPTIONAL** — not every service needs all four skeletons from day 0. Operator question at the start of the phase:

```
Generate reliability skeleton from BOO-25? (Schrader pillar 6)
  a) yes, all four (SLO + idempotency + retry + circuit breaker)  — recommended for backend with external dependencies
  b) idempotency + SLO only  — minimal write-side service without external dependencies
  c) SLO only  — read-only services; reliability measurement manifest is enough
  d) no  — skip (default for pure frontend / scripts / experimental setups)
```

**Default recommendation per stack:**

| Stack | Default answer | Rationale |
|-------|----------------|-----------|
| Node.js (a/c) | a) all four | backend with side effects, external calls expected |
| Python (d) | a) all four | same |
| Frontend (b) | d) no | no server endpoint, backend handles it |
| Other (e) | c) SLO only | tool-agnostic; the measurement manifest always makes sense |

**Stack defaults per skeleton** (operator can override — record as ADR):

| Stack | Idempotency | Retry | Circuit Breaker | SLO |
|-------|-------------|-------|-----------------|-----|
| Node.js (a/c) | `lib/idempotency.js` + `redis@5.x` | `lib/retry.js` + `p-retry@8.x` | `lib/circuit-breaker.js` + `opossum@9.x` | `docs/SLO.md` |
| Python (d) | `lib/idempotency.py` + `redis>=5.0` | `lib/retry.py` + `tenacity>=9.0` | `lib/circuit-breaker.py` + `pybreaker>=1.0` | `docs/SLO.md` |
| Frontend (b) | not active (backend handles it) | not active | not active | not active |
| Other (e) | operator choice | operator choice | operator choice | `docs/SLO.md` |

> [!important] SLO is an architectural artefact, not a marketing promise
> Whoever writes 99.99% without multi-region or active-passive failover is being dishonest. Default recommendation: 99.9% for single-region (43.8 min downtime/month), 99.95% with failover, 99.99% only with multi-region + chaos tests. Higher is a lie until proven otherwise.

> [!important] Idempotency is for write endpoints only
> Apply on POST / PUT / PATCH / DELETE — not on GET (idempotent per HTTP spec, the layer is overhead). Also not globally for all routes — only where side effects happen (DB writes, external API calls, money movement).

> [!important] One circuit breaker per external dependency, not a global one
> Pattern: `dbBreaker`, `paymentApiBreaker`, `s3Breaker` — separate instances with their own thresholds. If the DB is slow, auth must not fail along with it. Tune thresholds per dependency, document them in code.

> [!note] Coupling to the reliability dimension in `architecture-review`
> The reliability dimension in `architecture-review/references/dimensions-detail.en.md` §1 lists these five invariants as mandatory checks. The skeletons created here are the operationalised form of the same invariants — `/architecture-review` holds the `lib/` files and `docs/SLO.md` against the mandatory checks.

> **Issue reference:** BOO-25, Schrader Code Crash ch. 4 §Run the System (pillar 6 reliability). Counterpart to the reliability dimension in `architecture-review/references/dimensions-detail.en.md` §1.

### 4.4i Sensitive-paths configuration (BOO-18)

Ensures that code changes to sensitive paths (auth, payment, PII) trigger a **mandatory human review** — step 5.5 in the `/implement` skill blocks the commit until the operator explicitly approves. Schrader Code Crash ch. 3 §Enterprise Governance.

Operator question:

```
Configure sensitive paths for mandatory human review? (BOO-18)
  a) yes — scaffold `.claude/sensitive-paths.json` with default patterns (recommended for any project with auth/payment/PII)
  b) no — skip (default for purely experimental projects without sensitive data)
```

On `a) yes`:
- Render `.claude/sensitive-paths.json` from `references/file-templates.en.md` §`.claude/sensitive-paths.json (BOO-18)`
- Populate `{{OPERATOR_NAME}}` with the project name or the operator's GitHub handle
- Hint to the operator: extend the pattern list for project-specific sensitive paths (e.g. `src/api/**`, `stripe/**`)
- Commit the file: `git commit -m "chore: .claude/sensitive-paths.json — Mandatory Human Review Patterns (BOO-18)"`

On `b) no`: skip with log entry "BOO-18 human review: disabled".

> **Important:** `.claude/sensitive-paths.json` is NOT added to `.gitignore` — audit-trail requirement. Whoever defines sensitive paths must commit them.

> **Issue reference:** BOO-18, Schrader Code Crash ch. 3 §Enterprise Governance — "Mandatory human review for sensitive areas (authentication, payment, PII)".

### 4.5 Component skeletons (if block C = yes)

For each component from the docs architecture proposal:
- **If Obsidian layer:** `{OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Components/{component}.md`
- **If Obsidian skipped:** `{PROJECT_PATH}/docs/components/{component}.md`

Skeleton structure see `references/doc-architecture-proposal.en.md` (frontmatter + purpose + stack + architecture + configuration + phase status + connected stories + open questions + references).

All component docs get registered in `ARCHITECTURE_DESIGN.md §9 References`.

### 4.6 Install governance hooks

See `references/hooks-setup.en.md` for details.

Hooks:
- `spec-gate.sh` — blocks `git commit` with `<PREFIX>XXX` if spec file missing
- `doc-version-sync.sh` — blocks if `lib/config.js` VERSION bumped but DOC_FILES out of sync
- Optional (if block C = yes, orphan-check = yes): `orphan-check.sh` — blocks if a new `*.md` is not registered in the hub §9
- `pre-edit-bodyguard.sh` (BOO-86) — **Layer 0** PreToolUse hook on `Edit|Write`: catches secrets/unsafe patterns BEFORE the AI writes them (default warning, `BODYGUARD_STRICT=1` = hard block). Scaffolds `bodyguard/patterns/*.yml` + `SOURCES.md`. Content from `references/file-templates.en.md` §`hooks/pre-edit-bodyguard.sh (BOO-86 — Layer-0 Edit-Bodyguard)`. Registered in `settings.json` under `matcher: Edit|Write|MultiEdit` (separate matcher block, not inside the `Bash` block).
- `pre-commit` (BOO-4) — Quality-Gate Layer 2: ESLint + Semgrep with manifest reader. Reads `.semgrep.yml` (BOO-3), extracts active packs via `grep` + `sed`, builds `--config p/...` flags and invokes the Semgrep CLI. Content from `references/file-templates.en.md` §`.git/hooks/pre-commit (BOO-4 — Quality-Gate Layer 2)`. The mirroring CI Layer 3 (`semgrep.yml` workflow) is created in phase 4.4c — both layers read the same manifest.
- `dependency-check.sh` (BOO-12) — slopsquatting protection: third gate in the pre-commit hook after ESLint and Semgrep. Standalone Bash script under `.claude/hooks/dependency-check.sh` that only runs when `package.json`/`requirements.txt`/`pyproject.toml`/`Cargo.toml` is in the staged diff. Three stages: existence check (404 -> BLOCK, hallucination?), age check (package <30 days old -> warning, typosquatter risk), CVE check (`npm audit` / `pip-audit`, High/Critical -> BLOCK). With BOO-12 the `.git/hooks/pre-commit` hook from BOO-4 gets a fourth invocation at the end: `bash .claude/hooks/dependency-check.sh`. Content from `references/file-templates.en.md` §`hooks/dependency-check.sh (BOO-12 — slopsquatting protection)`. Schrader Code Crash ch. 3-4: 19.7% of AI-recommended packages do not exist. **Since BOO-197** the bootstrap additionally rolls out a project-local slopsquatting wordlist (`.claude/hooks/slopsquatting/wordlist.txt`) as an offline-capable first layer — the hook checks every new dependency against the list via `grep` before triggering the live registry query (second layer); if the wordlist is missing, only the registry query applies. A weekly workflow `.github/workflows/slopsquatting-refresh.yml` keeps the list current from public advisory sources (GHSA/OSV/OSSF) and opens a PR on change. Templates: `references/file-templates.en.md` §`.claude/hooks/slopsquatting/wordlist.txt (BOO-197 — slopsquatting wordlist)` + §`.github/workflows/slopsquatting-refresh.yml (BOO-197 — weekly wordlist refresh)`.
- `coverage-check.sh` (BOO-15) — diff coverage gate: measures coverage only on NEWLY added lines (`git diff --cached -U0`) against `coverage/coverage-final.json` (c8) or `coverage.json` (pytest-cov). Three thresholds: `>=80%` pass, `60-80%` warning with operator override, `<60%` BLOCK. Standalone Bash script under `.claude/hooks/coverage-check.sh`. **NOT** invoked from the pre-commit hook — tests take too long and would blow the 10s budget. Instead the `/implement` skill calls the hook in step 6a-quart, after the test suite has run with coverage output. Content from `references/file-templates.en.md` §`hooks/coverage-check.sh (BOO-15 — coverage gate >=80% for new code)`. Schrader Code Crash ch. 3 §Production Readiness — Gate 2: test coverage >=80% on new code, not total coverage.
- `ccusage-capture.sh` (BOO-189) — **NOT a quality gate, but a token/cost snapshot.** Standalone Bash script under `.claude/hooks/ccusage-capture.sh` that **appends** the text output of `ccusage` (via `npx --yes ccusage@latest daily`) verbatim to `docs/financials/sprint-costs.md` at sprint/story boundaries — bash-only, NO `jq`/`yq`, no JSON parsing. Invoked as a closing step of `/sprint-run`, `/implement`, and `/sprint-review` (wiring into the skills is a separate story). Never blocks a run: if `npx`/ccusage is missing, a hint snapshot is written instead of failing. The bootstrap creates the `docs/financials/` directory (phase 4.1) and scaffolds `docs/financials/sprint-costs.md` with a header. Complementary to `meta.json.token_tracking` (BOO-84, structured per-story estimate) — ccusage is the as-measured figure from the session logs. **Limitation:** ccusage may not attribute sub-agent (Task tool) tokens cleanly (issues #313/#806/#950) — the number is an approximation. Content from `references/file-templates.en.md` §`hooks/ccusage-capture.sh (BOO-189 — token/cost snapshot)`.

Registration:
```json
// {PROJECT_PATH}/.claude/settings.json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/spec-gate.sh\"" },
          { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/doc-version-sync.sh\"" }
        ]
      },
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/pre-edit-bodyguard.sh\"" }
        ]
      }
    ]
  }
}
```

> **Note:** the Claude Code harness may auto-regenerate `.claude/settings.json` on permission grants and strip hook sections. As a robust fallback: also register hooks in `.claude/settings.local.json` (gitignored).

> **Clone portability (BOO-152):** hook paths use `$CLAUDE_PROJECT_DIR` (set by the Claude Code harness to the project root) instead of an absolute path. This way the committed `settings.json` works unchanged in **every** clone/home — a prerequisite for multi-user VPS (Appendix P §3, `docs/runbooks/multi-user-vps.en.md`).

**Native pre-commit hook + `.githooks/` (BOO-152):** store the Quality-Gate-Layer-2 `pre-commit` (BOO-4) **additionally versioned** under `.githooks/pre-commit` (same content), copy `scripts/install-hooks.sh` from `references/file-templates.md` and run it once: `bash scripts/install-hooks.sh` (sets `core.hooksPath=.githooks`). This way every fresh `git clone` gets the pre-commit gate with **one** command — `.git/hooks/` is not cloned. The Claude Code runtime hooks (`spec-gate`, `doc-version-sync`, `pre-edit-bodyguard`) already come committed with `.claude/` + `settings.json`.

Hook test (dry run):
```bash
cd {PROJECT_PATH}
echo "test" > test.txt && git add test.txt
git commit -m "test: {ISSUE_PREFIX}1 — should be blocked"
# Expected: governance block
git restore --staged test.txt && rm test.txt
```

### 4.7 Create .env

If `B.5 == yes (exists)`: the operator manages `.env` — the skill only references it.

If `B.5 == no`:
```
I've created .env.example. Please fill your keys into {PROJECT_PATH}/.env.
Variable names are in .env.example.
NEVER name real keys in chat.
```

Wait for confirmation `done` before continuing.

### 4.8 Set up backlog adapter

The skill first creates the neutral Backlog Record (`docs/backlog/record-template.md` or `specs/backlog-record-template.md`, depending on project layout). The external adapter is optional.

If `BACKLOG_ADAPTER == linear`: the skill offers to create standard labels via Linear MCP:
- `architecture`, `bug`, `feature`, `refactor`, `docs`, `infra`
- Plus add-on labels: `privacy` (if Privacy activated), `compliance` (if Compliance activated)

If `BACKLOG_ADAPTER == github | jira | azure-devops | planner`: the operator gets the label/field list and mapping table for manual or adapter-assisted setup.

If `BACKLOG_ADAPTER == none`: external tool setup is `SKIP`; neutral Backlog Records remain active.

### 4.9 First git commit

```bash
cd {PROJECT_PATH}
git add -A
git commit -m "v{VERSION_START} — Initial Governance Setup"
# Push only if B.2 == yes
git push -u origin main
```

### 4.4j Audit-trail configuration (BOO-19)

Session logging is active by default in Claude Code (`~/.claude/settings.json`). This step ensures the audit-trail mechanism is anchored in the project.

**Steps:**

1. Copy `scripts/audit-trace.sh` from `intentron/bootstrap/scripts/audit-trace.sh` into the project directory:
   ```bash
   mkdir -p {PROJECT_PATH}/.claude/scripts
   cp {BOOTSTRAPPING_PATH}/bootstrap/scripts/audit-trace.sh {PROJECT_PATH}/.claude/scripts/
   chmod +x {PROJECT_PATH}/.claude/scripts/audit-trace.sh
   ```
2. The `## Session reference` block is already included in the spec template (`specs/TEMPLATE.md`) — no manual step needed.
3. Extend **GOVERNANCE.md** with a `## Audit trail` section:
   ```markdown
   ## Audit trail

   Every `/implement` session automatically writes a session reference into the spec file (BOO-19).
   Reconstruction: `bash .claude/scripts/audit-trace.sh {SPEC_ID}`

   **Retention policy (record as ADR under `docs/domain/adrs/`):**
   - Keep session logs for 90 days
   - Read access: operator only (local `~/.claude/`)
   - Sensitive prompts containing production data: avoid project scope — do not feed into `/implement`
   ```

> **Issue reference:** BOO-19, Schrader "Code Crash" ch. 3 §Enterprise Governance — "Audit trails: every prompt and every change are logged for later reconstruction."

### 4.4k Branch-protection setup (BOO-29)

Prerequisite to ensure no merge into `main` lands without green CI checks. **Runs only when `B.2 == yes`** (GitHub repo created) **and** Phase 4.9 (first git commit + `git push -u origin main`) has already executed — branch protection requires the remote `main` branch to exist.

**Steps:**

1. Copy `scripts/setup-branch-protection.sh` from `intentron/bootstrap/scripts/setup-branch-protection.sh` into the project directory:
   ```bash
   mkdir -p {PROJECT_PATH}/.claude/scripts
   cp {BOOTSTRAPPING_PATH}/bootstrap/scripts/setup-branch-protection.sh {PROJECT_PATH}/.claude/scripts/
   chmod +x {PROJECT_PATH}/.claude/scripts/setup-branch-protection.sh
   ```

2. Run the script — it reads all `.github/workflows/*.yml` dynamically and builds the `required_status_checks[contexts][]` list from each workflow's first `name:` field:
   ```bash
   cd {PROJECT_PATH}
   bash .claude/scripts/setup-branch-protection.sh
   ```

   Expected detection set depending on active workflows (phase 4.4 + 4.4c + 4.4d + 4.4g + phase 6 D.5):

   | Workflow file (BOO) | Detected context |
   |---------------------|------------------|
   | `eslint.yml` (BOO-28) | `ESLint` |
   | `ruff.yml` (BOO-28) | `Ruff` |
   | `semgrep.yml` (BOO-4) | `Semgrep` |
   | `tests.yml` / `coverage.yml` (BOO-15) | `Tests` / `Coverage` |
   | `perf.yml` (BOO-16) | `Perf` |
   | `sonar.yml` (BOO-5/D.5) | `SonarQube` (or `SonarCloud` depending on workflow) |

   Workflows that do not exist are simply omitted from `contexts[]` — the script does not hard-fail, it logs the detected workflows in `[INFO]` lines.

3. Internally the script calls (1:1 from BOO-29):
   ```bash
   gh api -X PUT "repos/${OWNER}/${REPO}/branches/main/protection" \
     -F required_status_checks[strict]=true \
     -F required_status_checks[contexts][]=<dynamic> \
     -F enforce_admins=false \
     -F required_pull_request_reviews[dismiss_stale_reviews]=true \
     -F required_pull_request_reviews[required_approving_review_count]=0 \
     -F restrictions=null \
     -F allow_force_pushes=false
   ```

   Idempotent — the PUT call is a replace, so re-runs are safe. Repeated execution overwrites the protection identically.

4. **Prerequisites the script checks itself (with operator message on failure):**
   - `gh --version` (CLI installed?)
   - `gh auth status` (logged in with `repo` scope?)
   - `git remote get-url origin` (remote present?)
   - Remote `main` branch exists (`gh api repos/<owner>/<repo>/branches/main`)

   On failure the script logs the next step clearly (e.g. `gh auth login`, `git push -u origin main`) — no silent fail.

5. Verify in the GitHub UI: `https://github.com/<owner>/<repo>/settings/branches` — protection rule should be active with the detected checks.

6. Open a test PR without green checks — the merge must be blocked.

**Fallback without `gh` (BOO-123):** If `gh` is not installed/authenticated, the automation fails — then set branch protection **manually** (applies **regardless** of the Sonar choice):
- **Recommended:** set up `gh` first (GitHub-connect runbook, HANDBUCH Appendix Y), then re-run `setup-branch-protection.sh`.
- **Or in the browser** under `…/settings/branches` → "Add rule" for `main`: **Require a pull request before merging** (1 approval), **Require status checks to pass** (pick the checks listed in the detection table from the existing workflows), **Restrict who can push**. This matches 1:1 what the script sets via the API.

> **Branch protection ≠ SonarQube (BOO-123):** branch protection is **not** coupled to SonarQube. `SonarCloud` is just **one** of several required checks derived dynamically from the workflows (see detection table). Without SonarQube, branch protection runs identically with the remaining checks (ESLint/Ruff/Semgrep/Tests/…). The "manual coercion" observed earlier came from a **missing `gh`**, not from Sonar.

If `B.2 == no/c` (no GitHub wanted): skip phase 4.4k completely — branch protection is GitHub-specific and has no equivalent on local or self-hosted setups without GitHub.

> **Issue reference:** BOO-29. Source: `scripts/setup-branch-protection.sh` (v3.18.0, 2026-05-12). Migration for existing projects: `references/migration-checklist-v1-to-v2.en.md` §BOO-29.

### 4.4l Backlog workflow states + repo integration (BOO-30/54, manual operator step)

**Run only for external backlog adapters.** For `BACKLOG_ADAPTER == none`, skip and document `SKIP` in the closing report.

**Clear separation:**
- **Automated (by /bootstrap):** Issue template is rendered in phase 4.3 with mandatory DoD section (see above). DoD checklist lives in `.claude/ISSUE_WRITING_GUIDELINES.md` v3.1 and is anchored in the issue template `.github/ISSUE_TEMPLATE/story.yml` via `migrate_boo_27()`.
- **Manual/adapter per project:** Create workflow states and repo integration in the selected tool. The neutral Backlog Record remains the framework language; the external tool is only an adapter.

**Operator instructions:** the skill lists the checkpoint and mapping here. Tool-specific details belong in adapter docs, not the framework contract.

**Workflow states (1:1 from BOO-30):**

| State | Meaning | Auto transition |
|---|---|---|
| Backlog | Triage | initial |
| In Progress | Skill working, local gates iterating | manual |
| In Review | PR open, CI running | auto on PR open |
| QA Failed | CI red, story re-opened | manual or webhook |
| Done | PR merged, all checks green | auto on PR merge |
| Cancelled | Discarded | manual |

**Adapter mapping:**

| Adapter | External ID | State mapping | Repo integration |
|---|---|---|---|
| Linear | Linear key optional, framework ID remains `{ISSUE_PREFIX}XXX` | Workflow states in the team | GitHub integration in Linear |
| GitHub Issues | Issue number optional | Labels/Projects or issue status | native in repo |
| Jira | Project key optional | Jira workflow | Development integration |
| Azure DevOps | Work item ID optional | Boards state | Repos/Pipelines link |
| Planner | Task ID optional | Buckets/labels | manual |
| none | only `{ISSUE_PREFIX}XXX` | Markdown status | none |

**Repo integration (if supported by the adapter):**
1. Connect the adapter to the project repo.
2. Auto-recognition kicks in for:
   - branch names with `{ISSUE_PREFIX}-XX` prefix (e.g. `BOO-30-feature-foo`)
   - PR titles with `{ISSUE_PREFIX}-XX`
   - commit messages with `{ISSUE_PREFIX}-XX`
   - PR body with `Closes {ISSUE_PREFIX}-XX`
3. PR-open transitions issue → `In Review`, merge transitions issue → `Done`.

**Operator checkpoint:**
- [ ] 6 workflow states created in the backlog adapter or justified as `SKIP` (exact names: `Backlog`, `In Progress`, `In Review`, `QA Failed`, `Done`, `Cancelled`)
- [ ] Repo integration connected to the project repo or justified as `SKIP`
- [ ] Test story with branch `{ISSUE_PREFIX}-XX-test` created — PR open transitions the issue to `In Review`

> **Issue reference:** BOO-30/54. Source: `references/issue-writing-guidelines-template.md` v3.1 + neutral Backlog Record. Migration for existing projects: `references/migration-checklist-v1-to-v2.en.md` §BOO-30 (issue-template extension is auto-applied, tool-adapter setup remains project-specific).

### 4.4m Token-Efficiency Setup (BOO-84)

**Purpose:** activates per-skill model routing and prompt caching for the new project. Follows the lightweight-design decision: recommendation, not hard lock, operator override always possible.

**Steps:**

1. **Insert Model-Routing section into `CLAUDE.md`.** The template in `references/file-templates.en.md` §`CLAUDE.md (minimum)` already contains the sections "Model-Routing Policy (BOO-84)" and "Prompt Caching (BOO-84)" — auto-included on render.
2. **Reference `model-tiers.json`.** The central mapping `bootstrap/references/model-tiers.json` is framework-owned and is NOT copied into the project. Skills read it via framework path. Operator finds it via `intentron/bootstrap/references/model-tiers.json` when in doubt.
3. **Extend `meta.json` schema.** Implement skill (step 6f-bis) now writes additional fields: `input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`, `model_used`, `skill_invoked`, `story_id`, `iteration_label`, plus `override_audit: []` array for override entries. See `implement/SKILL.en.md` §6f-bis.
4. **Document override precedence.** Operator is informed in the briefing: **CLI flag `--model <tier>` > CLAUDE.md `model_overrides:` > skill default tier**. Each override writes an audit-trail entry.
5. **Document Mandatory-Opus.** Security-relevant skills (`architecture-review`, `cloud-system-engineer`, `/implement` step 6e) must not auto-downgrade. Operator override possible but logged in the audit trail — audit argument for FINMA/BaFin/MaRisk.

**Operator checkpoint:**
- [ ] `CLAUDE.md` contains section "Model-Routing Policy (BOO-84)"
- [ ] `CLAUDE.md` contains section "Prompt Caching (BOO-84)"
- [ ] Operator knows `bootstrap/references/model-tiers.json` (framework path) is the source of truth for tier-to-version + pricing
- [ ] `meta.json` is extended with the new fields on the first `/implement` run (automatic via skill)

> **Issue reference:** BOO-84. Source: `references/file-templates.en.md` §`CLAUDE.md (minimum)`, `references/model-tiers.json`. Migration for existing projects: `references/migration-checklist-v1-to-v2.en.md` §BOO-84.

> **Design-decision note:** This story follows the INTENTRON motto "lightweight + pragmatic, no security compromises". Model routing is a recommendation with an override path — not a hard lock. Security skills stay documented on Opus (audit obligation).

### 4.4n Privacy Setup (BOO-69, only if Privacy add-on active)

**Purpose:** When the Privacy add-on is active (see A.4 `[x] Privacy / GDPR`), this phase sets up the privacy infrastructure. Mirrors the Security pattern 1:1: `dpo` standalone skill installed, `PRIVACY.md` rendered from template, `personal-data-paths.json` created as counterpart to `sensitive-paths.json`. Bootstrap adds nothing if the add-on is not active.

**Precondition:** `ADDONS` contains `"Privacy / GDPR"`. Otherwise skip.

**Steps:**

1. **Install DPO skill from the framework bundle** (BOO-74, analogous to `security-architect`):
   - Source: `$SKILL_SRC/dpo/` (framework repo, already cloned in Phase 5). Target: `~/.claude/skills/dpo/` (global) or `{TARGET_SKILLS_DIR}/dpo/` per `RUNTIME_TARGET`. Non-destructive: existing installation remains unchanged.
   - No external repo choice anymore — the skill comes from the same framework repo as bootstrap/ideation/implement. The skill's master remains `claudecodeskills` (mirror convention, see `references/skills-setup.en.md`).
   - Note: DPO remains **simultaneously** globally available for other projects. INTENTRON makes no exclusive claim.
2. **Install security-architect from the framework bundle** (prerequisite for DPO ↔ security-architect interplay) — same source `$SKILL_SRC/security-architect/`.
3. **Render `PRIVACY.md`** from `references/privacy-template.md` (DE) or `.en.md` (EN) depending on project language. Replace placeholders `{{PROJECT_NAME}}`, `{{VERSION_START}}`, `{{TODAY}}`. Mandatory sections (records of processing, deletion policy) receive a skeleton — operator fills in.
4. **Render `.claude/personal-data-paths.json` and/or `.codex/personal-data-paths.json`** from `references/file-templates.md` §`personal-data-paths.json`. Default patterns (`**/user*`, `**/customer*`, `**/profile*`, `**/*pii*`, `**/auth/profile/**`, `**/billing/**`). Operator hint: extend the pattern list project-specifically.
5. **Backlog label `privacy`** in the configured backlog adapter (Linear / GitHub Issues / MS Planner / Markdown backlog), create if not yet present.
6. **`ARCHITECTURE_DESIGN.md`** extend with privacy-section reference: "Privacy requirements: see `PRIVACY.md` and DPO skill output under `dpia/`."
7. **`environment.json`** extend with optional field `privacy_audit_cadence: 4` (default: DPO audit every 4 sprints).

**Operator checkpoint:**

- [ ] DPO skill globally available (`~/.claude/skills/dpo/SKILL.md` exists)
- [ ] security-architect skill globally available
- [ ] `PRIVACY.md` rendered in project root with project placeholders
- [ ] `.claude/personal-data-paths.json` and/or `.codex/personal-data-paths.json` created
- [ ] Backlog label `privacy` exists
- [ ] `ARCHITECTURE_DESIGN.md` references `PRIVACY.md`
- [ ] `environment.json.privacy_audit_cadence` set (default 4)

> **Important:** `PRIVACY.md` is NOT added to `.gitignore` — audit-trail obligation. Privacy documentation belongs in git. **`dpia/*.md`** may be more sensitive — the operator decides whether the DPIA files are committed or kept in a separate private repo.

> **Issue reference:** BOO-69. Source: `references/privacy-template.md` + `references/file-templates.md` §`personal-data-paths.json`. Migration for existing projects: `references/migration-checklist-v1-to-v2.md` §BOO-69. HANDBUCH background: Appendix O Privacy by Design.

> **Design-decision note:** Privacy is optional, but when active: fully operationalised. Mirrors the Security pattern (security-architect + SECURITY.md + sensitive-paths). The operator does not need to bring DPO knowledge — the skill asks the right probing questions. Issuing legal recommendations is not the skill's job; probing questions are.

### 4.4o Financials Setup (BOO-190, only if Financials activated)

**Purpose:** when `FINANCIALS = yes` (see A.9), this phase creates the Financials/ROI templates and writes the billing rate captured in A.9 into the baseline. Analogous to Privacy Setup (4.4n): template generation + initial fill, no runtime calculator. Bootstrap adds nothing if `FINANCIALS = no`.

**Precondition:** `FINANCIALS == yes`. Otherwise skip.

**Steps:**

1. **Create templates** under `docs/financials/` in the target project: `budget.md` (project budget template) + `worker-equivalent-baseline.md` (billing rate + geo defaults). Both are the canonical template sources in the framework repo (analogous to `sprint-costs.md`, BOO-189). `sprint-costs.md` (BOO-189) is not replaced — `budget.md` references it alongside.
2. **Write the active billing rate** into `worker-equivalent-baseline.md` section 1 from the A.9 values:
   - `geo` = `FINANCIALS_GEO`, `currency` = `FINANCIALS_CURRENCY`, `rate_per_hour` = `FINANCIALS_RATE`.
   - `source` = `FINANCIALS_SOURCE` (`intern` on input, otherwise `market-research-2026`).
   - `erhebungsjahr` accordingly (intern: year of the internal rate; market-research: `2025`).
   - **Internal precedence** is already resolved in A.9 — here just write, do not mix again.
3. **Pre-fill `budget.md` project assumptions** (geo/currency/rate_per_hour) with the same values; the reference to `worker-equivalent-baseline.md` (active rate) and `sprint-costs.md` (actuals, BOO-189) is already in the template.
4. **Native-currency rule** stays untouched as documented in the baseline template (no FX cross-conversion, only a >5% notice) — bootstrap writes no conversion.

**Operator checkpoint:**

- [ ] `docs/financials/budget.md` present in the project
- [ ] `docs/financials/worker-equivalent-baseline.md` present in the project
- [ ] Baseline section 1 filled with the active rate (`geo` / `currency` / `rate_per_hour` / `source` / `erhebungsjahr`)
- [ ] `budget.md` project assumptions pre-filled with the same values

> **Issue reference:** BOO-190. Source: `docs/financials/budget.md` + `docs/financials/worker-equivalent-baseline.md` (template SSoT in the framework repo). Consumers: BOO-191 (`/sprint-review` report), BOO-192 (`/backlog` forecast), data source dual column BOO-193. HANDBUCH background: Appendix AK.

> **Design-decision note:** Financials is optional, but when active: a lightweight template generator (design principle 2026-05-25) — no runtime calculator, no external tooling. The baseline numbers come from the internal deep research, not from fabricated rates. ROI language stays internal for now (ADR-D §Open) until ≥3 sprints of data exist.

### Phase 4.10: Domain Deep Research (MANDATORY)

**Purpose:** persist domain knowledge before stories get written. AI operator teams have no distributed subject-matter team knowledge — this step compensates systematically (Schrader ch. 2 §Differentiation crisis).

> **Skill source (BOO-219):** `/research` is a **vendored bundle skill** living directly in the `intentron` repo (in the Minimum set, Phase 5). This makes the mandatory phase fulfillable without an external repo dependency — no `claudecodeskills` clone needed.

**Steps:**

1. Ask the operator: "Which industry / which subject-matter domain context applies to this project?"
2. Invoke `/research` with the project topic — DEEP mode:
   - Domain terminology + glossary
   - Regulation (GDPR/BDSG/nDSG, PSD2, MiFID, HIPAA — depending on industry)
   - User personas + stakeholders
   - Industry metrics + KPIs
   - Competitors + market standards
3. Write the output to `Research/Domain-Overview.md` (frontmatter: `source: claude`, `type: domain-research`)
4. Create the `docs/domain/` folder with a `README.md` skeleton:

```markdown
# Domain Context

Curated key terms for [project name]. One term per file under `docs/domain/`.
Format: 1 file per key term, <30 lines, examples + counter-examples.

## Known terms
<!-- Extended during /ideation and /implement -->

| Term | File | Description |
|------|------|-------------|
```

5. For each key term from the research, create its own file: `docs/domain/{term}.md`
   Template per term file:
   ```markdown
   # {Term}

   **Definition:** [1–2 sentences]

   **Example:** [concrete real-world example]

   **Counter-example / delimitation:** [what it is NOT]

   **Regulation:** [if relevant — norm/law + core obligation]
   ```

**Not optional.** Even if the operator says "I know the industry": the research step costs 5–10 min and saves hours of story rework later from missing subject-matter vocabulary.

Phase 4 checkpoint: summary of files created.

---

## Phase 5: Install skills

Read `references/skills-setup.en.md` for details.

Skills are fetched from the **framework repo** via `git clone` into a temp folder and copied according to `RUNTIME_TARGET`:
- `claude-code` → `{PROJECT_PATH}/.claude/skills/`
- `codex` → `{PROJECT_PATH}/.codex/skills/`
- `cross-tool` / `unknown` → both target paths, identical skill revision

```bash
# Temp folder for skill source — framework repo (BOO-74: all bundle skills + dpo + security-architect live here)
SKILL_SRC=$(mktemp -d)
git clone --depth 1 https://github.com/vibercoder79/intentron "$SKILL_SRC"
```

> **Operator note (BOO-121):** Keep the local `bootstrap` skill current (`git pull` in the intentron clone). A stale version may still source bundle skills (esp. `intent`) per the **pre-BOO-74 structure** from `claudecodeskills` — today all bundle skills come **exclusively from intentron**. Regression guard: `bootstrap/scripts/check-skill-sources.sh` (CI: `skill-sources.yml`).

### Repo structure (BOO-74)

The `intentron` repo holds **all** bundle skills flat as top-level folders — no more `intentron/` nesting (that was the old `claudecodeskills` structure):

- **`$SKILL_SRC/<skill>/`** — all framework skills: `architecture-review`, `backlog`, `bootstrap`, `cloud-system-engineer`, `grafana`, `ideation`, `implement`, `intent`, `knowledge-onboarding`, `pitch`, `sprint-review`, `visualize` **plus `dpo`, `security-architect` and `research`** (vendored, BOO-74/219). `knowledge-onboarding` is existing-doc-onboarding (BOO-137) — install only, no auto-run. `research` is the engine of the mandatory Phase 4.10 (Domain Deep Research) and has lived in the bundle since BOO-219, so a single `git clone` is self-contained.

**Not in the framework repo:** `setup-checklist` is its own public repo (BOO-113). `design-md-generator` and `skill-creator` stay global/standalone and are not sourced by the framework — no optional claudecodeskills clone question in bootstrap anymore (BOO-219).

> **Master vs. mirror (BOO-74/219):** `dpo`, `security-architect` and `research` are maintained in the `claudecodeskills` repo (master, via `publish_skill.py`) and **mirrored** into the framework repo (vendoring). On a skill update: update the master in `claudecodeskills` first, then refresh the framework mirror. Details: `references/skills-setup.en.md` §sync convention.

### Skill selection

```
Which skills to install?
  a) Minimum (ideation, implement, backlog, intent, research)
  b) Standard (+ architecture-review, sprint-review, security-architect, dpo, knowledge-onboarding)
  c) Full (all framework skills: + grafana, cloud-system-engineer, visualize, pitch)
  d) Manual selection
```

> **Note (BOO-69/74):** `dpo` and `security-architect` are included from "Standard" up, because the Privacy add-on (A.4) and the security dimension depend on them. With the Privacy add-on active, both are installed regardless of the skill selection (see Phase 4.4n).

### Copy

All framework skills are flat top-level folders — no sub-folder distinction needed anymore:

```bash
for skill in $SELECTED_SKILLS; do
  SRC_PATH="$SKILL_SRC/$skill"   # framework repo: everything top-level
  # Derive target paths from RUNTIME_TARGET:
  # claude-code => .claude/skills
  # codex => .codex/skills
  # cross-tool/unknown => both
  cp -R "$SRC_PATH" "{PROJECT_PATH}/{TARGET_SKILLS_DIR}/$skill"
done
```

Result: all skills land **flat** in `.claude/skills/<skill>/` and/or `.codex/skills/<skill>/`.

### Project-specific adjustments (generic, not trading-specific)

- `.claude/ISSUE_WRITING_GUIDELINES.md` is rendered from `references/issue-writing-guidelines-template.md` (issue prefix substituted)
- `implement/references/change-checklist.md` contains generic change types — no project-specific adjustment needed. Project-specific specialist checklists can later be packaged via `/skill-creator`.

### Cleanup

```bash
rm -rf "$SKILL_SRC"
```

Phase 5 checkpoint: list the installed skills.

---

## Phase 6: Block D — Optional components

Read `references/optional-components.en.md` for implementation details.

> **Operator note (BOO-30/54):** Block D is the right place to finalize the manual backlog adapter from phase 4.4l — create workflow states + activate repo integration — before the first stories are produced via `/ideation`. Issue-template rendering itself is already automated in phase 4.3 (mandatory DoD section). With `BACKLOG_ADAPTER=none`, the neutral Backlog Record remains the leading form.

Ask each question individually with a clear recommendation and default:

### D.1 Self-healing agent

```
Set up self-healing agent?
(Cron every 15 min: checks doc versions, file integrity, sends alerts)

Recommended: from multiple contributors on, or when docs drift is critical.
[yes / no (default)]
```

On `yes`: render `agents/self-healing.js` from `references/self-healing-template.js` + generate cron entry.

### D.2 DocSync to the Obsidian vault

```
DocSync to the Obsidian vault?
(On every /implement, component docs in the vault are also updated)

No cron — runs as manual trigger via implement-skill T_last.
Recommended if an Obsidian vault is configured.
[yes (default if vault set) / no]
```

On `yes`: render `lib/doc-sync.js` from `references/doc-sync-template.js` + mapping repo → vault.

### D.3 Automation daemon (backlog webhook listener)

```
Automation daemon?
(Fully automatic story execution without operator approval — backlog adapter webhook triggers /implement)

Only for advanced setups with an external backlog adapter. Mind the security implications.
[yes / no (default)]
```

On `yes`: setup steps for the matching adapter webhook + daemon.

### D.4 Learning-loop level

Read `references/learning-loop.en.md` for the full design.

```
Activate learning loop?
The loop systematically captures: what worked, what didn't, next experiments.
Trigger: /sprint-review. Storage: journal/ + optional Obsidian.

  L1 — Simple       (learnings.md, bullets — recommended for solo projects)
  L2 — Structured   (sprint journal with frontmatter — recommended from 10+ sprints)
  L3 — SQLite       (quantitative metrics — recommended from 50+ sprints)
  no                (no lessons-learned documentation)

Default: L1. Which level?
```

If `L1/L2/L3` selected:
- Create `journal/` structure accordingly
- `.learning-loop` config in the repo (stores the level)
- If Obsidian active: `04 Ressourcen/{PROJECT_NAME}/learnings.md` as a cross-link from the PMO hub

The learning loop is fed by `sprint-review` (mandatory step at the end of the review) and read by `ideation` during story creation (anti-pattern warning).

### D.4b MEMORY.md header — Automemory boundary (BOO-200, ADR-3)

Prepend a boundary header to the operator-local automemory index file so project knowledge does not wrongly end up in automemory (boundary: ADR-3, HANDBUCH Appendix AM). Automemory lives at `~/.claude/projects/<project>/memory/MEMORY.md` (Claude Code convention: project path with `/` → `-`).

Non-destructive: existing index lines stay; the header is only prepended when the marker `automemory-vs-learning-loop:` is still missing. Header content (the `migrate` script writes the German variant; both carry the same marker):

```
<!-- automemory-vs-learning-loop: ADR-3 / BOO-200 -->
> **Operator-local automemory** — style, tool config, personal triggers. NOT in the repo.
> Project knowledge (story patterns, anti-patterns, architecture lessons) belongs in the **Learning-Loop**: `journal/learnings.md`. Boundary: ADR-3.
```

Existing projects pull the header via `intentron migrate` (`migrate_boo_200`); `verify-setup.sh` §4c checks its presence.

### D.5 SonarQube Cloud

```
Activate SonarQube Cloud?
(Code-quality dashboard: bugs, smells, security hotspots, coverage trends after every push)

Cost: public repos free. Private repos from ~10 EUR/month.
[Mac] Local: SonarLint VS Code connected mode.
[VPS] CI gate only — no IDE plugin.

[yes] Skill generates sonar-project.properties + .github/workflows/sonar.yml
[no] (default) — can be added later
```

On `yes`: read `references/optional-components.en.md §D.5` for implementation details including the verify step. **The SonarCloud side (account/org/token) is manual** — step by step in the **SonarCloud setup runbook (HANDBUCH Appendix AA, two scenarios)**; the first `git push` triggers `sonar.yml`.

> ⚠️ **Warning on `yes` (BOO-122):** With `sonar.yml`, **`SonarCloud` automatically becomes a required status check** (branch protection, phase 4.4k, builds the checks dynamically from all workflows) — **no green Sonar run, no merge**. If the account/token is missing, the job fails red and **your first PR is blocked**. Therefore:
> - **Set it up now:** walk through the SonarCloud setup runbook (BOO-119, HANDBUCH **Appendix AA**, two scenarios) (account/org/token + `SONAR_TOKEN` secret), **then** `yes`.
> - **Or enable later:** pick `no` for now; Sonar can be added anytime.
> - **Remove Sonar again** (if already scaffolded): delete `.github/workflows/sonar.yml`, set `tools_available.sonarqube_cloud = false`, re-run branch protection (`setup-branch-protection.sh` — `SonarCloud` then drops out of the required checks).
>
> **Optional question:** "Do the Sonar setup now — or just **scaffold without** the required check (create `sonar.yml`, but only add it to branch protection after the first green run)?"

On `no`: `tools_available.sonarqube_cloud = false` in `.claude/environment.json`.

### D.6 Self-hosted runner (BOO-46, only when the performance gate is active)

If `STACK_CHOICE` has a backend share (`a`, `c`, `d`) AND BOO-16's performance gate is active:

```
Activate a self-hosted runner for performance tests?
  (Follow-up to BOO-16. GitHub-hosted runners carry ±30%% variance, hence
   BOO-16's default 20%% threshold. A self-hosted runner with reserved
   resources cuts variance to ~5%% — the threshold can then tighten to 10%%.)

  Cost: a Hostinger VPS sidecar or a dedicated Mac mini.
  Effort: install runner software (step-by-step in HANDBUCH Appendix I).

  [yes] HANDBUCH §Self-hosted runner setup with step-by-step + migrate_boo_46() tightens perf.yml
  [no] (default) — GitHub-hosted stays active, threshold stays at 20%%
```

On `yes`: pure HANDBUCH pointers (no auto-setup, because VPS installation is operator territory). `migrate_boo_46()` patches `perf.yml` later (`runs-on: ubuntu-latest` -> `self-hosted`, threshold 1.20 -> 1.10) once the operator has installed the runner.
On `no`: no entry in `environment.json`, no perf.yml patch.

### D.7 Project-specific MCP servers (BOO-125, only when STACK = Frontend/Full-stack)

When `STACK_CHOICE = b` (frontend) or `c` (full-stack):

```
Set up further project-specific MCP servers?
  Suggestion for web/frontend: Vercel, Apify — or name your own source.
  [yes / no (default)]
```

On `yes`:
- Register the chosen MCP servers per `references/mcp-setup.en.md` (endpoint / auth / scope).
- Note: the **consuming story/skill** declares the MCP in its `requires_toolsets` block (HANDBUCH §requires_toolsets) — the bootstrap only sets up the server, not its usage.
- Add to `tools_available` in `.claude/environment.json` accordingly (read by `verify-setup.sh`).

**Vercel clarification (common confusion):**
- **Deploy** runs via the **Vercel↔GitHub integration** (git push → auto-deploy) — **no** MCP needed.
- The **Vercel MCP** is only for **agent interaction**: read/analyze deployment logs / env / config. Optional.

**Frontend combo:** "Node backend + frontend" maps cleanly onto `c) Full-stack` (backend + frontend in one project) — no separate combo path needed. `b) Frontend` is the pure frontend without its own backend.

On `no`: no MCP entry; project-specific MCPs can be added later anytime via `references/mcp-setup.en.md`.

Phase 6 checkpoint: optional-components status including provider postflight and intentionally deselected options.

---

## Phase 7: Finalization

Read `references/global-registry-update.en.md` for the exact path list.
Read `references/project-documentation-ssot.en.md` for the SSoT variants. Phase 7 finalizes not only SecondBrain, but always the selected project documentation SSoT.

### 7.1 Finalize project documentation SSoT

- `obsidian`: create or confirm `{OBSIDIAN_VAULT}/<project-area>/{PROJECT_NAME}/`.
- `repo-docs`: create `{PROJECT_PATH}/docs/project/`.
- `external-dms`: create `{PROJECT_PATH}/docs/project/DOCUMENTATION_SSOT.md` with URL/path and access notes.
- `undecided`: create `{PROJECT_PATH}/docs/project/` as fallback and add a TODO for the final SSoT.

Create or link standard artifacts:

- Project Hub / PMO Hub
- Developer Onboarding
- Project Governance
- Target Architecture
- Backlog overview or backlog reference
- `Decisions/`, `Meetings/`, `Research/`, `Assets/`, `Archive/`

### 7.2 SecondBrain integration (if Documentation SSoT == Obsidian)

- Create `{OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/`
- `{PROJECT_NAME} - PMO HUB.md` with project frontmatter, phase table, backlog link, references block
- Create or link `Developer Onboarding.md`, `Projekt-Governance.md`, `Zielarchitektur.md`, `Backlog.md`
- Create `Components/`, `Decisions/`, `Meetings/`, `Research/`, `Assets/`, `Archive/` folders
- `Architektur-Vorgaben.md` skeleton (populated by /ideation during research consolidation)
- Entry in `{OBSIDIAN_VAULT}/00 Kontext/Projekte.md` (project index)

### 7.3 Global registry (~/.claude/)

If the operator has a project table in `~/.claude/CLAUDE.md`:
- Add the project row (name, path, GitHub, Obsidian path, sprint-review frequency)
- The skill presents the row; the operator confirms the insertion point

### 7.3b Setup verification (BOO-79)

Before the final commit, deliver the **proof** that the scaffold is complete and functional:

1. Copy `references/verify-setup.sh` to `{PROJECT_PATH}/scripts/verify-setup.sh` (if not already done in Phase 4).
2. Run it in the project root: `bash scripts/verify-setup.sh`.
3. The script checks read-only: environment.json, toolchain reachability, git hooks (per repo!), core artifacts (CONVENTIONS.md, ARCHITECTURE_DESIGN.md, specs/, journal/), privacy add-on (if active), backlog adapter. Output PASS/WARN/FAIL + exit code (1 on FAIL).
4. **Fix FAIL items before finishing.** Present WARN items to the operator (often intentional, e.g. no test framework in a docs project).

> **Doc-drift check (BOO-229):** also copy `references/doc-drift-check.sh` to `{PROJECT_PATH}/scripts/doc-drift-check.sh` and run `bash scripts/doc-drift-check.sh` — read-only, checks the doc map against reality, using `ARCHITECTURE_DESIGN.md §References` + `INDEX.md` as the **single source of truth**: (1) **completeness** (every registered file exists; expected artifacts are registered), (2) **freshness** (`ARCHITECTURE_DESIGN.md` not older than `thresholds.architecture_doc_freshness_days`), (3) **local-vs-remote** (`git fetch` comparison against `origin`). **Warn-only at this stage** — the operator reviews WARN/FAIL, no abort; `/implement`, `/ideation` and `/architecture-review` call the same script in their pre-flight. The compliance **hard gate** (skill blocks on drift) is an opt-in add-on and lands as BOO-229 B2. Boundary: this is the **project** script — the repo-internal `.github/scripts/docs_drift_check.py` checks the framework repo itself. Background: HANDBUCH Appendix AS.

**Tool-install guidance for missing tools (BOO-115):** When `verify-setup.sh` (or the pre-flight gate, phase 0.2) reports a missing tool, the bootstrap emits **tool name + deeplink** — not just a WARN — and uses the `INSTALL_DEFAULT` from A.7:

- **`INSTALL_DEFAULT = system`** (solo-mac): direct install → HANDBUCH **Appendix Y.2 "Install the toolchain"** (language-matched DE/EN). Order: first `bash .claude/generate-environment-json.sh --force` (flips the tool flag false→true), **then** `bash scripts/verify-setup.sh`.
- **`INSTALL_DEFAULT = docker`** (VPS/factory/team): golden image → HANDBUCH **§Container profile (BOO-81)**. **Docker preflight:** `docker --version` → present: copy/build the container profile; missing: HANDBUCH pointer "install Docker (Linux/Mac)". Order: inside the container only `bash scripts/verify-setup.sh` is needed — `postCreateCommand` already calls `generate-environment-json.sh --force`.
- **Scaffold-only:** the bootstrap does NOT install the tools itself (exception: `c8` as a dev dep); it only points to the right guide. The operator picks system vs. Docker (default = `INSTALL_DEFAULT`, overridable).

5. The result feeds the closing table (7.5).

Manual variant / background: HANDBUCH Appendix T "Post-install verification" (point-by-point checklist).

### 7.3a Post-install quality-gate audit (BOO-183)

As the last verification step before the final commit: run `/quality-gate-audit --trigger post-install`.
It produces the **baseline report** under `docs/audits/YYYY-MM-DD-quality-gate-audit.md` and checks
whether the just-rolled-out gates (Semgrep wiring incl. the `.semgrep/` canary, coverage,
slopsquatting wordlist, Layer-0 bodyguard) are actually **wired** — not just nominally configured.
`verify-setup.sh` checks that files exist; the quality-gate audit checks that they actually bite
(signal test). The baseline report is committed along with 7.4; `docs/audits/` is excluded from the
docs-drift check. If a gate is `blind`, fix it before the first `/sprint-run` (the pre-sprint hard hook
in `sprint-run` step 1 would otherwise stop). Details: skill
[quality-gate-audit](../quality-gate-audit/SKILL.en.md).

### 7.4 Final commit

```bash
cd {PROJECT_PATH}
git add -A
git commit -m "v{VERSION_START} — Complete Governance Bootstrap"
git push  # only if B.2 == yes
```

### 7.5 Closing table

The closing report uses one postflight status model:

| Status | Meaning |
|--------|---------|
| `OK` | created, verified, or consciously confirmed as active |
| `WARN` | created, but with follow-up work/risk/missing external verification |
| `SKIP` | intentionally not relevant or deselected by the operator |
| `FAIL` | should have been set up, but failed or is blocked |

| Phase | What | Status | Note |
|-------|------|--------|------|
| Block A | Project core + stack + runtime + add-ons | OK/WARN/FAIL | name `RUNTIME_TARGET`, `GOVERNANCE_MODE`, `EXECUTION_ISOLATION` |
| Block B | Existing infrastructure | OK/WARN/FAIL | only reference existing paths/remotes, do not overwrite |
| Block C | Project documentation SSoT + docs architecture | OK/SKIP/WARN | report Obsidian/repo/DMS/fallback separately |
| Phase 4 | Base structure (files, git, linting, hooks, Backlog Record) | OK/WARN/FAIL | baseline artifacts must not be missing |
| Phase 5 | Skills installed ({skill_count}) | OK/WARN/FAIL | name target path `.claude/skills` and/or `.codex/skills` |
| Block D | Optional components | OK/SKIP/WARN/FAIL | list every selected option separately |
| Phase 7 | SecondBrain + registry + final commit | OK/SKIP/WARN/FAIL | verify external providers separately |

Mandatory closing checks:
- Do not write secrets into repo files, chat, `.env.example`, logs, or the closing report.
- Project documentation SSoT is selected or documented as fallback with TODO.
- Project Hub, Developer Onboarding, Governance, Target Architecture and Backlog reference exist or are clearly linked.
- Runtime instructions contain SSoT and Developer Onboarding as required reading.
- Story-spec template contains the Developer-Onboarding Pre-Flight.
- Verify external providers separately and do not mark them `OK` just because local files exist: GitHub, Linear, Jira, Azure DevOps, Planner, SonarQube, Grafana, Telegram, Obsidian sync.
- Print the provider postflight matrix from `references/provider-postflight.en.md`: GitHub, backlog, Research, Visualize/Miro, Monitoring, Obsidian.
- Document the upgrade principle: existing skills/artifacts remain; migrations add missing baseline and tighten gates, they do not delete project-specific customizations without explicit operator approval.

### 7.5a Upgrade mode for existing projects (BOO-60)

If Bootstrap runs in a project with an existing framework installation, **do not bootstrap from scratch**. Read `references/framework-upgrade.en.md` and ask:

```
Existing framework installation detected. Which upgrade mode?
  a) inspect — show differences only, write no files
  b) apply-safe — add only new files/missing sections
  c) apply-with-confirmation — confirm potentially overwriting changes one by one
```

Rules:
- `inspect` writes no project files.
- `apply-safe` overwrites no existing content.
- `apply-with-confirmation` requires operator approval per risky file.
- `.env`, secrets, local reports, and session files are never changed.
- The upgrade report is produced as closing output and can optionally be stored under `journal/reports/framework-upgrade/YYYY-MM-DD.md`.

### 7.5 VS Code extensions (optional, based on STACK_CHOICE)

**For all stacks:**
- ESLint `dbaeumer.vscode-eslint`
- SonarLint `SonarSource.sonarlint-vscode`
- Error Lens `usernamehw.errorlens`
- Claude Code `anthropic.claude-code`

**Node.js:** REST Client `humao.rest-client`

**Frontend / Full-stack:** Prettier `esbenp.prettier-vscode`, Auto Rename Tag `formulahendry.auto-rename-tag`, CSS Peek `pranaygp.vscode-css-peek`

**Python:** Python `ms-python.python`, Black Formatter `ms-python.black-formatter`, Ruff `charliermarsh.ruff`

### 7.6 Next steps

```
Bootstrap done. Continue with:

  1. Install VS Code extensions (list above)
  2. Start runtime: Claude Code (`cd {PROJECT_PATH} && claude`) or Codex in the project path
  3. /ideation or the matching Codex invocation — create your first story
  4. If learning loop active: run /sprint-review after 1–2 sprints
  5. Check the setup anytime: `bash scripts/verify-setup.sh` (`--strict` for CI) — read-only, PASS/WARN/FAIL. Details + sketch: HANDBUCH Appendix T.
  6. Fill SECURITY.md: run `security-architect` (DESIGN) — threat model (STRIDE) + mitigations (especially for governance standard/heavy).
  7. If existing docs / preliminary material present (block-B flag `bestands_doku_erkannt: true` or operator knows): run `/knowledge-onboarding` — routes GAP analyses, research, design files, plan, README etc. deterministically into the governance artefacts (rubric + manifest). Details: knowledge-onboarding/SKILL.en.md (BOO-137).
  8. Logging/monitoring a requirement? → enter the requirements in `observability.md` so `ARCHITECTURE_DESIGN.md` picks them up (runbook: docs/runbooks/logging-monitoring.md, concept: HANDBUCH §8d-ter).
  9. Want to set up routines? → see runbook `docs/runbooks/routinen-vernetzen.en.md` (3 setups + 7 routines with copy-ready prompts; switch C, ADR-2). Bootstrap deliberately does NOT ask for routines defaults.
  10. Infra layers (BOO-221): The §5b infra-layer table in `ARCHITECTURE_DESIGN.md` holds the 13 layers + references to the question/risk catalog (rows start at `n.ok`). If the default standards are fine → just start coding (lazy-fill, no obligation). Own/corporate rules per layer → run `/infrastructure-onboarding` (BOO-223) later for the guided reconciliation. `/architecture-review` finds open layers anyway.
```

> **Fill SECURITY.md (BOO-136):** the bootstrap scaffolds `SECURITY.md` only as a **skeleton**. `security-architect` (DESIGN mode) fills it based on the **STRIDE/OWASP review questions** — the operator needs no security expertise; the skill asks the questions.

> **Setup self-check anytime (BOO-128):** `verify-setup.sh` is read-only and independent of the `/implement` trial — the operator checks the setup themselves anytime. Ready-made prompt: "run `verify-setup.sh` and explain the WARN/FAIL items to me". Background + sketch: HANDBUCH Appendix T "Post-install verification".

> **Check the GitHub connect proactively when GitHub is in scope (BOO-123):** before you start, check `gh auth status` (CLI/API) **and** `git remote -v` (push path: HTTPS-via-`gh` or SSH) — branch protection needs both auth layers (`gh auth` ≠ `git auth`). Runbook: HANDBUCH Appendix Y "GitHub connect per VPS".

---

## Error handling

| Problem | Solution |
|---------|----------|
| git push fails | Check SSH key: `ssh -T git@github.com` |
| Backlog adapter error | Check adapter credentials/project key; with `none`, use only the local Backlog Record |
| Obsidian path unreachable | Verify path with `ls`, check if iCloud sync is active |
| Hook blocks commit | Create spec file from `specs/TEMPLATE.md`, fill agent pattern |
| doc-version-sync blocks | Update all DOC_FILES to the new VERSION, then `git add` |
| Harness strips hooks from settings.json | Register hooks additionally in `.claude/settings.local.json` (gitignored) as fallback |
| Component doc missing after /implement | Check T_last task in specs/TEMPLATE.md — must include component update |
| Learning-loop entry forgotten | Call /sprint-review again, run step 7 |
