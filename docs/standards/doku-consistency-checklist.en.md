# Documentation Consistency Checklist (mandatory acceptance)

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](doku-consistency-checklist.md)

> Reproducible acceptance block (BOO-214): From **Sprint 3** onward this checklist is copied as **mandatory acceptance** into **every documentation-touching story**. It makes the *docs-in-sync* principle (see [`../how-we-document.en.md`](../how-we-document.en.md)) operational — a tickable list instead of hoped-for discipline. The last criterion, **docs-drift green**, is the machine gate that enforces the remaining points by spot check.

## Why

A story that touches documentation is only **done** once every applicable point below is checked. "Applicable" means: not every story touches every point — a pure release-note story needs no sketch, a new convention does. The duty is to **consciously check** each point and mark non-applicable ones as *n/a* with a short reason rather than silently skipping them.

## The checklist (to copy into the story)

```markdown
## Documentation Consistency (mandatory — see docs/standards/doku-consistency-checklist.md)

- [ ] **Bilingual DE+EN** — every new/changed doc file has its EN mirror (`.en.md`) or EN anchor, content-equivalent (not 1:1 word translation; code identifiers, BOO numbers, paths, links verbatim).
- [ ] **Skill files in sync** — on a skill change `SKILL.md`/`SKILL.en.md` **and** `README.md`/`README.en.md` are maintained together; `version:` (SKILL) == `**Version:**` (README) in DE **and** EN.
- [ ] **HANDBUCH section (DE+EN)** — new/changed mechanic recorded in the HANDBUCH (§ or appendix), DE and EN in lockstep.
- [ ] **CONVENTIONS.md** — on a **new convention** (tool/adapter contract, branching, naming) `CONVENTIONS.md` is updated.
- [ ] **Doc index + README skills table** — new doc is linked in the central doc index (`docs/INDEX.md`); a new skill is entered in the **README skills table** (`({skill}/)` link, enforced by the docs-drift check).
- [ ] **Sketches** — where a concept calls for a visual, the Excalidraw pair DE+EN exists (`<name>-overview.excalidraw` + `.png` **and** `<name>-overview.en.excalidraw` + `.en.png`), visually verified via render loop.
- [ ] **Vault docs** — if a skill is affected: `03 Bereiche/Skills/<skill>.md` (+ `.en`) in SecondBrain caught up.
- [ ] **Vault index / PMO hub wikilinks** — new vault note wired into index/PMO hub via wikilink (no orphan).
- [ ] **Cross-links** — references to affected ADRs / skills / runbooks are set (bidirectional where sensible).
- [ ] **Glossary terms** — new domain terms explained (**HANDBUCH Appendix C** + `docs/glossar.md`/`.en.md`).
- [ ] **docs-drift check green** — `python3 .github/scripts/docs_drift_check.py` runs with **rc=0** (gate; no dead `references/` links, no version drift, DE/EN parity, complete skills table, no wave duplication).
```

## The points in detail

1. **Bilingual DE+EN.** Every documentation-touching story produces DE **and** EN. The EN part is a faithful mirror (same structure, tables, identifiers), not a literal prose translation. Trigger sentences and examples may stay in the original working language; descriptions and workflows are in lockstep across both languages.
2. **Skill files in sync.** When a skill changes, `SKILL.md` + `SKILL.en.md` + `README.md` + `README.en.md` are touched together. The version in the SKILL front matter (`version:`) and in the README (`**Version:**`) must be identical — in DE and EN. Otherwise the docs-drift check fails with `[version-drift]`.
3. **HANDBUCH section.** New mechanics, new gates, new runbooks are anchored in the HANDBUCH (matching `§` or an appendix) — DE and EN. The HANDBUCH is the human reference; what lives only in a release note is not discoverable.
4. **CONVENTIONS.md.** As soon as a **convention** is introduced or changed (tool/adapter contract, branching scheme, naming, wave-letter assignment), `CONVENTIONS.md` is carried along. Conventions are contracts — they belong in the one contractual place, not scattered.
5. **Doc index + README skills table.** New doc files are linked in the central doc index `docs/INDEX.md`. A **new skill** must additionally appear in the **skills table of the repo `README.md`** (link form `({skill}/)`) — this point is enforced by the docs-drift check (`[skills-table]`) at machine level.
6. **Sketches.** Where a concept needs a picture, an Excalidraw sketch belongs with it — DE **and** EN: `<name>-overview.excalidraw` + `.png` plus `<name>-overview.en.excalidraw` + `.en.png`. Sketches are not written "blind" but verified in the render loop (JSON → PNG → Read visual check → fix).
7. **Vault docs.** If a skill is affected, the SecondBrain skill doc under `03 Bereiche/Skills/<skill>.md` (+ `.en`) is caught up — including version history.
8. **Vault index / PMO hub wikilinks.** New vault notes are wired into index/PMO hub via wikilinks so no orphaned notes arise.
9. **Cross-links.** Affected **ADRs**, **skills** and **runbooks** are mutually linked. A doc that does not know its neighbours is not found.
10. **Glossary terms.** New domain terms are explained — both in the technical short form (**HANDBUCH Appendix C**) and in the plain-language glossary `docs/glossar.md` (+ `.en.md`).
11. **docs-drift check green.** The machine gate. `python3 .github/scripts/docs_drift_check.py` must return **rc=0**. It checks dead `references/*.md` links, SKILL↔README version parity, DE/EN parity, completeness of the skills table and duplicate release wave letters. As long as this gate is red the story is **not** done.

## References

[`../how-we-document.en.md`](../how-we-document.en.md) (doc map) · HANDBUCH §7 (artifacts) / Appendix C (glossary) · `docs/glossar.en.md` · `.github/scripts/docs_drift_check.py` (gate) · `docs/templates/story-template.en.md` (story template with the embedded mandatory block) · release-notes standard: [`../releases/_template-sprint.en.md`](../releases/_template-sprint.en.md). Related: Wave BW (docs definition-of-done, BOO-180), BOO-216 (release-notes standard).
