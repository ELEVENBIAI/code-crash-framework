---
name: sprint-review
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Periodisches Audit fuer Architektur-Gesundheit, Tech Debt und Backlog-Hygiene — plus
  Learning-Loop-Eintrag (L1/L2/L3) als Pflicht-Schritt. Verwenden fuer periodische Reviews
  oder wenn der Operator "Sprint Review", "Architektur Audit", "Tech Debt", "Aufraumen"
  oder "/sprint-review" sagt.
version: 2.7.0
metadata:
  hermes:
    category: governance
    tags: [retro, lessons-loop, anti-pattern-check]
    requires_toolsets: [terminal, git, sonarqube, linear]
    related_skills: [implement, architecture-review]
---

# Sprint Review

Periodisches Audit des Gesamtsystems plus Learning-Loop-Eintrag. Der Skill schliesst den Learning-Loop indem er am Ende die Lessons-Learned erfasst (Level L1/L2/L3, je nach Projekt-Konfiguration).

## Workflow (10 Schritte)

### Schritt 0: Environment laden

1. Lese `.claude/environment.json` (falls vorhanden — sonst Defaults verwenden + Warnung loggen).
2. Lese `CONVENTIONS.md` (falls vorhanden). Extrahiere `governance_mode`, `execution_isolation` und aktive Gates. Fallback: `standard` + `write-scope`.
3. Bei Bedarf Pfade extrahieren aus `paths.*` (z.B. `paths.reports_local`, `paths.lessons_l1`, `paths.lessons_l2_dir`, `paths.lessons_l3`, `paths.specs`, `paths.architecture_design`, `paths.conventions`).
4. Bei Tool-Aufruf pruefen: ist Tool in `tools_available.<tool>` aktiv? Bei `false` oder fehlendem Eintrag: Skill ueberspringt den Aufruf und gibt einen Hinweis im Output.
5. Fallback bei fehlender Datei: Standard-Pfade aus dem Schema annehmen (`journal/`, `journal/reports/local/`, `specs/`, `ARCHITECTURE_DESIGN.md`, `CONVENTIONS.md`) und im Output vermerken: "Hinweis: `.claude/environment.json` fehlt — Defaults aktiv. Empfehlung: `/bootstrap` re-rennen oder die Datei manuell anlegen."

### Schritt 1: System-Snapshot

Parallel laden:
1. Gesamtes Backlog (alle Status, Linear/M365/GitHub je nach Backlog-Tool)
2. **`ARCHITECTURE_DESIGN.md` VOLLSTAENDIG lesen** — bis zur letzten Zeile — alle Sektionen und ADRs.
   **PFLICHT-Checkliste:**
   - [ ] §1 Architectural Vision + Leitprinzipien
   - [ ] §3 Quality Attributes (aktive Standard-Dimensionen + Add-ons)
   - [ ] §4 Komponenten-Verweise
   - [ ] §6 Phasen-Mapping
   - [ ] §7 ADR-Tabelle vollstaendig
   - [ ] §9 Referenzen (alle verlinkten Docs kennen)
3. `SYSTEM_ARCHITECTURE.md` vollstaendig lesen
4. `lib/config.js` (aktuelle Konfiguration, DOC_FILES-Liste)
5. Git-Log der letzten Periode (Commits, Branches, neue Files)
6. Wenn Self-Healing aktiv: Self-Healing-Logs pruefen (haeufigste Warnings)
7. Wenn Learning-Loop aktiv: vorherige `journal/`-Eintraege lesen (fuer Schritt 8 Kontext)

### Schritt 1b: Governance-Konventions-Drift

Pruefe, ob die Projektpraxis zur `CONVENTIONS.md` passt:

| Konvention | Review-Frage |
|---|---|
| `governance_mode: lite` | Sind nur Basis-Gates aktiv und keine schweren Reports erzwungen? |
| `governance_mode: standard` | Existieren Spec-Gate, Security-Basischeck, Tests/Lint und Sprint-Review-Spuren? |
| `governance_mode: heavy` | Existieren erweiterte Security-/Compliance-/Architektur-Gates, Reports und Review-Nachweise? |
| `execution_isolation: write-scope` | Haben parallele Stories/Subagents klare `write_scopes` genutzt? |
| `execution_isolation: git-worktree` | Wurden parallele Agenten/agentische Runs in getrennten Worktrees oder Branches ausgefuehrt? |

