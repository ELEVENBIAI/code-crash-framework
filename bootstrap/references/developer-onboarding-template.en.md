# {{PROJECT_NAME}} — Developer Onboarding

**Version:** {{VERSION_START}} | **Updated:** {{TODAY}}
**Repository:** {{GITHUB_REPO}}

> Goal of this document: a completely unfamiliar development team can take over the project, run it locally, understand the architecture and safely implement the next story.

## Purpose

This onboarding is the handover artifact for humans and AI-assisted development environments. It is deliberately tool-neutral: a team should become productive with Claude Code, Codex, Cursor, GitHub Copilot, Google Antigravity, or a classic editor/terminal setup without relying on implicit knowledge from previous chats.

## Single Sources of Truth

| Artifact | Purpose |
|---|---|
| `{{PROJECT_HUB_PATH}}` | Project hub: status, goals, decisions, next steps |
| `ARCHITECTURE_DESIGN.md` | Target architecture, ADRs, quality attributes, references |
| `SECURITY.md` | Security rules, secrets, threat surface, mandatory checks |
| `CONVENTIONS.md` | Project contract: governance mode, execution isolation, gates |
| `docs/backlog/` or backlog tool | prioritized work, dependencies, status |
| `specs/` | local story specs and spec packs |

## Project in One Sentence

{{PROJECT_ONE_SENTENCE}}

## Target Architecture

{{TARGET_ARCHITECTURE_SUMMARY}}

Mandatory: this summary must reference `ARCHITECTURE_DESIGN.md` and must not create a second, divergent architecture truth.

## Required Reading

Read before every implementation:

1. `CONVENTIONS.md`
2. `ARCHITECTURE_DESIGN.md`
3. `SECURITY.md`
4. `{{PROJECT_HUB_PATH}}`
5. relevant story spec in `specs/`
6. relevant runtime, tooling, or component documentation

## Starting Implementation

1. Check branch and working tree: current branch, open diffs, edits made by others.
2. Identify the backlog record or local story spec.
3. Run the T0 preflight from the story spec.
4. Read relevant files before editing them.
5. Define the write scope, especially with sub-agents or parallel work.

## Backlog and Issue Workflow

- Every implementation needs a backlog record or adapter story.
- Every implementation needs a local spec (`specs/{{PREFIX}}XXX.md`) or an explicitly approved spec pack.
- Check dependencies and blockers before starting.
- Respect the order from backlog/project hub; document deviations.
- Close only after verification, documentation-impact review and backlog comment.

## Security

- No secrets in code, logs, commits, screenshots, or chat.
- `.env` remains local and gitignored; only `.env.example` is documented.
- For auth, APIs, external input, data flows, dependencies, CI, or governance changes, always check `SECURITY.md` and the story security validation.
- Sensitive paths may only be changed with documented human review when the project defines them.

## Development Rules

- Read files before editing them.
- Use existing patterns and local helpers.
- Do not add new frameworks, services, or runtime dependencies without rationale and approval.
- Register new files in architecture/index references.
- Run tests, linting, Semgrep and smoke checks according to project convention or document why they were skipped.

## Runtime and Tool Notes

| Area | Note |
|---|---|
| Runtime | {{RUNTIME_HINTS}} |
| Install/setup | {{SETUP_COMMANDS}} |
| Tests | {{TEST_COMMANDS}} |
| Lint/SAST | {{QUALITY_COMMANDS}} |
| Local services | {{LOCAL_SERVICE_HINTS}} |
| Deploy/release | {{DEPLOYMENT_HINTS}} |

Tool-switch context:

- Claude Code: respect skills, hooks and `.claude/environment.json` if present.
- Codex: respect `AGENTS.md`, sandbox/approvals, write scope and local skill instructions.
- Cursor/GitHub Copilot/Google Antigravity: load this document plus the SSoTs as project context; do not assume chat history.
- Classic development team: backlog, spec, architecture and security are enough to start; add missing implicit assumptions here.

## Optional Add-ons / Next Steps

Optional, **opt-in** operations/governance add-ons are **not** set up after the bootstrap and **deliberately not** asked in the interview (lightweight design principle). Activate them afterwards via the respective framework runbook when needed (background + extension rule: HANDBUCH Appendix AT):

- **Independent code reviewer (Codex)** — a second review pass from a different vendor (no conflict of interest, no gate). Runbook `codex-reviewer`.
- **Daily bug scanner** — triggered repo scan for bugs/regressions (report-only). Runbook `daily-bug-scanner`.
- **Headless VPS** — run sprints unattended (`claude -p` as cron/systemd). Runbook `headless-vps`.
- **Developer VPS from your phone** — remote control via Remote Control + tmux. Runbook `vps-vom-handy`.
- **CI spec-gate (server-side)** — enforces "no merge without a referenced `specs/<ISSUE>.md`" in CI (`--no-verify`-resistant). Opt-in, recommended for `governance_mode = heavy`. Runbook `spec-gate-ci`.

This list is extensible: new opt-in features are added here (and in the bootstrap post-install section §7.7) instead of as an interview question.

## Maintenance Obligation

Update this document when any of the following changes:

- target architecture, ADRs, or central components
- runtime, setup, test, lint, or deploy commands
- backlog/issue workflow, spec obligation, or gates
- security rules, secrets handling, or sensitive paths
- tool-switch notes for Claude Code, Codex, Cursor, GitHub Copilot, Google Antigravity, or classic development teams

At the end of every implementation, `/implement` checks whether this onboarding or the project hub must be updated. If no update is needed, the closeout documents "Onboarding/hub: no update needed".
