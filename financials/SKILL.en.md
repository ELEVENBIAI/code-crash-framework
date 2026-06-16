---
name: financials
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Template generator for the worker-equivalent / ROI view of a project. Creates and maintains the
  financials templates: budget.md + worker-equivalent-baseline.md. Holds the active billing rate and the
  market-research geo defaults as a fallback. NOT a runtime calculator — report (BOO-191) and forecast
  (BOO-192) consume the templates.
  Use when the operator says "Financials", "Verrechnungssatz", "ROI", "Worker-Equivalent" or "/financials".
version: 1.0.0
metadata:
  hermes:
    category: governance
    tags: [financials, roi, worker-equivalent, bootstrap]
    related_skills: [bootstrap, sprint-review, backlog]
---

# Financials

Template generator and documentation skill for the worker-equivalent / ROI view of a project. The skill
creates two templates and keeps them current — it does **not** calculate at runtime.

## What the skill does

It generates and maintains the two canonical financials templates under `docs/financials/`:

| Template | Content |
|----------|---------|
| `budget.md` | Lean project budget: active billing rate, currency/geo, optional token-cost assumption. References the baseline and `sprint-costs.md`. |
| `worker-equivalent-baseline.md` | Active project billing rate (section 1) plus the market-research geo defaults as a fallback (section 2) plus methodology/maintenance (section 3). |

Activation does not happen through the skill directly but through the **financials question in
`/bootstrap`** (see "Activation"). On *yes*, the templates are created and the active billing rate is set.

## Scope — not a runtime calculator

The skill provides the **data structure**, not the calculation. The actual ROI / worker-equivalent
calculation happens in the consumers:

| Consumer | Story | What it reads from the templates |
|----------|-------|----------------------------------|
| `/sprint-review` (worker-equivalent report) | BOO-191 | active rate from section 1 of the baseline |
| `/backlog` (sprint forecast) | BOO-192 | active rate from section 1 of the baseline |
| Actual-cost snapshot | BOO-189 (`sprint-costs.md`, already live) | kept alongside, not replaced |

The data source of the calculation is the dual column `effort_ai_hours` / `effort_human_equiv_hours` per
story (BOO-193). The skill is lightweight: no external tooling, no copy of the study — it references the
internal deep research as the data source.

## Activation (via /bootstrap)

`/bootstrap` asks the financials question during setup:

1. **Activate financials?** — on *yes* the skill creates `budget.md` + `worker-equivalent-baseline.md`.
2. **Internal billing rate?** — the four geo defaults (CH/DE/AT/US) are shown as a visible choice with
   source reference.
   - Operator enters own rate → `source: intern`.
   - Question skipped → market-research default → `source: market-research-2026`.

**Internal precedence:** If an entered internal rate exists, it beats the market-research default —
always (ADR-D, decided 2026-06-15).

## The two default sets per geo

Values from `docs/financials/worker-equivalent-baseline.md` (source: internal deep research
`02 Projekte/Code-Crash Framework/Research/2026-06-13 senior_dev_rates_baseline.md`, Owlist GmbH, survey
data 2025). `source: market-research-2026`, `erhebungsjahr: 2025`.

### Primary default — external freelance/contract P50 (opportunity-cost basis)

Recommended ROI basis. What would outsourcing the same work to a senior freelancer (5–10 yrs) have cost?
P50 (median), more robust than P75.

| Geo | Default | Confidence |
|-----|---------|------------|
| Switzerland (CHF) | CHF 137 / h | ★★☆ Medium |
| Germany (EUR) | EUR 95 / h | ★★★ High |
| Austria (EUR) | EUR 85 / h | ★★☆ Medium |
| USA (USD) | USD 120 / h | ★★★ High |

### Conservative default — internal fully-loaded lower bound

Fully-loaded hourly rate of a permanently employed senior dev. Lower bound for a more conservative ROI
calculation.

| Geo | Default |
|-----|---------|
| Switzerland (CHF) | CHF 99 / h |
| Germany (EUR) | EUR 58 / h |
| Austria (EUR) | EUR 57 / h |
| USA (USD) | USD 116 / h |

## Rule: native currency, no FX cross-conversion

Rates stay in the native currency per geo (CH CHF, DE/AT EUR, US USD). **No** FX cross-conversion. On a
rate drift >5 % versus the start of the year, only a user note — no automatic conversion (primary source
§2.3).

## Source obligation

Every value in the baseline file carries machine-readable:

- `source: intern` (operator input) **or** `source: market-research-2026` (geo default)
- `erhebungsjahr:` — for `intern` the year of the internal rate; for `market-research-2026` the year 2025

On a conflict between internal and market research, **internal precedence** applies. The source hierarchy
within the market-research values (BLS > Robert Half > Stack Overflow survey for USA; swissICT S3 for
CH senior) is documented in baseline section 3.

## Data source / references

- **Dual column** `effort_ai_hours` / `effort_human_equiv_hours` per story — BOO-193 (data source of the calculation).
- **Worker-equivalent report** in `/sprint-review` — BOO-191 (consumer).
- **Sprint forecast** in `/backlog` — BOO-192 (consumer).
- **Actual costs** `docs/financials/sprint-costs.md` — BOO-189 (ccusage snapshots, already live, kept alongside).
- **Primary source of baseline figures** — internal deep research `Research/2026-06-13 senior_dev_rates_baseline.md`.

## File structure

```
financials/
├── SKILL.md          ← skill definition (DE, read by Claude Code)
├── SKILL.en.md       ← skill definition (EN)
├── README.md         ← detailed docs (DE)
├── README.en.md      ← detailed docs (EN)
└── overview.png      ← overview diagram (delivered by a separate cluster)

docs/financials/                       ← canonical template sources (maintained by the skill)
├── budget.md
├── worker-equivalent-baseline.md
└── sprint-costs.md                    ← BOO-189, kept alongside
```
