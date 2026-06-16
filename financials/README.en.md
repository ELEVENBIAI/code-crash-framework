<a name="english"></a>

# Financials — Template Generator for the Worker-Equivalent / ROI View

> Creates and maintains the financials templates: `budget.md` + `worker-equivalent-baseline.md`. Holds the active billing rate and the market-research geo defaults as a fallback. Not a runtime calculator — the calculation happens in the consumers.

**Version:** 1.0.0 · **Command:** `/financials`

> **Activation:** Do not call directly — the templates are created via the **financials question in `/bootstrap`**. See "Activation".

---

## What the skill does

To turn AI effort into an ROI factor in **money**, the framework needs two things: a project-specific billing rate and an evidenced baseline. The `financials` skill provides both as a template — not as a calculation.

It generates and maintains two canonical templates under `docs/financials/`:

- **`budget.md`** — lean project budget: active billing rate, currency/geo, optional token-cost assumption. References the baseline and `sprint-costs.md` (BOO-189) without duplicating their content.
- **`worker-equivalent-baseline.md`** — the active project billing rate (section 1), the market-research geo defaults as a fallback (section 2), and the methodology/maintenance note (section 3).

The skill is **lightweight**: no external tooling, no copy of the study. The baseline figures come from the internal deep research, which the skill references instead of shipping a copy.

---

## Why

Not every operator has an internal billing rate at hand. So the ROI calculation works immediately anyway, the skill stores a researched geo default as a fallback. This lets the framework derive an ROI factor from the dual column `effort_ai_hours` / `effort_human_equiv_hours` (BOO-193) — either with the operator's own rate or with the market-research default.

ROI language stays internal for now, until ≥3 sprints of data exist (ADR-D §Open).

---

## Scope — not a runtime calculator

The skill provides the data structure. The actual calculation is done by the consumers:

| Consumer | Story | What it reads |
|----------|-------|---------------|
| `/sprint-review` — worker-equivalent report | BOO-191 | active rate from section 1 of the baseline |
| `/backlog` — sprint forecast | BOO-192 | active rate from section 1 of the baseline |
| `sprint-costs.md` — actual costs (ccusage) | BOO-189 (live) | kept alongside, not replaced |

How the ROI view calculates (short form):

```
AI cost                = measured token / cost consumption (sprint-costs.md)
Human-equiv cost       = Σ effort_human_equiv_hours of the sprint stories × rate_per_hour
ROI factor             = human-equiv cost ÷ AI cost
Wall clock             = real sprint duration from the sprint log
```

---

## Activation (via /bootstrap)

`/bootstrap` asks the financials question during setup:

1. **Activate financials?** — on *yes* the skill creates `budget.md` + `worker-equivalent-baseline.md`.
2. **Internal billing rate?** — the four geo defaults are shown as a visible choice with source reference:
   - Operator enters own rate → `source: intern`.
   - Question skipped → market-research default → `source: market-research-2026`.

**Internal precedence:** If an entered internal rate exists, it beats the market-research default — always (ADR-D, decided 2026-06-15).

---

## The two default sets per geo

Values from the internal deep research `Research/2026-06-13 senior_dev_rates_baseline.md` (Owlist GmbH, survey data 2025). `source: market-research-2026`, `erhebungsjahr: 2025`.

### Primary default — external freelance/contract P50 (opportunity-cost basis)

Recommended ROI basis. What would outsourcing to a senior freelancer (5–10 yrs) have cost? P50 (median), more robust than P75.

| Geo | Default | Confidence | Sources |
|-----|---------|------------|---------|
| Switzerland (CHF) | **CHF 137 / h** | ★★☆ Medium | swissICT 2025 S3; salary2freelance.com |
| Germany (EUR) | **EUR 95 / h** | ★★★ High | freelancermap Kompass 2025 |
| Austria (EUR) | **EUR 85 / h** | ★★☆ Medium | DACH derivation (~10 % below DE) |
| USA (USD) | **USD 120 / h** | ★★★ High | BLS OEWS May 2025; Robert Half 2025 |

### Conservative default — internal fully-loaded lower bound

Fully-loaded hourly rate of a permanently employed senior dev. Lower bound for a more conservative ROI calculation.

| Geo | Default |
|-----|---------|
| Switzerland (CHF) | **CHF 99 / h** |
| Germany (EUR) | **EUR 58 / h** |
| Austria (EUR) | **EUR 57 / h** |
| USA (USD) | **USD 116 / h** |

---

## Rule: native currency, no FX cross-conversion

Rates stay in the native currency per geo (CH CHF, DE/AT EUR, US USD). **No** FX cross-conversion. On a rate drift >5 % versus the start of the year, only a user note — no automatic conversion (primary source §2.3).

---

## Source obligation

Every value in the baseline file carries machine-readable `source:` and `erhebungsjahr:`:

- `source: intern` (operator input) or `source: market-research-2026` (geo default)
- `erhebungsjahr:` — for `intern` the year of the internal rate; for `market-research-2026` the year 2025

Source hierarchy on conflict within the market-research values (baseline section 3): BLS OEWS > Robert Half > Stack Overflow survey (USA); swissICT S3 for CH senior.

---

## Trigger phrases

- `/financials`
- "Financials"
- "Verrechnungssatz"
- "ROI"
- "Worker-Equivalent"

---

## Installation

```bash
cp -r financials ~/.claude/skills/financials
```

---

## File structure

```
financials/
├── SKILL.md          ← skill definition (DE, read by Claude Code)
├── SKILL.en.md       ← skill definition (EN)
├── README.md         ← docs (DE)
├── README.en.md      ← this file (EN)
└── overview.png      ← overview diagram (delivered by a separate cluster)

docs/financials/                       ← canonical template sources (maintained by the skill)
├── budget.md
├── worker-equivalent-baseline.md
└── sprint-costs.md                    ← BOO-189, kept alongside
```
