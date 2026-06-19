# Architecture Design Template

> **Usage:** this template is generated in phase 1 of the `/bootstrap` skill.
> All `{{PLACEHOLDERS}}` are filled with project info from phase 0.
> `ARCHITECTURE_DESIGN.md` is, per CLAUDE.md, the **entry document** — every new component
> is recorded here first, before the git commit.

---

# {{PROJECT_NAME}} — Architecture Design

**Version:** {{VERSION_START}} | **Updated:** {{TODAY}}
**Owner:** {{OWNER_NAME}}

> **Entry document.** Every new component and new file is recorded here first —
> before the git commit.

---

## §1 Big Picture

[System map — overview of all components and their connections.
ASCII diagram or descriptive text when the system is still small.]

```
[Component A] → [Component B] → [Output]
      ↑
[External API]
```

---

## §2 Design rationale ("the why")

[Reasoning behind the major architectural decisions.
Why this stack? Why this structure?
Answers "Why did we build X like this?" for new engineers and AI assistants.]

| Decision | Reason | Rejected alternative |
|----------|--------|----------------------|
| [e.g. Node.js instead of Python] | [reason] | [what was rejected and why] |

---

## §3 ADR — Architecture Decision Records

> ADRs document important architectural decisions with context, decision, and consequences.
> **Status:** Proposed → Active → Deprecated

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| ADR-01 | [First architectural decision] | Active | {{TODAY}} |

### ADR-01: [title]

**Status:** Active | **Date:** {{TODAY}}

**Context:** [what problem or situation forced this decision?]

**Decision:** [what was decided?]

**Consequences:**
- ✅ [positive effect]
- ⚠️ [limitation or trade-off]

---

## §4 Component overview

> Every new component MUST be entered here — before the git commit.

| Component | File/Path | Responsibility | Dependencies |
|-----------|-----------|----------------|--------------|
| Config (SSoT) | `lib/config.js` | VERSION, DOC_FILES, project config | — |
| [New component] | `[Path]` | [What does it do?] | [Which other components does it need?] |

---

## §5 Quality dimensions

> Check every story against these dimensions (architecture review):

| # | Dimension | Questions for this project |
|---|-----------|----------------------------|
| 1 | **Reliability** | Graceful degradation? Kill-switch present? |
| 2 | **Data Integrity** | SSoT respected? No dual-write? |
| 3 | **Security** | API keys in .env? Inputs validated? |
| 4 | **Performance** | Latency acceptable? Rate limits? Memory stable? |
| 5 | **Observability** | Logging? Alerts configured? |
| 6 | **Maintainability** | No code duplication? Config SSoT? Docs current? |
| 7 | **Testability** | Coverage on new code (change value)? Test pyramid (unit/contract/integration)? Pass rate stable? |
| 8 | **Scalability** | Behaviour under load and across multiple instances — statelessness, horizontal scaling, async decoupling. Detail: `architecture-review/references/dimensions-detail.en.md §8`. |
| 9 | **Cost Efficiency** | API costs calculated? Cheaper alternative? |
| 10 | **Domain Quality** | Does it improve the core quality of the project? |

### Context validation for this project

> These questions must be answered during bootstrap and major architecture changes.
> A blueprint is only valid when it matches the actual project context.

| Question | Answer / project decision |
|----------|---------------------------|
| Which dimensions are truly critical for this project? | [fill in] |
| Which dimensions are intentionally lightweight? | [fill in] |
| Which external providers, data sources, or platforms shape the architecture? | [fill in] |
| Which security/privacy boundaries must never be overwritten automatically? | [fill in] |
| Which assumptions must be re-checked after the first real implementation run? | [fill in] |

---

## §5b Infra layers (13-layer decision grid)

