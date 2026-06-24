<a name="english"></a>

# Bootstrap Skill

> A **portable bootstrap skill** for Claude Code, Codex, or cross-tool setups that sets up a complete AI-driven development governance framework for any new project — in 4 interview blocks (A-D) plus 7 setup phases, with zero external dependencies.

**Version:** 3.51.0 — generic, interview-friendly, with portable learning loop (L1/L2/L3). No project-type lock-in, no trading-specific residue.

> 3.50.0 — AGENTS.md review-guidelines block (BOO-239): Codex reviewer contract (senior-dev perspective, report-only, findings flow) as an AGENTS.md template + `migrate_boo_239`; §7.7 Codex pointer wired to the runbook `codex-reviewer.en.md`.
> 3.49.0 — Optional add-ons / next-steps section in post-install (BOO-248): opt-in add-ons (Codex reviewer, daily bug scanner, headless VPS, VPS-from-phone) as an extensible pointer list instead of an interview question — no bloat. §7.7 + developer onboarding + HANDBUCH Appendix AT.
> 3.48.0 — Compliance doc gate `compliance_doc_gate` (opt-in add-on, BOO-229 B2): FAIL block instead of WARN; bootstrap question A.10, CONVENTIONS + environment.json, autopilot pause
> 3.47.0 — Doc-drift checker `doc-drift-check.sh` scaffolded + migratable (BOO-229 B1)
> 3.44.0 — Status line custom script with live worker-equivalent (BOO-205)
**Foundation:** Claude Code Best Practice Checklist v10 (OWLIST GmbH, 2026) — context engineering, global settings, context protection, and agent patterns are integrated into the bootstrap process.

> **Claude Code mode:** `/bootstrap` is an interview that then scaffolds many governance files → answer the questions, then **`acceptEdits`** for the scaffold phase. No unattended operation (setup is one-off + interactive). Details: HANDBUCH §6 "Claude Code mode".

---

## Big Picture

![Bootstrap Skill — Interview-Block flow (A–D) + setup phases (0, 4, 5, 7)](docs/bootstrap-big-picture.en.png)

*Four interview blocks (A–D) frame the decisions, four setup phases (0, 4, 5, 7) execute them. Block D activates optional components only on demand. A dedicated Learning-Loop cycle (`/sprint-review` → `journal/learnings.md` → `/ideation`) makes the framework smarter with every sprint. [Excalidraw source](docs/bootstrap-big-picture.en.excalidraw)*

**Also available:** [Artifact Map](docs/artifact-map.en.excalidraw) — visual map of every artifact bootstrap creates (governance files, hooks, specs, self-healing, skills) and how they interact.

---

## Why This Framework?

Most AI development frameworks are either too much automation (black box, no traceability) or too little structure (cursor rules without governance). This one hits the sweet spot:

| Strength | What it means |
|----------|---------------|
| 🔒 **Governance enforced via Git hooks** | `spec-gate.sh` blocks every commit without a spec file. `doc-version-sync.sh` blocks every push on version drift. No other AI framework enforces this at the machine level. |
| 🔗 **Complete traceability** | Every change follows the path: Idea → Backlog Record/adapter → Spec → Commit → Changelog. Fully traceable — even months later. |
| 🔄 **Self-healing as safety net** | A cron agent checks every 15 minutes: Versions in sync? Files present? Daemons running? Auto-corrects when possible — no human intervention. |
| 👤 **Human-in-the-loop strictly enforced** | No code change without operator approval. No issue without spec. No spec without architecture dimensions. Claude asks — you decide. |

> **Comparison:** CrewAI has role-based crews. AutoGen has debate patterns. This framework has **enforced governance** — the only framework that machine-level guarantees AI-generated code meets the same quality standards as human code.

---

## What the Skill Does

When you type `/bootstrap` in Claude Code, it walks you through setting up:

| What | Why |
|------|-----|
| **GOVERNANCE.md** | Blueprint for the AI-driven development lifecycle — rules, workflows, quality gates |
| **AGENTS.md / CLAUDE.md** | Runtime entries: Codex via AGENTS.md, Claude Code via CLAUDE.md, both bound by CONVENTIONS.md. `CLAUDE.md` carries a **project-type marker** (BOO-148): `ACTIVE` (code + deployment, default) or `GOVERNANCE REFERENCE` (docs/specs only, no coding) — controls whether deployment/CI gates apply |
| **CONVENTIONS.md** | Adapter contract for runtime, backlog adapter, governance mode, execution isolation, and gates |
| **Self-Healing Agent** | Watches document versions + daemon health every 15 min (cron) |
| **Doc-sync module** | Keeps all docs on the same version, optionally mirrored to Obsidian |
| **Issue writing guidelines** | Structured story format for AI + human collaboration |
| **Skills installation** | Wires up ideation, implement, backlog, architecture-review, and more |
| **Backlog adapter + GitHub + Obsidian** | Connects Linear, GitHub Issues, Jira, Azure DevOps, Planner, or `none` into one coherent lifecycle |

---

## Industry-Standard 7-Stage SDLC

This framework mirrors proven development practices from Google, Amazon, and Meta, covering their **7-stage Software Development Lifecycle** fully with AI-supported skills.

| # | Phase | Google/Amazon standard | Our equivalent | Skills | Status |
|---|-------|------------------------|----------------|--------|--------|
| 1 | **Requirements** | PRD, user stories | `/ideation` → Backlog Record/adapter | `/ideation` | ✅ |
| 2 | **Design** | Design doc, arch review, ADRs | `/ideation` (8 dims) + `/architecture-review` | `/ideation`, `/architecture-review` | ✅ |
| 3 | **Planning** | Task breakdown, sprint planning | `/implement` step 4 → `specs/ISSUE-XX.md` + `/backlog` | `/implement`, `/backlog` | ✅ |
| 4 | **Build** | Code, tests, CI | `/implement` steps 5–6 | `/implement` | ✅ |
| 5 | **Review** | Code review, QA, security | `/implement` step 7 post-validation | `/implement` | ✅ |
| 6 | **Deploy** | CI/CD, staging, rollout | Git push → handoff | — | ⚠️ Partial |
| 7 | **Monitor** | Observability, alerting | Self-Healing (15 min cron), `/status`, `/breakfix` | `/breakfix`, `/status` | ✅ |

---

## Core Flow

```
Idea → /ideation → Backlog Record/adapter → /backlog → /implement → Code + Docs → Git Push → Done
```

Every change is:
1. **Authorized** via a Backlog Record or adapter entry (no code without a traceable story)
2. **Documented** in the same commit (no code without doc update)
3. **Monitored** by the self-healing agent (version drift detected within 15 min)
4. **Reproducible** — every workflow is a skill

---

## Installation

### On an existing Claude Code system
```bash
cp -r bootstrap/ ~/.claude/skills/bootstrap/
# Then in Claude Code: /bootstrap
```

### On a fresh machine (portable mode)
```bash
mkdir -p ~/.claude/skills/
cp -r bootstrap/ ~/.claude/skills/bootstrap/
claude
# /bootstrap
```

Zero external dependencies. All templates are embedded in `references/`.

---

## Bootstrap Phases (v3.0)

The bootstrap is structured as **4 interview blocks (A-D)** followed by **execution phases (4-7)**.

| Phase | What happens | Input needed? |
|-------|--------------|---------------|
| **Phase 0** — Briefing | Skill announces the 4-block flow | Confirmation "ready" |
| **Block A** — Project core | Stack + name + runtime + backlog adapter + prefix + version + add-ons (Privacy, Cost, Signal, Compliance) | 9 questions |
| **Block B** — Existing infrastructure | GitHub, project documentation SSoT, backlog, env, runtime handover — integrates into existing state | 6 questions |
| **Block C** — Doc architecture | Project Hub, Developer Onboarding, Governance, Target Architecture, Backlog reference + 3-layer proposal | Confirmation / customization |
| **Phase 4** — Base structure | Directories, Git, core files, `.claudeignore`, hooks, component skeletons | `.env` confirmation |
| **Phase 5** — Skills via git-clone | Skills copied from `claudecodeskills` repo (no VPS symlinks) | Skill tier |
| **Block D** — Optional components | Self-Healing / DocSync / Automation-Daemon / Learning-Loop / SonarQube / Research / Visualize / Monitoring — all at the end | targeted questions + provider postflight |
| **Phase 7** — Registry + finalization | selected documentation SSoT, optional Obsidian PMO hub + project index, final commit | None |