Abweichungen im Sprint-Report als `Governance Drift` dokumentieren und bei wiederholtem Auftreten ein Backlog-Issue vorschlagen.

### Schritt 2: Architektur-Review (aktive Dimensionen)

Aus `ARCHITECTURE_DESIGN.md §3 Quality Attributes` die **aktiven Dimensionen** lesen. Das sind die 7 Standard-Dimensionen + alle im Bootstrap-Block A.4 aktivierten Add-ons.

Pro aktiver Dimension: Status (OK / Warnung / Kritisch) + Befund + Empfehlung.

**Standard-Dimensionen:** Reliability, Data Integrity, Security, Performance, Observability, Maintainability, Testability

**Add-ons (wenn aktiv):** Privacy / Cost Efficiency / Signal Quality / Compliance

**Testability-spezifische Metriken im Sprint-Review:**
- Coverage auf neuem Code (Change Value, BOO-15-Anschluss): Trend ueber Sprint?
- Pass-Rate der Test-Suite: stabil gruen oder flaky / rot?
- Anzahl neu hinzugefuegter Contract-Tests bei externen Schnittstellen?

Detail-Fragen pro Dimension: siehe `architecture-review/references/dimensions-detail.md`.

### Schritt 2b: Reports-Aggregation + Metriken (BOO-6)

Sprint-Review aggregiert vier Quellen pro Sprint und schreibt die Ergebnisse als Frontmatter ins Sprint-File.

**Lese-Quellen (alle optional, graceful skip bei fehlender Quelle):**

| Quelle | Pfad | Was wird gelesen |
|---|---|---|
| Local Implement-Reports | `journal/reports/local/{date}_{story}/` | Iterations-Counts pro Tool aus `meta.json`, Iter-N-SARIF-Files fuer Pattern-Erkennung |
| CI-Reports | `journal/reports/ci/run-{id}/` | CI-Erfolgsraten, haeufige Failures (BOO-32-Konvention) |
| SonarQube Cloud API | `https://sonarcloud.io/api/` | neue Hotspots im Sprint, Coverage-Trend, Cognitive-Complexity-Trend |
| L3-DB | `journal/learnings.db` | Cross-Sprint-Trends (wenn Level L3 aktiv, sonst skip) |

**SonarQube-API-Lese-Block (analog architecture-review BOO-6):**

```bash
# Voraussetzung-Check (siehe architecture-review SKILL.md BOO-6-Block)
# Wenn SONAR_TOKEN + sonar-project.properties + tools_available.sonarqube_cloud == true:

# Neue Findings im aktuellen Sprint-Zeitraum (SPRINT_START_ISO -> heute)
curl -s -u "${SONAR_TOKEN}:" \
  "https://sonarcloud.io/api/issues/search?componentKeys=${PROJECT_KEY}&createdAfter=${SPRINT_START_ISO}&ps=100" \
  | jq '.issues | length'

# Coverage- und Complexity-Trend (History-API)
curl -s -u "${SONAR_TOKEN}:" \
  "https://sonarcloud.io/api/measures/search_history?component=${PROJECT_KEY}&metrics=coverage,cognitive_complexity&from=${SPRINT_START_ISO}" \
  | jq '.measures'
```

Bei fehlender Voraussetzung: graceful skip mit `[!info] SonarQube-Block uebersprungen — Metriken nicht verfuegbar`.

**Local-Reports-Aggregation:**

```bash
# Alle meta.json der letzten N Tage einlesen (N = Sprint-Dauer)
find journal/reports/local -name "meta.json" -mtime -${SPRINT_DAYS} | while read m; do
  jq '. | {story_id, iterations, final_status, pre_flight_warning}' "$m"
done | jq -s '
  {
    eslint_iterations_avg: (map(.iterations.eslint) | add / length),
    semgrep_findings_total: (map(.iterations.semgrep) | add),
    pre_flight_warnings_count: (map(select(.pre_flight_warning != null)) | length)
  }
'
```

**Cost-Aggregation (BOO-84):**

