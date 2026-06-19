# Doku-Smoke-Test — Sprint 3–6 (BOO-215)

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](doku-smoke-test-sprint-3-6.en.md)

> Zielgeführter, finaler Doku-Smoke-Test über alle Sprint-3-bis-6-Outputs. Bewertungsmaßstab: [`../standards/doku-consistency-checklist.md`](../standards/doku-consistency-checklist.md) (BOO-214, 11 Punkte). Durchgeführt am 2026-06-19 vor dem v0.13.0-Release und vor der v1.0-Major-Doku.

## Gesamt-Verdikt

**BESTANDEN — grün, mit zwei direkt behobenen Lücken.** Maschinelles Gate `docs-drift-check` rc=0 (20 Skills, 0 Befunde). Vier Persona-Journeys end-to-end durchgespielt, alle vier navigierbar. Pro-Story-Konsistenz über Sprint 3–6 geprüft; zwei echte Lücken gefunden (Klartext-Glossar, Doku-Index) und **in dieser Story direkt behoben** — keine Sammelfix-Story nötig.

## Methode (Anti-Fabrikations-Disziplin)

Geprüft wurde in zwei Schichten: (1) read-only Sub-Agents pro Story-Cluster (Sprint 3+4, Sprint 5, Sprint 6) gegen die 11-Punkte-Checkliste; (2) **Lead-Cross-Check jedes gemeldeten Befunds gegen die reale Datei**, bevor er als Lücke gilt. Das war nötig: Mehrere als „CRITICAL" gemeldete Befunde waren **fabriziert** und wurden mit Beleg zurückgewiesen (siehe Abschnitt „Zurückgewiesene Befunde"). Jede Pass/Fail-Zeile unten ist gegen einen realen Pfad belegt.

## Story-Inventar (Smoke-Test-Scope)

| Sprint | Release | Stories |
|--------|---------|---------|
| 3 | v0.11.0 | BOO-198, 201, 203, 210, 212, 214, 216 |
| 4 | Wave CE | BOO-190, 191, 192, 193 |
| 5 | v0.12.0 | BOO-199, 200, 204, 206, 207, 208, 209, 211, 213 |
| 6 | v0.13.0 | BOO-205, 194, 202, 217 (+ BOO-218 operator-async, offen) |

## Pro-Story-Konsistenz (verdichtet)

Nur Punkte mit Befund oder bewusstem n/a. Vollständige Belegtabellen sind in den Cluster-Prüfungen erfasst; hier die konsolidierte Sicht.

| Punkt (Standard) | Sprint 3+4 | Sprint 5 | Sprint 6 |
|------------------|-----------|----------|----------|
| 1 DE+EN-Parität | ✅ | ✅ | ✅ |
| 2 Skill↔README-Version | ✅ financials 1.0.0 · sprint-run 2.0.0 · sprint-review 2.8.0 | ✅ implement 2.16.0 · architecture-review 1.13.0 · ideation 2.9.0 · insights-review 1.0.0 · pitch 1.2.0 | ✅ bootstrap 3.44.0 · backlog 1.8.0 · quality-gate-audit 1.1.0 |
| 3 HANDBUCH-Sektion | ✅ Anhang AG/AH/AI/AJ/AK | ✅ Anhang AL/AM/AN/AO/AP · §11b | ✅ Anhang AQ |
| 4 CONVENTIONS.md | ➖ n/a | ➖ n/a (Execution-Isolation deckt Subagents) | ➖ n/a |
| 5 Doku-Index | ✅ | ⚠️→✅ **routinen-vernetzen fehlte → ergänzt** | ✅ |
| 6 Sketches | ✅ (sprint-run 6 Paare DE+EN) | ➖ optional (textuell hinreichend) | ➖ optional |
| 7+8 Vault-Doku/Wikilinks | ➖ extern (separat geprüft, s.u.) | ➖ extern | ➖ extern |
| 9 Cross-Links | ✅ goal↔sprint-run beidseitig | ✅ Anhang-Netz AL–AP | ✅ sprint-6↔qga |
| 10 Glossar | ⚠️→✅ **Klartext-Glossar fehlten Begriffe → ergänzt** | ⚠️→✅ (gleicher Fix) | ⚠️→✅ (gleicher Fix) |
| 11 docs-drift grün | ✅ rc=0 | ✅ rc=0 | ✅ rc=0 |

## Vier Persona-Journeys (end-to-end)

**P1 — Neuer Operator (Onboarding):** ✅ `README.md` (zweisprachig, `#deutsch`/`#english`) → `## Quickstart` (Z. 128, drei Installations-Wege) → `/bootstrap` (Repo-Root, ein `git clone`) → Onboarding-Checkliste [`bootstrap-prep.md`](../onboarding/bootstrap-prep.md) → `## The Skills` (Z. 227) → Skill-Dokus. Vollständiger Schritt-Pfad via HANDBUCH §4 verlinkt. **Navigierbar, kein toter Sprung.**

**P2 — Bestehender Operator (Update Build-vs-Buy):** ✅ Release-Index [`../releases/_index.md`](../releases/_index.md) / [`sprint-6.md`](../releases/sprint-6.md) → HANDBUCH Anhang AL (Schalter A / Native-Pfade, Z. 5451) + AN (`/ultraplan`, Z. 5523) → Migrations-Runbook [`framework-update.md`](../runbooks/framework-update.md) → Klarheit über `/goal`, native Subagents, Ultraplan-Trigger. **Migrationspfad durchgängig.**