---

## What Gets Created

After `/bootstrap`, your project and global environment have:

### Global / runtime (one-time, for all projects)
```
~/.claude/                 ← Claude Code runtime, if active
└── CLAUDE.md              ← Model routing, agent strategy, secrets policy

~/.codex/                  ← Codex runtime, if active
└── AGENTS.md              ← Codex rules and adapter notes
```

### In the project
```
my-project/
├── lib/config.js · doc-sync.js         ← Single source of truth
├── agents/self-healing.js              ← Cron health monitor (15 min)
├── AGENTS.md                           ← Codex entry, repo rules, scope notes
├── CLAUDE.md · CLAUDE.local.md         ← Claude Code entry + compatibility bridge
├── CONVENTIONS.md                      ← Runtime/backlog/governance adapter contract
├── ARCHITECTURE_DESIGN.md              ← Architectural decisions entry point
├── SYSTEM_ARCHITECTURE.md              ← Components, data flow, dependencies
├── COMPONENT_INVENTORY.md              ← File inventory (self-healing checks this)
├── GOVERNANCE.md · DEVELOPMENT_PROCESS.md · SECURITY.md
├── CHANGELOG.md · API_INVENTORY.md · INDEX.md · PROCESS_CATALOG.md
├── .env · .env.example · .gitignore · .claudeignore
├── specs/TEMPLATE.md                   ← Story template
├── journal/STRATEGY_LOG.md · LEARNINGS.md
├── .claude/ or .codex/                 ← depending on RUNTIME_TARGET, cross-tool uses both
│   └── skills/                         ← local skill copies
└── .claude/
    ├── settings.json                   ← Hooks (spec-gate, guard, format, Stop)
    ├── ISSUE_WRITING_GUIDELINES.md
    ├── hooks/spec-gate.sh · doc-version-sync.sh · guard.sh · format.sh
    ├── rules/agent-patterns.md
    └── skills/                         ← Linked based on selected skill tier
```

For the full map of artifacts and how they interconnect, see the [Artifact Map](docs/artifact-map.en.excalidraw) (PNG: [docs/artifact-map.en.png](docs/artifact-map.en.png)).

---

## The 8 Inviolable Rules

Claude follows these rules across the entire framework:

1. **Never implement without a Backlog Record or adapter story** — every change must be traceable
2. **Never close an issue without a changelog** — history must be complete
3. **Never change code without asking first** — human-in-the-loop for risk control
4. **Never claim "done" without git push** — code must always be on remote
5. **Never shorten an operator briefing in the backlog adapter** — original text is truth
6. **Never create an issue without labels** — labels are essential for filtering
7. **Never move sub-tasks directly to Done** — always through "In Progress" first
8. **Never add an API integration without updating the API inventory**

---

## Interfaces with Other Skills

The bootstrap skill is the **source** for every other skill in the repo. It installs, wires, and configures them all.

| Downstream skill | What bootstrap sets up for it |
|------------------|------------------------------|
| `/ideation` | `ARCHITECTURE_DESIGN.md` scaffold, 8-dimension references, story templates |
| `/backlog` | Neutral Backlog Record, adapter mapping, issue-writing guidelines, dependency fields |
| `/implement` | Spec templates, governance hooks, 8-step protocol wiring |
| `/architecture-review` | Dimensions reference, document structure |
| `/sprint-review` | Template for quarterly audit |
| `/research` | `OPENROUTER_API_KEY` slot in `.env`, skill references |
| `/security-architect` | Security-by-design section, STRIDE/OWASP references |
| `/grafana` | Grafana MCP slot, PromQL conventions |
| `/cloud-system-engineer` | Hostinger MCP slot, infra-dimension reference |
| `/visualize` | Miro MCP slot, required doc structure |
| `/skill-creator` | Global registry entry |
| `/design-md-generator` | Output folder wiring |

