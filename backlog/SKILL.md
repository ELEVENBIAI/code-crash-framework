---
name: backlog
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Sprint Planning und Backlog-Uebersicht. Laedt alle Issues,
  analysiert Abhaengigkeiten und schlaegt priorisierte Reihenfolge vor.
  Validiert die Doppelspalte effort_ai_hours / effort_human_equiv_hours bei neuen Stories.
  Verwenden wenn der Operator "was steht an", "Backlog", "Sprint Planning", "Prioritaeten" oder "/backlog" sagt.
version: 1.7.0
metadata:
  hermes:
    category: coding
    tags: [linear, m365, intent-label, prioritization]
    requires_toolsets: [linear, github, terminal]
    related_skills: [ideation, intent]
---

# Backlog

Gesamtes Backlog laden, nach Abhaengigkeiten sortieren und priorisierte Reihenfolge vorschlagen.

## Workflow

### Schritt 0: Environment + Systemkontext laden

Reihenfolge wichtig: ZUERST 0.1 (Environment), dann 0.2 (Systemkontext) — die Pfade aus `paths.architecture_design` / `paths.specs` informieren, wo die Systemkontext-Files liegen.

#### 0.1 Environment laden

1. Lese `.claude/environment.json` (falls vorhanden — sonst Defaults verwenden + Warnung loggen).
2. Bei Bedarf Pfade extrahieren aus `paths.*` (z.B. `paths.reports_local`, `paths.lessons_l3`, `paths.specs`, `paths.architecture_design`).
3. Bei Tool-Aufruf pruefen: ist Tool in `tools_available.<tool>` aktiv? Bei `false` oder fehlendem Eintrag: Skill ueberspringt den Aufruf und gibt einen Hinweis im Output.
4. Fallback bei fehlender Datei: Standard-Pfade aus dem Schema annehmen (`journal/`, `journal/reports/local/`, `specs/`, `ARCHITECTURE_DESIGN.md`) und im Output vermerken: "Hinweis: `.claude/environment.json` fehlt — Defaults aktiv. Empfehlung: `/bootstrap` re-rennen oder die Datei manuell anlegen."

#### 0.2 Systemkontext laden (parallel)

Vor der Issue-Analyse den System-Zustand verstehen — sonst werden Blocker als offen eingestuft
die bereits implementiert sind, oder Prioritaeten ignorieren bestehende ADR-Constraints.

1. **`CLAUDE.md` lesen** — Welche Stories sind als implementiert erwaehnt? (`[PROJECT]-XXX` in
   Versionsbeschreibungen). Aktuelle System-VERSION. Bekannte Diskrepanzen. Diese Stories
   sind effektiv "done" auch wenn Linear sie noch nicht als Completed zeigt.

2. **`ARCHITECTURE_DESIGN.md` VOLLSTAENDIG lesen** — Das Lead-Dokument mit allen
   strategischen Constraints. Bis zur letzten Zeile lesen — nicht abbrechen wenn du glaubst
   genug gelesen zu haben. Das Dokument waechst mit jeder neuen ADR.
   **PFLICHT-Checkliste — alle Sektionen muessen gelesen sein:**
   - [ ] §1 Architectural Vision + Leitprinzipien
   - [ ] §2 Quality Attributes (Availability, Latency, Security-Targets)
   - [ ] §3 Alle vorhandenen ADRs vollstaendig (ADR-1 bis zum letzten im Dokument — nicht nur die ersten 5!)
   - [ ] §4 Layer-to-Pipeline Mapping
   - [ ] §5 Failure Mode Analysis
   - [ ] §6 Component Relationships
   - [ ] §7 Scalability Roadmap
   - [ ] §8 Testing Architecture
   - [ ] Referenzen-Sektion (Links auf weitere Architektur-Dokumente)

3. **`SYSTEM_ARCHITECTURE.md` lesen** — Agent-Liste, Signal-Flow, Brain DB Schema, bekannte
   Schwachstellen. Gibt Klarheit ueber aktuellen Ist-Zustand und welche Pfade bereits
   implementiert sind.

4. **Completed Issues (letzte 30 Tage) laden** — Blocker-Status aktualisieren: Wenn eine Story
   in Linear "Done" ist aber noch als Blocker in offenen Issues referenziert wird, als
   "unblocked" markieren und in der Praesentation explizit nennen.

### Schritt 1: Backlog laden

- `linear.getOpenIssues()` — alle offenen Issues
- Nach Status gruppieren: In Progress > Todo > Backlog > Ideation