Lies `token_tracking` aus allen meta.json des Sprints und berechne Cost-Aggregate via `bootstrap/references/model-tiers.json` (Pricing zentral, nicht in jeder meta.json dupliziert).

```bash
TIERS_FILE="$(git rev-parse --show-toplevel)/../intentron/bootstrap/references/model-tiers.json"
# Fallback: an typischen Framework-Pfaden suchen (Operator-Setup)
if [ ! -f "$TIERS_FILE" ]; then
  TIERS_FILE=$(find ~/Documents/GitHub/intentron -name model-tiers.json -maxdepth 4 2>/dev/null | head -1)
fi

if [ -n "$TIERS_FILE" ] && [ -f "$TIERS_FILE" ]; then
  # Cost pro Story aus token_tracking.story_totals.estimated_cost_usd (vom implement-Skill bereits gefuellt wenn Hook aktiv)
  find journal/reports/local -name "meta.json" -mtime -${SPRINT_DAYS} | while read m; do
    jq -r '
      if .token_tracking and .token_tracking.story_totals
      then
        {
          story_id: .story_id,
          model_breakdown: (
            (.token_tracking.skill_invocations // [])
            | group_by(.model_tier_default)
            | map({tier: .[0].model_tier_default, input: (map(.input_tokens_total) | add), output: (map(.output_tokens_total) | add)})
          ),
          cache_hit_rate: .token_tracking.cache_hit_rate,
          estimated_cost_usd: .token_tracking.story_totals.estimated_cost_usd,
          override_count: (.override_audit // [] | length)
        }
      else
        {story_id: .story_id, model_breakdown: null, cache_hit_rate: null, estimated_cost_usd: null, override_count: 0}
      end
    ' "$m"
  done | jq -s '
    {
      total_cost_usd: (map(.estimated_cost_usd // 0) | add),
      stories_with_token_data: (map(select(.estimated_cost_usd != null)) | length),
      stories_without_token_data: (map(select(.estimated_cost_usd == null)) | length),
      cache_hit_rate_avg: (map(.cache_hit_rate) | map(select(. != null)) | if length > 0 then add / length else null end),
      override_count_total: (map(.override_count) | add),
      tier_breakdown: (
        map(.model_breakdown // []) | flatten
        | group_by(.tier)
        | map({tier: .[0].tier, input_tokens: (map(.input) | add), output_tokens: (map(.output) | add)})
      )
    }
  '
fi
```

Wenn `model-tiers.json` nicht gefunden wird oder keine Story Token-Daten enthaelt: graceful skip mit `[!info] Cost-Aggregat uebersprungen — model-tiers.json nicht gefunden oder Token-Tracking-Hook nicht aktiv`.

**CI-Reports-Aggregation:**

```bash
# Aus journal/reports/ci/run-*/ die SARIF + JUnit-XML Files lesen
# CI-Failure-Patterns aus letztem Sprint:
find journal/reports/ci -name "*.sarif" -mtime -${SPRINT_DAYS} | xargs jq -s '
  [.[] | .runs[].results[] | .ruleId] | group_by(.) | map({rule: .[0], count: length}) | sort_by(-.count) | .[0:5]
'
```

**L3-DB-Lese (wenn aktiv):**

```sql
-- Trend ueber letzte 5 Sprints
SELECT sprint_number, eslint_iterations_avg, coverage_trend, sonarqube_hotspots_new
FROM sprint_metrics
ORDER BY sprint_number DESC
LIMIT 5;
```

**Aggregat-Metriken ins Sprint-File-Frontmatter:**

`journal/sprint-{date}.md` Frontmatter erweitern (zusaetzlich zu existierenden Feldern):

