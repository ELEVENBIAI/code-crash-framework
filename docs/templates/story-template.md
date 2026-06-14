# Story-Template

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](story-template.en.md)

> Vorlage (BOO-214) für eine umsetzbare Story. Der Abschnitt **„Doku-Konsistenz"** ist ab **Sprint 3** Pflicht-Akzeptanz für jede Story, die Doku anfasst — er verweist auf die ausführliche [`../standards/doku-consistency-checklist.md`](../standards/doku-consistency-checklist.md). Kopieren, ausfüllen, nicht-zutreffende Punkte mit kurzer Begründung als *n/a* markieren.

---

## BOO-XXX — <Titel>

- **Label / Typ:** <governance | feature | fix | doku | …>
- **Story Points:** <Token-Schätzung + Ausführungsmodus: agentic | sub-agents | linear>
- **Branch:** `feat/boo-xxx-<slug>`
- **Spec:** `specs/BOO-XXX.md`

### Kontext / Warum

<1–3 Sätze: Auslöser, Problem, Operator-Quelle.>

### Akzeptanzkriterien

- [ ] <Kriterium 1>
- [ ] <Kriterium 2>
- [ ] …

### Doku-Konsistenz (Pflicht — siehe docs/standards/doku-consistency-checklist.md)

- [ ] **Zweisprachigkeit DE+EN** — EN-Spiegel/Anker vorhanden, inhaltlich äquivalent.
- [ ] **Skill-Dateien synchron** — `SKILL`/`README` je `.md`/`.en.md`, Version gleichstand.
- [ ] **HANDBUCH-Sektion (DE+EN)** — Mechanik im HANDBUCH eingetragen.
- [ ] **CONVENTIONS.md** — bei neuer Konvention ergänzt.
- [ ] **Doku-Index + README-Skills-Tabelle** — `docs/INDEX.md` verlinkt; neuer Skill in README-Tabelle.
- [ ] **Sketches** — Excalidraw DE+EN (`-overview.excalidraw` + `.png`), render-loop-geprüft.
- [ ] **Vault-Doku** — `03 Bereiche/Skills/<skill>.md` (+ `.en`) nachgezogen.
- [ ] **Vault-Index / PMO-Hub-Wikilinks** — neue Notiz vernetzt (kein Orphan).
- [ ] **Cross-Links** — ADRs / Skills / Runbooks verlinkt.
- [ ] **Glossar-Begriffe** — HANDBUCH Anhang C + `docs/glossar` ergänzt.
- [ ] **docs-drift-Check grün** — `python3 .github/scripts/docs_drift_check.py` rc=0.

> Nicht-zutreffende Punkte als `n/a — <Grund>` markieren, nicht löschen.

### Verweise

<ADRs · verwandte BOO · Runbooks · Release-Note (`docs/releases/...`)>
