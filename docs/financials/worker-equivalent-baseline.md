# Worker-Equivalent-Baseline — Verrechnungssätze für die ROI-Rechnung

> Datenbasis für die Worker-Equivalent-/ROI-Rechnung des Frameworks (BOO-190). Hält den **aktiven
> Projekt-Verrechnungssatz** plus die **Market-Research-Defaults pro Geo** als Fallback. Der
> Worker-Equivalent-Report (`/sprint-review`, BOO-191) und der Sprint-Forecast (`/backlog`, BOO-192)
> lesen den aktiven Satz aus Abschnitt 1.
>
> **Regel native Währung:** Sätze bleiben in der nativen Währung pro Geo (CH CHF, DE/AT EUR, US USD).
> **Keine** FX-Cross-Umrechnung. Bei Kurs-Drift >5 % gegenüber Jahresanfang nur ein Nutzerhinweis,
> kein automatisches Umrechnen (Primärquelle §2.3).

---

## 1. Aktiver Verrechnungssatz (dieses Projekt)

> Von `/bootstrap` (Financials-Frage) gesetzt. Gibt der Operator einen eigenen Satz ein →
> `source: intern`. Wird die Frage übersprungen → Market-Research-Default aus Abschnitt 2
> (`source: market-research-2026`). **Intern-Vorrang:** ein eingegebener interner Satz schlägt den
> Market-Research-Default immer (ADR-D, entschieden 2026-06-15).

```yaml
geo: <CH | DE | AT | US>          # bestimmt die Währung
currency: <CHF | EUR | USD>
rate_per_hour: <Zahl>             # Verrechnungssatz pro Stunde, native Währung
source: <intern | market-research-2026>
erhebungsjahr: <Jahr>             # bei intern: Jahr des internen Satzes; bei market-research: 2025
basis: <freelance-p50 | intern-vollkosten | eigen>
```

---

## 2. Market-Research-Defaults pro Geo (Fallback)

Quelle: interne Deep-Research `02 Projekte/Code-Crash Framework/Research/2026-06-13
senior_dev_rates_baseline.md` (Owlist GmbH, Erhebungsdaten 2025). `source: market-research-2026`,
`erhebungsjahr: 2025`.

### 2.1 Primär-Default — externer Freelance/Contract P50 (Opportunity-Cost-Basis)

Empfohlene ROI-Basis: Was hätte die Fremdvergabe derselben Arbeit an einen Senior-Freelancer (5–10 J.)
gekostet? P50 (Median), robuster als P75.

| Geo | Default | Typ | Tagessatz (8 h) | Confidence | Quellen |
|-----|---------|-----|-----------------|------------|---------|
| Schweiz (CHF) | **CHF 137 / h** | Externer Freelance P50 | CHF 1'100 | ★★☆ Mittel | swissICT 2025 S3; salary2freelance.com |
| Deutschland (EUR) | **EUR 95 / h** | Externer Freelance P50 | EUR 760 | ★★★ Hoch | freelancermap Kompass 2025 |
| Österreich (EUR) | **EUR 85 / h** | Externer Freelance P50 | EUR 680 | ★★☆ Mittel | DACH-Ableitung (~10 % unter DE) |
| USA (USD) | **USD 120 / h** | Externer Contract P50 | USD 960 | ★★★ Hoch | BLS OEWS Mai 2025; Robert Half 2025 |

### 2.2 Konservativ-Default — interner Vollkosten-Lower-Bound

Fully-Loaded-Stundensatz eines fest angestellten Senior-Devs (Bruttolohn × AG-Lohnnebenkosten ÷
produktive Jahresstunden). Untere Grenze für eine konservativere ROI-Rechnung.

| Geo | Default | Typ |
|-----|---------|-----|
| Schweiz (CHF) | **CHF 99 / h** | Interner Vollkostensatz P50 |
| Deutschland (EUR) | **EUR 58 / h** | Interner Vollkostensatz P50 |
| Österreich (EUR) | **EUR 57 / h** | Interner Vollkostensatz P50 |
| USA (USD) | **USD 116 / h** | Interner Vollkostensatz P50 |

---

## 3. Methodik & Pflege

**Warum extern P50 als Primär-Default:** Der ROI-Rechner bildet den **Opportunity Cost** der
Fremdvergabe ab — den Freelance-Marktpreis, nicht die interne Vollkostenstelle. Interne Sätze setzen
voraus, dass der Mitarbeiter in der Zeit keine andere Wertschöpfung gehabt hätte (unrealistisch). P50
spiegelt den typischen Markt, nicht das obere Quartil.

**Quellen-Hierarchie bei Widerspruch** (Primärquelle §5): BLS OEWS > Robert Half > Stack-Overflow-Survey
(USA); swissICT S3 für CH-Senior-Level; Glassdoor (Grundgehalt) vor levels.fyi (Large-Cap-Bias) für den
DE-Markt-Median.

**Update-Trigger** (Primärquelle §7) — Baseline mindestens jährlich (idealerweise Q1) prüfen:

| Trigger-Quelle | Veröffentlichung | Review |
|----------------|------------------|--------|
| freelancermap Freelancer-Kompass | März | Q1 |
| BLS OEWS 15-1252 | Mai/Juni | Q2 |
| swissICT „Saläre der ICT" | September | Q3 |
| Robert Half Salary Guide | Oktober | Q4 |
| FX-Spot-Check | bei Volatilität | CHF/EUR/USD-Drift >5 % → nur Geo-Nutzerhinweis, **kein** Umrechnen |

Volle Methodik, Confidence-Bänder, Widerspruchs-Analyse und Quellentabellen: interne Deep-Research
`2026-06-13 senior_dev_rates_baseline.md`. Nächste empfohlene Aktualisierung: Q1 2026 (freelancermap)
und Q3 2026 (swissICT).
