# Doku-Konsistenz-Checkliste (Pflicht-Akzeptanz)

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](doku-consistency-checklist.en.md)

> Reproduzierbarer Akzeptanz-Block (BOO-214): Ab **Sprint 3** wird diese Checkliste als **Pflicht-Akzeptanz** in **jede Doku-ändernde Story** kopiert. Sie macht das *Doku-synchron*-Prinzip (siehe [`../how-we-document.md`](../how-we-document.md)) operativ — eine abhakbare Liste statt gehoffter Disziplin. Das letzte Kriterium, **docs-drift grün**, ist das maschinelle Gate, das die übrigen Punkte stichprobenartig erzwingt.

## Wofür

Eine Story, die Doku anfasst, ist erst **done**, wenn alle zutreffenden Punkte unten abgehakt sind. „Zutreffend" heißt: nicht jede Story berührt jeden Punkt — eine reine Release-Note-Story braucht keinen Sketch, eine neue Konvention schon. Pflicht ist, jeden Punkt **bewusst zu prüfen** und nicht-zutreffende mit kurzer Begründung als *n/a* zu markieren statt stillschweigend zu überspringen.

## Die Checkliste (zum Kopieren in die Story)

```markdown
## Doku-Konsistenz (Pflicht — siehe docs/standards/doku-consistency-checklist.md)

- [ ] **Zweisprachigkeit DE+EN** — jede neue/geänderte Doku-Datei hat ihren EN-Spiegel (`.en.md`) bzw. den EN-Anker, inhaltlich äquivalent (nicht 1:1 Wort-Übersetzung; Code-Identifier, BOO-Nummern, Pfade, Links wortgleich).
- [ ] **Skill-Dateien synchron** — bei Skill-Änderung sind `SKILL.md`/`SKILL.en.md` **und** `README.md`/`README.en.md` gemeinsam gepflegt; `version:` (SKILL) == `**Version:**` (README) in DE **und** EN.
- [ ] **HANDBUCH-Sektion (DE+EN)** — neue/geänderte Mechanik ist im HANDBUCH (§ oder Anhang) eingetragen, DE und EN gleichstand.
- [ ] **CONVENTIONS.md** — bei **neuer Konvention** (Tool-/Adapter-Vertrag, Branching, Naming) ist `CONVENTIONS.md` ergänzt.
- [ ] **Doku-Index + README-Skills-Tabelle** — neue Doku ist im zentralen Doku-Index (`docs/INDEX.md`) verlinkt; neuer Skill ist in der **README-Skills-Tabelle** eingetragen (`({skill}/)`-Link, vom docs-drift-Check erzwungen).
- [ ] **Sketches** — wo ein Konzept visuell erklärt gehört, existiert das Excalidraw-Paar DE+EN (`<name>-overview.excalidraw` + `.png` **und** `<name>-overview.en.excalidraw` + `.en.png`), via Render-Loop sichtgeprüft.
- [ ] **Vault-Doku** — falls ein Skill betroffen ist: `03 Bereiche/Skills/<skill>.md` (+ `.en`) im SecondBrain nachgezogen.
- [ ] **Vault-Index / PMO-Hub-Wikilinks** — neue Vault-Notiz ist in Index/PMO-Hub via Wikilink vernetzt (kein Orphan).
- [ ] **Cross-Links** — Verweise zu betroffenen ADRs / Skills / Runbooks sind gesetzt (beidseitig wo sinnvoll).
- [ ] **Glossar-Begriffe** — neue Fachbegriffe sind im Glossar erklärt (**HANDBUCH Anhang C** + `docs/glossar.md`/`.en.md`).
- [ ] **docs-drift-Check grün** — `python3 .github/scripts/docs_drift_check.py` läuft mit **rc=0** (Gate; keine toten `references/`-Links, keine Versions-Drift, DE/EN-Parität, vollständige Skills-Tabelle, keine Wave-Dopplung).
```

## Die Punkte ausführlich