```yaml
---
sprint: 12
stories: [BOO-15, BOO-16, BOO-17]
metrics:
  eslint_iterations_avg: 2.3
  eslint_recurring_rules:
    - "no-unused-vars (4x)"
    - "react-hooks/exhaustive-deps (3x)"
  semgrep_findings_total: 0
  coverage_trend: "82% -> 84% (+2pp)"
  pre_flight_warnings_count: 1
  ci_failures_top5:
    - "BOO-15: SonarQube Hotspot in auth.ts"
  sonarqube_hotspots_new: 1
  sonarqube_hotspots_resolved: 3
  sonarqube_cognitive_complexity_trend: "stable"
  # BOO-84 Token-Effizienz-Metriken (alle optional, leer wenn Hook nicht aktiv)
  cost_breakdown:
    total_cost_usd: 1.23
    stories_with_token_data: 3
    stories_without_token_data: 0
    cache_hit_rate_avg: 0.78
    override_count_total: 0
    tier_breakdown:
      - tier: haiku
        input_tokens: 45000
        output_tokens: 8000
      - tier: sonnet
        input_tokens: 85000
        output_tokens: 18000
      - tier: opus
        input_tokens: 12000
        output_tokens: 4000
---
```

**Was Sprint-Review zusaetzlich erkennt:**

- Wiederkehrende Iterations-Pattern: "ESLint-Regel X hat in 4 von 5 Stories blockiert"
- Coverage-Drift ueber mehrere Sprints
- CI-Failure-Patterns (welche Checks failen am haeufigsten)
- Token-Pre-Flight-Warnings (BOO-40): wenn Operator regelmaessig trotz Warning weitermachte → Kalibrierung fuer BOO-39

Ergebnisse fliessen in Schritt 6 (Report) und Schritt 8 (Learning-Loop) ein — z.B. wenn 4x dieselbe ESLint-Regel scheiterte, Lesson "ESLint-Regel X als Custom-Rule fuer Skill-Generator pruefen".

### Schritt 3: Tech Debt Inventur

- Code-Duplikation identifizieren (gleiche Funktionen in mehreren Dateien)
- Hardcoded Werte die in `lib/config.js` gehoeren
- Deprecated Features die noch nicht entfernt sind
- Offene Code-Marker zaehlen und bewerten (unfertige Stellen, Workarounds, TODOs)
- Stale Dependencies oder veraltete API-Versionen

### Schritt 4: Backlog-Hygiene

- Verwaiste Issues (referenzierte Issues die nicht existieren)
- Issues ohne Abhaengigkeiten die welche haben sollten
- Obsolete Issues (durch andere Arbeit ueberfluessig geworden)
- Fehlende Issues (Tech Debt das kein Ticket hat)
- Prioritaeten noch aktuell?

### Schritt 5: Prozess-Compliance

- Haben alle kuerzlichen Issues das Pflicht-Template?
- Wurden Abhaengigkeiten bidirektional dokumentiert?
- Sind alle Doku-Files auf gleicher VERSION (`lib/config.js` vs. DOC_FILES)?
- Wurden Obsidian Change-Logs geschrieben?
- Component-Docs (Obsidian oder `docs/components/`) fuer alle aktiven Komponenten aktuell?
- Neue `*.md`-Files alle in `ARCHITECTURE_DESIGN.md §9` registriert? (orphan-check)

### Schritt 6: Report + Massnahmen

Dem Operator praesentieren:
- **Zusammenfassung**: 3-5 Saetze Gesamtbewertung
- **Top 3 Risiken**: Was sollte als naechstes angegangen werden?
- **Tech Debt Score**: Niedrig / Mittel / Hoch
- **Empfohlene Issues**: Neue Stories fuer identifizierten Tech Debt
- **Backlog-Bereinigung**: Issues zum Schliessen/Anpassen vorschlagen
- **Worker-Equivalent** (wenn Financials aktiv, BOO-191): KI-Kosten, Mensch-Equivalent-Kosten, ROI-Faktor und Wall-Clock — der Output-ROI des Sprints in Geld (Details + Rechnung siehe Schritt 9b). Bei inaktiven Financials oder fehlender Doppelspalte: Zeile weglassen (graceful skip).

### Schritt 7: Anti-Pattern-Selbstdiagnose (BOO-26)

> Liest `intentron/references/anti-pattern-katalog.md` und stellt pro AP eine kurze Ja/Nein/Unklar-Frage.
> Kein harter Block — dieser Schritt ist Reflexion, nicht Gate.
> Dauer: ca. 5 Minuten.

**Technische APs (Prozess + Qualität — skill-detektierbar):**