**P3 — Pitch-Adressat (Konzern-Decision-Maker):** ✅ USP-13-Liste HANDBUCH Anhang AP (Z. 5582, kanonisch, „13 Komponenten ohne Anthropic-Pendant") → Anhang-Wegweiser (Z. 29) + Tabelle (Z. 2422) → [`pitch/README.md`](../pitch/README.md) → Validierungs-Links auf Skill-Dokus. **Pitch-Kette schlüssig.**

**P4 — Wartender Operator (Routinen):** ✅ [`routinen-vernetzen.md`](../runbooks/routinen-vernetzen.md) → `## Drei Aufstellungs-Optionen` (Z. 14) → `## Sieben Routinen` (Z. 28: Backlog-Triage, Sprint-Review, Quality-Gate-Audit, Dependency-Drift, Doku-Drift, Cost-Drift, Hermes-Health) → `## Einrichtung pro Aufstellung` (Z. 135) mit kopierfertigen Prompts. **Drei Optionen + sieben Routinen vollständig.**

## Gefundene Lücken — direkt behoben

| # | Lücke | Datei(en) | Fix |
|---|-------|-----------|-----|
| G1 | Klartext-Glossar (für Fachseite/Management/Kunden) enthielt **keinen** Sprint-3–6-Strategiebegriff (Build-vs-Buy, `/goal`, native Subagent, Ultraplan, `/insights`, Worker-Equivalent, Status Line, Native-Feature-Beobachtung). HANDBUCH/Anhang C decken die Begriffe ab, das Nicht-Entwickler-Glossar nicht. | `docs/glossar.md` + `glossar.en.md` | Neue Sektion „Strategie & Native-Pfade (ab Sprint 3)" — 9 Klartext-Einträge mit Analogie, DE+EN. |
| G2 | Runbook `routinen-vernetzen` (BOO-213, Sprint 5) fehlte im Doku-Index, obwohl die Tabelle praktisch jedes andere Runbook listet. | `docs/INDEX.md` + `INDEX.en.md` | Eine Tabellenzeile DE+EN ergänzt (alphabetisch nach README). |

## Zur Kenntnis / Operator-Entscheid (nicht unilateral geändert)

- **`insights-review` nicht in der INDEX-Skill-Tabelle.** Diese Tabelle ist ein **kuratierter Subset** („Die 15 Top-Level-Skills") und lässt auch `financials`, `quality-gate-audit`, `statusline`, `research` bewusst aus. Die maschinell erzwungene README-Skills-Tabelle (Punkt 5, docs-drift) enthält `insights-review` korrekt. Ob die INDEX-Kuration auf 16 erweitert wird, ist eine bewusste Kuratierungs-Entscheidung außerhalb des BOO-215-Scopes — **bewusst nicht still geändert**.
- **Optionale Sketches** für Status-Line-Flow / Sprint-Plan-Sync / ADR-5-Trigger: nicht Pflicht („wo ein Konzept visuell erklärt gehört"); die Features sind textuell hinreichend dokumentiert. Kandidaten für eine spätere Sketch-Welle, kein Konsistenz-Fehler.
- **Vault-Doku (Punkte 7+8)** liegt außerhalb des Repos (SecondBrain). Separat nachgezogen im Rahmen dieser Story (Sprints.md, Index, PMO-Hub, Skill-Dokus) — siehe BOO-215-Result.

## Zurückgewiesene Befunde (Sub-Agent-Fabrikationen, mit Beleg widerlegt)

| Behauptung (Sub-Agent) | Schweregrad behauptet | Realität (Beleg) |
|------------------------|----------------------|------------------|
| „`README.en.md` fehlt komplett — DE/EN-Parität verletzt" | CRITICAL | **Falsch.** Root-`README.md` ist zweisprachige Single-Datei: `[🇬🇧 English](#english) · [🇩🇪 Deutsch](#deutsch)` (Z. 1). Kein separates `.en.md` nötig. |
| „ADR-5 fehlt als Datei, 9× referenziert" | CRITICAL | **Falsch.** Repo-ADRs sind themen-benannt (`docs/domain/adrs/{branching-standard,cross-session-drift,design-story-handling}.md`). ADR-1…5 sind **Vault-ADRs by design** (`Decisions/`), im Repo nur als Cross-Link geführt — konventionskonform. |
| „bootstrap-Versions-Drift: 3.44.0 statt 3.41/3.42/3.43" | MEDIUM | **Falsch.** bootstrap ist über Sprint 5→6 legitim auf 3.44.0 gewandert (BOO-205). SKILL==README in DE+EN, docs-drift grün. |
| „CONVENTIONS.md fehlen `## Schalter`/`## Ultraplan`-Sektionen" | HIGH | **Kein Befund.** Standard verlangt CONVENTIONS nur bei Tool-/Adapter-/Branching-/Naming-Konventionen, nicht pro Feature. native_paths/Ultraplan korrekt im HANDBUCH. |

## docs-drift-check

```
docs-drift-check: 20 Skills geprueft, 0 Drift-Befund(e).
OK — keine Doku-Drift.   (rc=0)
```

## Fazit

Die Sprint-3–6-Doku ist konsistent, zweisprachig und navigierbar. Die zwei realen Lücken sind behoben, der `docs-drift`-Gate ist grün, alle vier Persona-Pfade tragen. **Damit ist der Smoke-Test grün — die Voraussetzung für die v1.0-Major-Doku (`v1.0-native-pivot.md`) ist erfüllt.**
</content>
