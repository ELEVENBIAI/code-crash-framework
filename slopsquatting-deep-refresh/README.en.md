# Slopsquatting Deep Refresh — the Quarterly Methodology Review

> Quarterly deep-research review of the slopsquatting wordlist *methodology*: are the sources still the right ones, the filters still effective, the thresholds still sensible? Produces a cited update recommendation — no auto-write. The weekly auto-refresh keeps the data fresh; this skill checks whether the data is being kept *correctly* fresh.

**Version:** 1.0.0 · **Command:** `/slopsquatting-deep-refresh`

> **Claude Code mode:** pure research + recommendation skill, writes nothing into the guard mechanics → **`plan`** (plan mode): the update recommendation emerges in dialogue, implemented only after operator approval (ideally as its own story). Details: HANDBUCH §6 "Claude Code mode" and **Appendix AE**.

---

## What the skill does

The skill is the **manual quarterly layer** of the slopsquatting guard and a thin orchestrator: it runs `/research` (deep research) with a fixed quarterly prompt template and reconciles the wordlist *methodology* against the current research state. Four dimensions:

1. **New data sources** — new public advisory / malicious-package feeds that would increase coverage
2. **Changed/deprecated feeds** — have the currently used sources changed schema, endpoint, or availability? Is one dead?
3. **Research state of the methodology** — new attack vectors, new ecosystems, new detection methods
4. **Threshold candidates** — age check, 90-day freshness, source filters: still sensible?

Output is an **update recommendation** plus an optional threshold proposal — **no auto-write**. The operator decides what flows back into the templates.

---

## What problem it solves

Schrader names slopsquatting as its own AI-specific attack vector: **19.7% of AI-recommended packages do not exist** (*Code Crash* ch. 3-4). Attackers register exactly these hallucinated or typosquatted names with malware. The weekly auto-refresh (layer 1) keeps the *known cases* current — but a guard whose **sources** age goes blind unnoticed. Just as a configured quality gate can still be blind (wiring canary, BOO-183), an auto-refreshed guard can draw from the wrong sources.

The quarterly review forces the deliberate pause: not "is the list fresh?" (that's layer 1) but "are we still querying the *right* sources, with the *right* filters, against the *current* research state?".

---

## Two layers — boundary

| Layer | What | Cadence | Maintains | Mechanism |
|-------|------|---------|-----------|-----------|
| **1 — Data refresh** | keep wordlist *entries* current | weekly (cron) | `wordlist.txt` | `slopsquatting-refresh.yml` → PR |
| **2 — Methodology review** (this skill) | review the *method* behind the wordlist | quarterly (manual) | sources, filters, thresholds | `/slopsquatting-deep-refresh` → `/research` → recommendation |

Layer 1 **writes** (via PR). Layer 2 only **recommends**.

---

## Triggers

- `/slopsquatting-deep-refresh`
- "slopsquatting quarterly review"
- "review wordlist methodology"
- "new slopsquatting sources"
- "reconcile slopsquatting guard against research state"

---

## Workflow overview (3 steps)

| # | Step | What happens |
|---|------|--------------|
| 1 | **Load context** | Read `wordlist.txt` (incl. `last_refreshed` + entry count), `slopsquatting-override.yaml`, `slopsquatting-refresh.yml` (→ source list, filters). Missing file = note it, no hard fail. |
| 2 | **Run `/research`** | Fill the quarterly prompt template from [references/quarterly-review-prompt.md](references/quarterly-review-prompt.md) with the current state and pass to `/research` (deep research) — 4 dimensions, cited. |
| 3 | **Recommendation** | Condense the `/research` result into an update recommendation + optional threshold proposal. No auto-write. Report storage `journal/reports/slopsquatting/quarterly-<YYYY-Qn>.md` only on confirmation. |

---

## Output

Structured recommendation (no write access to wordlist/workflow):

1. **Summary** — did the methodology move, action needed yes/no
2. **Source recommendations** — `Source | Status | Recommendation | Rationale + citation`
3. **Threshold-adjustment proposal** (optional) — `Threshold | current | proposal | rationale`
4. **Research notes** — new findings with source links
5. **Next steps** — which template file to touch, whether a story is needed

---

## Modes / features

- **Quarterly review (default)** — the full 3-step run against the current research state.
- **Ad-hoc review** — the same run outside the quarterly cadence, triggered by a concrete event (dead source, new attack vector, repeatedly stale wordlist in `quality-gate-audit`).
- **Diff-to-prior-quarter** — if an earlier report exists under `journal/reports/slopsquatting/`, the skill builds the delta to the last review.
- **Graceful degradation** — if a context file is missing, the review runs with what's there and notes the gap.

---

## Sparring-partner principle

The skill **writes nothing** into the guard mechanics. A methodology change to the supply-chain gate is security-relevant and belongs documented and reviewed — ideally as its own story through the pipeline (`/intent` → ... → `/implement`), not auto-committed. The skill researches, compares against the current state, recommends with justification. The operator decides. (INTENTRON guiding principle: lightweight + pragmatic, no security compromises.)

---

## Background

Slopsquatting only works while a malicious name slips through unnoticed. A project-local wordlist of known cases is the cheapest early detection — a `grep` instead of a registry roundtrip, and it bites even offline. For this list to stay reliable it needs two maintenance layers: a **data layer** that auto-refreshes the entries weekly (layer 1), and a **methodology layer** that quarterly checks whether the refresh method itself is still right (this skill).

The split is deliberate: data changes fast and is automatable (new malicious packages daily) — methodology changes slowly and needs judgment (add a source, shift a threshold, deprecate a source). Running the slow part quarterly and manually is lightweight; automating it would be over-engineering and would remove a security-relevant decision from review.

---

## Sources

- **Book:** Matthias Schrader, *Code Crash* (2025), ch. 3-4 — slopsquatting as an AI-specific supply-chain attack vector, the "19.7%" hallucination rate
- **BOO-197** — slopsquatting wordlist + quarterly layer (this skill)
- **BOO-183** — `quality-gate-audit`: checks existence **and** 90-day freshness of the wordlist
- **BOO-12** — `dependency-check.sh`: the pre-commit hook that uses the wordlist
- **HANDBUCH Appendix AE** — slopsquatting wordlist maintenance (full picture of both layers)

---

## Installation and usage

The skill lives under `~/.claude/skills/slopsquatting-deep-refresh/` (local) or `intentron/slopsquatting-deep-refresh/` in the repo. Requires an available `/research` skill (deep research). Activated after the setup script (`setup.sh`).

Usage in chat:

```
/slopsquatting-deep-refresh
```

Or via trigger phrase:

```
slopsquatting quarterly review is due — reconcile the wordlist methodology against the current state
```

The skill loads the context, runs `/research`, and presents the update recommendation.

---

## File structure

```
intentron/slopsquatting-deep-refresh/
├── SKILL.md                          ← skill definition (DE — primary)
├── SKILL.en.md                       ← skill definition (EN)
├── README.md                         ← German README
├── README.en.md                      ← this file (EN)
└── references/
    └── quarterly-review-prompt.md       ← /research prompt template for the quarterly review (DE + EN)
```

> Note: the overview sketch (`slopsquatting-deep-refresh-overview.excalidraw`/`.png` + `.en`) will be added in a later central render pass and is still missing.
