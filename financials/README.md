<a name="deutsch"></a>

# Financials — Template-Generator fuer die Worker-Equivalent-/ROI-Sicht

> Legt die Financials-Templates an und pflegt sie: `budget.md` + `worker-equivalent-baseline.md`. Haelt den aktiven Verrechnungssatz und die Market-Research-Geo-Defaults als Fallback. Kein Laufzeit-Rechner — die Rechnung passiert in den Konsumenten.

**Version:** 1.0.0 · **Befehl:** `/financials`

> **Aktivierung:** Nicht direkt aufrufen — die Templates entstehen ueber die **Financials-Frage in `/bootstrap`**. Siehe Abschnitt „Aktivierung".

---

## Was der Skill tut

Um aus dem KI-Aufwand einen ROI-Faktor in **Geld** zu bilden, braucht das Framework zwei Dinge: einen projektspezifischen Verrechnungssatz und eine belegte Baseline. Der `financials`-Skill liefert beides als Template — nicht als Rechnung.

Er erzeugt und pflegt zwei kanonische Templates unter `docs/financials/`:

- **`budget.md`** — schlankes Projekt-Budget: aktiver Verrechnungssatz, Waehrung/Geo, optionale Token-Kosten-Annahme. Verweist auf die Baseline und auf `sprint-costs.md` (BOO-189), dupliziert deren Inhalt aber nicht.
- **`worker-equivalent-baseline.md`** — der aktive Projekt-Verrechnungssatz (Abschnitt 1), die Market-Research-Geo-Defaults als Fallback (Abschnitt 2) und die Methodik/Pflege-Notiz (Abschnitt 3).

Der Skill ist **leichtgewichtig**: kein externes Tooling, keine eigene Kopie der Studie. Die Baseline-Zahlen stammen aus der internen Deep-Research, auf die der Skill verweist statt sie mitzuschleppen.

---

## Warum

Nicht jeder Operator hat einen internen Verrechnungssatz zur Hand. Damit die ROI-Rechnung trotzdem sofort funktioniert, hinterlegt der Skill einen recherchierten Geo-Default als Fallback. So bildet das Framework aus der Doppelspalte `effort_ai_hours` / `effort_human_equiv_hours` (BOO-193) einen ROI-Faktor — entweder mit dem eigenen Satz des Operators oder mit dem Market-Research-Default.

ROI-Sprache bleibt vorerst intern, bis ≥3 Sprints Daten vorliegen (ADR-D §Offen).

---

## Abgrenzung — kein Laufzeit-Rechner

Der Skill liefert die Datenstruktur. Die eigentliche Rechnung machen die Konsumenten:

| Konsument | Story | Was er liest |
|-----------|-------|--------------|
| `/sprint-review` — Worker-Equivalent-Report | BOO-191 | aktiver Satz aus Abschnitt 1 der Baseline |
| `/backlog` — Sprint-Forecast | BOO-192 | aktiver Satz aus Abschnitt 1 der Baseline |
| `sprint-costs.md` — Ist-Kosten (ccusage) | BOO-189 (live) | wird daneben gefuehrt, nicht ersetzt |

So rechnet die ROI-Sicht (Kurzform):

```
KI-Kosten            = gemessener Token-/Kosten-Verbrauch (sprint-costs.md)
Mensch-Equiv-Kosten  = Σ effort_human_equiv_hours der Sprint-Stories × rate_per_hour
ROI-Faktor           = Mensch-Equiv-Kosten ÷ KI-Kosten
Wall-Clock           = reale Sprint-Dauer aus dem Sprint-Log
```

---

## Aktivierung (via /bootstrap)

`/bootstrap` stellt waehrend des Setups die Financials-Frage:

1. **Financials aktivieren?** — bei *ja* legt der Skill `budget.md` + `worker-equivalent-baseline.md` an.
2. **Interner Verrechnungssatz?** — die vier Geo-Defaults werden als sichtbare Auswahl mit Quellenverweis angezeigt:
   - Operator gibt einen eigenen Satz ein → `source: intern`.
   - Frage wird uebersprungen → Market-Research-Default → `source: market-research-2026`.

**Intern-Vorrang:** Liegt ein eingegebener interner Satz vor, schlaegt er den Market-Research-Default — immer (ADR-D, entschieden 2026-06-15).

---

## Die zwei Default-Sets pro Geo

Werte aus der internen Deep-Research `Research/2026-06-13 senior_dev_rates_baseline.md` (Owlist GmbH, Erhebungsdaten 2025). `source: market-research-2026`, `erhebungsjahr: 2025`.

### Primaer-Default — externer Freelance/Contract P50 (Opportunity-Cost-Basis)

Empfohlene ROI-Basis. Was haette die Fremdvergabe an einen Senior-Freelancer (5–10 J.) gekostet? P50 (Median), robuster als P75.

| Geo | Default | Confidence | Quellen |
|-----|---------|------------|---------|
| Schweiz (CHF) | **CHF 137 / h** | ★★☆ Mittel | swissICT 2025 S3; salary2freelance.com |
| Deutschland (EUR) | **EUR 95 / h** | ★★★ Hoch | freelancermap Kompass 2025 |
| Oesterreich (EUR) | **EUR 85 / h** | ★★☆ Mittel | DACH-Ableitung (~10 % unter DE) |
| USA (USD) | **USD 120 / h** | ★★★ Hoch | BLS OEWS Mai 2025; Robert Half 2025 |

### Konservativ-Default — interner Vollkosten-Lower-Bound

Fully-Loaded-Stundensatz eines fest angestellten Senior-Devs. Untere Grenze fuer eine konservativere ROI-Rechnung.

| Geo | Default |
|-----|---------|
| Schweiz (CHF) | **CHF 99 / h** |
| Deutschland (EUR) | **EUR 58 / h** |
| Oesterreich (EUR) | **EUR 57 / h** |
| USA (USD) | **USD 116 / h** |

---

## Regel: native Waehrung, keine FX-Cross-Umrechnung

Saetze bleiben in der nativen Waehrung pro Geo (CH CHF, DE/AT EUR, US USD). **Keine** FX-Cross-Umrechnung. Bei Kurs-Drift >5 % gegenueber Jahresanfang nur ein Nutzerhinweis, kein automatisches Umrechnen (Primaerquelle §2.3).

---

## Quellen-Pflicht

Jeder Wert im Baseline-File traegt maschinen-lesbar `source:` und `erhebungsjahr:`:

- `source: intern` (Operator-Eingabe) oder `source: market-research-2026` (Geo-Default)
- `erhebungsjahr:` — bei `intern` das Jahr des internen Satzes; bei `market-research-2026` das Jahr 2025

Quellen-Hierarchie bei Widerspruch innerhalb der Market-Research-Werte (Baseline Abschnitt 3): BLS OEWS > Robert Half > Stack-Overflow-Survey (USA); swissICT S3 fuer CH-Senior.

---

## Trigger-Phrasen

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

## Dateistruktur

```
financials/
├── SKILL.md          ← Skill-Definition (DE, wird von Claude Code gelesen)
├── SKILL.en.md       ← Skill-Definition (EN)
├── README.md         ← diese Datei (DE)
├── README.en.md      ← Doku (EN)
└── overview.png      ← Uebersichts-Diagramm (geliefert von separatem Cluster)

docs/financials/                       ← kanonische Template-Quellen (vom Skill gepflegt)
├── budget.md
├── worker-equivalent-baseline.md
└── sprint-costs.md                    ← BOO-189, daneben gefuehrt
```
