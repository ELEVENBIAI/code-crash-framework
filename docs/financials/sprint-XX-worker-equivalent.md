---
sprint: XX
type: worker-equivalent-actual
geo: CH
currency: CHF
rate_per_hour: 137
rate_source: market-research-2026
ki_cost: <native>
human_equiv_cost: <Σ effort_human_equiv_hours × rate>
roi_factor: <human_equiv_cost / ki_cost>
wall_clock_days: <n>
sum_effort_ai_hours: <Σ>
sum_effort_human_equiv_hours: <Σ>
stories: [BOO-XX, ...]
---

# Worker-Equivalent-Report — Sprint XX (Ist)

> Vom `/sprint-review`-Schritt 9b (BOO-191) je Sprint erzeugt. Hält den **Ist-ROI** des Sprints:
> was die KI-Arbeit real gekostet hat gegen das, was die gleiche Arbeit klassisch (Mensch-Equivalent)
> gekostet hätte. Datengrundlage sind ausschliesslich schon vorhandene Quellen — keine neue Erhebung.
> `XX` durch die Sprint-Nummer ersetzen; eine Datei pro Sprint.

## Felder

| Feld | Bedeutung |
|---|---|
| `sprint` | Sprint-Nummer (entspricht `XX` im Dateinamen). |
| `type` | Immer `worker-equivalent-actual` — grenzt den Ist-Report vom Forecast (BOO-192) ab. |
| `geo` / `currency` | Geo und native Währung aus `worker-equivalent-baseline.md` Abschnitt 1 (CH→CHF, DE/AT→EUR, US→USD). |
| `rate_per_hour` | Aktiver Verrechnungssatz aus der Baseline (Abschnitt 1). Native Währung. |
| `rate_source` | `intern` oder `market-research-2026` — übernommen aus der Baseline. |
| `ki_cost` | KI-Kosten in nativer Währung: aus dem Cost-Aggregat (`/sprint-review` Schritt 2b, `cost_breakdown.total_cost_usd`) bzw. dem ccusage-Ist-Snapshot (`sprint-costs.md`, BOO-189). **Näherung** — siehe Hinweis unten. |
| `human_equiv_cost` | Σ `effort_human_equiv_hours` × `rate_per_hour`. |
| `roi_factor` | `human_equiv_cost / ki_cost`. |
| `wall_clock_days` | Kalendertage des Sprints (erster bis letzter Sprint-Commit / Sprint-Log). |
| `sum_effort_ai_hours` | Σ `effort_ai_hours` der abgeschlossenen Stories — **Kontext**, nicht in der ROI-Formel. |
| `sum_effort_human_equiv_hours` | Σ `effort_human_equiv_hours` der abgeschlossenen Stories. |
| `stories` | Liste der im Sprint abgeschlossenen Story-IDs, deren Doppelspalte aggregiert wurde. |

## ROI-Formel

```
ROI = Σ(effort_human_equiv_hours) × rate_per_hour ÷ ki_cost
```

`Σ effort_ai_hours` geht **nicht** in die Formel ein — es steht nur als Kontext (wie viel KI-Arbeitszeit
real anfiel), nicht als Kostentreiber. Kostentreiber der KI-Seite ist allein `ki_cost`.

## Native Währung

Verrechnungssatz und Mensch-Equivalent-Kosten bleiben in der nativen Währung aus der Baseline. **Keine**
FX-Cross-Umrechnung — auch nicht, wenn `ki_cost` aus ccusage in USD vorliegt und die Baseline CHF/EUR führt.
Bei Kursdrift >5 % gegenüber Jahresanfang nur ein Nutzerhinweis, kein automatisches Umrechnen
(`worker-equivalent-baseline.md` §2.3).

## Hinweise

- **ROI intern:** Die ROI-Sprache bleibt vorerst intern (ADR-D §Offen), bis ≥3 Sprints Ist-Daten vorliegen.
  Erst dann ist der Faktor stabil genug für eine Auftraggeber-Ausgabe.
- **KI-Kosten = Näherung:** ccusage attribuiert Sub-Agent-Token (Task-Tool) nicht zuverlässig dem
  auslösenden Lauf (Issues #313/#806/#950). In sub-agent-lastigen Sprints ist `ki_cost` eine Näherung,
  kein Cent-genauer Audit.
- **Forecast-Gegenstück:** BOO-192 erzeugt im `/backlog` den Forecast (pro Story geschätzt, Sprint-Aggregat)
  und liest dieses Ist-Schema maschinell gegen (Forecast-vs-Ist-Drift). Das Frontmatter-Schema deshalb
  stabil halten.