Every skill in this repo starts from the foundation bootstrap lays.

---

## Self-Healing Mechanism

```
Cron (every 15 min)
  └── node agents/self-healing.js
      ├── Check M: All DOC_FILES on same VERSION as config.js?
      │   → No: alert + auto-sync via doc-sync.js
      ├── Check U: All documented components on disk?
      │   → No: warning
      └── Check P: All daemon processes running (lock files)?
          → No: restart via start-script with backoff
```

The version number in `config.js` is the **single source of truth**. Bump it → self-healing updates all doc files on the next cron run.

---

## Portability

Zero external dependencies:

| Needed | Source |
|--------|--------|
| GOVERNANCE.md content | `references/governance-template.md` (embedded) |
| Self-healing script | `references/self-healing-template.js` (embedded) |
| Doc-sync script | `references/doc-sync-template.js` (embedded) |
| Issue guidelines | `references/issue-writing-guidelines-template.md` (embedded) |
| File templates | `references/file-templates.md` (embedded) |

## Runtime, Backlog, and Governance Modes

Bootstrap explicitly asks for the target runtime:

| Runtime | Entry | Role |
|---------|-------|------|
| `claude-code` | `CLAUDE.md` | Claude Code is primary; `AGENTS.md` may act as a Codex bridge |
| `codex` | `AGENTS.md` | Codex is primary; `CLAUDE.md` remains a compatibility bridge |
| `cross-tool` | both | both entries active, `CONVENTIONS.md` is the hard contract |
| `unknown` | both | portable baseline, tightened later |

Backlog is adapter-neutral: Linear, GitHub Issues, Jira, Azure DevOps, Planner, and `none` all map onto the same Backlog Record. Linear is supported, but not required.

Governance modes (`lite`, `standard`, `heavy`) control gate strictness and evidence requirements. They must not remove baseline artifacts or skills: runtime entry, `CONVENTIONS.md`, hub docs, spec template, `journal/`, Backlog Record, and skill baseline always remain.

The closing report uses `OK`, `WARN`, `SKIP`, `FAIL`. External providers are verified separately; local files alone do not make GitHub, Linear/Jira/Azure/Planner, SonarQube, Grafana, Telegram, or Obsidian sync `OK`. Secrets must never land in chat, repo files, logs, or the closing report. Existing projects follow the upgrade path in `references/framework-upgrade.en.md`: `inspect`, `apply-safe`, `apply-with-confirmation`, with an optional report under `journal/reports/framework-upgrade/YYYY-MM-DD.md`.

Provider postflight evaluates GitHub, backlog adapters, Research, Visualize/Miro, Monitoring, and Obsidian separately from skill installation status. Details: `references/provider-postflight.en.md`.

Copy the `bootstrap/` folder anywhere → it works immediately.

---

## Prerequisites

### Required
| What | Why |
|------|-----|
| **Claude Code** | The AI operator |
| **Node.js** | Self-healing + doc-sync |
| **GitHub repository** | Already created (empty or with code) |
| **SSH access to GitHub** | Only if a GitHub remote is used and pushed |
| **Backlog decision** | External adapter or `none` for local Backlog Records |

### Optional
Obsidian, Telegram Bot Token, OpenRouter API Key, Hostinger API Key, Miro Access Token, Grafana Cloud, Prometheus.

---

## License

MIT — free to use, adapt for your project.

Part of **INTENTRON**.
Skills repo: [github.com/vibercoder79/claudecodeskills](https://github.com/vibercoder79/claudecodeskills)

---

---
