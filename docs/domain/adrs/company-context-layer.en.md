# ADR: Company-context layer on the developer VPS (BOO-242)

- **Status:** proposed (spike result 2026-06-21) — operator sign-off pending
- **Context source:** brainstorm 2026-06-20 (operator) + spike BOO-242

## Context

Developer VPSs today sync **project knowledge** via GitHub (VPS operator layer BOO-138/139: `PROJECTS_ROOT`, `journal/`, daily-note routine). The global `~/.claude/CLAUDE.md` is already the **central map** (machine context + `PROJECTS_ROOT` + project registry + journaling convention). What is missing: the **company-wide context** (purpose, goals, values) so that Claude/Codex knows, across projects, which company it works for. The risk to avoid: **two disconnected mechanisms** (SecondBrain vs. project directories).

## Decision

A **lean company-context layer as a referenced layer of the existing global `~/.claude/CLAUDE.md`** (for Codex analogously `AGENTS.md`) — **not a parallel mechanism, not a full vault clone**.

- **Scope (whitelist):** company/purpose, goals/strategic goals, values (optionally tone).
- **Excluded:** branding/color codes → project level (`ARCHITECTURE.md`/`DESIGN.md`); sensitive material (financials, customer internals) → stays in the master vault (privacy/sovereignty, HANDBUCH Appendix Q).
- **Form:** a small `company-context.md`. **One VPS** → inline in the global `CLAUDE.md` (machine-context section). **Several VPSs** → those few files in a small GitHub repo (or the operator-layer repo), distributed via `git pull`.
- **Wiring:** the global `CLAUDE.md`/`AGENTS.md` names the layer explicitly; skills read it like `00 Kontext/` today.
- **Sync:** `git pull` (manual or pull-on-session-start). `cron-sync` was an anti-pattern for *skills* → evaluate separately for a read-only context.
- **Surfacing:** opt-in via the post-install checklist (no bootstrap bloat) — the BOO-239 pattern.

## Rationale

- **Lightweight** (no full vault) and reuses the existing map → **no two mechanisms**.
- Pattern proven (SecondBrain clone on the OpenCLAW VPS with GitHub sync).
- Closes the context gap at the VPS boundary without exposing sensitive material.

## Alternatives (rejected)

- **Full `secondbrain-setup` vault clone** onto the dev VPS — overkill for a pure dev VPS.
- **A separate mechanism detached from `CLAUDE.md`** — creates exactly the two disconnected systems we want to avoid.

## Consequences

- Implementation is a **follow-up story** (inline/repo scaffold + `CLAUDE.md`/`AGENTS.md` wiring + DE+EN docs), only after operator sign-off.
- Related: VPS operator layer (BOO-138/139), cloud reference architecture (BOO-243), sovereignty (HANDBUCH Appendix Q).
