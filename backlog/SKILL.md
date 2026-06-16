---
name: backlog
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Sprint Planning und Backlog-Uebersicht. Laedt alle Issues,
  analysiert Abhaengigkeiten und schlaegt priorisierte Reihenfolge vor.
  Validiert die Doppelspalte effort_ai_hours / effort_human_equiv_hours bei neuen Stories.
  Verwenden wenn der Operator "was steht an", "Backlog", "Sprint Planning", "Prioritaeten" oder "/backlog" sagt.
version: 1.6.0
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

### Schritt 5: Backlog-Hygiene (optional)

Falls Probleme erkannt:
- Fehlende Abhaengigkeiten nachtragen
- Verwaiste Referenzen melden
- Obsolete Issues dem Operator zum Schliessen vorschlagen