| AP | Diagnose-Frage | Ja/Nein/Unklar |
|----|---------------|----------------|
| AP1 Tool-Chaos | Mehr als 2 verschiedene KI-Coding-Tools im Einsatz — ohne zentrale Evaluation? | |
| AP2 Review-Überlastung | Haben PR-Reviews im letzten Sprint regelmäßig >24h gedauert? | |
| AP3 Feature-Inflation | Wurden Features ohne Intent-Anbindung gebaut — weil sie "schnell gehen"? | |
| AP4 Sicherheit als Endstation | Werden Sicherheitschecks als letzter Schritt vor Deployment gemacht statt in der Pipeline? | |
| AP5 Technische Schulden | Steigen Duplikationsraten oder widersprüchliche Patterns im Code? | |
| AP6 Erfahrungsschulden | Wurden Features ohne UX/Design-Review geliefert — "Design kommt später"? | |
| AP8 Geschwindigkeit ohne System | Mehr als 1 Rollback im letzten Sprint wegen fehlender Tests oder Observability? | |
| AP10 Slopware | Mehr Features als in vorherigen Sprints — aber sinkende Outcome-Messung? | |

**Kultur-APs (nur Reflexion — nicht skill-detektierbar):**

| AP | Diagnose-Frage | Ja/Nein/Unklar |
|----|---------------|----------------|
| AP7 Verantwortungsdiffusion | Hat jemand "Die KI hat es so gemacht" gesagt wenn etwas schiefgelaufen ist? | |
| AP9 Individual-First als Isolation | Gibt es Doppelarbeit weil Architekturentscheidungen nicht geteilt wurden? | |
| AP11 Politische Saboteure | Gibt es ein Muster von systematischen Blockaden bei denselben Personen? | |

**Auswertung:**
- **Alle Nein:** Kein akutes AP-Problem — kurze Notiz in Learning-Loop
- **1-2 Ja/Unklar:** Eintrag in Sprint-Retro mit konkretem Gegenmittel aus `anti-pattern-katalog.md`
- **3+ Ja/Unklar:** ADR-Vorschlag anlegen (unter `docs/domain/adrs/`) + Issue in Backlog für Gegenmittel

Detaillierte Symptome + Gegenmittel: `intentron/references/anti-pattern-katalog.md`

### Schritt 7c: DPO-Audit-Trigger (BOO-69, nur wenn Privacy-Add-on aktiv)

> **Aktivierung:** Dieser Schritt wird nur ausgefuehrt, wenn `PRIVACY.md` im Projekt-Root existiert UND der Sprint-Counter die `privacy_audit_cadence`-Schwelle erreicht hat (aus `environment.json`, Default: alle 4 Sprints).

**Zweck:** Periodische Datenschutz-Compliance-Pruefung via **deterministischem Kontrollkatalog** (BOO-87) statt Freitext-Bewertung. Der Katalog-Runner arbeitet die YAML-Kataloge unter `dpo/controls/` Control-fuer-Control ab und erzeugt ein reproduzierbares, auditor-ready Report-Paar.

**Schritte:**

1. **Cadence-Check:** Sprint-Counter (z.B. via `journal/sprints/`-Verzeichnis-Anzahl) gegen `environment.json.privacy_audit_cadence` pruefen. Wenn nicht erreicht: skip mit Log-Eintrag "BOO-69 DPO-Audit: Cadence nicht erreicht (Sprint {{N}} von {{CADENCE}})".
2. **Katalog-Runner ausfuehren** (deterministisch, BOO-87): aus dem Projekt-Root
   `DPO_PROJECT_ROOT=. python3 <dpo-skill>/scripts/dpo-audit.py`
   (`<dpo-skill>` = Pfad des dpo-Skills, Standalone unter `~/.claude/skills/dpo/`). Der Runner liest `dpo/controls/gdpr.yml` + `ndsg.yml` plus optionale Projekt-Overlays unter `.claude/dpo/controls/`.
3. **Erzeugtes Report-Paar** unter `dpo/reports/<date>_audit.md` (menschenlesbar) + `.json` (maschinenlesbar). Jeder Control hat den Status:
   - **PASS** — mechanischer Check erfuellt (reproduzierbar)
   - **GAP** — mechanischer Check fehlgeschlagen, konkrete Luecke (siehe `mapsTo`)
   - **REVIEW-NEEDED** — Urteils-Check, den der Operator manuell bestaetigt (kein Auto-Urteil, keine Rechtsberatung)
