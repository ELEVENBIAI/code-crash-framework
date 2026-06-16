---
sprint: XX
type: worker-equivalent-forecast
geo: CH
currency: CHF
rate_per_hour: 137
rate_source: market-research-2026
ki_cost: <geschätzt: Σ token_estimate × Tier-Preis (USD)>
human_equiv_cost: <geschätzt: Σ effort_human_equiv_hours × rate>
roi_factor: <geschätzt: human_equiv_cost / ki_cost>
wall_clock_days: <geschätzt: ceil(Σ effort_ai_hours / 6)>
sum_effort_ai_hours: <Σ geplant>
sum_effort_human_equiv_hours: <Σ geplant>
stories: [BOO-XX, ...]
---

# Worker-Equivalent-Forecast — Sprint XX (geschätzt)

> Vom `/backlog`-Schritt 4b (BOO-192) beim Vorschlagen der Sprint-Reihenfolge erzeugt. Hält den
> **erwarteten ROI** des geplanten Sprints: was die KI-Arbeit voraussichtlich kostet gegen das, was die
> gleiche Arbeit klassisch (Mensch-Equivalent) gekostet hätte — pro Story geschätzt, über alle Stories
> zum Sprint-Aggregat summiert. Datengrundlage sind ausschliesslich schon vorhandene Quellen
> (`token_estimate`, Doppelspalte, Baseline-Satz, Tier-Preis) — keine neue Erhebung. `XX` durch die
> Sprint-Nummer ersetzen; eine Datei pro Sprint.

## Felder

Das Frontmatter ist **feld-gleich** zum Ist-Report (`sprint-XX-worker-equivalent.md`, BOO-191) — sonst
greift der Forecast-vs-Ist-Vergleich nicht. Einziger Unterschied: `type: worker-equivalent-forecast` und
geschätzte statt Ist-Werte.

| Feld | Bedeutung (Forecast) |
|---|---|
| `sprint` | Sprint-Nummer (entspricht `XX` im Dateinamen). |
| `type` | Immer `worker-equivalent-forecast` — grenzt den Forecast vom Ist-Report (BOO-191) ab. |
| `geo` / `currency` | Geo und native Währung aus `worker-equivalent-baseline.md` Abschnitt 1 (CH→CHF, DE/AT→EUR, US→USD). |
| `rate_per_hour` | Aktiver Verrechnungssatz aus der Baseline (Abschnitt 1). Native Währung. |
| `rate_source` | `intern` oder `market-research-2026` — übernommen aus der Baseline. |
| `ki_cost` | **Geschätzte** KI-Kosten: Σ (`token_estimate` × Tier-Preis aus `model-tiers.json`, `tiers.<recommended_model>.pricing`, USD pro Mio Tokens). Näherung — USD bleibt USD, keine FX-Umrechnung. |
| `human_equiv_cost` | **Geschätzt:** Σ `effort_human_equiv_hours` × `rate_per_hour`. |
| `roi_factor` | **Geschätzt:** `human_equiv_cost / ki_cost`. |
| `wall_clock_days` | **Geschätzte** Wall-Clock (Heuristik): `ceil(Σ effort_ai_hours / 6)` — ein KI-Arbeitstag ≈ 6 produktive AI-Stunden inkl. Setup/Review. |
| `sum_effort_ai_hours` | Σ geplante `effort_ai_hours` der Sprint-Stories — **Kontext** + Eingang der Wall-Clock-Heuristik, nicht in der ROI-Formel. |
| `sum_effort_human_equiv_hours` | Σ geplante `effort_human_equiv_hours` der Sprint-Stories. |
| `stories` | Liste der für den Sprint geplanten Story-IDs, deren Schätzung aggregiert wurde. |

## ROI-Formel (Forecast)

```
ROI_forecast = Σ(effort_human_equiv_hours) × rate_per_hour ÷ ki_cost_forecast
```

`Σ effort_ai_hours` geht **nicht** in die ROI-Formel ein — es liefert nur die Wall-Clock-Heuristik und steht
als Kontext (wie viel KI-Arbeitszeit erwartet wird). Kostentreiber der KI-Seite ist allein `ki_cost`.

## Native Währung

Verrechnungssatz und Mensch-Equivalent-Kosten bleiben in der nativen Währung aus der Baseline. **Keine**
FX-Cross-Umrechnung — auch nicht, wenn `ki_cost` als USD aus dem Tier-Preis vorliegt und die Baseline
CHF/EUR führt (`worker-equivalent-baseline.md` §2.3).

## Forecast-vs-Ist-Drift

Beim nächsten Planungslauf liest `/backlog` (Schritt 4b-2) dieses Forecast-Frontmatter gegen das
gleichnamige Ist-Frontmatter (`sprint-XX-worker-equivalent.md`) und weist die **Drift** je Dimension aus
(`ki_cost`, `human_equiv_cost`, `roi_factor`). Die Drift ist ein **Quality-Gate-Signal** (Kalibrierung,
Anschluss `quality-gate-audit` Cost-Drift, vgl. [[Decisions/2026-05-06 Cost-Drift als
Quality-Gate-Dimension]]) — **kein Hard-Block**. Damit der Vergleich maschinell läuft, das Frontmatter-Schema
stabil und feld-gleich zum Ist-Report halten.

## Hinweise

- **Schätzung, nicht Messung:** Alle Werte sind Forecast-Schätzungen aus Story-Estimates. Der Ist-Wert
  steht erst nach dem Sprint im Worker-Equivalent-Report (BOO-191).
- **KI-Kosten = Näherung:** `token_estimate` ist eine Vorab-Schätzung; ohne Input/Output-Split wird die
  konservative Output-Rate je Mio Tokens angesetzt. In sub-agent-lastigen Sprints driftet die spätere
  Ist-Attribution (ccusage-Grenze, Issues #313/#806/#950).
- **ROI intern:** Die ROI-Sprache bleibt vorerst intern (ADR-D §Offen), bis ≥3 Sprints Ist-Daten vorliegen.
