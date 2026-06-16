---
name: financials
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Template-Generator fuer die Worker-Equivalent-/ROI-Sicht eines Projekts. Legt die Financials-Templates
  an und pflegt sie: budget.md + worker-equivalent-baseline.md. Haelt den aktiven Verrechnungssatz und
  die Market-Research-Geo-Defaults als Fallback. KEIN Laufzeit-Rechner — Report (BOO-191) und Forecast
  (BOO-192) konsumieren die Templates.
  Verwenden wenn der Operator "Financials", "Verrechnungssatz", "ROI", "Worker-Equivalent" oder
  "/financials" sagt.
version: 1.0.0
metadata:
  hermes:
    category: governance
    tags: [financials, roi, worker-equivalent, bootstrap]
    related_skills: [bootstrap, sprint-review, backlog]
---

# Financials

Template-Generator und Doku-Skill fuer die Worker-Equivalent-/ROI-Sicht eines Projekts. Der Skill legt
zwei Templates an und haelt sie aktuell — er rechnet **nicht** zur Laufzeit.

## Was der Skill tut

Er erzeugt und pflegt die zwei kanonischen Financials-Templates unter `docs/financials/`:

| Template | Inhalt |
|----------|--------|
| `budget.md` | Schlankes Projekt-Budget: aktiver Verrechnungssatz, Waehrung/Geo, optionale Token-Kosten-Annahme. Verweist auf die Baseline und auf `sprint-costs.md`. |
| `worker-equivalent-baseline.md` | Aktiver Projekt-Verrechnungssatz (Abschnitt 1) plus die Market-Research-Geo-Defaults als Fallback (Abschnitt 2) plus Methodik/Pflege (Abschnitt 3). |

Die Aktivierung passiert nicht ueber den Skill direkt, sondern ueber die **Financials-Frage in
`/bootstrap`** (siehe Abschnitt „Aktivierung"). Bei *ja* werden die Templates angelegt und der aktive
Verrechnungssatz gesetzt.

## Abgrenzung — kein Laufzeit-Rechner

Der Skill liefert die **Datenstruktur**, nicht die Rechnung. Die eigentliche ROI-/Worker-Equivalent-Rechnung
geschieht in den Konsumenten:

| Konsument | Story | Was er aus den Templates liest |
|-----------|-------|--------------------------------|
| `/sprint-review` (Worker-Equivalent-Report) | BOO-191 | aktiver Satz aus Abschnitt 1 der Baseline |
| `/backlog` (Sprint-Forecast) | BOO-192 | aktiver Satz aus Abschnitt 1 der Baseline |
| Ist-Kosten-Snapshot | BOO-189 (`sprint-costs.md`, bereits live) | wird daneben gefuehrt, nicht ersetzt |

Datenquelle der Rechnung ist die Doppelspalte `effort_ai_hours` / `effort_human_equiv_hours` pro Story
(BOO-193). Der Skill ist leichtgewichtig: kein externes Tooling, keine eigene Studie-Kopie — er
referenziert die interne Deep-Research als Datenquelle.

## Aktivierung (via /bootstrap)

`/bootstrap` stellt waehrend des Setups die Financials-Frage:

1. **Financials aktivieren?** — bei *ja* legt der Skill `budget.md` + `worker-equivalent-baseline.md` an.
2. **Interner Verrechnungssatz?** — die vier Geo-Defaults (CH/DE/AT/US) werden als sichtbare Auswahl mit
   Quellenverweis angezeigt.
   - Operator gibt eigenen Satz ein → `source: intern`.
   - Frage uebersprungen → Market-Research-Default → `source: market-research-2026`.

**Intern-Vorrang:** Liegt ein eingegebener interner Satz vor, schlaegt er den Market-Research-Default —
immer (ADR-D, entschieden 2026-06-15).

## Die zwei Default-Sets pro Geo

Werte aus `docs/financials/worker-equivalent-baseline.md` (Quelle: interne Deep-Research
`02 Projekte/Code-Crash Framework/Research/2026-06-13 senior_dev_rates_baseline.md`, Owlist GmbH,
Erhebungsdaten 2025). `source: market-research-2026`, `erhebungsjahr: 2025`.

### Primaer-Default — externer Freelance/Contract P50 (Opportunity-Cost-Basis)

Empfohlene ROI-Basis. Was haette die Fremdvergabe derselben Arbeit an einen Senior-Freelancer (5–10 J.)
gekostet? P50 (Median), robuster als P75.

| Geo | Default | Confidence |
|-----|---------|------------|
| Schweiz (CHF) | CHF 137 / h | ★★☆ Mittel |
| Deutschland (EUR) | EUR 95 / h | ★★★ Hoch |
| Oesterreich (EUR) | EUR 85 / h | ★★☆ Mittel |
| USA (USD) | USD 120 / h | ★★★ Hoch |

### Konservativ-Default — interner Vollkosten-Lower-Bound

Fully-Loaded-Stundensatz eines fest angestellten Senior-Devs. Untere Grenze fuer eine konservativere
ROI-Rechnung.

| Geo | Default |
|-----|---------|
| Schweiz (CHF) | CHF 99 / h |
| Deutschland (EUR) | EUR 58 / h |
| Oesterreich (EUR) | EUR 57 / h |
| USA (USD) | USD 116 / h |

## Regel: native Waehrung, keine FX-Cross-Umrechnung

Saetze bleiben in der nativen Waehrung pro Geo (CH CHF, DE/AT EUR, US USD). **Keine** FX-Cross-Umrechnung.
Bei Kurs-Drift >5 % gegenueber Jahresanfang nur ein Nutzerhinweis, kein automatisches Umrechnen
(Primaerquelle §2.3).

## Quellen-Pflicht

Jeder Wert im Baseline-File traegt maschinen-lesbar:

- `source: intern` (Operator-Eingabe) **oder** `source: market-research-2026` (Geo-Default)
- `erhebungsjahr:` — bei `intern` das Jahr des internen Satzes; bei `market-research-2026` das Jahr 2025

Bei Widerspruch zwischen intern und Market-Research gilt **Intern-Vorrang**. Die Quellen-Hierarchie
innerhalb der Market-Research-Werte (BLS > Robert Half > Stack-Overflow-Survey fuer USA; swissICT S3 fuer
CH-Senior) ist in der Baseline Abschnitt 3 dokumentiert.

## Datenquelle / Referenzen

- **Doppelspalte** `effort_ai_hours` / `effort_human_equiv_hours` pro Story — BOO-193 (Datenquelle der Rechnung).
- **Worker-Equivalent-Report** im `/sprint-review` — BOO-191 (Konsument).
- **Sprint-Forecast** im `/backlog` — BOO-192 (Konsument).
- **Ist-Kosten** `docs/financials/sprint-costs.md` — BOO-189 (ccusage-Snapshots, bereits live, wird daneben gefuehrt).
- **Primaerquelle Baseline-Zahlen** — interne Deep-Research `Research/2026-06-13 senior_dev_rates_baseline.md`.

## Dateistruktur

```
financials/
├── SKILL.md          ← Skill-Definition (DE, wird von Claude Code gelesen)
├── SKILL.en.md       ← Skill-Definition (EN)
├── README.md         ← ausfuehrliche Doku (DE)
├── README.en.md      ← ausfuehrliche Doku (EN)
└── overview.png      ← Uebersichts-Diagramm (geliefert von separatem Cluster)

docs/financials/                       ← kanonische Template-Quellen (vom Skill gepflegt)
├── budget.md
├── worker-equivalent-baseline.md
└── sprint-costs.md                    ← BOO-189, daneben gefuehrt
```
