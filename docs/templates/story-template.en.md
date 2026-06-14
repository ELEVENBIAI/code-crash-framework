# Story Template

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](story-template.md)

> Template (BOO-214) for an actionable story. The **"Documentation Consistency"** section is mandatory acceptance from **Sprint 3** for every story that touches documentation — it points to the detailed [`../standards/doku-consistency-checklist.en.md`](../standards/doku-consistency-checklist.en.md). Copy, fill in, mark non-applicable points as *n/a* with a short reason.

---

## BOO-XXX — <title>

- **Label / type:** <governance | feature | fix | docs | …>
- **Story points:** <token estimate + execution mode: agentic | sub-agents | linear>
- **Branch:** `feat/boo-xxx-<slug>`
- **Spec:** `specs/BOO-XXX.md`

### Context / why

<1–3 sentences: trigger, problem, operator source.>

### Acceptance criteria

- [ ] <criterion 1>
- [ ] <criterion 2>
- [ ] …

### Documentation Consistency (mandatory — see docs/standards/doku-consistency-checklist.md)

- [ ] **Bilingual DE+EN** — EN mirror/anchor present, content-equivalent.
- [ ] **Skill files in sync** — `SKILL`/`README` each `.md`/`.en.md`, versions in lockstep.
- [ ] **HANDBUCH section (DE+EN)** — mechanic recorded in the HANDBUCH.
- [ ] **CONVENTIONS.md** — updated on a new convention.
- [ ] **Doc index + README skills table** — `docs/INDEX.md` linked; new skill in README table.
- [ ] **Sketches** — Excalidraw DE+EN (`-overview.excalidraw` + `.png`), render-loop verified.
- [ ] **Vault docs** — `03 Bereiche/Skills/<skill>.md` (+ `.en`) caught up.
- [ ] **Vault index / PMO hub wikilinks** — new note wired in (no orphan).
- [ ] **Cross-links** — ADRs / skills / runbooks linked.
- [ ] **Glossary terms** — HANDBUCH Appendix C + `docs/glossar` updated.
- [ ] **docs-drift check green** — `python3 .github/scripts/docs_drift_check.py` rc=0.

> Mark non-applicable points as `n/a — <reason>`, do not delete them.

### References

<ADRs · related BOO · runbooks · release note (`docs/releases/...`)>
