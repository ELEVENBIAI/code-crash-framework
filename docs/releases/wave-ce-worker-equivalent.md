# Wave CE — Worker-Equivalent: zweite Steuerungs-Dimension neben Token-Verbrauch (BOO-190 / BOO-191 / BOO-192 / BOO-193)

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](wave-ce-worker-equivalent.en.md)

**Was jetzt da ist:** Token-Verbrauch ist eine **Input-Metrik** — sie sagt, was ein Sprint kostet, nicht, was er wert ist. Mit Sprint 4 (4a + 4b) kommt die zweite Achse dazu: das **Worker-Equivalent**. ROI = Mensch-Equivalent-Kosten ÷ KI-Kosten — also was ein Sprint einen Menschen gekostet hätte, geteilt durch das, was die KI gekostet hat. Vier Stories bauen das Fundament: eine globale **Doppelspalte** (`effort_ai_hours` + `effort_human_equiv_hours`) in jeder neuen Story, ein neuer Skill **`financials`** mit Geo-Verrechnungssätzen, ein **Ist-Report** im Sprint-Review und ein **Forecast** im Backlog. Die Lehre dahinter: **Was du nur am Input misst, kannst du nicht am Output steuern.**

## Die Lehre — Input-Metrik vs. Output-Steuerung

Token-Verbrauch (ccusage, Wave-Vorläufer) beantwortet die Frage „Was hat das gekostet?". Das ist notwendig, aber blind für die eigentliche Steuerungsfrage: „Hat sich das gelohnt?". Ein Sprint, der 12 USD Token verbraucht und drei Mannwochen Entwicklerarbeit ersetzt, ist ein anderer Fall als einer, der dieselben 12 USD verbraucht und eine halbe Stunde spart — am reinen Token-Verbrauch sehen beide identisch aus.

Das **Worker-Equivalent** macht diesen Unterschied messbar. Es stellt der KI-Kosten-Achse eine zweite gegenüber: was dieselbe Arbeit einen Menschen gekostet hätte (`effort_human_equiv_hours` × Verrechnungssatz). Der Quotient ist der **ROI** — Output-Steuerung statt Input-Buchhaltung. Entschieden in **ADR-D** (2026-06-15): Token bleibt die Input-Metrik, Worker-Equivalent wird die Output-Dimension. Beide laufen parallel, keine ersetzt die andere.

## Änderungen

- **Doppelspalte im globalen Story-Template (BOO-193):** Jede neue Story trägt ab sofort `effort_ai_hours` **und** `effort_human_equiv_hours` (Vault `User-Story-Template.md`). Beide Felder sind **Pflicht für neue Stories** — **kein Backfill**: die Bestands-Stories BOO-183–188 sind ausgenommen. Der **`backlog`-Skill (v1.6.0)** validiert die Doppelspalte deterministisch: neue Stories ohne beide Felder werden geflaggt und gelten **nicht als sprint-ready**. Dokumentiert in HANDBUCH Anhang G.
- **Neuer Skill `financials` (v1.0.0) + Templates (BOO-190):** Template-Generator, der `docs/financials/budget.md` und `docs/financials/worker-equivalent-baseline.md` erzeugt. Die Verrechnungssätze kommen aus einer internen Senior-Dev-Rates-Primärquelle — zwei Default-Sets je Geo: **extern** (Freelance/Contract, P50) CH 137 / DE 95 / AT 85 / US 120 und **konservativ intern** CH 99 / DE 58 / AT 57 / US 116, jeweils in **nativer Währung — keine FX-Cross-Umrechnung** (nur ein Hinweis bei Abweichung >5 %). Bei Konflikt hat das **Intern-Set Vorrang**. Aktivierung über den Bootstrap (`intentron init` A.9 + Phase 4.4o) inklusive Pflicht-Quartett: HANDBUCH Anhang AK, `migrate_boo_190`, `verify-setup`. Grundlage: **ADR-D → entschieden**.
- **`sprint-review` (v2.7.0) — Worker-Equivalent-Report, Ist (BOO-191):** neuer **Schritt 9b** aggregiert pro Sprint die KI-Kosten, die Mensch-Equivalent-Kosten, den ROI und die Wall-Clock-Zeit — aus der Doppelspalte, `ccusage` und dem Verrechnungssatz. Abgelegt als `docs/financials/sprint-XX-worker-equivalent.md`.
- **`backlog` (v1.7.0) — Forecast-Block (BOO-192):** erwartete KI-Kosten (aus `token_estimate` × Tier-Preis), Mensch-Equivalent (aus Doppelspalte × Satz), ROI und Sprint-Aggregat — **vor** dem Sprint. Persistiert als `docs/financials/sprint-XX-forecast.md` mit **feld-gleichem Schema** zum Ist-Report. Die **Forecast-vs-Ist-Drift** ist ein Quality-Gate-**Signal**, kein Hard-Block.

## Migration — bestehende Projekte nachziehen

- **Financials aktivieren:** Bestandsprojekte schalten das Financials-Modul über `/bootstrap` (A.9) bzw. `migrate_boo_190` frei. Idempotent, nicht-destruktiv.
- **Doppelspalte:** gilt **nur für neue Stories**. Bestehende Stories werden nicht nachträglich befüllt (kein Backfill, BOO-183–188 ausgenommen).

## Abgrenzung

- **ROI-Sprache bleibt vorerst intern** — erst nach ≥ 3 Sprints mit echten Daten wird das Worker-Equivalent nach aussen getragen.
- **Kein eigener Framework-Versions-Tag** — Sprint 4 ist eine **Sprint-Release-Note** (Wave ce), kein Versions-Release. Der nächste SemVer-Tag bleibt **v0.12.0 für Sprint 5**.
- Wave-Buchstabe **ce** (cd = Semgrep Custom-Rule-Wiring BOO-185/188).

## Verweise

ADR-D „Worker-Equivalent — zweite Steuerungs-Dimension neben Token-Verbrauch" (2026-06-15, entschieden). Specs: `specs/BOO-190.md`, `specs/BOO-191.md`, `specs/BOO-192.md`, `specs/BOO-193.md`. Verwandt: BOO-189 (ccusage Token-/Kosten-Hook, Input-Metrik), README.