> **Second axis next to §5.** §5 is the **quality axis** (what the system must be able to do); this table is the
> **infra axis** (which infrastructure decision is made per layer). **Single entry point** for this project's infra state —
> one row per layer. Mandatory questions, failure modes and anti-patterns per layer live in the stack-neutral catalog
> `cloud-system-engineer/references/infrastructure-dimensions.en.md` (the "Reference" column points there). No duplication
> with §5: where a layer primarily realizes a quality property (security, monitoring, performance), the row cross-references
> the matching §5 dimension instead of restating it.
>
> **Status:** `ok` (decided + implemented) · `n.ok` (open / to rework) · `n/a (deliberate)` (deliberately irrelevant for
> this project, with a one-sentence rationale). **Lazy-fill allowed:** empty rows are fine, `/architecture-review` finds
> them and nudges for rework. Depth **on-demand**: "Reference" may point to a project sub-MD (e.g. `DB_SCHEMA.md`,
> `IAM_POLICY.md`, `RECOVERY_PLAN.md`) — only when needed, no scaffolding upfront.

| # | Layer | Decision (1 sentence) | Status | Reference |
|---|-------|-----------------------|--------|-----------|
| 1 | Frontend | [fill in / n/a (deliberate)] | n.ok | [catalog §1](cloud-system-engineer/references/infrastructure-dimensions.en.md) |
| 2 | APIs & Backend | [fill in] | n.ok | [catalog §2](cloud-system-engineer/references/infrastructure-dimensions.en.md) |
| 3 | Database & Storage | [fill in] | n.ok | [catalog §3](cloud-system-engineer/references/infrastructure-dimensions.en.md) |
| 4 | Caching & CDN | [fill in] | n.ok | [catalog §4](cloud-system-engineer/references/infrastructure-dimensions.en.md) |
| 5 | Hosting & Deployment | [fill in] | n.ok | [catalog §5](cloud-system-engineer/references/infrastructure-dimensions.en.md) |
| 6 | Cloud & Compute | [fill in] | n.ok | [catalog §6](cloud-system-engineer/references/infrastructure-dimensions.en.md) |
| 7 | CI/CD & Version Control | [fill in] | n.ok | [catalog §7](cloud-system-engineer/references/infrastructure-dimensions.en.md) |
| 8 | Rate Limiting | [fill in] | n.ok | [catalog §8](cloud-system-engineer/references/infrastructure-dimensions.en.md) |
| 9 | IAM / RBAC / Permissions | [fill in] | n.ok | [catalog §9](cloud-system-engineer/references/infrastructure-dimensions.en.md) · Q: §5 Security |
| 10 | Security & RLS | [fill in] | n.ok | [catalog §10](cloud-system-engineer/references/infrastructure-dimensions.en.md) · Q: §5 Security |
| 11 | Monitoring / Logs / Alerts | [fill in] | n.ok | [catalog §11](cloud-system-engineer/references/infrastructure-dimensions.en.md) · Q: §5 Observability |
| 12 | Rollback & Recovery | [fill in] | n.ok | [catalog §12](cloud-system-engineer/references/infrastructure-dimensions.en.md) · Q: §5 Reliability |
| 13 | Audit / Compliance & SLAs | [fill in] | n.ok | [catalog §13](cloud-system-engineer/references/infrastructure-dimensions.en.md) |

---

## §6 References

> Links to all connected architecture documents — SSoT for cross-references.

| Document | Path | Content |
|----------|------|---------|
| System architecture | `SYSTEM_ARCHITECTURE.md` | Components, data flow |
| Component inventory | `COMPONENT_INVENTORY.md` | Detailed component list |
| Governance | `GOVERNANCE.md` | Framework rules, ADRs |
| Security contract | `SECURITY.md` | Security principle, change-type matrix, security validation, sensitive paths |
| API inventory | `API_INVENTORY.md` | External APIs (must be updated!) |
| Process catalog | `PROCESS_CATALOG.md` | How the system works |

### Security reference model

`ARCHITECTURE_DESIGN.md` is the lead document: it names Security as a quality dimension, records security/privacy boundaries, and links to `SECURITY.md`. `SECURITY.md` is the operational security contract and points to sub-artifacts such as `API_INVENTORY.md`, `.semgrep.yml`, `.codex/hooks.json`, `.claude/sensitive-paths.json`, `.codex/sensitive-paths.json`, threat models, and privacy/compliance documents.

---

*Updated by Claude Code on every architectural decision.*
