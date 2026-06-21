# INTENTRON — Document Index

[🇩🇪 Deutsch](./INDEX.md) · [🇬🇧 English](./INDEX.en.md)

This index lists **all documents** of the framework in one place — not the generated artifacts (`.excalidraw`/`.png`), not the `specs/`, and not the release notes (`docs/releases/`). Read it as a map: the first table opens up the actual documentation (handbook, runbooks, ADRs, onboarding, references), the second the skill documentation. All paths are relative to `docs/`. Back to the entry page: [README](../README.md).

The **Languages** column shows whether a document is bilingual (`DE+EN`) or German-only (`DE`). The English twin sits next to the German file as `<name>.en.md`.

## Documentation

| Document | Description | Audience | Languages |
| --- | --- | --- | --- |
| [ADR: Branching standard](./domain/adrs/branching-standard.md) | Architecture decision for trunk-based development with a protected `main` branch. | Developers, architects | DE+EN |
| [ADR: Company-context layer (dev VPS)](./domain/adrs/company-context-layer.en.md) | Spike decision (proposed): lean company context (purpose/goals/values) as a referenced layer of the global CLAUDE.md instead of a parallel SecondBrain. | Operator, developers | DE+EN |
| [ADR: Cross-session drift](./domain/adrs/cross-session-drift.md) | Documents and accepts the BOO-number and wave-letter offset caused by parallel sessions. | Developers, operator | DE+EN |
| [ADR: Design-story handling](./domain/adrs/design-story-handling.md) | Architecture decision to implement design stories against a reference instead of `change_type:design`. | Developers, architects | DE+EN |
| [Anti-pattern catalog](../references/anti-pattern-katalog.md) | Catalog of typical sprint- and program-level anti-patterns (Schrader ch. 7) as a review reference. | Operator, lead | DE+EN |
| [Artifact & sign-off map](./onboarding/artefakt-landkarte.md) | Overview of which artifacts the framework delivers and which roles sign them off. | Customer, operator | DE+EN |
| [Audit perspective (runbook)](./runbooks/audit-perspective.md) | How an auditor verifies rule compliance via reproducible evidence. | Auditor, CISO/CIO/CTO | DE+EN |
| [Bootstrap pre-questionnaire](./onboarding/bootstrap-prep.md) | Questionnaire that captures the key facts before a project is set up. | Customer, operator | DE+EN |
| [Business case (runbook)](./runbooks/ceo-business-case.md) | Why a decision-maker invests in INTENTRON — the economic rationale. | CEO, decision-makers | DE+EN |
| [CISO view (runbook)](./runbooks/ciso-security.md) | What INTENTRON means for cyber security, from threat model to gate. | CISO | DE+EN |
| [Code quality & tech debt (runbook)](./runbooks/cto-code-quality.md) | How a CTO secures code quality with the quality-gate chain. | CTO | DE+EN |
| [Compliance mechanics](./compliance/compliance-mechanik.md) | End-to-end mechanics of gates and catalogs across the entire lifecycle. | Operator, compliance | DE+EN |
| [Conventions](../CONVENTIONS.md) | Binding conventions for work, code, and documentation in the framework. | Developers, operator | DE |
| [Daily bug scanner (runbook)](./runbooks/daily-bug-scanner.en.md) | How the Codex reviewer job works and is built: trigger/cron, prompt contract, sandbox, memory.md dedup, findings, setup, limits. | Operator, developers | DE+EN |
| [Demo preparation (runbook)](./runbooks/demo-vorbereitung.en.md) | Prep script: VPS → /bootstrap → example story + ready prompt → feature walkthrough → reset, so you arrive at the customer with a finished demo. | Sales, operator | DE+EN |
| [DPO view (runbook)](./runbooks/dpo-privacy.md) | Where data protection is hard-wired in the framework — planning, code, audit. | DPO | DE+EN |
| [Doc review 2026-06-03 (BOO-114–129)](./doc-review-2026-06-03-boo-114-129.md) | DE+EN review of onboarding, sketches, and handbook for currency and gaps. | Operator, doc author | DE |
| [Developer quick-start (cheat sheet)](./quickstart-entwickler.en.md) | Quick guide "when do I use what?" — `/implement` vs `/sprint-run` vs `--auto`, gates, switches. ≤5 pages. | Developers | DE+EN |
| [Framework update (runbook)](./runbooks/framework-update.md) | How an existing project is lifted to the current framework state. | Operator | DE+EN |
| [Glossary for non-developers](./glossar.md) | Plain-language explanations of core terms (repo, commit, …) for non-technical readers. | Non-developers, stakeholders | DE+EN |
| [HANDBUCH (Handbook)](../HANDBUCH.md) | The complete framework handbook — explains the system as a coherent whole (incl. the Hermes Human-in-the-Lead rationale, Appendix D). | Operator, developers | DE+EN |
| [Headless VPS (runbook)](./runbooks/headless-vps.en.md) | Start the sprint unattended via `claude -p "/sprint-run --auto"` as a cron or systemd job — budget cap, sandbox, deny rules, non-root. | Operator, DevOps | DE+EN |
| [Hostinger VPS setup (runbook)](./runbooks/hostinger-vps-setup.md) | Step-by-step OS bootstrap and hardening of a Hostinger VPS. | Operator, DevOps | DE+EN |
| [Integration-discovery questionnaire](./onboarding/integration-discovery.md) | Captures the customer-specific part for CI/CD into the customer's live environment. | Customer, customer IT | DE+EN |
| [AI architecture principles](../references/ki-architektur-prinzipien.md) | The four AI architecture principles as a mandatory prerequisite (Schrader ch. 4). | Architects, operator | DE+EN |
| [Collision protection: three layers](./kollisionsschutz-drei-ebenen.md) | Separates the three layers of parallelism and their respective protection mechanisms. | Developers, operator | DE+EN |
| [Customer demo (runbook)](./runbooks/customer-demo.en.md) | Script to show the framework live to a customer in 1–2 h — flow with timing, role use-cases, live gate block, reset. | Sales, operator | DE+EN |
| [LICENSE](../LICENSE.md) | License text (PolyForm Perimeter License 1.0.0) of the framework. | Everyone | DE |
| [Logging & monitoring (runbook)](./runbooks/logging-monitoring.md) | Set up logging/monitoring after bootstrap: fill `observability.md` — onboarding questions + examples. | Operator, DevOps | DE+EN |
| [Multi-user VPS (runbook)](./runbooks/multi-user-vps.md) | Onboard a new team member on a shared VPS. | Operator, DevOps | DE+EN |
| [Pitch](./pitch/README.md) | Description of the standalone 30-minute pitch presentation in OWLIST layout. | Sales, operator | DE |
| [Q&A](./qa.md) | Collection of operational practice questions complementing the handbook. | Operator, developers | DE |
| [README](../README.md) | Framework entry page with overview, navigation, and the positioning (sequential pipeline, human-gated merges). | Everyone | DE |
| [Connect routines (runbook)](./runbooks/routinen-vernetzen.md) | Three setup options for recurring routines with copy-ready prompt templates (switch C). | Operator | DE+EN |
| [SECURITY](../SECURITY.md) | Security policy of the framework (vulnerability reporting, scope). | Everyone, security | DE |
| [How this framework documents](./how-we-document.md) | Explains the doc model: versioned Markdown in the repo, enforced by hooks. | Operator, doc author | DE+EN |
| [Catch up SecondBrain setup (runbook)](./runbooks/secondbrain-nachziehen.md) | Add the SecondBrain integration to an existing project without re-bootstrapping. | Operator | DE+EN |
| [SonarCloud setup (runbook)](./runbooks/sonarcloud-setup.md) | SonarCloud integration for new GitHub repos via GitHub Actions. | Operator, DevOps | DE+EN |
| [Sprint run (runbook)](./runbooks/sprint-run.md) | Run an entire sprint fully automatically with `/sprint-run`. | Operator | DE+EN |
| [Sprint unattended via tmux (runbook)](./runbooks/sprint-unattended-tmux.md) | Run a sprint unattended on the VPS with tmux. | Operator, DevOps | DE+EN |
| [Integrate a stack linter (runbook)](./runbooks/stack-linter-integrieren.md) | Integrate a non-covered stack/linter (e.g. PHP/TYPO3, Go) step by step — the 5 places + verification. | Operator, DevOps | DE+EN |
| [Unit tests (runbook)](./runbooks/unit-tests.md) | Unit-test flow in detail: 6a-quart test gate, diff coverage, JUnit XML, anti-placeholder check. | Operator | DE+EN |
| [Vercel CI/CD setup (runbook)](./runbooks/vercel-cicd-setup.md) | Vercel CI/CD integration via GitHub Actions, deploy after green checks. | Operator, DevOps | DE |
| [VPS from your phone (runbook)](./runbooks/vps-vom-handy.en.md) | Observe/steer a running Claude Code session on the VPS from your phone — Remote Control + tmux, human-gated on irreversible actions. | Operator, developers | DE+EN |
| [VPS team setup (runbook)](./runbooks/vps-team-setup.md) | Set up INTENTRON on a developer VPS for teams. | Operator, DevOps | DE |