### Schritt 2: Abhaengigkeiten analysieren

- Issue-Descriptions lesen: `## Abhaengigkeiten` Sektionen
- Abhaengigkeitsgraph aufbauen: Was blockiert was?
- Zirkulaere Abhaengigkeiten erkennen und melden
- Verwaiste Issues identifizieren (referenzierte Issues die nicht existieren)

**Schema-Chain Check (PFLICHT — laeuft bei jedem Backlog-Durchlauf):**

1. Alle offenen Issues auf `## DB Schema Impact` Sektion pruefen — welche planen ein Schema-Update?
2. Schema-Chain aufbauen: `currentSchemaVersion → targetSchemaVersion` pro Story
3. Sortier-Regel: **Stories mit niedrigerer `targetSchemaVersion` IMMER zuerst** — keine zwei Schema-Update-Stories gleichzeitig als "In Progress"
4. Konflikt-Flag: Zwei Stories mit gleicher `targetSchemaVersion` → sofort als **kritischen Blocker** melden (eine muss umgeschrieben werden)
5. In Priorisierungs-Empfehlung explizit nennen: "Schema-Chain: STORY-A (v17→v18) muss vor STORY-B (v18→v19) kommen"

**Doppelspalten-Validierung (PFLICHT — laeuft bei jedem Backlog-Durchlauf):**

Jede **neue** Story (Status `Todo` oder `Backlog`, angelegt ab Roll-Out dieser Aenderung) muss die zwei Effort-Felder `effort_ai_hours` (real geschaetzter KI-Aufwand inkl. Setup, Iteration, Review) und `effort_human_equiv_hours` (klassischer Senior-Dev-Aufwand fuer dieselbe Story ohne Framework) tragen. Die Pruefung ist **deterministisch** (Feld vorhanden + numerisch), kein Prompt-Versprechen.

1. Pro neuer Story beide Felder im Story-Frontmatter/Body lesen.
2. **Pruefkriterium:** beide Felder vorhanden UND numerisch UND `> 0`.
3. Fehlt eines oder ist es nicht-numerisch / `<= 0` → Story als **Hygiene-Befund FLAGGEN** und in Schritt 3/4 **NICHT als sprint-ready** einstufen.
4. **Remediation-Hinweis** ausgeben (konkret): "Story X fehlt `effort_ai_hours` und/oder `effort_human_equiv_hours` (numerisch, >0) — bitte im Story-Template nachtragen (siehe HANDBUCH Anhang G, Abschnitt Doppelspalte). Nicht sprint-ready bis ergaenzt."
5. **Ausnahme (kein Backfill):** Die pre-rollout-Stories **BOO-183 bis BOO-188** werden **NICHT** geflaggt — fuer sie gilt die Doppelspalte nicht rueckwirkend.

### Schritt 3: Reihenfolge vorschlagen

Sortier-Kriterien (in dieser Prioritaet):
1. **In Progress** — laufende Arbeit zuerst abschliessen
2. **Blocker** — Issues die andere blockieren
3. **Intent-Label** — `on-intent` VOR `neutral` bei gleichem Status + gleicher Priority; `off-intent`-Stories am Ende mit Warnung ("Story X ist off-intent — gehoert ins Backlog, nicht in den Sprint")
4. **Priority** — P1 > P2 > P3 > P4
5. **Abhaengigkeits-Tiefe** — Issues ohne Abhaengigkeiten vor solchen mit
6. **Alter** — aeltere Issues vor neueren (bei gleicher Prio)

**Intent-Label-Quelle:** Das Label wird aus der `## Intent-Check`-Sektion im Story-Body extrahiert (gesetzt von `/ideation` Schritt 0.6). Fehlt das Label → Story wird als `neutral` behandelt. Bei der Ausgabe erklaeren: "Story X priorisiert vor Y weil on-intent bei gleichen Points."

**Sprint-Ready-Gate (Doppelspalte):** Stories, die in der Doppelspalten-Validierung (Schritt 2) geflaggt wurden, gelten als **nicht sprint-ready** und werden in der Reihenfolge NICHT als naechste umsetzbare Story empfohlen — auch wenn sie nach Prio/Alter vorne stuenden. Sie erscheinen mit Hygiene-Flag, bis die Felder ergaenzt sind.

### Schritt 4: Praesentieren