4. **Aggregation in den Sprint-Report:** Sektion `## Privacy Audit (BOO-69/BOO-87)` mit Verweis auf `dpo/reports/<date>_audit.md`, der PASS/GAP/REVIEW-NEEDED-Zusammenfassung sowie der **GAP-Liste** und den **REVIEW-NEEDED-Punkten**, die der Operator abarbeitet.
5. **Backlog-Folge-Stories anlegen** (pro offenem GAP und pro offenem REVIEW-NEEDED-Punkt): je eine Story im Backlog-Adapter mit Label `privacy`.

**Skip-Fall:** Wenn `PRIVACY.md` fehlt oder Cadence nicht erreicht → Schritt 7c ueberspringen, keine weiteren Konsequenzen.

> **Issue-Referenz:** BOO-69 (Trigger) + BOO-87 (deterministischer Kontrollkatalog). DPO-Skill als Standalone unter `~/.claude/skills/dpo/`. Kataloge: `dpo/controls/`. Configuration: `environment.json.privacy_audit_cadence` (Default 4). HANDBUCH-Hintergrund: Anhang O Privacy by Design §AUDIT-Modus + §Deterministischer Kontrollkatalog (BOO-87).

### Schritt 8: Learning-Loop-Eintrag (PFLICHT wenn Learning-Loop aktiv)

> **Aktivierung:** Dieser Schritt wird nur ausgefuehrt wenn `{PROJECT_PATH}/.learning-loop` existiert (Inhalt: `L1`, `L2` oder `L3`).
> Wenn das File fehlt: Skill ueberspringt Schritt 7 und endet nach Schritt 6.

Der Learning-Loop erfasst systematisch **drei Kategorien**: was funktionierte, was nicht funktionierte, naechster Experiment. Details siehe `bootstrap/references/learning-loop.md`.

#### Level L1 — Einfach (learnings.md)

Skill fragt:
```
Sprint-Review abgeschlossen. Jetzt Learning-Loop-Eintrag:

1. WAS FUNKTIONIERTE in dieser Periode? (3 Bullets, mit Story-Link wenn relevant)
2. WAS NICHT FUNKTIONIERTE (+ Root-Cause wenn bekannt)? (3 Bullets)
3. NAECHSTES EXPERIMENT / CHANGE? (3 Bullets, konkret und messbar)
```

Skill haengt Eintrag mit Datums-Header an:
- `{PROJECT_PATH}/journal/learnings.md`
- Wenn Obsidian aktiv: Mirror in `{OBSIDIAN_VAULT}/04 Ressourcen/{PROJECT_NAME}/learnings.md`

Commit: `docs: sprint-review learnings {TODAY}`

#### Level L2 — Strukturiert (Sprint-Journal)

Skill bereitet Frontmatter aus Git-Log + Backlog-API vor (Sprint-Nummer, Story-Counts, Velocity, Zeitraum).

Skill fragt die 4 qualitativen Sektionen:
1. Was funktionierte (mit Tag-Liste)
2. Was nicht funktionierte (+ Root-Cause, mit Tag-Liste)
3. Naechstes Experiment (Idee + Messkriterium + zugeordnete Story)
4. Learnings fuer kommende Sprints (Meta-Regeln)

Skill speichert:
- Primary: `{PROJECT_PATH}/journal/sprint-{YYYY-MM-XX}.md` mit vollem Frontmatter
- Mirror (wenn Obsidian aktiv): `{OBSIDIAN_VAULT}/04 Ressourcen/{PROJECT_NAME}/sprints/sprint-{YYYY-MM-XX}.md`

Commit: `docs: sprint-retro {SPRINT_NUMBER} ({TODAY})`

**Quartals-Meta-Retro:** Bei jedem 4. Sprint-Review konsolidiert der Skill die letzten 4 Sprint-Retros und schreibt `{PROJECT_PATH}/journal/quarterly-{YYYY-QX}.md` mit Trends, Top-Anti-Patterns, erfolgreichen Experimenten.

#### Level L3 — SQLite + MD (nur wenn aktiv)

