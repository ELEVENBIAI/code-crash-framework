# Daily Bug Scanner — independent Codex reviewer as a scheduled job (runbook)

[🇩🇪 Deutsch](./daily-bug-scanner.md) · [🇬🇧 English](./daily-bug-scanner.en.md)

> How the daily bug scanner works and is built. In short: a **triggered job** that has **Codex** (deliberately a different tool than the author) review the code from a senior-developer perspective and **propose** findings as backlog tickets. Source: BOO-50. Productizing it as a named opt-in governance layer is **BOO-239**.

## What it is — and is not

- A **routine / job**, **not** a self-triggering agent: a **trigger** (cron) kicks off **Codex**; Codex reviews and **proposes**. The human decides. **No auto-fix, no auto-merge** (human-in-the-lead, cf. [Our position](../../README.md#our-position-sequential-pipeline-human-gated-merges)).
- Codex is deliberately a **different tool than the author** (Claude) → no conflict of interest (reviewer ≠ author; cf. BOO-239, four-eyes BOO-150).

## Mechanics (end-to-end)

1. **Trigger** — cron schedule in `.codex/automations/<name>.toml` (`schedule`).
2. **Prompt contract** — "daily code reviewer: scan for critical bugs/security/edge cases".
3. **Codex run** — async in an isolated cloud sandbox.
4. **Dedup** — reads `memory.md` for previously reported findings.
5. **Return** — new findings as a backlog ticket (label, e.g. `autofix`) or PR; report "X found, Y duplicates".

## The `.toml` explained

```toml
[automation]
name = "Daily Bug-Scanner"
cwd = "{{PROJECT_PATH}}"
schedule = "0 8 * * *"          # cron: daily 08:00

[prompt]
content = """
Daily code reviewer for {{PROJECT_NAME}}: scan for critical bugs/security/edge cases,
check whether a backlog ticket (label: autofix) exists, create one for new findings
(title, affected files as absolute paths, impact, repro, suggested fix, format specs/TEMPLATE.md).
Read {{ABSOLUTE_MEMORY_PATH}}/memory.md for previous findings. Report: X found, Y duplicates.
"""
```

| Field | Meaning |
|---|---|
| `name` | display name of the automation |
| `cwd` | working directory (project path) |
| `schedule` | cron expression (the trigger) |
| `prompt.content` | the reviewer brief (senior-dev perspective + dedup + output format) |

## Wiring (Codex has **no** MCP)

Codex is **not** wired via MCP, but via: the **Linear↔Codex integration** (`@Codex` in the issue), **GitHub** (PR as return channel) and **file context** (`AGENTS.md` / `CONVENTIONS.md` / `specs/`). (MCP is used by Claude in this framework — Linear/Obsidian/Grafana/Miro.)

## Setup

1. **Linear → Settings → Integrations → Codex → Connect GitHub.**
2. Set up **GitHub auth** for Codex.
3. **`$CODEX_HOME` workaround:** put an absolute `memory.md` path in the `.toml`.

## Privacy / sovereignty

The reviewer reads a lot of (potentially all) code → choose the tier **deliberately**: **OpenAI Standard** (US, commercial terms) vs. **Azure OpenAI Switzerland North** (CH residency, no training). See HANDBUCH **Appendix Q** (sovereignty stack).

## Limits

- **No auto-fix / auto-merge** — the scanner only proposes (human-in-the-lead).
- **Known gap:** local Codex hook enforcement (pre-commit/gates) is undocumented in the repo (no schema/example). The **CI layer (layer 3)** does apply to Codex too, since it is commit-agnostic.

## Related

HANDBUCH **Appendix J** (Codex onboarding, with this scanner as the optional example) · **Appendix Q** (sovereignty) · **BOO-239** (productization as the opt-in "independent reviewer" layer) · **BOO-50** (source).

## Visualization

> [!note] Sketch pending (BOO-241)
> An Excalidraw sketch of the mechanics (trigger → Codex sandbox → `memory.md` → findings) will follow via the render loop and be embedded here. Open acceptance criterion, see `specs/BOO-241.md`.