Dem Operator zeigen:
- Priorisierte Liste mit Begruendung
- Abhaengigkeits-Konflikte oder Luecken
- **Doppelspalten-Hygiene-Befunde** — neue Stories ohne `effort_ai_hours` / `effort_human_equiv_hours`, explizit als **nicht sprint-ready** markiert, mit Remediation-Hinweis
- Issues die veraltet oder obsolet sein koennten
- Empfehlung: "Als naechstes wuerde ich [STORY-XX] umsetzen weil..."

### Schritt 4b: Sprint-Forecast (BOO-192, nur wenn Financials aktiv)

> **Aktivierung:** Dieser Schritt laeuft beim Vorschlagen der Sprint-Reihenfolge (direkt nach Schritt 4)
> und macht den **erwarteten** ROI des geplanten Sprints in Geld sichtbar — pro geplanter Story geschaetzt,
> ueber alle Stories zum **Sprint-Aggregat** summiert. Er ist das Forecast-Gegenstueck zum Ist-Report aus
> `/sprint-review` Schritt 9b (BOO-191). Keine neue Datenerhebung — nur Schaetzung aus schon vorhandenen
> Quellen (`token_estimate`, Doppelspalte, Baseline-Satz, Tier-Preis).

**Graceful skip (kein harter Block):** Fehlt `docs/financials/worker-equivalent-baseline.md` (Financials nicht
aktiv) oder tragen die geplanten Stories keine Doppelspalte (`effort_ai_hours` / `effort_human_equiv_hours`,
BOO-193) → diesen Schritt mit `[!info] Sprint-Forecast uebersprungen — Financials nicht aktiv bzw. keine
Doppelspalten-Daten` ueberspringen. Die Priorisierung bleibt gueltig.

**Eingaben (alle schon vorhanden, nichts neu erheben):**

| Eingabe | Quelle |
|---|---|
| `token_estimate` je Story | Execution-Isolation-Block der Spec (`specs/<STORY>.md`) bzw. Story-Frontmatter |
| `recommended_model` je Story | Spec/Story (Tier: `haiku` / `sonnet` / `opus`); fehlt es → `sonnet` als Default |
| Tier-Preis | `bootstrap/references/model-tiers.json`, `tiers.<tier>.pricing` (USD pro Mio Tokens) |
| `effort_human_equiv_hours` / `effort_ai_hours` | Doppelspalte je Story (BOO-193) |
| Aktiver Verrechnungssatz + Waehrung | `docs/financials/worker-equivalent-baseline.md` **Abschnitt 1** (`rate_per_hour`, `currency`, `geo`, `source`) — Intern-Vorrang gilt dort bereits (BOO-190) |

**Tier-Preis laden (analog `sprint-review` Schritt 2b — graceful skip wenn nicht gefunden):**

```bash
TIERS_FILE="$(git rev-parse --show-toplevel)/../intentron/bootstrap/references/model-tiers.json"
# Fallback: an typischen Framework-Pfaden suchen (Operator-Setup)
if [ ! -f "$TIERS_FILE" ]; then
  TIERS_FILE=$(find ~/Documents/GitHub/intentron -name model-tiers.json -maxdepth 4 2>/dev/null | head -1)
fi
# Wenn nicht gefunden: KI-Kosten-Schaetzung weglassen (graceful skip), Forecast-Block laeuft
# mit Mensch-Equiv + Wall-Clock weiter.
```

**Rechnung je Story (exakt — native Waehrung, keine FX):**

- **Erwartete KI-Kosten** = `token_estimate` × Tier-Preis aus `model-tiers.json` (`tiers.<recommended_model>.pricing`,
  USD pro Mio Tokens). Naeherung: ohne Input/Output-Split die konservative Output-Rate je Mio Tokens ansetzen
  (`output_per_million`), bzw. einen 70/30-Input/Output-Mix, falls die Spec einen Split fuehrt. Tier-Preis ist USD —
  bei CHF/EUR-Baseline **keine** FX-Umrechnung der KI-Kosten erzwingen (USD bleibt USD; im Output kennzeichnen).
- **Erwarteter Mensch-Equiv-Wert** = `effort_human_equiv_hours` × `rate_per_hour` (native Waehrung der Baseline).
- **Erwartete Wall-Clock** (Heuristik) = aus `effort_ai_hours` abgeleitet: grobe Faustregel
  `wall_clock_days ≈ ceil(Σ effort_ai_hours / 6)` (ein KI-Arbeitstag ≈ 6 produktive AI-Stunden inkl. Setup/Review).
  Heuristik, kein Versprechen — als „erwartet" ausweisen.