Zusaetzlich zu L2:
- Skill parst die L2-Frontmatter + Bullets
- Insert in `{PROJECT_PATH}/journal/learnings.db` via `journal/write_sprint.py`
- Tabellen: `sprints`, `events`, `metrics`, `experiments` (Schema siehe `bootstrap/references/learning-loop.md`)

Skill fragt optional nach zusaetzlichen Metriken (z.B. `avg_story_time_days`, `api_cost_total`).

### Schritt 9: Kosten-Snapshot (BOO-189)

Zum Review-Abschluss einen **Ist-Verbrauch** aus den lokalen Claude-Code-Logs erfassen — als gemessene
Groesse, komplementaer zum geschaetzten `token_tracking`-Cost-Aggregat aus Schritt 2b:

- Aufruf: `bash .claude/hooks/ccusage-capture.sh "/sprint-review <sprint>"` (Capture-Template aus dem Setup,
  intern `npx --yes ccusage@latest daily`). Haengt einen Token-/Kosten-Snapshot an
  `docs/financials/sprint-costs.md` an.
- **Soft-Gate:** schlaegt der Aufruf fehl (ccusage/npx nicht installiert, kein Log), **nur warnen** und das
  Review **nicht abbrechen** — der Report bleibt gueltig.
- **Komplementaer zur Schaetzung:** der Ist-Wert ergaenzt das aggregierte `token_tracking` der Story-`meta.json`
  (Schritt 2b), ersetzt es nicht — Schaetzung (`meta.json`) vs. Messung (ccusage) nebeneinander.
