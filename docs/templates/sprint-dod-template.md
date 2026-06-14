# Sprint-Definition-of-Done — Template

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](sprint-dod-template.en.md)

> Wiederverwendbare Sprint-Abnahme (BOO-216). Kopieren in den jeweiligen Sprint-Block (`Sprints.md`) und abhaken. Der Punkt **„Release-Note geschrieben und veröffentlicht"** ist ab **Sprint 3** verpflichtend — die Release-Note ist kein optionaler Nachklapp, sondern Teil der Sprint-Abnahme. Verweise: [`../standards/doku-consistency-checklist.md`](../standards/doku-consistency-checklist.md), [`../releases/_index.md`](../releases/_index.md).

---

## Sprint N — Definition of Done

- [ ] **Alle Stories umgesetzt** — jede Sprint-Story `Done` (Linear), Akzeptanzkriterien erfüllt.
- [ ] **Quality-Gates grün** — Semgrep, ESLint/Ruff, Coverage ≥ 80 % auf neuem Code, GitHub Actions; `docs_drift_check.py` rc=0.
- [ ] **Doku-Konsistenz** — für jede Doku-ändernde Story die [Doku-Konsistenz-Checkliste](../standards/doku-consistency-checklist.md) erfüllt (DE+EN, Skill-Dateien, HANDBUCH, Index, Sketches, Vault, Cross-Links, Glossar).
- [ ] **Release-Note geschrieben und veröffentlicht** *(Pflicht ab Sprint 3)* — `docs/releases/sprint-N.md` (+ `.en.md`) nach [`_template-sprint.md`](../releases/_template-sprint.md), Versions-Overview `docs/releases/vX.Y.Z-overview.md`, Eintrag in [`_index.md`](../releases/_index.md) (+ `.en.md`) und Vault-MoC `03 Bereiche/Skills/_Releases.md`.
- [ ] **Sprint-Journal** — `journal/sprint-{date}.md` geschrieben (`/sprint-review`-Aggregation), Learnings festgehalten.
- [ ] **Kosten-Snapshot** — `bash .claude/hooks/ccusage-capture.sh "/sprint-run <sprint>"` gelaufen, Eintrag in `docs/financials/sprint-costs.md` (BOO-189).
- [ ] **ADR-Status** — alle im Sprint entschiedenen ADRs im Vault auf `entschieden`/`superseded` nachgezogen.
- [ ] **Linear/Vault synchron** — Stories `Done`, PMO-HUB-Wikilinks, Daily Note, `Sprints.md`-DoD abgehakt.

> Nicht-zutreffende Punkte mit kurzer Begründung als *n/a* markieren, nicht stillschweigend weglassen.