- **ROI-Faktor je Story** = erwarteter Mensch-Equiv-Wert ÷ erwartete KI-Kosten.
  > `effort_ai_hours` geht **nicht** in die ROI-Formel ein — nur als Kontext und in die Wall-Clock-Heuristik.

**Sprint-Aggregat** ueber alle geplanten Stories: Σ erwartete KI-Kosten, Σ erwarteter Mensch-Equiv-Wert,
Σ Wall-Clock (bzw. Aggregat-Heuristik), Sprint-ROI = Σ Mensch-Equiv ÷ Σ KI-Kosten.

**Output-Block „Sprint-Forecast" (DE+EN) — zeigt beim Vorschlagen der Reihenfolge:**

```
Sprint-Forecast (BOO-192) — geplanter Sprint {N}
  Pro Story:
    {STORY} — KI ~{ki_cost} USD · Mensch-Equiv ~{human_equiv} {currency} · Wall-Clock ~{days} T · ROI ~{roi}×
    ...
  Sprint-Aggregat:
    - Erwartete KI-Kosten:        ~{Σ ki_cost} USD   (token_estimate × Tier-Preis, Naeherung)
    - Erwarteter Mensch-Equiv:    ~{Σ human_equiv} {currency}
    - Erwartete Wall-Clock:       ~{Σ days} Tage  (Heuristik aus effort_ai_hours)
    - Erwarteter Sprint-ROI:      ~{roi}×  (Mensch-Equiv ÷ KI)
```

**Forecast persistieren:** den Forecast unter `docs/financials/sprint-XX-forecast.md` ablegen
(Template-Schema siehe [`docs/financials/sprint-XX-forecast.md`](../docs/financials/sprint-XX-forecast.md)).
`XX` = Sprint-Nummer. Das Frontmatter **feld-gleich** zum Ist-Report
(`sprint-XX-worker-equivalent.md`, BOO-191) halten, nur `type: worker-equivalent-forecast` und geschaetzte
statt Ist-Werte — sonst greift der Forecast-vs-Ist-Vergleich nicht.

#### Schritt 4b-2: Forecast-vs-Ist-Vergleich (Drift)

> Laeuft beim naechsten Planungslauf, sobald fuer einen frueheren Sprint **beide** Files vorliegen:
> der persistierte Forecast (`docs/financials/sprint-XX-forecast.md`) und der Ist-Report
> (`docs/financials/sprint-XX-worker-equivalent.md`, BOO-191). Fehlt einer von beiden → skip mit Hinweis.

1. Beide Frontmatter laden und je Dimension gegenueberstellen.
2. **Drift** je Dimension ausweisen (Ist gegen Forecast, in Prozent):
   - `ki_cost`-Drift = (Ist `ki_cost` − Forecast `ki_cost`) ÷ Forecast `ki_cost`
   - `human_equiv_cost`-Drift = (Ist − Forecast) ÷ Forecast
   - `roi_factor`-Drift = (Ist − Forecast) ÷ Forecast
3. **Drift = Quality-Gate-Signal, KEIN Hard-Block.** Die Drift blockiert keinen Sprint; sie macht
   systematische Unter-/Ueberschaetzung sichtbar (Kalibrierung), analog den Token-Pre-Flight-Warnings.
   Anschluss: das Cost-Drift-Signal fliesst in `quality-gate-audit` ein (vgl.
   [[Decisions/2026-05-06 Cost-Drift als Quality-Gate-Dimension]]) — als **Signal**, nicht als Gate-Block.

**Output-Block „Forecast-vs-Ist" (DE+EN):**

```
Forecast-vs-Ist (BOO-192) — Sprint {N}   [Signal, kein Block]
  - KI-Kosten:     Forecast ~{f_ki} → Ist {a_ki}   (Drift {±x}%)
  - Mensch-Equiv:  Forecast ~{f_he} → Ist {a_he}   (Drift {±x}%)
  - ROI-Faktor:    Forecast ~{f_roi}× → Ist {a_roi}×  (Drift {±x}%)
  Hinweis: Drift ist ein Kalibrierungssignal (quality-gate-audit Cost-Drift), kein Sprint-Block.
```

### Schritt 5: Backlog-Hygiene (optional)

Falls Probleme erkannt:
- Fehlende Abhaengigkeiten nachtragen
- Verwaiste Referenzen melden
- Obsolete Issues dem Operator zum Schliessen vorschlagen
