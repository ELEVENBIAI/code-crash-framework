# Runbook: Connecting Routines Intelligently

> Source: ADR-2 Switch C. Bootstrap **does not ask** about routine defaults — setups are
> operator- and environment-specific. This runbook describes three setup options and seven
> routine suggestions with copy-ready prompt blocks. You decide what to set up.

A "routine" is a recurring, scheduled run of a framework skill (e.g. daily
`/backlog` triage). The value comes from **interconnection**: the routines feed each other
(backlog triage → sprint review → quality-gate audit) and keep the project healthy between active
sessions.

---

## Three setup options

| Option | Mechanics | Pros | Cons |
|--------|-----------|------|------|
| **1. Developer VPS** | Anthropic Routines / Scheduled Agents in the cloud | always on; no local machine needed; central for the team | VPS costs; set up secrets/repo access on the VPS |
| **2. Local MacBook** | `cron` + Claude CLI locally | nothing to host; uses existing auth | only runs when the Mac is on; personal, not shared |
| **3. Local server / NAS / Raspberry Pi** | `cron` + Claude CLI always-on | always on, local, cost-efficient | machine setup/maintenance; repo clone + auth needed |

**Rule of thumb:** Solo + irregular → Option 2. Solo + reliable → Option 3. Team / multiple projects →
Option 1. The prompt blocks below are setup-neutral — only the trigger (Anthropic routine vs.
`cron` entry) differs.

---

## Seven routines

Per routine: **Goal · Trigger phrase · Skill · Output location · Setup suitability · Prompt block** (to
copy). Routines 1–3 are the **mandatory set**, 4–7 are optional.

### 1. Backlog triage (daily) — Mandatory set

- **Goal:** prioritize open issues, check sprint fit, catch drift early.
- **Trigger phrase:** "Triage the backlog."
- **Skill:** `/backlog`
- **Output location:** backlog tool (Linear/GitHub) + optionally `journal/`
- **Suitability:** all three setups.

```text
Run /backlog in triage mode for this project: prioritize open issues, check sprint fit
(80% token window), mark stories without a complete spec as not sprint-ready, and report the
top 5 candidates for the next sprint. No code changes. Summarize the result in 5 lines.
```

### 2. Sprint review (weekly) — Mandatory set

- **Goal:** architecture health, tech debt, learning-loop entry.
- **Trigger phrase:** "Do the sprint review."
- **Skill:** `/sprint-review`
- **Output location:** `journal/sprint-{date}.md`
- **Suitability:** all; with `complement_insights` active, additionally `insights-review` (operator reflection).

```text
Run /sprint-review for this project: system snapshot, governance drift, tech-debt inventory,
backlog hygiene, anti-pattern self-diagnosis, and learning-loop entry in journal/sprint-{date}.md.
If complement_insights is active: add the operator-reflection meta block (insights-review). Report
the three most important findings + actions.
```

### 3. Quality-gate self-audit (monthly) — Mandatory set

- **Goal:** check whether the declared gates are actually **wired** (not just configured).
- **Trigger phrase:** "Audit the quality gates."
- **Skill:** `/quality-gate-audit`
- **Output location:** `docs/audits/YYYY-MM-DD-quality-gate-audit.md`
- **Suitability:** all.

```text
Run /quality-gate-audit for this project: check whether Semgrep wiring, coverage gate, slopsquatting, and
the Layer-0 edit bodyguard are actually wired (wired vs. blind). Write the audit report to
docs/audits/. If at least one gate is blind: report it prominently with a repair hint.
```

### 4. Dependency drift (weekly) — Slopsquatting check

- **Goal:** check new/updated dependencies against slopsquatting/hallucination packages.
- **Trigger phrase:** "Check dependency drift."
- **Skill:** Slopsquatting wordlist check (`/slopsquatting-deep-refresh` or `.github/workflows/slopsquatting-refresh.yml`)
- **Output location:** `.claude/hooks/slopsquatting/wordlist.txt` + report
- **Suitability:** Option 1/3 (always-on preferred).

```text
Check this project's dependencies for slopsquatting/hallucination packages: update the
slopsquatting wordlist and reconcile new or changed dependencies against it. Report every hit
with package name, source, and risk assessment. No auto-installation.
```

### 5. Doc drift (monthly) — CLAUDE.md vs CONVENTIONS.md

- **Goal:** keep governance docs in sync; find dead references + version drift.
- **Trigger phrase:** "Check doc drift."
- **Skill:** `python3 .github/scripts/docs_drift_check.py` + manual CLAUDE.md/CONVENTIONS.md reconciliation
- **Output location:** console / issue on drift
- **Suitability:** all.

```text
Check this project's doc consistency: run python3 .github/scripts/docs_drift_check.py and reconcile
CLAUDE.md against CONVENTIONS.md (runtime_target, governance_mode, active gates, native-paths block).
Report every discrepancy, dead references/ links, and version drift. On drift: suggest a concrete fix
but change nothing without approval.
```

### 6. Cost drift (weekly) — Token tracking & cache hit rate

- **Goal:** keep token/cost consumption and cache efficiency in view.
- **Trigger phrase:** "Check cost drift."
- **Skill:** ccusage snapshot (`docs/financials/sprint-costs.md`)
- **Output location:** `docs/financials/sprint-costs.md`
- **Suitability:** all; especially with daemon/sprint-run usage.

```text
Capture a token/cost snapshot for this project (ccusage against the local Claude Code JSONL logs)
and append it to docs/financials/sprint-costs.md. Compare with the previous week: report notable
cost drift, poor cache hit rate, or sprint runs that blew the token budget.
```

### 7. Hermes health (monthly) — only if Hermes VPS active

- **Goal:** check the health of the Hermes observation/orchestration layer.
- **Trigger phrase:** "Check Hermes health."
- **Skill:** Hermes health check (project-specific)
- **Output location:** Hermes log / report
- **Suitability:** only Option 1/3 with an active Hermes VPS.

```text
Check this project's Hermes layer (only if active): are the Hermes daemons running, are the
observation triggers set, are there errors in the Hermes log? Report the status in 5 lines. If Hermes
is not set up: abort with the note "Hermes not active — skip routine".
```

---

## Setup per option (brief)

- **Option 1 (Developer VPS):** create a routine per prompt block as an Anthropic Scheduled Agent / Routine
  (see `/schedule`). Repo clone + auth + secrets one-time on the VPS.
- **Option 2 (MacBook) / Option 3 (Server/NAS/Pi):** a `cron` entry per routine that launches the Claude CLI
  in the project directory with the prompt block. Example frequencies: daily `0 8 * * *`, weekly
  `0 8 * * 1`, monthly `0 8 1 * *`.

> **Lightweight (design principle):** Start with the mandatory set (1–3). Use 4–7 only when the concrete
> need is there — no routine without value.
