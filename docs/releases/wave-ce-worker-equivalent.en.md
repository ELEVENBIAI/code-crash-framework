# Wave CE — Worker-equivalent: a second steering dimension alongside token consumption (BOO-190 / BOO-191 / BOO-192 / BOO-193)

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](wave-ce-worker-equivalent.md)

**What is now in place:** Token consumption is an **input metric** — it tells you what a sprint costs, not what it is worth. With Sprint 4 (4a + 4b) the second axis arrives: the **worker-equivalent**. ROI = human-equivalent cost ÷ AI cost — that is, what a sprint would have cost a human, divided by what the AI cost. Four stories build the foundation: a global **dual column** (`effort_ai_hours` + `effort_human_equiv_hours`) on every new story, a new skill **`financials`** with geo billing rates, an **actuals report** in sprint review and a **forecast** in the backlog. The lesson behind it: **what you measure only on the input, you cannot steer on the output.**

## The lesson — input metric vs. output steering

Token consumption (ccusage, predecessor wave) answers the question "what did this cost?". That is necessary, but blind to the actual steering question: "was it worth it?". A sprint that burns 12 USD of tokens and replaces three person-weeks of developer work is a different case from one that burns the same 12 USD and saves half an hour — on pure token consumption both look identical.

The **worker-equivalent** makes that difference measurable. It puts a second axis opposite the AI-cost axis: what the same work would have cost a human (`effort_human_equiv_hours` × billing rate). The quotient is the **ROI** — output steering instead of input bookkeeping. Decided in **ADR-D** (2026-06-15): token stays the input metric, worker-equivalent becomes the output dimension. Both run in parallel, neither replaces the other.

## Changes

- **Dual column in the global story template (BOO-193):** every new story now carries `effort_ai_hours` **and** `effort_human_equiv_hours` (vault `User-Story-Template.md`). Both fields are **mandatory for new stories** — **no backfill**: the legacy stories BOO-183–188 are exempt. The **`backlog` skill (v1.6.0)** validates the dual column deterministically: new stories missing either field are flagged and do **not** count as sprint-ready. Documented in HANDBOOK appendix G.
- **New skill `financials` (v1.0.0) + templates (BOO-190):** a template generator that produces `docs/financials/budget.md` and `docs/financials/worker-equivalent-baseline.md`. The billing rates come from an internal senior-dev-rates primary source — two default sets per geo: **external** (freelance/contract, P50) CH 137 / DE 95 / AT 85 / US 120 and **conservative internal** CH 99 / DE 58 / AT 57 / US 116, each in **native currency — no FX cross-conversion** (only a note when the deviation exceeds 5 %). On conflict the **internal set takes precedence**. Activated via the bootstrap (`intentron init` A.9 + Phase 4.4o) including the mandatory quartet: HANDBOOK appendix AK, `migrate_boo_190`, `verify-setup`. Basis: **ADR-D → decided**.
- **`sprint-review` (v2.7.0) — worker-equivalent report, actuals (BOO-191):** a new **step 9b** aggregates, per sprint, the AI cost, the human-equivalent cost, the ROI and the wall-clock time — from the dual column, `ccusage` and the billing rate. Stored as `docs/financials/sprint-XX-worker-equivalent.md`.
- **`backlog` (v1.7.0) — forecast block (BOO-192):** expected AI cost (from `token_estimate` × tier price), human-equivalent (from the dual column × rate), ROI and sprint aggregate — **before** the sprint. Persisted as `docs/financials/sprint-XX-forecast.md` with a **field-identical schema** to the actuals report. The **forecast-vs-actuals drift** is a quality-gate **signal**, not a hard block.

## Migration — retrofitting existing projects

- **Activate financials:** existing projects enable the financials module via `/bootstrap` (A.9) resp. `migrate_boo_190`. Idempotent, non-destructive.
- **Dual column:** applies **to new stories only**. Existing stories are not filled retroactively (no backfill, BOO-183–188 exempt).

## Scope

- **ROI language stays internal for now** — only after ≥ 3 sprints of real data does the worker-equivalent get carried outward.
- **No own framework version tag** — Sprint 4 is a **sprint release note** (Wave ce), not a version release. The next SemVer tag stays **v0.12.0 for Sprint 5**.
- Wave letter **ce** (cd = Semgrep custom-rule wiring BOO-185/188).

## References

ADR-D "Worker-equivalent — a second steering dimension alongside token consumption" (2026-06-15, decided). Specs: `specs/BOO-190.md`, `specs/BOO-191.md`, `specs/BOO-192.md`, `specs/BOO-193.md`. Related: BOO-189 (ccusage token/cost hook, input metric), README.