1. **Zweisprachigkeit DE+EN.** Jede Doku-ändernde Story produziert DE **und** EN. Der EN-Teil ist ein originalgetreuer Spiegel (gleiche Struktur, Tabellen, Identifier), keine wortwörtliche Übersetzung der Prosa. Trigger-Sätze und Beispiele dürfen in der Original-Arbeitssprache bleiben; Beschreibungen und Workflows sind beidsprachig gleichstand.
2. **Skill-Dateien synchron.** Wird ein Skill geändert, gehören `SKILL.md` + `SKILL.en.md` + `README.md` + `README.en.md` zusammen angefasst. Die Version in der SKILL-Frontmatter (`version:`) und im README (`**Version:**`) müssen identisch sein — in DE und EN. Der docs-drift-Check failt sonst mit `[version-drift]`.
3. **HANDBUCH-Sektion.** Neue Mechanik, neue Gates, neue Runbooks werden im HANDBUCH (passende `§` oder ein Anhang) verankert — DE und EN. Das HANDBUCH ist die menschliche Referenz; was nur in einer Release-Note steht, ist nicht auffindbar.
4. **CONVENTIONS.md.** Sobald eine **Konvention** eingeführt oder geändert wird (Tool-/Adapter-Vertrag, Branching-Schema, Naming, Wave-Buchstaben-Vergabe), wird `CONVENTIONS.md` mitgezogen. Konventionen sind Verträge — sie gehören an die eine vertragliche Stelle, nicht verstreut.
5. **Doku-Index + README-Skills-Tabelle.** Neue Doku-Dateien werden im zentralen Doku-Index `docs/INDEX.md` verlinkt. Ein **neuer Skill** muss zusätzlich in der **Skills-Tabelle der Repo-`README.md`** stehen (Link-Form `({skill}/)`) — diesen Punkt erzwingt der docs-drift-Check (`[skills-table]`) maschinell.
6. **Sketches.** Wo ein Konzept ein Bild braucht, gehört ein Excalidraw-Sketch dazu — DE **und** EN: `<name>-overview.excalidraw` + `.png` sowie `<name>-overview.en.excalidraw` + `.en.png`. Sketches werden nicht „blind" geschrieben, sondern im Render-Loop (JSON → PNG → Read-Sichtprüfung → fix) verifiziert.
7. **Vault-Doku.** Ist ein Skill betroffen, wird die SecondBrain-Skill-Doku unter `03 Bereiche/Skills/<skill>.md` (+ `.en`) nachgezogen — inklusive Versionshistorie.
8. **Vault-Index / PMO-Hub-Wikilinks.** Neue Vault-Notizen werden über Wikilinks in Index/PMO-Hub vernetzt, damit keine verwaisten Notizen entstehen.
9. **Cross-Links.** Betroffene **ADRs**, **Skills** und **Runbooks** werden gegenseitig verlinkt. Eine Doku, die ihre Nachbarn nicht kennt, wird nicht gefunden.
10. **Glossar-Begriffe.** Neue Fachbegriffe werden erklärt — sowohl in der technischen Kurzfassung (**HANDBUCH Anhang C**) als auch im Klartext-Glossar `docs/glossar.md` (+ `.en.md`).
11. **docs-drift-Check grün.** Das maschinelle Gate. `python3 .github/scripts/docs_drift_check.py` muss **rc=0** liefern. Es prüft tote `references/*.md`-Links, Versions-Gleichstand SKILL↔README, DE/EN-Parität, Vollständigkeit der Skills-Tabelle und doppelte Release-Wave-Buchstaben. Solange dieses Gate rot ist, ist die Story **nicht** done.

## Verweise

[`../how-we-document.md`](../how-we-document.md) (Doku-Landkarte) · HANDBUCH §7 (Artefakte) / Anhang C (Glossar) · `docs/glossar.md` · `.github/scripts/docs_drift_check.py` (Gate) · `docs/templates/story-template.md` (Story-Template mit eingebettetem Pflicht-Block) · Release-Notes-Standard: [`../releases/_template-sprint.md`](../releases/_template-sprint.md). Verwandt: Wave BW (Doku-Definition-of-Done, BOO-180), BOO-216 (Release-Notes-Standard).