## Skill documentation

The framework's 15 top-level skills. Each links to its `README.md`; the English twin sits next to it as `README.en.md`.

| Skill | Purpose | Languages |
| --- | --- | --- |
| [architecture-review](../architecture-review/README.md) | Architecture review for single stories or the whole system along the active architecture dimensions. | DE+EN |
| [backlog](../backlog/README.md) | Sprint planning and backlog overview: loads issues, analyzes dependencies, proposes prioritization. | DE+EN |
| [bootstrap](../bootstrap/README.md) | Sets up a new project with the governance framework — interactive block-interview flow and doc architecture. | DE+EN |
| [cloud-system-engineer](../cloud-system-engineer/README.md) | Checks VPS infrastructure, security, container status, DNS, and firewall — standalone or as a teammate. | DE+EN |
| [dpo](../dpo/README.md) | Data protection officer: privacy by design in three modes (ASSESS, REVIEW, AUDIT). | DE+EN |
| [grafana](../grafana/README.md) | Grafana dashboard development and metric queries via the official Grafana MCP server. | DE+EN |
| [ideation](../ideation/README.md) | Deep research, architecture review, and user-story creation with learning-loop and anti-pattern warnings. | DE+EN |
| [implement](../implement/README.md) | Implementation protocol for user stories — 8-step workflow incl. post-implement validation. | DE+EN |
| [intent](../intent/README.md) | Operationalizes "Intent before Implementation": distills a measurable intent statement as input for /ideation. | DE+EN |
| [knowledge-onboarding](../knowledge-onboarding/README.md) | Routes existing documentation deterministically into governance artifacts via three adapters and a manifest. | DE+EN |
| [pitch](../pitch/README.md) | Closes the 4P pipeline: gathers evidence as a Markdown briefing for stakeholder meetings. | DE+EN |
| [security-architect](../security-architect/README.md) | Security by design in four modes (DESIGN, REVIEW, AUDIT, SKILL-SCAN) across the development process. | DE+EN |
| [sprint-review](../sprint-review/README.md) | Periodic audit for architecture health, tech debt, and backlog hygiene plus a learning-loop entry. | DE+EN |
| [sprint-run](../sprint-run/README.md) | Sprint orchestrator: runs an entire sprint automatically across worktrees, CI, and merge. | DE+EN |
| [visualize](../visualize/README.md) | Generates architecture diagrams in Miro from the project's architecture docs. | DE+EN |

> [!info] Anthropic-native, not a skill
> [`goal/`](../goal/README.en.md) (`README.md` + `README.en.md`, DE+EN) documents the **Anthropic-native** termination engine [`/goal`](../goal/README.en.md) — sprint engine behind `/sprint-run`, story engine for long `/implement` runs. Not a framework skill (no `SKILL.md`), hence not counted in the skill table above (build-vs-buy, ADR-1).
