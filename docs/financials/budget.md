# Projekt-Budget — Worker-Equivalent & Kosten

> Schlankes Budget-Template für die Financials-/ROI-Sicht eines Projekts (BOO-190). Von `/bootstrap`
> (Financials-Frage) angelegt, danach vom Operator gepflegt. Verweist auf die zwei Mess-/Referenz-Quellen
> daneben — selbst hält diese Datei nur die Projekt-Annahmen.

## Projekt-Annahmen

```yaml
geo: <CH | DE | AT | US>
currency: <CHF | EUR | USD>
rate_per_hour: <Zahl>             # = aktiver Satz aus worker-equivalent-baseline.md Abschnitt 1
token_cost_assumption: <optional> # falls KI-Token-Kosten separat budgetiert werden
```

## Quellen daneben (nicht hier duplizieren)

| Quelle | Was sie liefert | Datei |
|--------|------------------|-------|
| Verrechnungssatz + Geo-Defaults | aktiver Satz (intern/market-research) + Fallback-Baseline | [`worker-equivalent-baseline.md`](worker-equivalent-baseline.md) |
| Ist-Token-/Kosten-Verbrauch | gemessene ccusage-Snapshots pro Sprint/Story (BOO-189) | [`sprint-costs.md`](sprint-costs.md) |
| Worker-Equivalent-Report pro Sprint | KI-Kosten / Mensch-Equiv / ROI / Wall-Clock (BOO-191) | `sprint-XX-worker-equivalent.md` |

## So rechnet die ROI-Sicht (Kurzform)

- **KI-Kosten** = gemessener Token-/Kosten-Verbrauch (`sprint-costs.md`).
- **Mensch-Equivalent-Kosten** = Σ `effort_human_equiv_hours` der Sprint-Stories × `rate_per_hour`.
- **ROI-Faktor** = Mensch-Equivalent-Kosten ÷ KI-Kosten.
- **Wall-Clock** = reale Sprint-Dauer aus dem Sprint-Log.

> Die Doppelspalte `effort_ai_hours` / `effort_human_equiv_hours` pro Story (BOO-193) ist die
> Datenquelle. ROI-Sprache bleibt vorerst intern, bis ≥3 Sprints Daten vorliegen (ADR-D §Offen).
