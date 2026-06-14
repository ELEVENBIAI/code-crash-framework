# Sprint Definition of Done — Template

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](sprint-dod-template.md)

> Reusable sprint sign-off (BOO-216). Copy into the relevant sprint block (`Sprints.md`) and check off. The item **"Release note written and published"** is mandatory from **Sprint 3** onward — the release note is not an optional afterthought but part of the sprint sign-off. References: [`../standards/doku-consistency-checklist.en.md`](../standards/doku-consistency-checklist.en.md), [`../releases/_index.en.md`](../releases/_index.en.md).

---

## Sprint N — Definition of Done

- [ ] **All stories delivered** — every sprint story `Done` (Linear), acceptance criteria met.
- [ ] **Quality gates green** — Semgrep, ESLint/Ruff, coverage ≥ 80 % on new code, GitHub Actions; `docs_drift_check.py` rc=0.
- [ ] **Documentation consistency** — for every doc-changing story the [documentation consistency checklist](../standards/doku-consistency-checklist.en.md) is met (DE+EN, skill files, HANDBUCH, index, sketches, vault, cross-links, glossary).
- [ ] **Release note written and published** *(mandatory from Sprint 3)* — `docs/releases/sprint-N.md` (+ `.en.md`) per [`_template-sprint.en.md`](../releases/_template-sprint.en.md), version overview `docs/releases/vX.Y.Z-overview.md`, entry in [`_index.en.md`](../releases/_index.en.md) (+ `.md`) and vault MoC `03 Bereiche/Skills/_Releases.md`.
- [ ] **Sprint journal** — `journal/sprint-{date}.md` written (`/sprint-review` aggregation), learnings captured.
- [ ] **Cost snapshot** — `bash .claude/hooks/ccusage-capture.sh "/sprint-run <sprint>"` run, entry in `docs/financials/sprint-costs.md` (BOO-189).
- [ ] **ADR status** — all ADRs decided in the sprint updated in the vault to `entschieden`/`superseded`.
- [ ] **Linear/vault in sync** — stories `Done`, PMO hub wikilinks, daily note, `Sprints.md` DoD checked off.

> Mark non-applicable items as *n/a* with a brief reason, do not silently omit them.