- **Bekannte Grenze:** ccusage attribuiert Sub-Agent-Token (Task-Tool) nicht sauber (Issues #313/#806/#950) —
  in stark sub-agent-getriebenen Laeufen ist der ausgewiesene Verbrauch evtl. unvollstaendig bzw. dem Parent
  zugeschlagen.

### Schritt 9b: Worker-Equivalent-Report (BOO-191, nur wenn Financials aktiv)

> **Aktivierung:** Dieser Schritt laeuft direkt nach Schritt 9 — dort liegt der Ist-Verbrauch (ccusage,
> `sprint-costs.md`) bereits vor. Er macht den **Output-ROI** des Sprints in Geld sichtbar:
> was hat es real gekostet (KI), was haette es klassisch gekostet (Mensch-Equivalent), wie schnell waren wir
> (Wall-Clock). Keine neue Datenerhebung — nur Aggregation schon vorhandener Quellen.

**Graceful skip (kein harter Block):** Fehlt `docs/financials/worker-equivalent-baseline.md` (Financials nicht
aktiv) oder tragen die im Sprint abgeschlossenen Stories keine Doppelspalte (`effort_ai_hours` /
`effort_human_equiv_hours`, BOO-193) → diesen Schritt mit `[!info] Worker-Equivalent-Report uebersprungen —
Financials nicht aktiv bzw. keine Doppelspalten-Daten` ueberspringen. Das Review bleibt gueltig.

**Eingaben (alle schon vorhanden, nichts neu erheben):**

| Eingabe | Quelle |
|---|---|
| Aktiver Verrechnungssatz + Waehrung | `docs/financials/worker-equivalent-baseline.md` **Abschnitt 1** (`rate_per_hour`, `currency`, `geo`, `source`) — Intern-Vorrang gilt dort bereits (BOO-190) |
| Σ `effort_ai_hours` (Kontext) | Execution-Isolation-Block der im Sprint abgeschlossenen Stories (Doppelspalte, BOO-193) |
| Σ `effort_human_equiv_hours` | Execution-Isolation-Block der im Sprint abgeschlossenen Stories (Doppelspalte, BOO-193) |
| KI-Kosten | Cost-Aggregat aus Schritt 2b (`cost_breakdown.total_cost_usd`); ergaenzend der ccusage-Ist-Snapshot aus Schritt 9 (`sprint-costs.md`, BOO-189) |
| Wall-Clock | Sprint-Log / Git-Zeitraum (erster bis letzter Sprint-Commit) |

**Rechnung (exakt):**

- **Mensch-Equivalent-Kosten** = Σ `effort_human_equiv_hours` × `rate_per_hour` (native Waehrung aus der Baseline,
  **keine** FX-Umrechnung).
- **ROI-Faktor** = Mensch-Equivalent-Kosten ÷ KI-Kosten.
  > Σ `effort_ai_hours` wird **nur als Kontext** ausgewiesen — **nicht** Teil der ROI-Formel.
- **KI-Kosten** stammen aus dem Cost-Aggregat (Schritt 2b) bzw. ccusage; native ohne Umrechnung. Achtung: ccusage
  attribuiert Sub-Agent-Token nicht sauber (Issues #313/#806/#950) — den KI-Kosten-Wert im Report als **Naeherung**
  kennzeichnen.

**Output-Block „Worker-Equivalent" (DE+EN) — zeigt im Review:**

```
Worker-Equivalent (BOO-191) — Sprint {N}
  - KI-Kosten:                {ki_cost} {currency}   (Naeherung, ccusage-Sub-Agent-Grenze)
  - Σ effort_ai_hours:        {sum_ai} h  (Kontext, nicht in ROI)
  - Σ effort_human_equiv_h:   {sum_human} h
  - Verrechnungssatz:         {rate_per_hour} {currency}/h  ({source})
  - Mensch-Equivalent-Kosten: {human_equiv_cost} {currency}
  - ROI-Faktor:               {roi_factor}×  (Mensch-Equiv ÷ KI)
  - Wall-Clock:               {wall_clock_days} Tage
```

**Report-Datei ablegen:** `docs/financials/sprint-XX-worker-equivalent.md` (Template-Schema siehe
[`docs/financials/sprint-XX-worker-equivalent.md`](../docs/financials/sprint-XX-worker-equivalent.md)). `XX` =
Sprint-Nummer. Frontmatter strukturiert halten, damit BOO-192 (Forecast-vs-Ist) sie maschinell gegenliest.

**Sichtbarkeit:** Den Worker-Equivalent-Block zusaetzlich in **Schritt 6 (Report)** und in der **Abschluss-Summary**
ausweisen (siehe unten). ROI-Sprache bleibt vorerst **intern** (ADR-D §Offen), bis ≥3 Sprints Daten vorliegen.

### Abschluss

Nach Schritt 9b (bzw. Schritt 8 wenn Learning-Loop, sonst Schritt 7):

```
Sprint-Review abgeschlossen.

Report:
  - Architektur: {n} OK / {n} Warnungen / {n} Kritisch
  - Tech Debt: {Score}
  - Backlog-Bereinigung: {n} Empfehlungen
  - Anti-Pattern-Selbstdiagnose: {n} Ja-Treffer — {Aktion}
  - Worker-Equivalent: ROI {roi_factor}× (Mensch-Equiv {human_equiv_cost} {currency} ÷ KI {ki_cost} {currency}) — oder: uebersprungen
  - Learning-Loop: {Level} → {n} Eintraege gespeichert

Commits:
  - sprint-review report (falls als MD gespeichert)
  - learnings entry (Schritt 8)

Naechste Schritte:
  1. Empfohlene Issues in Backlog pruefen
  2. Quartals-Meta-Retro wenn Sprint Nummer % 4 == 0
```

## Integration mit anderen Skills

- **`/ideation`** liest bei jeder Story-Erstellung die letzten 3 Learning-Loop-Eintraege (Schritt 0.5) und warnt bei Anti-Pattern-Match.
- **`/architecture-review --system`** kann das Sprint-Review im System-weiten Scope ausfuehren (alle aktiven Dimensionen).
- **`/breakfix`** schreibt Breakfix-Learnings parallel in den Loop als `what_didnt` mit Root-Cause.

## Trigger-Bedingungen

- Operator sagt: "Sprint Review", "Architektur Audit", "Tech Debt", "Aufraumen", "retro"
- Slash-Command: `/sprint-review`
- Cron (optional): Wochentlich / monatlich — schickt Reminder: "Zeit fuer sprint-review"
- Nach jedem 4. Sprint: Quartals-Meta-Retro-Trigger

## Konfiguration

Learning-Loop-Aktivierung: `{PROJECT_PATH}/.learning-loop` File mit Inhalt `L1`, `L2` oder `L3`. Wird im Bootstrap Block D.4 angelegt oder spaeter manuell.
