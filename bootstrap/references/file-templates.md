# Datei-Templates für neues Projekt

Alle Templates mit {{PLATZHALTER}} müssen mit den gesammelten Projekt-Infos befüllt werden.

---

## config.js

```javascript
// lib/config.js — Single Source of Truth
'use strict';

const VERSION = '{{VERSION_START}}';

// Dokumentationsdateien — Self-Healing überwacht Versions-Sync
const DOC_FILES = {
  'CLAUDE.md': {
    path: 'CLAUDE.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'CONVENTIONS.md': {
    path: 'CONVENTIONS.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'SYSTEM_ARCHITECTURE.md': {
    path: 'SYSTEM_ARCHITECTURE.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'ARCHITECTURE_DESIGN.md': {
    path: 'ARCHITECTURE_DESIGN.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'COMPONENT_INVENTORY.md': {
    path: 'COMPONENT_INVENTORY.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'DEVELOPMENT_PROCESS.md': {
    path: 'DEVELOPMENT_PROCESS.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'DEVELOPER_ONBOARDING.md': {
    path: 'DEVELOPER_ONBOARDING.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  },
  'GOVERNANCE.md': {
    path: 'GOVERNANCE.md',
    versionPattern: /\*\*Version:\*\*\s*([\d.]+)/
  }
};

// Projekt-spezifische Config (anpassen)
const CONFIG = {
  PROJECT_NAME: '{{PROJECT_NAME}}',
  ISSUE_PREFIX: '{{ISSUE_PREFIX}}',
  GITHUB_REPO: '{{GITHUB_REPO}}',
};

module.exports = { VERSION, DOC_FILES, CONFIG };
```

---

## CLAUDE.md (Minimum)

```markdown
# {{PROJECT_NAME}} — AI System Reference

<!-- {{PROJECT_TYPE_MARKER}} mögliche Werte: "> **PROJEKT-TYP: AKTIV** — Code + Deployment in diesem Repo" oder "> **PROJEKT-TYP: GOVERNANCE-REFERENZ** — nur Docs/Specs, kein Coding" -->
{{PROJECT_TYPE_MARKER}}

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}
**Repository:** {{GITHUB_REPO}}

## Identität

{{PROJECT_DESC}}

## Session-Start-Routine (Leichtgewicht-SecondBrain, BOO-129)

Beim Start jeder Session zuerst klären — **wo stehen wir?**
1. Lies den **PMO-Hub**: `docs/project/README.md` (bzw. `{{PROJECT_NAME}} - PMO HUB.md`).
2. Lies die **neuesten Einträge** in `docs/project/meetings/` (letzte Protokolle) und `docs/project/decisions/` (jüngste ADRs).
3. Lies die **neueste Daily Note** in `journal/daily/` (wo sind wir gestern stehen geblieben? offene Punkte).
4. Fasse den **Stand** in 2-3 Sätzen zusammen (offene Action Items, letzte Entscheidung) und schlage den nächsten Schritt vor.

## Session-Ende-Routine (Daily Note, BOO-139)

Am natürlichen Sessionende — oder wenn der Operator die Session beendet — **aktiv anbieten**:

> „Soll ich die Daily Note schreiben, damit die nächste Session weiß, wo wir stehen?"

Bei Bestätigung → `journal/daily/YYYY-MM-DD.md` (eine Datei pro Tag, chronologisch sortierbar):
- **Was wurde gemacht** (Stichpunkte, pro Story/Thema)
- **Entscheidungen** — nur Titel + Verweis auf `docs/project/decisions/` (keine Duplikation)
- **Offen für nächste Session** (Action Items)

**Schreib-Konvention (Stand zurückschreiben):**
- Tages-Logbuch → `journal/daily/YYYY-MM-DD.md`
- Meeting-Minutes / Action Items → `docs/project/meetings/YYYY-MM-DD-<thema>.md`
- Entscheidungen → `docs/project/decisions/` (ADRs)

So wird aus den Markdown-Ordnern ein **Leichtgewicht-SecondBrain** im Repo (ohne Obsidian): *Start liest Stand (PMO-Hub + Meetings/Decisions + letzte Daily Note) → arbeiten → Daily Note / Minutes / Decisions zurückschreiben.* Loop-Visualisierung: `docs/assets/boo-129-leichtgewicht-secondbrain.png`.

> Pfade gelten für `documentation_ssot = repo-docs`. Bei `obsidian` sinngemäß: PMO-Hub + `Meetings/` + `Decisions/` im Vault, Daily Notes im Vault-Daily-Ordner. Bei `external-dms`: Einstiegspunkt laut `docs/project/README.md`; Daily Notes weiterhin lokal in `journal/daily/`.

## Regeln (NIEMALS)

1. **NIEMALS** Code ändern ohne Backlog-Record oder Adapter-Story
2. **NIEMALS** Code ändern ohne Spec-File (`specs/{{PREFIX}}XXX.md`)
3. **NIEMALS** Backlog-Record/Adapter-Story schließen ohne Git Push + Changelog
4. **NIEMALS** API Keys im Chat — User trägt direkt in .env ein
5. **NIEMALS** Backlog-Record ohne Klassifikation/Labels/Tags anlegen
6. **NIEMALS** `config.js` VERSION erhöhen ohne alle DOC_FILES zu bumpen
7. **NIEMALS** Sub-Task direkt von Backlog → Done — immer zuerst "In Progress"
8. **NIEMALS** neue Datei anlegen ohne Eintrag in `ARCHITECTURE_DESIGN.md §Referenzen` + `INDEX.md`
9. **NIEMALS** Issue schließen ohne Integration-Test-Check (neue Komponente abgedeckt?)
10. [Projektspezifische Regeln ergänzen]

## Governance-Hooks

Zwei automatische Git-Hooks sind aktiv:
- **spec-gate.sh**: Blockiert Commits mit Issue-Referenz wenn `specs/{{PREFIX}}XXX.md` fehlt
  oder `## Agent-Pattern` nicht ausgefüllt ist
- **doc-version-sync.sh**: Blockiert Commits wenn `config.js` VERSION erhöht wurde
  aber DOC_FILES-Einträge noch die alte Version haben

## Agent-Pattern (PFLICHT vor jeder Story)

Vor dem Start jeder Story deklarieren:
- **Solo** — 1 klar abgegrenzte Story, <5 Dateien
- **Subagent** — isolierter Task / Einzelrecherche
- **Agent-Team** — >3 unabhängige Tasks ODER Debugging mit unklarer Ursache
- **Parallel-Subagents** — mehrere unabhängige Recherchen gleichzeitig

Entscheidung in `specs/{{PREFIX}}XXX.md` unter `## Agent-Pattern` eintragen — wird von spec-gate.sh erzwungen.

## System-Architektur

[Kurze Übersicht der wichtigsten Komponenten — nach und nach ergänzen]

## Config-Werte

Alle Config-Werte kommen aus `lib/config.js`. VERSION ist dort SSoT.

## Handoff-Prozess

Nach Feature-Entwicklung:
1. Code committen + pushen
2. CLAUDE.md + Changelog updaten
3. Operator informieren: "Feature X fertig"

## Model-Routing-Policy (BOO-84)

Pro Skill ist ein **empfohlenes Modell-Tier** definiert (siehe Skill-Frontmatter `recommended_model`). Die Tier-zu-Version-Mappings und Pricing sind zentral in `bootstrap/references/model-tiers.json` von INTENTRON gepflegt.

| Tier | Modell-Klasse | Wofuer | Default fuer Skills |
|------|--------------|--------|---------------------|
| `haiku` | Claude Haiku | Iterations-Loops, Lints, Frage-Generierung, kleine Smoke-Tests | `/implement` Schritte 6a/6a-bis/6a-tris/6a-quart, Lint-Loops |
| `sonnet` | Claude Sonnet | Sicherer Default fuer die meisten Skill-Aufgaben | `bootstrap`, `backlog`, `visualize`, `sprint-review`, `pitch`, `ideation`, `intent` |
| `opus` | Claude Opus | Architektur-Reviews, Security-Findings, Threat Modeling | `architecture-review`, `cloud-system-engineer`, `/implement` Schritt 6e (Security-Findings) |

### Projekt-weite Overrides

```yaml
model_overrides:
  # Skill-Name: gewuenschtes Tier (haiku | sonnet | opus)
  # Beispiel:
  # implement-iterations: sonnet   # statt haiku (default), wenn Iterationen komplexer sind
```

### Einmalige Overrides

Pro Aufruf via CLI-Flag, z.B. `/implement --model opus`. Praezedenz: **CLI-Flag > CLAUDE.md `model_overrides:` > Skill-Default**. Jeder Override wird in `meta.json` mit Skill, empfohlenem Tier, genutztem Modell, Operator und Zeitstempel im `override_audit` festgehalten.

### Pflicht-Bleibt-Opus

Security-relevante Skills (`architecture-review`, `cloud-system-engineer`, `/implement` Schritt 6e) duerfen pro Story-Lauf **nicht** automatisch auf ein schwaecheres Tier downgrade-en. Operator-Override moeglich, aber dokumentiert im Audit-Trail.

## Native-Pfade (ADR-2 / BOO-199)

Claude-Code-Native-Features vor Framework-Eigenbau. Pro Projekt überschreibbar. Die Flags gelten **nur** bei `runtime_target: claude-code` (Schalter A) — bei `codex`/`cross-tool` sind sie inaktiv.

```yaml
native_paths:
  prefer_native_subagents: true   # /implement generiert echte .claude/agents/<story>-<agent>.md (eigenes 200k-Window) statt Text-Block-Briefings
  prefer_goal_termination: true   # /sprint-run nutzt /goal als Termination-Engine
  prefer_ultraplan: auto          # /architecture-review + /ideation schlagen /ultraplan vor — auto | always | never
  complement_insights: true       # /sprint-review ruft /insights auf und integriert Meta-Block
```

## Prompt-Caching (BOO-84)

Prompt-Caching nutzt Anthropics ephemeral cache markers fuer Komponenten mit hoher Wiederverwendung innerhalb einer Story-Iteration. Geltungsbereich:

- **SKILL.md-Files** aller geladenen Skills
- `CONVENTIONS.md`, `SECURITY.md`, `ARCHITECTURE_DESIGN.md`
- Repo-Map (in `/implement` Schritt 3 erzeugt)

Constraints:
- Mindest-Block-Groesse 1024 Tokens (kleinere Bloecke werden ignoriert)
- Cache TTL 5 Minuten
- Cache-Bloecke duerfen keine Secrets enthalten (kein API-Key, kein Token)
- Cache-Hit-Rate wird in `meta.json` als separater Wert getrackt
```

---

## CONVENTIONS.md (Projekt-lokaler Vertrag)

```markdown
# {{PROJECT_NAME}} — Project Conventions

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}
**Framework:** INTENTRON
**Master-Spezifikation:** `intentron/CONVENTIONS.md`

> Dieses Dokument ist der projektlokale Vertrag fuer Governance-Modus, Ausfuehrungs-Isolation und aktive Gates. Alle Skills lesen zuerst diese Datei, bevor sie Storys schreiben oder umsetzen.

## 1. Governance-Modus

**Aktiver Modus:** `{{GOVERNANCE_MODE}}`

| Modus | Wann nutzen | Aktive Mindest-Bausteine |
|---|---|---|
| `lite` | Wegwerf-Skripte, Lernprojekte, kleine private Experimente | `CLAUDE.md`/`AGENTS.md`, `CONVENTIONS.md`, `specs/`, Spec-Gate, Basis-Linting |
| `standard` | serioese Solo-Projekte, kleine Produktivservices, Kundenarbeit | alles aus `lite` plus Security-Gates, Issue-Guidelines, CI-Lint/SAST, Sensitive-Paths, Learning-Loop L1 |
| `heavy` | regulierte, umsatzkritische, PII-/Payment-/Auth-lastige oder langlebige Systeme | alles aus `standard` plus Coverage-/Performance-Gates, SonarQube, Branch-Protection, Audit-Trail, Mandatory Review, L2/L3-Learning-Loop nach Bedarf |

### Was dieser Modus bewusst weglassen darf

| Bereich | `lite` | `standard` | `heavy` |
|---|---|---|---|
| CI/CD | optional, keine Branch Protection | CI-Lint/SAST empfohlen/default bei GitHub | Branch Protection + Required Checks |
| Security | Basis-Hygiene | SAST, Sensitive Paths | Mandatory Review + Audit-Trail |
| Coverage/Performance | Hinweis statt hartes Gate | aktiv wenn konfiguriert | als Gate erwartet |
| Observability/SLO | nur bei Bedarf | Basis-Doku wenn relevant | verpflichtende Nachweise bei produktionsnahen Systemen |
| Learning | optional/L1 | L1 default | L2/L3 fuer langlebige Systeme |
| Worktrees | nicht erforderlich | Write-Scopes fuer Subagents | `git-worktree` fuer agentische Spuren |

`none` ist kein Governance-Modus, sondern eine Execution-Isolation.

## 2. Execution Isolation

**Aktive Isolation:** `{{EXECUTION_ISOLATION}}`

| Isolation | Bedeutung | Erlaubte Modi |
|---|---|---|
| `none` | ein Operator / ein Worktree, keine parallelen Edits | `linear` |
| `write-scope` | parallele Helfer nur mit disjunkter Datei-Ownership | `linear`, `sub-agents` |
| `git-worktree` | jeder parallele Agent bekommt eigenen Git-Worktree / Branch | `linear`, `sub-agents`, `agentic` |

Regeln:

- `sub-agents` braucht `write-scope` oder `git-worktree`.
- `agentic` braucht `git-worktree`.
- Specs mit `execution_mode: sub-agents` oder `agentic` muessen `worktree_strategy` und `write_scopes` deklarieren.
- Subagents duerfen fremde Aenderungen nicht revertieren.
- Integration/Merge passiert durch Lead-Agent oder Operator.

## 3. Aktive Gates

| Gate | Status | Quelle |
|---|---|---|
| Spec-Gate | aktiv | `hooks/spec-gate.sh` |
| Doc-Version-Sync | aktiv | `hooks/doc-version-sync.sh` |
| Linting | nach Stack | `eslint.config.mjs` / `pyproject.toml` |
| Semgrep | nach Modus | `.semgrep.yml` |
| Dependency-Check | nach Modus | `.claude/hooks/dependency-check.sh` |
| Slopsquatting-Wordlist | nach Modus | `.claude/hooks/slopsquatting/wordlist.txt` (Refresh: `.github/workflows/slopsquatting-refresh.yml`) |
| Coverage-Gate | nach Modus | `.claude/hooks/coverage-check.sh` |
| Anti-Platzhalter-Check | nach Modus | `.claude/hooks/anti-placeholder-check.py` |
| Performance-Gate | nach Modus | `.github/workflows/perf.yml` |
| Sensitive-Paths-Review | nach Modus | `.claude/sensitive-paths.json` |

## 4. Pipeline-Abgrenzung

Das Framework ist zuerst eine sequenzielle Engineering-Pipeline mit Quality-Gates, nicht selbst ein vollautonomer Developer-Agent. Subagents sind spezialisierte Ausfuehrungshelfer innerhalb einer kontrollierten Story. Claude, Codex oder Hermes koennen dieses Framework agentisch nutzen, aber nur innerhalb der hier deklarierten Konventionen.
```

---

## ARCHITECTURE_DESIGN.md (Minimum)

```markdown
# {{PROJECT_NAME}} — Architecture Design

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}

## Übersicht

{{PROJECT_DESC}}

## Quality Attributes

| Attribut | Priorität | Beschreibung |
|----------|-----------|-------------|
| Reliability | Hoch | [Ausfallsicherheit, Retry-Logik] |
| Data Integrity | Hoch | [Konsistenz, Validierung] |
| Security | Hoch | [Auth, Secrets-Handling] |
| Performance | Mittel | [Latenz, Throughput] |
| Observability | Mittel | [Logging, Monitoring] |
| Maintainability | Mittel | [Code-Qualität, Doku] |

## ADRs (Architecture Decision Records)

| Nr | Datum | Titel | Status |
|----|-------|-------|--------|
| ADR-01 | {{TODAY}} | Initial Architecture | Active |

## Referenzen (alle Dateien)

> **Pflicht:** Jede neue Datei sofort hier eintragen — vor dem git commit.

| Datei | Zweck |
|-------|-------|
| `CLAUDE.md` | AI-Kontext, Regeln, Governance |
| `CONVENTIONS.md` | Projekt-Konventionen: Governance-Modus, Execution-Isolation, aktive Gates |
| `SYSTEM_ARCHITECTURE.md` | Komponenten, Flows, Konfiguration |
| `ARCHITECTURE_DESIGN.md` | ADRs, Quality Attributes, Referenzen |
| `DEVELOPER_ONBOARDING.md` | Einstieg, SSoTs, Runtime-/Tool-Hinweise, Pflegepflicht fuer neue Entwicklerteams |
| `INDEX.md` | Alle Docs kategorisiert |
| `COMPONENT_INVENTORY.md` | Alle Komponenten mit Status |
| `GOVERNANCE.md` | Entwicklungs-Prozess, Governance-Regeln |
| `SECURITY.md` | Security-Policy, API-Key-Regeln |
| `CHANGELOG.md` | Version-History |
| `lib/config.js` | SSoT alle Parameter |
| `specs/TEMPLATE.md` | Story-Template |
```

---

## INDEX.md (Minimum)

```markdown
# {{PROJECT_NAME}} — Docs Index

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}

> Alle Dokumente des Projekts kategorisiert.
> **Pflicht:** Jede neue Datei sofort hier eintragen — vor dem git commit.

## Core

| Datei | Zweck | Aktualisiert |
|-------|-------|-------------|
| `CLAUDE.md` | AI-Kontext, Regeln, Governance | v{{VERSION_START}} |
| `CONVENTIONS.md` | Projekt-Konventionen, Governance-Modus, Execution-Isolation | v{{VERSION_START}} |
| `SYSTEM_ARCHITECTURE.md` | Komponenten, Agent-Liste, Flows | v{{VERSION_START}} |
| `ARCHITECTURE_DESIGN.md` | ADRs, Quality Attributes | v{{VERSION_START}} |
| `INDEX.md` | Dieses Verzeichnis | v{{VERSION_START}} |

## Governance

| Datei | Zweck |
|-------|-------|
| `GOVERNANCE.md` | Entwicklungs-Prozess, Regeln |
| `CONVENTIONS.md` | Projekt-lokaler Vertrag fuer Skills und Adapter |
| `SECURITY.md` | Security-Policy |
| `CHANGELOG.md` | Version-History |
| `specs/TEMPLATE.md` | Story-Template |

## Komponenten

| Datei | Zweck |
|-------|-------|
| `COMPONENT_INVENTORY.md` | Alle Komponenten mit Status |
| `lib/config.js` | SSoT Konfiguration |
```

---

## SYSTEM_ARCHITECTURE.md (Minimum)

```markdown
# {{PROJECT_NAME}} — System Architecture

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}

## Komponenten

[Hier Komponenten eintragen wenn System wächst]

## Config

Alle Parameter in `lib/config.js`. VERSION ist SSoT.
```

---

## COMPONENT_INVENTORY.md (Minimum)

```markdown
# {{PROJECT_NAME}} — Component Inventory

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}

| Komponente | Datei | Status | Beschreibung |
|-----------|-------|--------|-------------|
| Config | `lib/config.js` | Active | SSoT alle Parameter |
```

---

## specs/TEMPLATE.md

```markdown
---
story_id: {{ISSUE_PREFIX}}XXX
estimate: <SP, gesetzt von /ideation Schritt 5b>
token_estimate: <absolute Tokens, gesetzt von /ideation Schritt 5b>
execution_mode: <linear | sub-agents | agentic, gesetzt von /ideation Schritt 5b>
worktree_strategy: <none | write-scope | git-worktree, gesetzt gemaess CONVENTIONS.md>
codex_execution_hint: <single-agent | parallel-workers | worktree-required, optional>
write_scopes:
  - <Pfad oder Glob, z.B. "src/auth/**">
estimation_basis: |
  <Prosa: Files-Anzahl, Diff-Groesse, Tests, Doku, Cross-Skill, References, L3-Faktor>
---

# {Feature Name}

> **Issue:** {{ISSUE_PREFIX}}XXX | **Erstellt:** {Datum} | **Status:** Draft / Approved / Done

## Agent-Pattern

> **PFLICHT — vor dem Start ausfuellen. Wird von spec-gate.sh erzwungen.**

- [ ] **Solo** — 1 klar abgegrenzte Story, <5 Dateien, keine parallelen Komponenten
- [ ] **Subagent** — isolierter Task / Einzelrecherche / Explore-Auftrag
- [ ] **Agent-Team** — >3 unabhaengige Tasks ODER Debugging mit unklarer Ursache ODER Cross-Layer
- [ ] **Parallel-Subagents** — mehrere unabhaengige Recherchen gleichzeitig

**Gewähltes Pattern:** [Solo / Subagent / Agent-Team / Parallel-Subagents]
**Begründung:** [Warum dieses Pattern? Tasks zaehlen, Trigger-Bedingung benennen]
**Team-Komposition:** [Nur bei Agent-Team: z.B. "Lead (Sonnet) + Explore (Haiku) + Plan (Sonnet)" — sonst "n/a"]

## Execution Isolation

> Pflicht, wenn `execution_mode` = `sub-agents` oder `agentic`.

**Projekt-Konvention:** siehe `CONVENTIONS.md`
**Worktree-Strategie:** [none / write-scope / git-worktree]
**Write-Scopes:**
- [Pfad/Glob + verantwortlicher Agent, z.B. `src/auth/**` — Lead]
- [Pfad/Glob + verantwortlicher Agent]
**Integrationsregel:** [Wer merged/integrated? Lead-Agent oder Operator]

---

## Why

[1-2 Saetze: Welches Problem wird geloest? Warum jetzt?]

## What

[Konkretes Deliverable. Woran erkennt man, dass es fertig ist?]

## Constraints

### Must
- [Bestehende Patterns/Conventions einhalten]
- [Config SSoT in lib/config.js]

### Must Not
- [Keine neuen Dependencies ohne Begruendung]
- [Kein Code ausserhalb des Scopes aendern]
- [Keine Hardcoded Values — alles ueber config.js]
- [Keine Secrets in Code/Logs]

### Out of Scope
- [Explizit ausgeschlossene Features/Aenderungen]

## Current State

**Relevante Dateien:**
- `path/to/file.js` — [was die Datei tut, warum relevant]

**Bestehende Patterns:**
- [Konvention die eingehalten werden muss, mit Beispiel-Datei]

**Architektur-Dimensionen (betroffen):**
- [Welche Dimensionen sind relevant? Kurze Einschaetzung]

## Tasks

> Jeder Task: max 3 Dateien, unter 30min, unabhaengig committbar.
> Tasks die zusammen ausgeliefert werden muessen → gruppieren.
> Letzter Task = IMMER Dokumentation + Config.

### T0: Prozesskatalog-Check
- [ ] Runtime-Anweisungen gelesen (`AGENTS.md`, `CLAUDE.md` oder projektspezifischer Einstieg)
- [ ] Runtime-Details geklaert: Setup, Test, Lint/SAST, lokale Services, Deploy-Hinweise
- [ ] `DEVELOPER_ONBOARDING.md` oder verlinktes Developer Onboarding gelesen
- [ ] Project Hub / PMO Hub gelesen
- [ ] `ARCHITECTURE_DESIGN.md` und/oder Zielarchitektur gelesen
- [ ] `SECURITY.md` gelesen
- [ ] Backlog-Matrix / Story-Reihenfolge gelesen
- [ ] Story-Blocker im Backlog-Tool oder lokalen Backlog geprueft
- [ ] Blocker benannt oder als "keine" dokumentiert
- [ ] Lokale Story-Spec, Spec-Pack oder Uplift-Matrix gelesen
- [ ] Lokale Story-Spec oder Spec-Pack gegen Issue/Backlog abgeglichen
- [ ] Gibt es einen aehnlichen Prozess der erweitert werden kann? (Referenz)
- [ ] Welche bestehenden Dateien werden beruehrt?

### T1: [Erster Task]
- [ ] [Konkrete Aufgabe]
- [ ] Verify: [Wie pruefen wir dass T1 korrekt ist?]

### T2: [Zweiter Task]
- [ ] [Konkrete Aufgabe]
- [ ] Verify: [Wie pruefen wir dass T2 korrekt ist?]

### T_last: Dokumentation + Config
- [ ] ARCHITECTURE_DESIGN.md §Referenzen um neue Dateien ergaenzen
- [ ] INDEX.md um neue Dateien ergaenzen
- [ ] COMPONENT_INVENTORY.md aktualisieren
- [ ] DEVELOPER_ONBOARDING.md aktualisieren oder begruenden: keine Aenderung noetig
- [ ] Project Hub / PMO-Hub aktualisieren oder begruenden: keine Aenderung noetig
- [ ] CHANGELOG.md Eintrag
- [ ] config.js VERSION bumpen
- [ ] Alle DOC_FILES auf neue VERSION setzen

## Rollout

> **PFLICHT fuer AI-generierte Stories — wird von spec-gate.sh erzwungen.**
> Fuer reine Doku-Aenderungen ohne neuen Code-Pfad: `**Feature-Flag:** n/a — [Begruendung]` eintragen.

**Feature-Flag:** `flag.{{STORY_ID}}` — Default: `false`

**Implementierung (Projekt-Groesse):**
- Kleines Projekt: Env-Variable `FLAG_{{STORY_ID}}=true/false`
- Mittleres Projekt: `config/flags.json` (hot-reloadable)
- Grosses Projekt: Externes Tool (LaunchDarkly / Unleash) — ADR anlegen

**Stufen:**
- [ ] Stufe 1: 5 % Nutzer / 24h — Erfolgs-Kriterium: keine Fehler im Log
- [ ] Stufe 2: 50 % Nutzer / 24h — Erfolgs-Kriterium: P95 ≤ Baseline × 1.05
- [ ] Stufe 3: 100 % Nutzer — Flag nach 72h stabilem Betrieb entfernen

**Rollback-Kommando:** `FLAG_{{STORY_ID}}=false` (Config-Reload, keine Code-Aenderung noetig)

**AI-Markierung:** Alle in dieser Story hinzugefuegten Code-Pfade erhalten Kommentar `// AI-generated: {{STORY_ID}}` (Rollback-Identifikation, BOO-17).

---

## Dokumentations-Impact

| Datei | Was aendern |
|-------|-------------|
| `ARCHITECTURE_DESIGN.md` | §Referenzen: neue Datei eintragen |
| `INDEX.md` | Neue Datei eintragen |
| `CHANGELOG.md` | Version-Eintrag |

## Abhaengigkeiten

- **Blockiert durch:** —
- **Blockiert:** —

## Acceptance Criteria

- [ ] [Messbares Kriterium 1]
- [ ] [Messbares Kriterium 2]
- [ ] spec-gate.sh + doc-version-sync.sh gruen (kein blockierter Commit)
- [ ] Integration-Test-Skill: Neue Komponente abgedeckt oder Skill erweitert
- [ ] ESLint: 0 Errors (Warnings dokumentiert)
- [ ] Obsidian Change-Log Eintrag

## Session-Referenz

> Wird von `/implement` Schritt 5 automatisch befuellt (BOO-19).

**Session-Timestamp:** {automatisch}
**Session-ID:** `{automatisch}` (best-effort — neueste Session beim Commit)
**Session-Log:** `~/.claude/projects/.../sessions/{session-id}.jsonl`
**Commit-SHA:** `{automatisch nach Git Commit}`
**Audit-Trace:** `bash .claude/scripts/audit-trace.sh {SPEC_ID}` (braucht jq)
```

---

## spec-gate.sh (Hook-Template)

> Anpassen: WORKSPACE-Pfad + ISSUE_PREFIX + CONTAINER_CMD (optional, nur bei Agent-Systemen).

```bash
#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  SPEC-GATE — Governance Hook
#  Blockiert git commit wenn specs/{PREFIX}XXX.md fehlt oder Agent-Pattern fehlt.
#
#  Claude Code PreToolUse Hook (Bash)
#  Input: JSON via stdin: {"tool_input": {"command": "..."}}
#  Exit 1 → Tool-Call blockiert | Exit 0 → erlaubt
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

WORKSPACE="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
ISSUE_PREFIX="{{ISSUE_PREFIX}}"  # z.B. "PROJ-"

# JSON parsen → Command extrahieren
INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null || echo "")

# Nur git commit Befehle prüfen
if ! echo "$CMD" | grep -qE 'git commit'; then
  exit 0
fi

# {PREFIX}XXX aus Commit-Message extrahieren (dynamisch)
PREFIX_ESC=$(echo "$ISSUE_PREFIX" | sed 's/[-]/\\-/g')
ISSUE=$(echo "$CMD" | grep -oP "${PREFIX_ESC}[0-9]+" | head -1 || echo "")
if [ -z "$ISSUE" ]; then
  exit 0  # Kein Issue referenziert → kein Gate
fi

# Spec-File prüfen
SPEC_FILE="$WORKSPACE/specs/${ISSUE}.md"
if [ ! -f "$SPEC_FILE" ]; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  🚫  GOVERNANCE-SPERRE: specs/${ISSUE}.md fehlt!           "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Commit mit ${ISSUE} ist BLOCKIERT."
  echo ""
  echo "  Nächste Schritte:"
  echo "  1. specs/TEMPLATE.md lesen"
  echo "  2. specs/${ISSUE}.md erstellen + befüllen"
  echo "  3. git add specs/${ISSUE}.md && git commit -m 'docs: specs/${ISSUE}.md'"
  echo ""
  exit 1
fi

# Agent-Pattern prüfen — Sektion vorhanden?
if ! grep -q "## Agent-Pattern" "$SPEC_FILE"; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  🚫  GOVERNANCE-SPERRE: Agent-Pattern fehlt in Spec!        "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Commit mit ${ISSUE} ist BLOCKIERT."
  echo ""
  echo "  Nächste Schritte:"
  echo "  1. specs/${ISSUE}.md öffnen"
  echo "  2. ## Agent-Pattern Sektion aus specs/TEMPLATE.md einfügen"
  echo "  3. Gewähltes Pattern ausfüllen"
  echo ""
  exit 1
fi

# Agent-Pattern prüfen — nicht leer/TBD
PATTERN=$(grep "^\*\*Gewähltes Pattern:\*\*" "$SPEC_FILE" | sed 's/\*\*Gewähltes Pattern:\*\* //' | tr -d '[:space:]' || echo "")
if [ -z "$PATTERN" ] || [ "$PATTERN" = "TBD" ] || echo "$PATTERN" | grep -q "\["; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  🚫  GOVERNANCE-SPERRE: Agent-Pattern nicht ausgefüllt!     "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Erlaubte Werte: Solo | Subagent | Agent-Team | Parallel-Subagents"
  echo ""
  exit 1
fi

# Agent-Team: Team-Komposition prüfen
if echo "$PATTERN" | grep -qi "Agent-Team"; then
  TEAM=$(grep "^\*\*Team-Komposition:\*\*" "$SPEC_FILE" | sed 's/\*\*Team-Komposition:\*\* //' | tr -d '[:space:]' || echo "")
  if [ -z "$TEAM" ] || [ "$TEAM" = "n/a" ] || echo "$TEAM" | grep -q "\["; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  🚫  GOVERNANCE-SPERRE: Team-Komposition fehlt!             "
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "  Pattern 'Agent-Team' gewählt aber Team-Komposition ist leer."
    echo "  Beispiel: Lead (Sonnet) + Explore (Haiku) + Plan (Sonnet)"
    echo ""
    exit 1
  fi
fi

# Rollout-Sektion prüfen (BOO-17 — Feature-Flag-Konvention)
if ! grep -q "## Rollout" "$SPEC_FILE"; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  🚫  GOVERNANCE-SPERRE: ## Rollout fehlt in Spec!           "
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Commit mit ${ISSUE} ist BLOCKIERT."
  echo ""
  echo "  Naechste Schritte:"
  echo "  1. specs/${ISSUE}.md oeffnen"
  echo "  2. ## Rollout Sektion aus specs/TEMPLATE.md einfuegen"
  echo "  3. Feature-Flag-Name und Rollout-Stufen ausfuellen"
  echo "     (Fuer reine Doku-Stories: '**Feature-Flag:** n/a' genügt)"
  echo ""
  exit 1
fi

exit 0
```

---

## doc-version-sync.sh (Hook-Template)

> Anpassen: WORKSPACE-Pfad.

```bash
#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  DOC-VERSION-SYNC — Governance Hook
#  Blockiert git commit wenn lib/config.js VERSION erhöht wurde,
#  aber DOC_FILES noch die alte Version haben.
#
#  Escape-Hatch: git commit --no-verify
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

WORKSPACE="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null || echo "")

if ! echo "$CMD" | grep -qE 'git commit'; then exit 0; fi
if echo "$CMD" | grep -q "\-\-no-verify"; then exit 0; fi

cd "$WORKSPACE" 2>/dev/null || exit 0
STAGED=$(git diff --staged --name-only 2>/dev/null || echo "")
if ! echo "$STAGED" | grep -q "lib/config.js"; then exit 0; fi

RESULT=$(node -e "
const { execSync } = require('child_process');
const { readFileSync, existsSync } = require('fs');
const path = require('path');
const BASE = '$WORKSPACE';

try {
  const staged = execSync('git show :lib/config.js', { cwd: BASE }).toString();
  let head = '';
  try { head = execSync('git show HEAD:lib/config.js', { cwd: BASE }).toString(); } catch {}

  const newVer = (staged.match(/const VERSION\s*=\s*'([\d.]+)'/) || [])[1];
  const oldVer = (head.match(/const VERSION\s*=\s*'([\d.]+)'/)  || [])[1] || '';
  if (!newVer || newVer === oldVer) { process.exit(0); }

  const docRe = /'[^']+\.md'\s*:\s*\{\s*path:\s*'([^']+)'\s*,\s*versionPattern:\s*(\/[^/\n]+\/[gimsuy]*)/g;
  const mismatches = [];
  let m;
  while ((m = docRe.exec(staged)) !== null) {
    const relPath = m[1];
    const patStr  = m[2];
    const fullPath = path.join(BASE, relPath);
    if (!existsSync(fullPath)) continue;
    const parts = patStr.match(/^\/(.+)\/([gimsuy]*)$/);
    if (!parts) continue;
    const pat = new RegExp(parts[1], parts[2]);
    const content = readFileSync(fullPath, 'utf8');
    const match = content.match(pat);
    if (!match || match[1] === newVer) continue;
    mismatches.push(relPath + '|||' + match[1]);
  }

  if (mismatches.length === 0) { process.exit(0); }
  process.stdout.write('MISMATCH:' + newVer + ':' + oldVer + ':' + mismatches.join(':::'));
} catch (e) { process.exit(0); }
" 2>/dev/null || echo "")

if [ -z "$RESULT" ] || [[ "$RESULT" != MISMATCH:* ]]; then exit 0; fi

NEW_VER=$(echo "$RESULT" | cut -d: -f2)
OLD_VER=$(echo "$RESULT" | cut -d: -f3)
ENTRIES=$(echo "$RESULT" | cut -d: -f4-)

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🚫  DOC-VERSION-SYNC: Doku nicht auf v${NEW_VER} aktualisiert!"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  lib/config.js VERSION: ${OLD_VER} → ${NEW_VER}"
echo "  Folgende Doku-Dateien haben noch die alte Version:"
echo ""
echo "$ENTRIES" | tr ':::' '\n' | while IFS= read -r entry; do
  [ -z "$entry" ] && continue
  FILE=$(echo "$entry" | cut -d'|' -f1)
  OLDV=$(echo "$entry" | cut -d'|' -f4)
  echo "    ❌  ${FILE}  (hat: ${OLDV})"
done
echo ""
echo "  Escape-Hatch: git commit --no-verify"
echo ""
exit 1
```

---

## .gitignore

```
node_modules/
.env
*.log
*.pid
*.lock
.DS_Store
dist/
build/
__pycache__/
*.pyc
.venv/
venv/

# BOO-36: lokale Iteration-Outputs aus /implement Schritt 6
# (ESLint-SARIF, Test-JUnit-XML, Coverage-JSON, Semgrep-SARIF, meta.json pro Run)
# Werden NICHT committed — /sprint-review aggregiert sie in journal/sprint-{date}.md.
journal/reports/local/

# BOO-204: transiente Story-Subagent-Definitionen aus /implement Schritt 4b
# (pro Lauf generiert als <STORY-ID>-<agent>.md, nicht Teil des Story-Diffs).
# Praezise auf Issue-praefixierte Dateien — persistente Agents wie lint-fixer.md bleiben getrackt.
.claude/agents/*-[0-9]*-*.md

# BOO-151: NUR bei Multi-User-VPS (mehrere Menschen, ein Projekt) aktivieren —
# Daily Notes sind dann persoenlich pro User -> lokal, nicht geteilt.
# Bei Solo/Single-Operator bleibt journal/daily/ committet (= SecondBrain-Logbuch).
# journal/daily/
```

---

## journal/reports/local/<RUN_DIR>/meta.json (BOO-36 — Implement-Run-Metadaten)

> Jeder `/implement`-Run schreibt am Ende dieser Datei. Schema fix, von `/sprint-review` parsbar.

```json
{
  "story_id": "BOO-15",
  "started_at": "2026-04-27T14:30:00Z",
  "completed_at": "2026-04-27T14:34:00Z",
  "iterations": {
    "eslint": 3,
    "tests": 2,
    "semgrep": 1,
    "coverage": 1
  },
  "final_status": "passed",
  "environment": "mac",
  "pre_flight_warning": null
}
```

**Feld-Konvention:**

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `story_id` | string | Issue-Key aus Linear (z.B. `BOO-36`) |
| `started_at` | ISO-8601 UTC | Run-Start (`date -u +%Y-%m-%dT%H:%M:%SZ`) |
| `completed_at` | ISO-8601 UTC | Run-Ende |
| `iterations.eslint` | int | Anzahl ESLint-Iterationen (0 wenn Gate uebersprungen) |
| `iterations.tests` | int | Anzahl Test-Iterationen |
| `iterations.semgrep` | int | Anzahl Semgrep-Iterationen |
| `iterations.coverage` | int | Anzahl Coverage-Iterationen |
| `final_status` | enum | `passed` \| `failed` \| `stopped_iteration_limit` |
| `environment` | enum | `mac` \| `vps` \| `ci` \| `unknown` (aus `.claude/environment.json`) |
| `pre_flight_warning` | string \| null | Gesetzt von `/implement` Schritt 0b (BOO-40) wenn Operator trotz Projektion > 80% weitergemacht hat. Format: `"projection 90%, user proceeded"`. `null` bei normalem Run. Wird von `/sprint-review` ausgewertet — wenn Session tatsaechlich gecompacted hat, fliesst die Lesson zurueck nach L3 fuer BOO-39-Kalibrierung. |

**Pfad-Konvention:**
- Run-Verzeichnis: `journal/reports/local/{YYYY-MM-DD_HHMM}_{STORY-ID}/`
- Verzeichnis ist gitignored (siehe `.gitignore`-Block oben)
- Weitere Dateien im selben Verzeichnis:
  - `eslint-iter{N}.sarif` — pro ESLint-Iteration
  - `tests-iter{N}.junit.xml` — pro Test-Iteration
  - `coverage-final.json` — Coverage-Endstand
  - `semgrep-final.sarif` — Semgrep-Endstand

**Verantwortlichkeit (BOO-36):**
- **Schreiben:** `/implement` (raw Outputs + meta.json)
- **Lesen + aggregieren:** `/sprint-review` (in `journal/sprint-{date}.md`)
- **L3-DB-Write:** ausschliesslich `/sprint-review` zweite Phase in `journal/learnings.db` — Implement schreibt NICHT direkt in die L3-DB.

---

## .env.example

```bash
# Linear
LINEAR_API_KEY=

# Telegram (optional)
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=

# Research (optional)
OPENROUTER_API_KEY=

# Automation Daemon (optional)
LINEAR_WEBHOOK_SECRET=
DAEMON_PORT=3001

# Claude Code
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
```

---

## CHANGELOG.md

```markdown
# Changelog — {{PROJECT_NAME}}

## v{{VERSION_START}} — {{TODAY}}

- Initial project setup with INTENTRON
- Governance hooks installed: spec-gate.sh, doc-version-sync.sh
- Base skills installed
```

---

## eslint.config.mjs (Node.js / Full-Stack)

**Industriestandard-Set seit BOO-2 (2026-05-01):** ESLint Recommended + Airbnb Base + Security + SonarJS. Alles MIT-Lizenz, kein Cloud-Service, keine Lizenzkosten.

**npm-Installation:**
```bash
npm install --save-dev eslint @eslint/js eslint-config-airbnb-base \
  eslint-plugin-security eslint-plugin-sonarjs @eslint/compat
```

(`@eslint/compat` ueberbrueckt Configs, die noch keine native Flat-Config-Form haben — z.B. eslint-config-airbnb-base. Bei Projekten, die ausschliesslich Flat-Config-native Plugins nutzen, kann das Paket entfallen.)

```javascript
// eslint.config.mjs — ESLint v9+ Flat Config (Industriestandard, BOO-2)
import js from '@eslint/js';
import { FlatCompat } from '@eslint/compat';
import securityPlugin from 'eslint-plugin-security';
import sonarjsPlugin from 'eslint-plugin-sonarjs';

const compat = new FlatCompat();

export default [
  // Layer 1 — ESLint Recommended (Syntax, no-undef, no-unreachable etc.)
  js.configs.recommended,

  // Layer 2 — Airbnb Base (Industriestandard fuer Code-Stil + Best Practices)
  ...compat.extends('eslint-config-airbnb-base'),

  // Layer 3 — Security-Plugin (eval, child_process, RegExp DoS, unsafe Buffer ...)
  securityPlugin.configs.recommended,

  // Layer 4 — SonarJS (Code Smells, Cognitive Complexity, duplicate Logic)
  sonarjsPlugin.configs.recommended,

  // Hausregeln (ueberschreiben/ergaenzen die obigen Configs gezielt)
  {
    files: ['**/*.js', '**/*.mjs'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'commonjs',
      globals: {
        require: 'readonly',
        module: 'readonly',
        exports: 'readonly',
        process: 'readonly',
        console: 'readonly',
        setTimeout: 'readonly',
        clearTimeout: 'readonly',
        setInterval: 'readonly',
        clearInterval: 'readonly',
        __dirname: 'readonly',
        __filename: 'readonly',
        Buffer: 'readonly',
      },
    },
    rules: {
      'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      'no-console': 'off',
      'semi': ['error', 'always'],
      'no-undef': 'error',
    },
  },
  {
    ignores: ['node_modules/**', 'dist/**', 'build/**'],
  },
];
```

**Mit React / Frontend (TSX):** statt `eslint-config-airbnb-base` das Paket `eslint-config-airbnb` verwenden (zieht React-spezifische Regeln mit, plus `eslint-plugin-react` und `eslint-plugin-jsx-a11y` als Peer Deps).

**Zusaetzlich fuer `.tsx`/JSX (BOO-141, Pflicht bei Stack b/c mit React):** das `globals`-Paket installieren und einen eigenen Frontend-Block mit Browser- **und** React-Globals ergaenzen. Ohne diesen Block wirft `js.configs.recommended`'s `no-undef`-Regel bei jeder `.tsx`-Datei mit JSX `'React' is not defined` (und `window`/`document`/`fetch` sind ebenfalls undefiniert), weil der Node-Hausregeln-Block oben nur Node-Globals kennt:

```bash
npm install --save-dev globals
```

```javascript
// am Kopf von eslint.config.mjs (zusaetzlich, nur bei React/Frontend)
import globals from 'globals';

// ... im Export-Array als eigener Frontend-Block (nach den Layer-Configs,
//     parallel zum Node-Hausregeln-Block):
{
  files: ['**/*.ts', '**/*.tsx'],
  languageOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    globals: {
      ...globals.browser,   // window, document, fetch, ...
      React: 'readonly',    // klassischer JSX-Transform / React.*-Referenzen
    },
  },
  rules: {
    'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    'no-undef': 'error',
  },
},
```

**Iteration im Implement-Skill:** `/implement` Schritt 6a iteriert deklarativ ueber den ESLint-Output bis 0 Errors (max. 5 Iterationen, dann Stopp mit Hinweis). Compound Engineering Mechanik #1 nach Schrader Code Crash.

---

## tsconfig.json (BOO-127)

Nur bei `LANG_VARIANT = ts` (Stack a/b/c). Strikte Defaults — Typsicherheit ist ein Gate, keine Deko.

**npm-Installation (zusaetzlich zu eslint.config.mjs):**
```bash
npm install --save-dev typescript typescript-eslint
```

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2022"],
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noEmit": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules", "dist", "build"]
}
```

`eslint.config.mjs` bindet bei `ts` zusaetzlich `typescript-eslint` ein:

```javascript
// am Kopf von eslint.config.mjs (zusaetzlich, nur bei TypeScript)
import tseslint from 'typescript-eslint';
// ... im Export-Array nach js.configs.recommended:  ...tseslint.configs.recommended,
// und die Hausregeln/`files` auf '**/*.ts','**/*.tsx' ausweiten.
```

**Frontend/Meta-Framework (Next.js, Nuxt, SvelteKit ...):** `module`/`moduleResolution` auf `Bundler`, `jsx: "preserve"`, `lib` um `DOM` ergaenzen; ein framework-eigenes `tsconfig` (z.B. `next/tsconfig`) ggf. via `extends` einbinden — Operator bestaetigt das als ADR.

---

## tsc --noEmit Typecheck (BOO-127)

Nur bei `LANG_VARIANT = ts`. Der Bootstrap nutzt **Weg A** (Schritt in `eslint.yml`); Weg B ist optional.

**Weg A — Schritt in `eslint.yml` (Default):** nach dem ESLint-Schritt ergaenzen:
```yaml
      - name: TypeScript typecheck
        run: npx tsc --noEmit
```

**Weg B — eigene `.github/workflows/typecheck.yml`:**
```yaml
name: Typecheck
on: [push, pull_request]
jobs:
  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npx tsc --noEmit
```

Required Status Check (BOO-29): `typecheck` (Weg B) bzw. der gruene `eslint`-Lauf inkl. tsc-Schritt (Weg A). Lokal deckt der Pre-Commit-Hook (Phase 4.6) `tsc --noEmit` ab.

---

## .prettierrc (Frontend / Full-Stack)

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
```

---

## pyproject.toml (Python)

**Industriestandard-Set seit BOO-2 (2026-05-01):** Ruff mit `S` (flake8-bandit, Security) als zusaetzliches Regelset — erkennt `eval`, `exec`, unsichere Hashes, Shell-Injection-Pattern, hardcoded Passwords etc. Plus `B` (flake8-bugbear, haeufige Python-Bugs) und `C4` (flake8-comprehensions, idiomatischere Listen-/Dict-Comprehensions).

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = [
  "E",   # pycodestyle Errors
  "W",   # pycodestyle Warnings
  "F",   # Pyflakes (unused imports/vars)
  "I",   # isort (Import-Reihenfolge)
  "B",   # flake8-bugbear (Bug-Patterns)
  "C4",  # flake8-comprehensions (idiomatische Listen/Dicts)
  "S",   # flake8-bandit (Security)
]
ignore = []

[tool.ruff.lint.per-file-ignores]
"tests/*" = ["S101"]          # `assert` in Tests erlaubt
"migrations/*" = ["S608"]     # raw SQL in Migrations erlaubt

[tool.black]
line-length = 100
target-version = ["py311"]
```

**Iteration im Implement-Skill:** `/implement` Schritt 6a iteriert deklarativ auch ueber Ruff-Findings bis 0 Errors (gleiche 5-Iterations-Heuristik wie ESLint).

---

## .semgrep.yml (alle Stacks)

**SAST-Default-Set seit BOO-3 (2026-05-06):** Drei-Layer-Aufbau — Layer 1 ist universelle Pflicht (security-audit, secrets), Layer 2 ist sprach-spezifisch (auto-erkannt aus `package.json` / `pyproject.toml`), Layer 3 ist optional fuer Web-Projekte (`p/owasp-top-ten`, manuell einkommentieren). Alle Pakete vom Semgrep Registry, MIT-Lizenz, lokal lauffaehig.

> [!important] Manifest-File, kein Semgrep-Native-Config
> `.semgrep.yml` ist hier ein **Manifest-File** — Semgrep's nativer `include`-Key ist eigentlich fuer File-Patterns, nicht fuer Pack-Namen. Pack-Loading laeuft ausschliesslich ueber `--config p/...`-Flags der CLI. Das Manifest wird in BOO-4 vom Pre-Commit-Hook gelesen, der die `include:`-Liste in entsprechende `--config`-Flags umsetzt. `--validate` laeuft durch (das File ist YAML-konform), ein direkter `--config=.semgrep.yml`-Lauf liefert "No config given" — das ist erwartet. Bis BOO-4 done ist, laufen die Packs manuell via z.B. `semgrep --config p/security-audit --config p/secrets`.

**Voraussetzung:** Semgrep CLI installiert (`brew install semgrep` oder `pip install semgrep`).

```yaml
# .semgrep.yml — SAST-Default fuer Governance v2 (BOO-3, v3.2.3)
# Konsumiert von Pre-Commit-Hook (BOO-4) und CI (kuenftig).
rules: []
include:
  # Layer 1 — Pflicht (alle Stacks)
  - p/security-audit
  - p/secrets

  # Layer 2 — Sprach-spezifisch (auto-erkannt aus package.json / pyproject.toml)
  # - p/javascript        # bei Node-/Frontend-Projekten
  # - p/python            # bei Python-Projekten

  # Layer 3 — Optional fuer Web-Projekte (manuell einkommentieren)
  # - p/owasp-top-ten     # bei Web-Frontend, REST-APIs, GraphQL
```

**Sprach-Auto-Erkennung im Auto-Setup:** `migrate_boo_3()` aktiviert `p/javascript` automatisch wenn `package.json` im Repo-Root liegt, `p/python` wenn `pyproject.toml` liegt. Layer 3 bleibt immer kommentiert — Operator entscheidet bewusst pro Projekt.

**Iteration im Implement-Skill:** Geplant in BOO-4 — `/implement` ergaenzt Schritt 6 um einen Semgrep-Pass nach dem ESLint-Pass (gleiche 5-Iterations-Heuristik). Bis BOO-4 done ist, laeuft Semgrep nur als manueller Befehl `semgrep --config=.semgrep.yml`.

---

## .semgrep/custom-rules.yml (BOO-185 — Custom-Rule-Wiring + Canary)

**Custom-Rule-Verdrahtung seit BOO-185 (2026-06-11):** Das Verzeichnis `.semgrep/` haelt projekt-eigene Semgrep-Regeln, die **zusaetzlich** zu den Registry-Packs aus `.semgrep.yml` geladen werden. CI (Layer 3) und Pre-Commit (Layer 2) verdrahten das Verzeichnis via `--config .semgrep/`, sobald es existiert. Damit ist die Custom-Rule-Schicht von Anfang an aktiv — nicht nominell vorhanden, aber blind.

> [!important] Lehre aus dem Semgrep-Vorfall — nominell konfiguriert heisst nicht aktiv
> Ein Custom-Rule-Verzeichnis, das zwar existiert, aber nie via `--config` an die CLI uebergeben wird, ist **faktisch blind** — die Regeln laufen schlicht nie. Genau das war der Befund hinter ADR „Semgrep Custom-Rule-Wiring — Verifikations-Pattern fuer Quality Gates" (2026-06-11). Die Custom-Rule unten ist ein **Wiring-Canary**: Sie trifft ausschliesslich den literalen Tripwire `QGAUDIT-CANARY-TRIPWIRE` in `.semgrep/test-fixtures/wiring-canary.py`. Die Registry-Packs (`p/security-audit`, `p/secrets`, …) wuerden diesen Literal **nicht** melden — feuert die Regel beim gezielten Audit-Scan, ist `--config .semgrep/` beweisbar aktiv. Der `quality-gate-audit`-Skill (BOO-183) nutzt diesen Canary als Wiring-Beweis.

```yaml
# .semgrep/custom-rules.yml — projekt-eigene Semgrep-Regeln (BOO-185)
# DE: Wird via `--config .semgrep/` zusätzlich zu den Registry-Packs geladen.
# EN: Loaded via `--config .semgrep/` in addition to the registry packs.
rules:
  - id: qgaudit-wiring-canary
    languages: [python]
    severity: ERROR
    message: >
      QGAUDIT wiring canary fired — custom Semgrep rules are wired. Expected ONLY in
      .semgrep/test-fixtures/wiring-canary.py. If this fires elsewhere, remove the tripwire literal.
    patterns:
      - pattern: $X = "QGAUDIT-CANARY-TRIPWIRE"
```

**Warum eine echte Regel und kein Kommentar:** Nur eine ausfuehrbare Custom-Rule beweist, dass `--config .semgrep/` greift. Wuerde der Tripwire von den Registry-Packs gemeldet, waere der Beweis wertlos — er wird es nicht, also ist ein Treffer ein eindeutiges Signal fuer die lebende Verdrahtung. Eigene Projekt-Regeln werden hier neben dem Canary ergaenzt.

---

## .semgrep/test-fixtures/wiring-canary.py (BOO-185 — Verifikations-Canary)

**Verifikations-Tripwire seit BOO-185 (2026-06-11):** Diese Fixture-Datei traegt den literalen Tripwire, auf den die Custom-Rule `qgaudit-wiring-canary` matcht. Solange ein **gezielter** Audit-Scan (`semgrep --config .semgrep/ .semgrep/test-fixtures/wiring-canary.py`) den Canary meldet, gilt die Custom-Rule-Schicht als **verdrahtet**; meldet er nichts, ist sie **blind** — und der `quality-gate-audit`-Skill schlaegt Alarm.

> [!important] Canary nicht dauerhaft rot — via `.semgrepignore` aus dem Repo-weiten Scan ausgenommen
> Der Tripwire ist eine `ERROR`-Severity-Regel. Liefe er im normalen CI-/Pre-Commit-Scan mit, waere die CI neuer Projekte **dauerrot**. Deshalb ist `.semgrep/test-fixtures/` im `.semgrepignore`-Template ausgeschlossen (naechster Block) — der Canary wird **nur** vom gezielten Audit-Scan des `quality-gate-audit`-Skills (BOO-183) erfasst, nie vom Repo-weiten Scan.

```python
# QGAUDIT-CANARY-DO-NOT-REMOVE
# DE: Beweist, dass das Custom-Rule-Verzeichnis .semgrep/ in CI verdrahtet ist.
# EN: Proves the custom-rule directory .semgrep/ is wired into CI.
# Der quality-gate-audit-Skill scannt diese Datei gezielt mit `--config .semgrep/`
# und erwartet, dass die Regel `qgaudit-wiring-canary` feuert. NICHT löschen.
tripwire = "QGAUDIT-CANARY-TRIPWIRE"
```

**Lifecycle:** Die Datei ist bewusst minimal und darf nicht geloescht werden — sie ist der einzige beabsichtigte Treffer der Canary-Regel. Verschwindet der Tripwire, verliert der Audit seinen Beweis, dass die Verdrahtung lebt.

---

## .semgrepignore (alle Stacks)

```
# .semgrepignore — Default-Excludes fuer Governance v2 (BOO-3)
node_modules/
dist/
build/
journal/reports/
.venv/
__pycache__/
.semgrep/test-fixtures/
```

**Begruendung:** `node_modules/` und `.venv/` sind Dependencies (nicht eigener Code), `dist/` und `build/` sind Build-Artefakte (haben eigene Lint-Stage). `journal/reports/` ist vom Self-Healing-Loop generiert (kein Source-Code). `__pycache__/` ist Python-Bytecode-Cache. `.semgrep/test-fixtures/` enthaelt den Wiring-Canary (BOO-185) — eine `ERROR`-Regel, die nur fuer den gezielten Audit-Scan des `quality-gate-audit`-Skills feuern soll, nie fuer den Repo-weiten Scan (sonst dauerrot).

---

## .git/hooks/pre-commit (BOO-4 — Quality-Gate Layer 2)

**Lokal blockierender Pre-Commit-Hook seit BOO-4 (2026-05-06):** Zweite Stufe der Drei-Layer-Quality-Gate-Architektur (ADR vom 2026-04-27). Layer 2 ist der lokale Hook, Layer 3 ist die GitHub Action (`semgrep.yml`, naechster Block). Identische Manifest-Reader-Logik in beiden Layern — `.semgrep.yml` ist die Single Source of Truth fuer aktive Packs.

> [!important] Manifest-Reader, kein Native-Config-Lauf
> Der Hook liest `.semgrep.yml` (Manifest aus BOO-3) zeilenweise mit `grep` + `sed`, extrahiert die aktiven Pack-Namen (Zeilen, die mit `- p/` beginnen — auskommentierte Zeilen mit `# - p/` werden ignoriert) und konstruiert daraus `--config p/...`-Flags. KEIN `yq`, kein YAML-Parser — bewusst nur Bash-Bordmittel, damit der Hook ohne Zusatz-Dependencies laeuft. Wer den Hook via `--no-verify` umgeht, wird im CI-Layer 3 (siehe naechster Block) gefangen.

**Voraussetzung:** Semgrep CLI installiert (`brew install semgrep` auf Mac, `pip install semgrep` auf Linux/VPS). Mac-Operatoren installieren manuell, VPS-Operatoren bekommen Auto-Install in BOO-44.

**Husky-Alternative:** Bei reinen Node-Projekten kann statt `.git/hooks/pre-commit` auch `.husky/pre-commit` verwendet werden — Inhalt identisch. Default ist Native-Hook, weil sprachneutral.

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit — Quality-Gate-Architektur Layer 2 (lokal, blockierend)
# DE: Konsumiert eslint.config.mjs (BOO-2) und .semgrep.yml (BOO-3 Manifest).
# EN: Consumes eslint.config.mjs (BOO-2) and .semgrep.yml (BOO-3 manifest).
set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"

# --- ESLint-Gate (BOO-2) ---
if [[ -f "eslint.config.mjs" ]]; then
    CHANGED_JS=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(js|mjs|jsx|ts|tsx)$' || true)
    if [[ -n "$CHANGED_JS" ]]; then
        echo "[PRE-COMMIT] ESLint auf $(echo "$CHANGED_JS" | wc -l | tr -d ' ') Datei(en)"
        echo "$CHANGED_JS" | xargs npx eslint --max-warnings=0 || {
            echo "[PRE-COMMIT] ESLint-Gate BLOCKIERT. Findings beheben oder bewusste Ausnahme dokumentieren."
            exit 1
        }
    fi
fi

# --- Semgrep-Gate (BOO-4, Manifest-Reader-Logik) ---
if [[ -f ".semgrep.yml" ]]; then
    # Manifest-Reader: extrahiert aktive Pack-Namen (Layer 1 Pflicht + Layer 2/3 wenn nicht auskommentiert)
    PACKS=$(grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml | sed -E 's/^[[:space:]]*-[[:space:]]+//' || true)
    if [[ -n "$PACKS" ]]; then
        ARGS=""
        for pack in $PACKS; do
            ARGS="$ARGS --config $pack"
        done
        # BOO-185: Custom-Rule-Verzeichnis zusätzlich verdrahten
        if [[ -d ".semgrep" ]]; then
            ARGS="$ARGS --config .semgrep/"
        fi
        echo "[PRE-COMMIT] Semgrep mit Packs: $(echo "$PACKS" | tr '\n' ' ')"
        if ! command -v semgrep >/dev/null 2>&1; then
            echo "[PRE-COMMIT] Semgrep CLI nicht installiert — 'brew install semgrep' (Mac) oder 'pip install semgrep' (Linux)"
            exit 1
        fi
        # shellcheck disable=SC2086
        if ! semgrep $ARGS --error --quiet 2>&1; then
            echo "[PRE-COMMIT] Semgrep-Gate BLOCKIERT. High/Critical Findings beheben."
            exit 1
        fi
    else
        echo "[PRE-COMMIT] .semgrep.yml hat keine aktiven Packs — Gate uebersprungen"
    fi
fi

exit 0
```

**Two-Layer-Logik:** Wer `--no-verify` umgeht, wird im CI-Layer 3 (`.github/workflows/semgrep.yml`) gefangen. Beide Layer lesen dasselbe Manifest — Drift unmoeglich.

**Klon-Portabilitaet (BOO-152):** `.git/hooks/` wird von `git clone` **nicht** uebernommen. Damit jedes frische Klon das Pre-Commit-Gate bekommt, legt der Bootstrap den Hook **zusaetzlich versioniert** unter `.githooks/pre-commit` ab (gleicher Inhalt) und `scripts/install-hooks.sh` aktiviert ihn per `core.hooksPath`. Ein neues Teammitglied ruft nach `git clone` nur `bash scripts/install-hooks.sh` auf.

---

## scripts/install-hooks.sh (BOO-152 — Git-Hooks pro Klon aktivieren)

> `.git/hooks/` wird von `git clone` nicht uebernommen. Dieses Script aktiviert die **versionierten** Hooks aus `.githooks/` per `core.hooksPath` — idempotent, ein Befehl pro Klon.

```bash
#!/usr/bin/env bash
# scripts/install-hooks.sh — aktiviert die versionierten Git-Hooks fuer diesen Klon (BOO-152)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

if [ -d .githooks ]; then
  git config core.hooksPath .githooks
  chmod +x .githooks/* 2>/dev/null || true
  echo "OK — core.hooksPath=.githooks gesetzt. Pre-Commit-Gate aktiv."
else
  echo "WARN — .githooks/ fehlt. Hooks via '/bootstrap' (Merge-Modus) oder 'migrate-to-v2.sh' nachziehen." >&2
  exit 1
fi
```

> Die Claude-Code-Runtime-Hooks (`spec-gate`, `doc-version-sync`, `pre-edit-bodyguard`) kommen bereits committet mit `.claude/` + `settings.json` (Pfade via `$CLAUDE_PROJECT_DIR`) — sie brauchen `install-hooks.sh` **nicht**. Nur der native Git-`pre-commit` (Quality-Gate Layer 2) wird so aktiviert.

---

## .github/workflows/semgrep.yml (BOO-4 — Quality-Gate Layer 3)

**CI-Layer seit BOO-4 (2026-05-06):** Dritte Stufe der Drei-Layer-Quality-Gate-Architektur. Spiegel zum Pre-Commit-Hook — identische Manifest-Reader-Logik, identische Pack-Auswahl. Blockiert Merge via Branch-Protection (siehe BOO-29 — Required Status Check `Semgrep`).

**SARIF-Output:** Die GitHub Action schreibt das Ergebnis als SARIF nach `.ci-reports/semgrep.sarif` und uploaded es zusaetzlich als CodeQL-Sarif (GitHub Security-Tab) und als Artefakt (Hermes-Konsumtion in BOO-32).

**Husky-Hinweis:** Husky betrifft nur den Pre-Commit-Layer 2 — die GitHub Action ist davon unabhaengig.

```yaml
# .github/workflows/semgrep.yml — Quality-Gate Layer 3 (CI, blockiert Merge)
# DE: Liest dasselbe .semgrep.yml-Manifest wie der Pre-Commit-Hook.
# EN: Reads the same .semgrep.yml manifest as the pre-commit hook.
name: Semgrep
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  security-events: write

jobs:
  semgrep:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Semgrep
        run: pip install semgrep

      - name: Read manifest and run Semgrep
        run: |
          mkdir -p .ci-reports
          ARGS=""
          while IFS= read -r line; do
              pack=$(echo "$line" | sed -E 's/^[[:space:]]*-[[:space:]]+//')
              ARGS="$ARGS --config $pack"
          done < <(grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml)
          if [[ -z "$ARGS" ]]; then
              echo "::error::No active packs in .semgrep.yml"
              exit 1
          fi
          # BOO-185: Custom-Rule-Verzeichnis zusätzlich verdrahten (Registry-Packs + projekt-eigene Rules)
          if [[ -d .semgrep ]]; then
              ARGS="$ARGS --config .semgrep/"
          fi
          # shellcheck disable=SC2086
          semgrep $ARGS --error --sarif --output=.ci-reports/semgrep.sarif

      - uses: github/codeql-action/upload-sarif@v4
        with:
          sarif_file: .ci-reports/semgrep.sarif
        if: always() && hashFiles('.ci-reports/semgrep.sarif') != ''

      - uses: actions/upload-artifact@v4
        with:
          name: semgrep-report
          path: .ci-reports/semgrep.sarif
```

**Zwei Quellen, eine Action (BOO-185):** Die Action laedt beide Quellen — die Registry-Packs aus dem `.semgrep.yml`-Manifest **und** die projekt-eigenen Custom-Rules aus `.semgrep/` (via `--config .semgrep/`, sobald das Verzeichnis existiert). Damit ist die Custom-Rule-Schicht aktiv verdrahtet statt nur nominell vorhanden. Das Canary-Fixture `.semgrep/test-fixtures/` bleibt via `.semgrepignore` aus dem Repo-weiten Scan ausgenommen — es wird nur vom gezielten Audit-Scan erfasst (sonst dauerrot).

**Two-Layer-Logik:** Beide Layer lesen `.semgrep.yml` und verdrahten `.semgrep/`. Wenn der Operator den Hook via `--no-verify` umgeht, blockiert spaetestens diese Action den Merge. Wenn die Action gestrippt wird, blockiert der Hook den Commit lokal. Belt-and-Suspenders.

---

## .github/workflows/eslint.yml (BOO-28 — ESLint CI Gate)

**CI-Layer seit BOO-28 (2026-05-12):** Dritter Layer der Quality-Gate-Architektur fuer Linting (Pendant zur Semgrep-Action, anderer Tool-Klasse). Wird in Phase 4.4 des Bootstrap-Flows fuer Stacks `a) Node.js Backend`, `b) Frontend` und `c) Full-Stack` angelegt. Pendant fuer Python ist `ruff.yml` (naechster Block).

**SARIF-Output (Pflicht):** Die Action schreibt das Ergebnis als SARIF nach `.ci-reports/eslint.sarif` und uploaded es via `github/codeql-action/upload-sarif@v4` in den GitHub-Security-Tab. SARIF-Output ist Pflicht — wird in BOO-32 (CI-Output-Standardisierung) fuer Hermes-Konsumtion gelesen.

**SARIF-Formatter:** `@microsoft/eslint-formatter-sarif` muss als devDependency installiert sein — `npm install --save-dev @microsoft/eslint-formatter-sarif`. Wird vom `npm ci`-Step im Workflow automatisch installiert, sobald die devDependency in `package.json` vorhanden ist.

**Branch-Protection:** Required Status Check `eslint` wird in BOO-29 aktiviert — ohne gruene Action kein Merge in `main`.

```yaml
name: ESLint
on: [push, pull_request]

permissions:
  contents: read
  security-events: write

jobs:
  eslint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npx eslint . --format=@microsoft/eslint-formatter-sarif --output-file=.ci-reports/eslint.sarif
      - uses: github/codeql-action/upload-sarif@v4
        with: { sarif_file: .ci-reports/eslint.sarif }
        if: always() && hashFiles('.ci-reports/eslint.sarif') != ''
```

**Two-Layer-Logik:** Pre-Commit-Hook (Layer 2, Phase 4.6) blockiert lokal via `npx eslint --max-warnings=0`, diese Action (Layer 3) blockiert CI. Wer den Hook via `--no-verify` umgeht, wird in Layer 3 gefangen.

---

## .github/workflows/ruff.yml (BOO-28 — Ruff CI Gate)

**CI-Layer seit BOO-28 (2026-05-12):** Python-Pendant zur ESLint-Action (vorheriger Block). Wird in Phase 4.4 des Bootstrap-Flows fuer Stack `d) Python` angelegt.

**SARIF-Output (Pflicht):** Ruff hat seit Version 0.5 nativen SARIF-Support via `--output-format=sarif`. Die Action schreibt nach `.ci-reports/ruff.sarif` und uploaded via `github/codeql-action/upload-sarif@v4`. Wird in BOO-32 fuer Hermes-Konsumtion gelesen.

**Branch-Protection:** Required Status Check `ruff` wird in BOO-29 aktiviert (analog `eslint` fuer Node-Projekte).

```yaml
name: Ruff
on: [push, pull_request]

permissions:
  contents: read
  security-events: write

jobs:
  ruff:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install ruff
      - run: |
          mkdir -p .ci-reports
          ruff check . --output-format=sarif --output-file=.ci-reports/ruff.sarif
      - uses: github/codeql-action/upload-sarif@v4
        with: { sarif_file: .ci-reports/ruff.sarif }
        if: always() && hashFiles('.ci-reports/ruff.sarif') != ''
```

**Two-Layer-Logik:** Analog zu ESLint — Pre-Commit-Hook (Layer 2) ruft `ruff check` lokal auf, diese Action (Layer 3) blockiert CI.

---

## hooks/dependency-check.sh (BOO-12 — Slopsquatting-Schutz)

**Drittes Gate im Pre-Commit-Hook seit BOO-12 (2026-05-06):** Eigenstaendiges Bash-Skript unter `.claude/hooks/dependency-check.sh`, vom Pre-Commit-Hook (BOO-4) als drittes Gate nach ESLint und Semgrep aufgerufen. Pruefung neu hinzugefuegter Dependencies in vier Stufen: Wordlist (Offline-Block gegen bekannte Slopsquatting-/Typosquatting-Pakete, BOO-197), Existenz (Halluzinations-Block), Age (Typosquatter-Warnung), CVE (Vulnerability-Block).

**Zwei Schichten seit BOO-197:** Die Wordlist-Stufe (`.claude/hooks/slopsquatting/wordlist.txt`, naechster Block) ist die **offline-faehige erste Schicht** — sie blockt bekannte malicious Pakete sofort per `grep`, ohne Registry-Roundtrip. Die Live-Registry-Query (Existenz/Age/CVE) bleibt unveraendert als **zweite Schicht** bestehen; die Wordlist ersetzt sie nicht, sondern faengt dokumentierte Slopsquatting-Treffer noch vor dem Netz-Call ab. Fehlt die Wordlist, wird die Stufe uebersprungen (kein Hard-Fail) — die Registry-Query greift weiter.

> [!important] Schrader Code Crash Kap. 3-4
> 19,7 % der KI-empfohlenen Pakete existieren nicht — Slopsquatting ist ein eigener Angriffsvektor. Angreifer registrieren typosquatted oder von KI halluzinierte Package-Namen mit Malware. ESLint und Semgrep pruefen Code, aber nicht die Supply Chain — dieser Hook schliesst diese Luecke vor dem Commit.

**Voraussetzungen:** `curl` ist Standard auf Mac/Linux (vorhanden). Optional: `npm` (Node-Projekte — fuer schnelleren Existenz-/Age-Lookup und CVE-Pruefung), `pip-audit` (Python — fuer CVE-Pruefung). Bei fehlendem Tool faellt das Skript auf einen curl-Fallback gegen die Registry-API zurueck. KEIN `yq`, KEIN `jq` — bewusst nur Bash-Bordmittel + `grep`/`sed`/`awk`.

**Performance:** Hook laeuft nur, wenn `package.json`, `requirements.txt`, `pyproject.toml` oder `Cargo.toml` im Diff der gestagten Files ist. Bei reinen Code-Commits sofort `exit 0` — kein Registry-Roundtrip.

**Cargo-Status:** Aktuell nur Erkennung mit Operator-Hinweis (`cargo audit` manuell). Cargo-Vollunterstuetzung folgt in zukuenftiger Iteration.

```bash
#!/usr/bin/env bash
# hooks/dependency-check.sh — Slopsquatting-Schutz (BOO-12, BOO-197)
# DE: Vier-Stufen-Check fuer neu hinzugefuegte Dependencies — Wordlist, Existenz, Age, CVE.
#     Schrader Code Crash Kap. 3-4: 19,7% der KI-empfohlenen Pakete existieren nicht.
# EN: Four-stage check for newly added dependencies — wordlist, existence, age, CVE.
#     Schrader Code Crash ch. 3-4: 19.7% of AI-recommended packages don't exist.
set -euo pipefail

# BOO-197: Offline-Wordlist als erste Schicht (zweite Schicht = Live-Registry-Query unten)
WORDLIST=".claude/hooks/slopsquatting/wordlist.txt"

# --- Trigger-Detection: laeuft nur wenn Manifest-Datei im Diff ---
CHANGED=$(git diff --cached --name-only --diff-filter=ACMR)
TRIGGERS_NPM=$(echo "$CHANGED" | grep -E '^package\.json$' || true)
TRIGGERS_PIP=$(echo "$CHANGED" | grep -E '^(requirements\.txt|pyproject\.toml)$' || true)
TRIGGERS_CARGO=$(echo "$CHANGED" | grep -E '^Cargo\.toml$' || true)

if [[ -z "$TRIGGERS_NPM" && -z "$TRIGGERS_PIP" && -z "$TRIGGERS_CARGO" ]]; then
    exit 0  # Kein Manifest-Diff — Hook ueberspringen
fi

AGE_THRESHOLD_DAYS=30
BLOCKED=0

# --- Helfer: extrahiert NEU hinzugefuegte Dependency-Namen aus package.json-Diff ---
extract_new_npm_deps() {
    # POSIX-konform (BSD-grep/sed-kompatibel): match nur "+"-Zeilen mit
    # "key": "version-wert" — Wert muss mit Versionsnummer beginnen
    # (optional ^, ~, >=, <= prefix). Filtert Top-Level-"version" raus.
    git diff --cached package.json 2>/dev/null \
        | grep -E '^\+[[:space:]]+"[^"]+":[[:space:]]*"[~^>=<]?[0-9]' \
        | sed -E 's/^\+[[:space:]]+"([^"]+)":.*/\1/' \
        | grep -vE '^(version)$' \
        || true
}

extract_new_pypi_deps() {
    # requirements.txt: extrahiert NEU hinzugefuegte Zeilen (Paket==version oder Paket>=version)
    if [[ -n "$TRIGGERS_PIP" ]] && echo "$TRIGGERS_PIP" | grep -q "requirements.txt"; then
        git diff --cached requirements.txt 2>/dev/null \
            | grep -E '^\+[a-zA-Z]' \
            | sed -E 's/^\+([a-zA-Z0-9_-]+).*/\1/' \
            || true
    fi
    # pyproject.toml: extrahiert dependencies/optional-dependencies
    if [[ -n "$TRIGGERS_PIP" ]] && echo "$TRIGGERS_PIP" | grep -q "pyproject.toml"; then
        git diff --cached pyproject.toml 2>/dev/null \
            | grep -E '^\+[[:space:]]+"[a-zA-Z]' \
            | sed -E 's/^\+[[:space:]]+"([a-zA-Z0-9_-]+).*/\1/' \
            || true
    fi
}

# --- Check 0: Wordlist (BOO-197 — offline-faehige erste Schicht) ---
# Prueft <ecosystem>:<name> gegen die statische Slopsquatting-Wordlist.
# Treffer = SOFORT BLOCK (return 1). Fehlt die Wordlist: ueberspringen (return 0).
check_wordlist() {
    local ecosystem="$1" pkg="$2"
    [[ -f "$WORDLIST" ]] || return 0  # keine Wordlist — Stufe ueberspringen, Registry-Query greift weiter
    # Exakt-Match auf "ecosystem:name", Kommentar-/Leerzeilen ignoriert.
    if grep -vE '^[[:space:]]*#' "$WORDLIST" 2>/dev/null \
        | grep -qiE "^[[:space:]]*${ecosystem}:${pkg}[[:space:]]*$"; then
        return 1  # in Wordlist — malicious/typosquatted
    fi
    return 0
}

# --- Check 1: Existenz ---
check_npm_existence() {
    local pkg="$1"
    if command -v npm >/dev/null 2>&1; then
        if npm view "$pkg" name >/dev/null 2>&1; then
            return 0  # existiert
        else
            return 1  # 404
        fi
    else
        # curl-Fallback
        if curl -fsSL --max-time 5 "https://registry.npmjs.org/$pkg" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    fi
}

check_pypi_existence() {
    local pkg="$1"
    if curl -fsSL --max-time 5 "https://pypi.org/pypi/$pkg/json" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# --- Check 2: Age ---
check_npm_age() {
    local pkg="$1"
    local created
    if command -v npm >/dev/null 2>&1; then
        created=$(npm view "$pkg" time.created 2>/dev/null || echo "")
    else
        created=$(curl -fsSL --max-time 5 "https://registry.npmjs.org/$pkg" 2>/dev/null \
            | grep -oE '"created":"[^"]+"' | head -1 | sed -E 's/"created":"([^"]+)"/\1/' || echo "")
    fi
    [[ -z "$created" ]] && return 0  # kein Datum — kein Warn
    local pkg_epoch
    pkg_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${created%.*}" +"%s" 2>/dev/null || \
                date -d "$created" +"%s" 2>/dev/null || echo "0")
    [[ "$pkg_epoch" == "0" ]] && return 0
    local now_epoch days
    now_epoch=$(date +"%s")
    days=$(( (now_epoch - pkg_epoch) / 86400 ))
    if (( days < AGE_THRESHOLD_DAYS )); then
        echo "[DEP-CHECK] WARNUNG: Paket '$pkg' ist nur $days Tage alt — Typosquatter-Risiko, manuell verifizieren"
    fi
    return 0
}

# --- Check 3: CVE ---
check_npm_cve() {
    if command -v npm >/dev/null 2>&1 && [[ -f "package-lock.json" ]]; then
        local audit_output
        audit_output=$(npm audit --audit-level=high 2>&1 || true)
        if echo "$audit_output" | grep -qE 'high|critical'; then
            echo "[DEP-CHECK] BLOCK: npm audit meldet High/Critical Vulnerabilities. Lauf 'npm audit' fuer Details."
            return 1
        fi
    fi
    return 0
}

check_pypi_cve() {
    if command -v pip-audit >/dev/null 2>&1; then
        local audit_output
        audit_output=$(pip-audit --strict 2>&1 || true)
        if echo "$audit_output" | grep -qiE 'vulnerability|cve'; then
            echo "[DEP-CHECK] BLOCK: pip-audit meldet Vulnerabilities. Lauf 'pip-audit' fuer Details."
            return 1
        fi
    fi
    return 0
}

# --- Hauptlauf ---
echo "[DEP-CHECK] Slopsquatting-Schutz aktiv"
if [[ -f "$WORDLIST" ]]; then
    echo "[DEP-CHECK] Wordlist-Schicht aktiv: $WORDLIST"
else
    echo "[DEP-CHECK] HINWEIS: Wordlist '$WORDLIST' fehlt — Stufe 0 uebersprungen, nur Live-Registry-Query"
fi

if [[ -n "$TRIGGERS_NPM" ]]; then
    NEW_NPM=$(extract_new_npm_deps)
    for pkg in $NEW_NPM; do
        if ! check_wordlist "npm" "$pkg"; then
            echo "[DEP-CHECK] Paket in Slopsquatting-Wordlist — BLOCK: npm-Paket '$pkg' steht in $WORDLIST"
            BLOCKED=1
            continue  # bekannt malicious — Registry-Checks eruebrigen sich
        fi
        if ! check_npm_existence "$pkg"; then
            echo "[DEP-CHECK] BLOCK: npm-Paket '$pkg' existiert nicht in der Registry — Halluzination?"
            BLOCKED=1
        else
            check_npm_age "$pkg"
        fi
    done
    check_npm_cve || BLOCKED=1
fi

if [[ -n "$TRIGGERS_PIP" ]]; then
    NEW_PYPI=$(extract_new_pypi_deps)
    for pkg in $NEW_PYPI; do
        if ! check_wordlist "pypi" "$pkg"; then
            echo "[DEP-CHECK] Paket in Slopsquatting-Wordlist — BLOCK: PyPI-Paket '$pkg' steht in $WORDLIST"
            BLOCKED=1
            continue
        fi
        if ! check_pypi_existence "$pkg"; then
            echo "[DEP-CHECK] BLOCK: PyPI-Paket '$pkg' existiert nicht — Halluzination?"
            BLOCKED=1
        fi
    done
    check_pypi_cve || BLOCKED=1
fi

if [[ -n "$TRIGGERS_CARGO" ]]; then
    echo "[DEP-CHECK] HINWEIS: Cargo-Diff erkannt — Cargo-Check wird in zukuenftiger Iteration ergaenzt. Operator: 'cargo audit' manuell laufen lassen."
fi

if (( BLOCKED == 1 )); then
    echo "[DEP-CHECK] Gate BLOCKIERT. Slopsquatting-Risiko vermeiden — Pakete verifizieren, dann erneut committen."
    exit 1
fi

echo "[DEP-CHECK] Gate bestanden"
exit 0
```

**Drei-Layer-Architektur erweitert:** Quality-Gate Layer 2 (`.git/hooks/pre-commit`) bekommt mit BOO-12 einen vierten Aufruf nach ESLint und Semgrep: `bash .claude/hooks/dependency-check.sh`. Layer 3 (CI) bleibt unveraendert — Slopsquatting-Schutz ist bewusst pre-commit-only, weil ein Halluzinations-Paket gar nicht erst in den Branch gelangen soll.

**Anti-Patterns:**
- KEIN Auto-Install von `pip-audit` oder `npm` — Operator-Verantwortung. Hook bleibt sprachneutral.
- KEINE Pflicht-Dependency wie `yq`/`jq` — Bash + `grep`/`sed`/`awk` + `curl` reichen. Die Wordlist-Stufe (BOO-197) liest `wordlist.txt` ausschliesslich per `grep` — kein YAML-/JSON-Parser.
- KEIN Block bei Cargo-Diff — nur Hinweis, weil Cargo-Vollunterstuetzung in spaeterer Iteration.
- KEIN Hard-Fail wenn die Wordlist fehlt — Stufe 0 wird uebersprungen, die Live-Registry-Query bleibt aktiv.

---

## .claude/hooks/slopsquatting/wordlist.txt (BOO-197 — Slopsquatting-Wordlist)

**Offline-Schicht seit BOO-197 (2026-06-14):** Statische Wordlist bekannter malicious/typosquatted Pakete unter `.claude/hooks/slopsquatting/wordlist.txt`. Sie ist die **erste, offline-faehige Schicht** des Slopsquatting-Schutzes — der `dependency-check.sh`-Hook (vorheriger Block) prueft jede neu hinzugefuegte Dependency per `grep` gegen diese Liste, bevor er die Live-Registry-Query (zweite Schicht) anstoesst. Ein Treffer blockt sofort, ohne Netz-Call. Die Wordlist **ersetzt** die Registry-Query nicht — sie faengt dokumentierte Slopsquatting-/Typosquatting-Namen frueh und auch offline ab.

> [!important] Schrader Code Crash Kap. 3-4
> Slopsquatting funktioniert nur, solange ein malicious Name unbemerkt durchrutscht. Eine projekt-lokale Wordlist bekannter Faelle ist die billigste Frueherkennung: ein `grep` statt eines Registry-Roundtrips, und sie greift auch ohne Netz (CI-Runner ohne egress, Offline-Commit). Die Live-Query bleibt fuer alles Unbekannte zustaendig.

**Format:** eine Zeile pro Paket, Schema `<ecosystem>:<package-name>` (`ecosystem` = `npm` | `pypi` | `cargo`). Kommentar- und Leerzeilen (`#`) werden ignoriert. Der Header traegt das Feld `# last_refreshed: YYYY-MM-DD`.

**90-Tage-Frische-Kriterium (Anker fuer `quality-gate-audit`, BOO-183):** Der `quality-gate-audit`-Skill prueft Existenz **und** Alter der Wordlist — `last_refreshed` (bzw. die Datei-Mtime) darf nicht aelter als 90 Tage sein. Eine ueberalterte Wordlist faellt im Audit auf, weil dann der woechentliche Refresh-Workflow (naechster Block) nicht mehr laeuft.

```text
# .claude/hooks/slopsquatting/wordlist.txt — bekannte Slopsquatting-/Typosquatting-Pakete (BOO-197)
# last_refreshed: 2026-06-14
# Format: <ecosystem>:<package-name>   (ecosystem = npm | pypi | cargo)
# Auto-gepflegt vom Workflow .github/workflows/slopsquatting-refresh.yml (woechentlich).
# Manuelle Eintraege/Ausnahmen: .claude/hooks/slopsquatting/slopsquatting-override.yaml
pypi:colourama
pypi:requasts
npm:noblox.js-proxy
```

**Seed-Inhalt:** Die drei Seed-Eintraege sind oeffentlich dokumentierte Faelle (Typosquats von `colorama`/`requests` bzw. der bekannte `noblox.js`-Typosquat). Die Liste startet bewusst klein — der woechentliche Refresh-Workflow (naechster Block) ergaenzt automatisch neue `malicious-package`-Eintraege aus oeffentlichen Advisory-Quellen.

---

## .github/workflows/slopsquatting-refresh.yml (BOO-197 — woechentlicher Wordlist-Refresh)

**Refresh-Workflow seit BOO-197 (2026-06-14):** GitHub-Actions-Workflow, der die Wordlist (`wordlist.txt`, vorheriger Block) woechentlich aktuell haelt. Er zieht bekannte malicious Pakete aus oeffentlichen Advisory-Quellen, dedupliziert sie, diffed gegen die aktuelle Wordlist, aktualisiert `last_refreshed` und oeffnet bei Aenderung einen PR mit Diff-Beschreibung. Der Diff wird **nie** direkt auf `main` committet — ein Mensch merged den PR.

**Quellen:** GitHub Advisory Database (GHSA, GraphQL — `malware`-Typ), OSV (osv.dev — `ecosystems`-Filter auf `MAL-`-IDs), OSSF Package-Analysis-Feed, npm Advisory-JSON. Alle Quellen werden auf `malicious-package`-Eintraege gefiltert. Wo eine API einen Token braucht, nutzt der Workflow `${{ secrets.GITHUB_TOKEN }}` (GHSA-GraphQL) — die uebrigen Quellen sind oeffentlich ohne Token.

**Override:** `.claude/hooks/slopsquatting/slopsquatting-override.yaml` haelt manuelle Eintraege fest, die der Refresh **nie entfernt** (`never_remove`) bzw. **nie hinzufuegt** (`never_add` — False-Positives, projekt-eigene Pakete mit aehnlichem Namen). Der Override wird nach dem Merge der Quellen angewandt. bash-only Parsing per `grep`/`sed` — kein `yq`.

> [!important] Token-Hinweis
> `${{ secrets.GITHUB_TOKEN }}` ist der eingebaute Action-Token (kein PAT noetig). Reicht ein Quell-Endpunkt nicht mit dem eingebauten Token, dokumentiert der Workflow das benoetigte Secret als Kommentar — **niemals echte Secrets im Template**.

```yaml
# .github/workflows/slopsquatting-refresh.yml — woechentlicher Wordlist-Refresh (BOO-197)
# DE: Zieht bekannte malicious Pakete, diffed gegen wordlist.txt, oeffnet bei Aenderung einen PR.
# EN: Pulls known malicious packages, diffs against wordlist.txt, opens a PR on change.
name: Slopsquatting Wordlist Refresh
on:
  schedule:
    - cron: '0 6 * * 1'   # Montag 06:00 UTC
  workflow_dispatch: {}

permissions:
  contents: write
  pull-requests: write

jobs:
  refresh:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Refresh wordlist from public advisory sources
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          set -euo pipefail
          WORDLIST=".claude/hooks/slopsquatting/wordlist.txt"
          OVERRIDE=".claude/hooks/slopsquatting/slopsquatting-override.yaml"
          mkdir -p "$(dirname "$WORDLIST")"
          TMP_NEW="$(mktemp)"

          # --- Quelle 1: GitHub Advisory DB (GHSA, GraphQL, type=MALWARE) ---
          # Benoetigt nur den eingebauten GITHUB_TOKEN.
          gh api graphql -f query='
            query { securityAdvisories(first: 100, classifications: [MALWARE]) {
              nodes { identifiers { value }
                vulnerabilities(first: 10) { nodes { package { ecosystem name } } } } } }' \
            --jq '.data.securityAdvisories.nodes[].vulnerabilities.nodes[]?
                  | "\(.package.ecosystem|ascii_downcase):\(.package.name)"' \
            2>/dev/null >> "$TMP_NEW" || echo "::warning::GHSA source unavailable"

          # --- Quelle 2: OSV (osv.dev, malicious-package IDs beginnen mit MAL-) ---
          for eco in npm PyPI crates.io; do
            curl -fsSL --max-time 20 "https://api.osv.dev/v1/query" \
              -d "{\"package\":{\"ecosystem\":\"$eco\"}}" 2>/dev/null \
              | grep -oE '"id":"MAL-[^"]+"' >/dev/null 2>&1 || true
          done
          # OSV-Vollabzug laeuft ueber den OSV-Bucket-Export (gs://osv-vulnerabilities),
          # hier bewusst nur als Platzhalter-Quelle — Operator erweitert pro Bedarf.

          # --- Quelle 3: OSSF Package-Analysis-Feed (oeffentlich, ohne Token) ---
          curl -fsSL --max-time 20 \
            "https://raw.githubusercontent.com/ossf/package-analysis/main/examples/feeds/malicious-packages.txt" \
            2>/dev/null >> "$TMP_NEW" || echo "::warning::OSSF feed unavailable"

          # --- Normalisieren: ecosystem:name, klein, dedupliziert ---
          NORM="$(mktemp)"
          grep -vE '^[[:space:]]*(#|$)' "$TMP_NEW" \
            | sed -E 's/[[:space:]]+//g' \
            | tr 'A-Z' 'a-z' \
            | sed -E 's/^pypi:/pypi:/; s/^crates.io:/cargo:/' \
            | grep -E '^(npm|pypi|cargo):[a-z0-9._@/-]+$' \
            | sort -u > "$NORM" || true

          # --- Override anwenden (bash-only, kein yq) ---
          # never_add: Zeilen aus dem Frischabzug entfernen.
          # never_remove: am Ende garantiert wieder hinzufuegen.
          if [[ -f "$OVERRIDE" ]]; then
            sed -n '/never_add:/,/never_remove:/p' "$OVERRIDE" \
              | grep -E '^[[:space:]]*-[[:space:]]' \
              | sed -E 's/^[[:space:]]*-[[:space:]]*//; s/[[:space:]]*$//' \
              | while read -r drop; do
                  [[ -n "$drop" ]] && sed -i "\#^${drop}\$#d" "$NORM"
                done
          fi

          # --- Bestehende (nicht-Kommentar) Eintraege mergen ---
          MERGED="$(mktemp)"
          { grep -vE '^[[:space:]]*(#|$)' "$WORDLIST" 2>/dev/null || true; cat "$NORM"; } \
            | sort -u >> "$MERGED"

          # never_remove garantiert behalten
          if [[ -f "$OVERRIDE" ]]; then
            sed -n '/never_remove:/,$p' "$OVERRIDE" \
              | grep -E '^[[:space:]]*-[[:space:]]' \
              | sed -E 's/^[[:space:]]*-[[:space:]]*//; s/[[:space:]]*$//' >> "$MERGED"
          fi
          MERGED_SORTED="$(mktemp)"; sort -u "$MERGED" > "$MERGED_SORTED"

          # --- Neue Wordlist mit aktualisiertem Header schreiben ---
          TODAY="$(date -u +%Y-%m-%d)"
          {
            echo "# .claude/hooks/slopsquatting/wordlist.txt — bekannte Slopsquatting-/Typosquatting-Pakete (BOO-197)"
            echo "# last_refreshed: ${TODAY}"
            echo "# Format: <ecosystem>:<package-name>   (ecosystem = npm | pypi | cargo)"
            echo "# Auto-gepflegt vom Workflow .github/workflows/slopsquatting-refresh.yml (woechentlich)."
            echo "# Manuelle Eintraege/Ausnahmen: .claude/hooks/slopsquatting/slopsquatting-override.yaml"
            cat "$MERGED_SORTED"
          } > "$WORDLIST"

      - name: Open PR on change
        uses: peter-evans/create-pull-request@v6
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          branch: chore/slopsquatting-wordlist-refresh
          commit-message: 'chore(security): Slopsquatting-Wordlist-Refresh (BOO-197)'
          title: 'chore(security): Slopsquatting-Wordlist-Refresh'
          body: |
            Automatischer woechentlicher Refresh der Slopsquatting-Wordlist (BOO-197).
            Quellen: GHSA (MALWARE), OSV (MAL-), OSSF Package-Analysis-Feed.
            Diff unten pruefen — Override-Regeln: .claude/hooks/slopsquatting/slopsquatting-override.yaml
          add-paths: |
            .claude/hooks/slopsquatting/wordlist.txt
```

**Override-Beispiel** (`.claude/hooks/slopsquatting/slopsquatting-override.yaml`):

```yaml
# slopsquatting-override.yaml — manuelle Steuerung des Wordlist-Refresh (BOO-197)
# never_add:    diese Namen NIE in die Wordlist aufnehmen (False-Positives, eigene Pakete).
# never_remove: diese Namen IMMER in der Wordlist behalten (manuell verifizierte Faelle).
never_add:
  - npm:my-internal-pkg
never_remove:
  - pypi:colourama
```

**Lauffaehigkeit & Grenzen:** Der Workflow ist im Aufbau lauffaehig — `peter-evans/create-pull-request@v6` oeffnet nur bei tatsaechlichem Diff einen PR (kein Leer-PR). Die OSV-Stufe ist als Platzhalter markiert: der vollstaendige `MAL-`-Abzug laeuft ueber den OSV-Bucket-Export; der Operator erweitert sie projektspezifisch. `${{ secrets.GITHUB_TOKEN }}` reicht fuer GHSA und PR-Erstellung — kein PAT noetig, keine echten Secrets im Template.

---

## hooks/coverage-check.sh (BOO-15 — Coverage-Gate >=80% fuer neuen Code)

**Viertes Gate seit BOO-15 (2026-05-06), aber NICHT im Pre-Commit-Hook:** Eigenstaendiges Bash-Skript unter `.claude/hooks/coverage-check.sh`, vom `/implement`-Skill in Schritt 6a-quart aufgerufen — nicht vom Pre-Commit-Hook, weil ein voller Test-Lauf das 10s-Budget des Hooks sprengen wuerde. Das Skript korreliert die NEU hinzugefuegten Zeilen aus `git diff --cached -U0` mit Coverage-Daten aus `coverage/coverage-final.json` (c8) bzw. `coverage.json` (pytest-cov) und entscheidet anhand drei Schwellwerten.

> [!important] Schrader Code Crash Kap. 3 §Production Readiness — Gate 2
> Testabdeckung >=80 % auf neuem Code, nicht Gesamt-Coverage. Gesamt-Coverage auf Legacy-Repos ist unfair: ein gut getestetes Feature kann durch grosse ungetestete Altlasten unter den Schwellwert rutschen. Diff-Coverage misst nur das, wofuer der aktuelle Commit verantwortlich ist.

**Voraussetzungen:** Test-Tooling lauffaehig — `npx c8 npm test` (Node) oder `pytest --cov` (Python) muss vor dem Hook gelaufen sein und JSON-Output erzeugt haben. `python3` wird fuer das JSON-Parsing verwendet (Standard auf Mac/Linux). KEIN `jq`, KEIN `yq`, KEINE npm/pip-Coverage-Dependency wie `@connectis/diff-test-coverage` oder `diff-cover` — Custom-Bash-Parser plus Python-Helfer fuer JSON.

**Drei Schwellwerte (env-overridable):**
- `COVERAGE_PASS=80` — Diff-Coverage >=80% bestanden, weiter zu 6b.
- `COVERAGE_WARN=60` — 60-80% Warnung, Operator-Freigabe mit Begruendung im Linear-Kommentar.
- `<60%` — Gate BLOCKIERT, Tests hinzufuegen oder Story splitten.
- Keine Test-Infra (kein JSON-Coverage-File): Gate uebersprungen mit Hinweis "/bootstrap nachziehen".

**Performance:** Skript-Lauf <2 Sekunden auch bei groesseren Diffs (serielle Per-File-Coverage-Lookups, gecached pro File). Test-Lauf selbst kann mehrere Minuten dauern — daher bewusst aus dem Pre-Commit-Hook ausgelagert.

**Konfigurierbar:** `COVERAGE_PASS=90 COVERAGE_WARN=70 bash .claude/hooks/coverage-check.sh` ueberschreibt die Defaults pro Lauf.

> **Skript-Inhalt: Single-Source seit BOO-89.** Der vollstaendige Skript-Body lebt kanonisch in
> `bootstrap/references/hooks/coverage-check.sh` (v2, inkl. BOO-88-Nenner-Fix). Bootstrap rendert ihn
> **verbatim aus dieser Datei**; die Migration (`migrate_boo_15`) kopiert sie — kein eingebetteter
> Heredoc mehr. **Hier NICHT inline pflegen** (sonst Drift). Konsistenz prueft `bootstrap/scripts/check-hook-sources.sh`.

**Anti-Patterns:**
- KEINE `@connectis/diff-test-coverage` als npm-Dependency — Custom-Bash-Parser bleibt sprachneutral.
- KEINE `diff-cover` als Python-Dependency — selber Grund.
- KEIN Aufruf im Pre-Commit-Hook (`.git/hooks/pre-commit`) — Tests dauern zu lange, sprengen das 10s-Budget. Wird ausschliesslich vom `/implement`-Skill in Schritt 6a-quart aufgerufen.
- KEIN Block bei nur-Test-/Config-/Doc-Diffs — Gate uebersprungen.

---

## hooks/anti-placeholder-check.py (BOO-177 — Anti-Platzhalter-Check fuer Test-Dateien)

**Fuenftes Gate seit BOO-177, im `/implement`-Skill in Schritt 6a-quint (nach Coverage), NICHT im Pre-Commit-Hook:** Ein gezielter, deterministischer Check **nur auf Test-Dateien** — er flaggt Tests, die die Coverage-Zahl heben, ohne etwas zu testen. Gleiches Grundproblem wie die Schwester-Story BOO-176 ("Agent gamed das Gate"), hier auf der Test-Ebene.

> [!important] Test-Qualitaet ≠ Test-Quantitaet
> Coverage (BOO-15) misst *wie viel* Code von Tests beruehrt wird. Triviale/leere Tests (`expect(true).toBe(true)`, `assert True`, leerer Koerper) und unbegruendete Skips heben diese Zahl, ohne eine Aussage zu pruefen. Der Anti-Platzhalter-Check schliesst genau diese Luecke — deterministisch, ohne Linter.

**KEIN Linter:** ESLint/Ruff/PHPStan pruefen Stil/Typen, nicht Test-Sinnhaftigkeit. Dies ist ein **eigener, gezielter Check** (Python-AST wie `raw-pii-guard.py` + JS/TS-Heuristik), kein "alle Linter".

**Erkennt Test-Dateien** an: `*.test.{js,ts,jsx,tsx,mjs,cjs}`, `*.spec.{js,ts,jsx,tsx,mjs,cjs}`, `test_*.py`, `*_test.py`, sowie alles unter `tests/**` / `__tests__/**` (Jest/Vitest- und pytest-Konventionen). Nicht-Test-Dateien werden ignoriert.

**Flaggt zwei Klassen:**
- **Triviale/leere Tests** — `expect(true).toBe(true|toEqual|toBeTruthy)`, `assert(true)`, `assert True`, `assert 1 == 1` / `assert x == x` (gleiche Konstante), leerer Testkoerper (nur `pass` / `...` / Docstring).
- **Unbegruendete Skips** — `it.skip`/`test.skip`/`describe.skip`/`xit`/`xdescribe`/`xtest`, `@pytest.mark.skip`/`@pytest.mark.skipif` **ohne** `reason=` (Python) bzw. ohne Begruendungskommentar in derselben oder der Vorgaengerzeile (JS/TS).

**Voraussetzungen:** Nur `python3`-Stdlib (`ast`, `re`) — KEIN `semgrep`, KEIN npm/pip-Dependency. Default = Warnung (Exit 0); `--strict` bzw. `STRICT=1` macht jeden Treffer zum Hard-Fail (Exit 1) — konsistent mit `raw-pii-guard.py` (BOO-93) und dem Layer-0-Bodyguard (BOO-86).

**Projekt-Allowlist** (optional) `.claude/anti-placeholder-check.local` — ein Glob pro Zeile, `#`-Kommentare; Praefix `path:` deklariert zusaetzliche Test-Pfade, sonst wird der Glob von der Pruefung **ausgenommen**.

> **Skript-Inhalt: Single-Source.** Der vollstaendige Skript-Body lebt kanonisch in
> `bootstrap/references/hooks/anti-placeholder-check.py`. Bootstrap/Migration (`migrate_boo_177`)
> **kopiert ihn verbatim** nach `.claude/hooks/anti-placeholder-check.py` — kein eingebetteter
> Heredoc. **Hier NICHT inline pflegen** (sonst Drift) — gleiche Konvention wie `coverage-check.sh`
> und `raw-pii-guard.py` (BOO-89).

**Anti-Patterns:**
- KEIN Linter und KEINE Linter-Regel — Test-Sinnhaftigkeit ist ein eigenes Thema.
- KEIN Aufruf im Pre-Commit-Hook — laeuft ausschliesslich im `/implement`-Skill (Schritt 6a-quint).
- KEIN Block bei Diffs ohne Test-Dateien — Gate uebersprungen.
- KEINE generischen Muster (z.B. jedes `expect`) — bewusst spezifisch, niedrige Fehlalarm-Quote.

**Selbsttest:** `python3 .claude/hooks/anti-placeholder-check.py --self-test` (muss `SELF-TEST OK` zeigen).

---

## hooks/ccusage-capture.sh (BOO-189 — Token-/Kosten-Snapshot)

**Capture-Hook seit BOO-189 — KEIN Quality-Gate, sondern eine Messung:** Eigenstaendiges Bash-Skript unter `.claude/hooks/ccusage-capture.sh`, das an Sprint-/Story-Grenzen einen Snapshot des Token-/Kosten-Verbrauchs an `docs/financials/sprint-costs.md` **anhaengt**. Es blockiert nichts und entscheidet nichts — es persistiert eine Ist-Messgroesse, damit der Token-Verbrauch eine belegte Zahl ist statt einer Vermutung. Datenquelle ist [`ccusage`](https://github.com/ryoppippi/ccusage) (MIT), das die lokalen Claude-Code-JSONL-Logs auswertet; Aufruf per `npx --yes ccusage@latest`.

> [!important] Schrader Code Crash — Token sind Budget
> Token-Verbrauch ist die reale Kostengroesse einer KI-gestuetzten Pipeline. „Wir glauben, das war guenstig" ist keine Zahl. Der Capture-Hook macht den Verbrauch pro Sprint/Story zu einer persistierten, nachpruefbaren Messung — die Grundlage fuer jede Budget- oder ROI-Aussage.

**Wann aufgerufen:** als **Abschluss-Schritt** von `/sprint-run`, `/implement` und `/sprint-review` (die Verdrahtung in diesen Skills ist eine eigene Story). Manuell: `bash .claude/hooks/ccusage-capture.sh "<label>"` — z.B. `"/sprint-run sprint-2"`. Das Label landet als Snapshot-Ueberschrift in der Datei.

**Bei Max-/Pro-Account** liefert ccusage den Token-Verbrauch als Schattenpreis (was die gleiche Nutzung per API gekostet haette); bei **API-Nutzung** echte Kosten in Projekt-Waehrung. Beides wird unveraendert als Textblock uebernommen.

> [!warning] Sub-Agent-Token werden evtl. nicht sauber attribuiert
> ccusage attribuiert Token von Sub-Agents (Task-Tool) derzeit nicht zuverlaessig dem ausloesenden Lauf zu — siehe ccusage-Issues #313, #806, #950. Snapshots aus Sub-Agent-lastigen Laeufen koennen den Verbrauch daher unter- oder fehlattribuieren. Die Zahl ist eine **Naeherung**, kein Cent-genauer Audit. (Ausfuehrliche Doku: HANDBUCH/README.)

**Voraussetzungen:** `npx` (Node) muss verfuegbar sein — `npx --yes ccusage@latest` zieht das Tool bei Bedarf transient. Kein globales Install noetig, keine Projekt-Dependency. Fehlt `npx`, schreibt der Hook einen Hinweis-Snapshot statt zu failen.

**bash-only, kein jq:** Der Hook parst **nichts**. Er nimmt die **Textausgabe** von `ccusage daily` und haengt sie verbatim in einem Code-Fence an die Markdown-Datei — bewusst kein `--json` + `jq`/`yq`. Begruendung wie bei den uebrigen Hooks: sprachneutral, dependency-frei, kein JSON-Parser im Bash-Hook. Was ccusage anzeigt, steht im Snapshot.

**Komplementaer zu `meta.json.token_tracking`** (implement/SKILL.md, BOO-84): Das `token_tracking`-Schema ist die **strukturierte Story-Schaetzung** pro Iteration/Skill-Aufruf, vom `/implement`-Lauf selbst befuellt (Pricing aus `bootstrap/references/model-tiers.json`). ccusage ist die **Ist-Messung aus den Session-Logs** — unabhaengig erhoben, ueber alle Laeufe einer Session hinweg. Die beiden ergaenzen sich: `meta.json` = was die Pipeline pro Story zu verbrauchen meint, `sprint-costs.md` = was ccusage in den Logs tatsaechlich gemessen hat.

```bash
#!/usr/bin/env bash
# .claude/hooks/ccusage-capture.sh — Token-/Kosten-Snapshot nach Sprint/Story (BOO-189)
# DE: Haengt einen ccusage-Snapshot an docs/financials/sprint-costs.md an.
# EN: Appends a ccusage snapshot to docs/financials/sprint-costs.md.
# Aufruf: bash .claude/hooks/ccusage-capture.sh "<label>"   z.B. "/sprint-run sprint-2"
# bash-only: ccusage-Textausgabe wird verbatim angehaengt — KEIN jq/yq, kein JSON-Parsing.
# Limitation: Sub-Agent-Token (Task-Tool) evtl. nicht sauber attribuiert — ccusage #313/#806/#950.
set -euo pipefail

LABEL="${1:-manual}"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT="$ROOT/docs/financials/sprint-costs.md"
mkdir -p "$(dirname "$OUT")"

# Datei mit Header anlegen, falls noch nicht vorhanden (idempotent).
if [[ ! -f "$OUT" ]]; then
  printf '# Sprint-Kosten — Token-Verbrauch (ccusage, BOO-189)\n\n> Persistierte Snapshots des Token-/Kosten-Verbrauchs. Sub-Agent-Token werden von ccusage evtl. nicht sauber attribuiert (Issues #313/#806/#950).\n' > "$OUT"
fi

TS="$(date -u +%Y-%m-%dT%H:%MZ)"

# ccusage-Textausgabe holen (kein --json, kein Parsing). Bei Fehler: Hinweis statt Hard-Fail.
if command -v npx >/dev/null 2>&1; then
  SNAP="$(npx --yes ccusage@latest daily --since "$(date -u +%Y%m%d)" 2>/dev/null || echo '(ccusage-Aufruf fehlgeschlagen)')"
else
  SNAP="(npx/ccusage nicht installiert — npm i -g ccusage oder npx ccusage@latest)"
fi

# Snapshot verbatim als Code-Fence anhaengen.
{
  printf '\n## %s — %s\n\n```\n%s\n```\n' "$TS" "$LABEL" "$SNAP"
} >> "$OUT"

echo "[ccusage] Snapshot angehaengt: $OUT ($LABEL)"
```

**Anti-Patterns:**
- KEIN `--json` + `jq`/`yq` — die Textausgabe wird verbatim angehaengt, bewusst kein Parser im Hook.
- KEINE globale ccusage-Installation als Projekt-Dependency erzwingen — `npx --yes ccusage@latest` zieht es transient.
- KEIN Hard-Fail, wenn `npx`/ccusage fehlt — Hinweis-Snapshot statt Abbruch, der Hook darf einen Lauf nie blockieren.
- KEINE Interpretation der Sub-Agent-Zahlen als exakt — Naeherung (ccusage #313/#806/#950).

---

## docs/financials/budget.md (BOO-190 — Projekt-Budget-Template)

**Template-Generator seit BOO-190 — kein Laufzeit-Rechner:** Schlankes Projekt-Budget fuer die Financials-/ROI-Sicht. Von `/bootstrap` (Financials-Frage) **einmalig generiert** und danach vom Operator gepflegt. Haelt nur die Projekt-Annahmen (Verrechnungssatz, Geo/Waehrung, optional Token-Kosten) und verweist auf die zwei Mess-/Referenz-Quellen daneben (`worker-equivalent-baseline.md`, `sprint-costs.md`).

> [!important] Schrader Code Crash — ROI braucht einen belegten Satz
> Aus der Story-Doppelspalte (`effort_ai_hours` / `effort_human_equiv_hours`, BOO-193) wird nur dann ein ROI-Faktor in Geld, wenn ein projektspezifischer Verrechnungssatz existiert. `budget.md` ist die eine Stelle, an der dieser Satz und seine Geo/Waehrung wohnen — alles andere (Ist-Kosten, Baseline) liegt referenziert daneben, nicht dupliziert.

**Generierung (byte-identisch zur SSoT):** Der Heredoc unten ist die kanonische Template-Quelle und **byte-identisch** zu `docs/financials/budget.md` im Framework-Repo. `migrate_boo_190()` in `migrate-to-v2.sh` legt die Datei daraus an, falls sie im Zielprojekt fehlt (idempotent).

**Worker-Equivalent-Baseline (`worker-equivalent-baseline.md`) gehoert dazu, ist aber kein zweites Voll-Heredoc:** Die Baseline ist **Framework-Referenzdatum** (Geo-Defaults aus der internen Deep-Research, vom `financials`-Skill dokumentiert) — keine pro-Projekt-Datentabelle. `migrate_boo_190()` legt dafuer nur einen **kurzen Pointer-Stub** an, der den aktiven Satz (Abschnitt 1) lokal haelt und fuer die Geo-Defaults auf die Skill-Referenz verweist. So vermeiden wir die Triplikat-Pflege einer ~60-Zeilen-Tabelle.

```markdown
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
```

**Anti-Patterns:**
- KEIN zweites Voll-Heredoc fuer `worker-equivalent-baseline.md` — die ~60-Zeilen-Geo-Tabelle ist Framework-Referenz (Skill `financials`), nicht pro-Projekt-Daten. Nur Pointer-Stub generieren.
- KEINE FX-Cross-Umrechnung — Satz bleibt nativ pro Geo (CH CHF / DE,AT EUR / US USD); bei Kurs-Drift >5 % nur Nutzerhinweis (Primaerquelle §2.3).
- KEIN Ueberschreiben einer vorhandenen `budget.md` — `migrate_boo_190()` legt nur an, wenn sie fehlt (idempotent, Operator-Pflege bleibt erhalten).

---

## .claude/statusline.sh (BOO-205 — Status-Line mit Worker-Equivalent)

> Native Claude-Code-Status-Line. **SSoT ist die reale Datei `bootstrap/templates/statusline.sh`** — hier bewusst KEIN Heredoc-Duplikat (Triplikat-Pflege vermeiden, vgl. `worker-equivalent-baseline.md`). `migrate_boo_205` installiert sie byte-identisch als `.claude/statusline.sh` und verdrahtet sie. Aktiv **nur** bei `runtime_target: claude-code` (Schalter A) — bei `codex`/`cross-tool`/`unknown` wird nichts verdrahtet.

Das Skript liest das von Claude Code auf stdin uebergebene JSON (`.model.display_name`, `.context_window.total_input_tokens`/`.context_window_size`, `.cost.total_cost_usd`, `.worktree.branch`) und reichert das **Worker-Equivalent** an (`effort_ai_hours` / `effort_human_equiv_hours` aus `specs/<story>.md`, BOO-193). Defensiv: jedes Feld optional, Exit immer 0. Ausgabe (eine Zeile):

```
Sonnet 4.7 | 142k/200k ctx | Worker-Equiv: 2.5h / 16h | Story BOO-205 | $4.20
```

Verdrahtung in `.claude/settings.json` (nativer Render-Pfad — Claude Code liest die Status-Line ausschliesslich hier, **nicht** aus `environment.json`):

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash .claude/statusline.sh",
    "padding": 0
  }
}
```

`migrate_boo_205` ergaenzt zusaetzlich eine Manifest-Referenz `"status_line": ".claude/statusline.sh"` in `.claude/environment.json` (AC#2 — das Framework-Manifest kennt das Skript; die Render-Verdrahtung bleibt `settings.json`). Volle Doku: HANDBUCH **Anhang AQ**.

---

## hooks/pre-edit-bodyguard.sh (BOO-86 — Layer-0 Edit-Bodyguard)

**Layer-0-Gate seit BOO-86:** Ein Claude-Code-**PreToolUse-Hook** auf `Edit|Write`, der
unsichere Muster (Secrets, `eval`, abgeschaltete TLS-Pruefung, SQL-Konkatenation) abfaengt,
**bevor** die KI sie auf die Platte schreibt — Geschwister-Hook zu `spec-gate.sh` (das auf
`Bash`/`git commit` feuert). Default ist **Warnung** (low-false-positive, keine
Alarm-Muedigkeit); Hard-Block per `BODYGUARD_STRICT=1`. Bewusst leichtgewichtig: eine kleine,
kuratierte Muster-Menge — KEIN voller Semgrep-Lauf pro Edit (Tiefe bleibt bei Layer 2/3).

**Scaffold (alle dependency-frei, nur bash + python3-Stdlib):**

| Datei | Zweck |
|-------|-------|
| `.claude/hooks/pre-edit-bodyguard.sh` | der Hook (liest stdin-JSON, matched Muster) |
| `.claude/hooks/bodyguard/patterns/_universal.yml` | Secrets, sprachunabhaengig |
| `.claude/hooks/bodyguard/patterns/gate-configs.yml` | Quality-Gate-Aufweichung (Regel-Deaktivierung / Schwellen-Edit), sprachunabhaengig — BOO-176 |
| `.claude/hooks/bodyguard/patterns/{python,javascript,java,c-cpp}.yml` | sprachspezifisch |
| `.claude/hooks/bodyguard/SOURCES.md` | Herkunft/Versionen/Pflege-Konvention |
| `.claude/bodyguard.local.yml` | **optionales** Projekt-Overlay (uebersteuert Basis per `name`) |

Muster-Schema (flacher YAML-Subset, vom Mini-Parser im Hook gelesen — kein PyYAML noetig):
`name` · `pattern` (Python-Regex) · `sprache` · `quelle` (CWE/OWASP/gitleaks/Semgrep — Pflicht, Audit-Beleg) · `action` (`block|warn`).

```bash
#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  PRE-EDIT-BODYGUARD — Layer-0 Governance Hook (BOO-86)
#  Faengt unsichere Muster ab, BEVOR die KI sie schreibt.
#
#  Claude Code PreToolUse Hook (Bash) — Matcher: Edit|Write
#  Input: JSON via stdin: {"tool_input": {"file_path": "...", "content"/"new_string": "..."}}
#  Exit 1 → Tool-Call blockiert | Exit 0 → erlaubt (Default: Warnung)
#  BODYGUARD_STRICT=1 → warn-Muster werden zu block (opt-in Hard-Block)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERN_DIR="${SCRIPT_DIR}/bodyguard/patterns"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
OVERLAY="${PROJECT_ROOT}/.claude/bodyguard.local.yml"
STRICT="${BODYGUARD_STRICT:-0}"

INPUT="$(cat)"

printf '%s' "$INPUT" | python3 -c "$(cat <<'PYEOF'
import sys, json, re, os
pattern_dir, overlay, strict = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
try:
    data = json.loads(sys.stdin.read())
except Exception:
    sys.exit(0)  # nicht parsebar → nicht blockieren
ti = data.get("tool_input", {}) or {}
file_path = ti.get("file_path", "") or ""
content = ti.get("content") or ti.get("new_string") or ""
if not content and isinstance(ti.get("edits"), list):
    content = "\n".join(e.get("new_string", "") for e in ti["edits"])
if not content:
    sys.exit(0)
ext = os.path.splitext(file_path)[1].lower()
lang_map = {".js":"javascript",".mjs":"javascript",".cjs":"javascript",".ts":"javascript",
            ".tsx":"javascript",".jsx":"javascript",".py":"python",".java":"java",
            ".c":"c-cpp",".h":"c-cpp",".cpp":"c-cpp",".cc":"c-cpp",".hpp":"c-cpp"}
lang = lang_map.get(ext)
def parse_patterns(path):
    out, cur = [], None
    if not os.path.isfile(path):
        return out
    for line in open(path, encoding="utf-8"):
        s = line.rstrip("\n")
        if not s.strip() or s.lstrip().startswith("#"):
            continue
        if s.lstrip().startswith("- "):
            if cur: out.append(cur)
            cur, s = {}, s.lstrip()[2:]
        if ":" in s and cur is not None:
            k, v = s.split(":", 1)
            cur[k.strip()] = v.strip().strip("'\"")
    if cur: out.append(cur)
    return out
files = [os.path.join(pattern_dir, "_universal.yml"),
         os.path.join(pattern_dir, "gate-configs.yml")]  # immer geladen (Quality-Gate-Schutz, BOO-176)
if lang: files.append(os.path.join(pattern_dir, lang + ".yml"))
files.append(overlay)  # Overlay zuletzt → uebersteuert per name
patterns, order = {}, []
for f in files:
    for p in parse_patterns(f):
        n = p.get("name")
        if not n or not p.get("pattern"): continue
        if n not in patterns: order.append(n)
        patterns[n] = p
blocks, warns = [], []
for n in order:
    p = patterns[n]
    try: rx = re.compile(p["pattern"])
    except re.error: continue
    if rx.search(content):
        action = (p.get("action") or "warn").lower()
        if strict and action == "warn": action = "block"
        msg = "  [%s] %s — %s" % (n, p.get("quelle","?"), file_path or "?")
        (blocks if action == "block" else warns).append(msg)
if warns:
    sys.stderr.write("[BODYGUARD] WARNUNG — unsichere Muster im neuen Code:\n" + "\n".join(warns) + "\n")
if blocks:
    sys.stderr.write("\n[BODYGUARD] BLOCKIERT — sicherheitskritische Muster:\n" + "\n".join(blocks) +
                     "\n  Bitte entfernen/ersetzen: Secret in env/Secret-Manager, parametrisierte Query, sichere API/TLS.\n")
    sys.exit(1)
sys.exit(0)
PYEOF
)" "$PATTERN_DIR" "$OVERLAY" "$STRICT"
```

**`bodyguard/patterns/_universal.yml`** (Secrets, sprachunabhaengig):

```yaml
# Bodyguard Layer-0 — universelle Muster (sprachunabhaengig)
# Schema: - name / pattern / sprache / quelle / action(block|warn)
- name: aws-access-key-id
  pattern: 'AKIA[0-9A-Z]{16}'
  sprache: alle
  quelle: 'gitleaks / CWE-798'
  action: block
- name: private-key-block
  pattern: '-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----'
  sprache: alle
  quelle: 'gitleaks / CWE-321'
  action: block
- name: slack-token
  pattern: 'xox[baprs]-[0-9A-Za-z-]{10,}'
  sprache: alle
  quelle: 'gitleaks / CWE-798'
  action: block
- name: github-token
  pattern: 'gh[pousr]_[0-9A-Za-z]{36,}'
  sprache: alle
  quelle: 'gitleaks / CWE-798'
  action: block
- name: generic-secret-assignment
  pattern: '(?i)(api[_-]?key|secret|token|passwd|password)\s*[:=]\s*[\x27"][^\x27"]{8,}[\x27"]'
  sprache: alle
  quelle: 'gitleaks / CWE-798'
  action: warn
```

**`bodyguard/patterns/python.yml`**:

```yaml
- name: python-subprocess-shell-true
  pattern: 'subprocess\.(run|call|Popen|check_output)\([^)]*shell\s*=\s*True'
  sprache: python
  quelle: 'CWE-78 / Bandit B602'
  action: block
- name: python-requests-verify-false
  pattern: 'verify\s*=\s*False'
  sprache: python
  quelle: 'CWE-295'
  action: block
- name: python-eval
  pattern: '\beval\s*\('
  sprache: python
  quelle: 'CWE-95 / Bandit B307'
  action: warn
- name: python-yaml-load-unsafe
  pattern: 'yaml\.load\s*\((?![^)]*SafeLoader)'
  sprache: python
  quelle: 'CWE-20 / Bandit B506'
  action: warn
- name: python-sql-fstring
  pattern: '(?i)(execute|executemany)\s*\(\s*f[\x27"]'
  sprache: python
  quelle: 'CWE-89'
  action: warn
```

**`bodyguard/patterns/javascript.yml`** (gilt auch fuer TypeScript):

```yaml
- name: js-tls-reject-unauthorized-false
  pattern: 'rejectUnauthorized\s*:\s*false'
  sprache: javascript
  quelle: 'CWE-295'
  action: block
- name: js-node-tls-env-0
  pattern: 'NODE_TLS_REJECT_UNAUTHORIZED\s*=\s*[\x27"]?0'
  sprache: javascript
  quelle: 'CWE-295'
  action: block
- name: js-eval
  pattern: '\beval\s*\('
  sprache: javascript
  quelle: 'CWE-95 / eslint no-eval'
  action: warn
- name: js-child-process-exec
  pattern: '(?i)child_process[\s\S]{0,20}\bexec\s*\('
  sprache: javascript
  quelle: 'CWE-78'
  action: warn
- name: js-sql-string-concat
  pattern: '(?i)(query|execute)\s*\(\s*[`\x27"][^`\x27"]*\+'
  sprache: javascript
  quelle: 'CWE-89'
  action: warn
```

**`bodyguard/patterns/java.yml`**:

```yaml
- name: java-runtime-exec
  pattern: 'Runtime\.getRuntime\(\)\.exec\s*\('
  sprache: java
  quelle: 'CWE-78'
  action: warn
- name: java-deserialize
  pattern: 'new\s+ObjectInputStream\s*\('
  sprache: java
  quelle: 'CWE-502'
  action: warn
- name: java-sql-concat
  pattern: '(?i)(createStatement|executeQuery)\s*\([^)]*\+'
  sprache: java
  quelle: 'CWE-89'
  action: warn
```

**`bodyguard/patterns/c-cpp.yml`**:

```yaml
- name: c-gets
  pattern: '\bgets\s*\('
  sprache: c-cpp
  quelle: 'CWE-242'
  action: block
- name: c-strcpy
  pattern: '\bstrcpy\s*\('
  sprache: c-cpp
  quelle: 'CWE-120'
  action: warn
- name: c-system
  pattern: '\bsystem\s*\('
  sprache: c-cpp
  quelle: 'CWE-78'
  action: warn
- name: c-sprintf
  pattern: '\bsprintf\s*\('
  sprache: c-cpp
  quelle: 'CWE-120'
  action: warn
```

**`bodyguard/patterns/gate-configs.yml`** (Quality-Gate-Aufweichung — sprachunabhaengig, immer geladen, BOO-176):

Diese Muster flaggen **verdaechtige Regel-Deaktivierung / Schwellen-Edits** im neuen Inhalt — der
Hook sieht nur den NEUEN Inhalt (kein Alt/Neu-Vergleich), also wird hier nicht „Senkung erkannt",
sondern „du editierst eine Quality-Schwelle / deaktivierst eine Regel — das ist eine
Operator-Entscheidung, kein Agent-Workaround". Den echten Alt→Neu-Schwellen-Vergleich macht die
Post-Story-Gate-Assertion (anderer Cluster), nicht dieser Hook.

```yaml
# Bodyguard Layer-0 — Quality-Gate-Aufweichung (sprachunabhaengig)
# Schema: - name / pattern / sprache / quelle / action(block|warn)
# Immer geladen (wie _universal.yml), weil Gate-Configs auf vielen Datei-Endungen leben.
- name: eslint-disable-file-wide
  pattern: '/\*\s*eslint-disable\s*\*/'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: ts-nocheck
  pattern: '@ts-nocheck'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: python-bare-noqa
  pattern: '#\s*noqa(?!\s*:)'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: python-bare-type-ignore
  pattern: '#\s*type:\s*ignore(?!\[)'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: pytest-mark-skip
  pattern: '@pytest\.mark\.skip\b'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: js-suite-skip
  pattern: '\b(describe|it|test|xit)\.skip\s*\(|\bxit\s*\('
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: phpstan-level-edit
  pattern: '(?m)^\s*level:\s*\d'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: coverage-threshold-edit
  pattern: '(?i)(fail_under|coverageThreshold|minimum_coverage)\s*[:=]'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
```

> **Hinweis:** Default ist `warn` — diese Muster sollen den Operator alarmieren, nicht hart blocken
> (false-positive-arm: ein legitimer `# noqa` ohne Code ist selten, aber moeglich). Wer Gate-Edits
> hart sperren will, faehrt den Hook mit `BODYGUARD_STRICT=1`. Den eigentlichen Review-Block bei
> Gate-Config-Dateien liefert zusaetzlich `.claude/sensitive-paths.json` (siehe dort, Gruppe
> „Gate-Config / Quality-Threshold").

**`bodyguard/SOURCES.md`** (Herkunft + Pflege-Konvention):

```markdown
# Bodyguard-Muster — Quellen & Pflege (BOO-86)

Die Muster sind **kuratiert aus anerkannten Katalogen**, nicht erfunden. Jedes Muster
traegt im `quelle`-Feld seinen Beleg.

| Quelle | Wofuer |
|--------|--------|
| CWE (Common Weakness Enumeration) | kanonische Schwachstellen-IDs pro Muster |
| OWASP (Top 10, ASVS, Cheat Sheets) | Priorisierung/Begruendung |
| gitleaks (open source) | Secret-Muster (`_universal.yml`) |
| Semgrep Registry / Bandit / eslint-plugin-security | sprachspezifische Unsafe-Code-Muster |
| BOO-176 (Quality-Gate-Integritaet) | Quality-Gate-Aufweichung (`gate-configs.yml`): Regel-Deaktivierung / Schwellen-Edit |

## Pflege-Konvention
- **Kuratiert + klein halten** — wenige Muster mit hoher Trefferquote. Lieber 30
  wasserdichte als 300 nervige (sonst Alarm-Muedigkeit → Hook wird abgeschaltet).
- **Basis** kommt mit Framework-Versionen (dieses Template). **Projekt-Overlay**
  `.claude/bodyguard.local.yml` ist kundeneigen und ueberlebt Updates.
- Optionales `sync-bodyguard-patterns.sh` gleicht gegen Upstream ab und **schlaegt** Muster
  **vor** — Mensch entscheidet, KEIN Auto-Merge (Supply-Chain-Schutz).
- Default-Schweregrad ist `warn`; `block` nur fuer eindeutige, kontextunabhaengige Treffer
  (Secrets, abgeschaltete TLS-Pruefung, `gets`). Die `gate-configs.yml`-Muster bleiben bewusst
  `warn` (Operator-Alarm bei Gate-Aufweichung), der harte Review-Block kommt aus `sensitive-paths.json`.
```

**`.claude/bodyguard.local.yml`** (optionales Projekt-Overlay — uebersteuert/ergaenzt die Basis):

```yaml
# Projekt-eigene Bodyguard-Muster — uebersteuert die Framework-Basis per `name`.
# Ueberlebt Framework-Updates. Gleiches Schema wie patterns/*.yml.
# Beispiel: internen Legacy-Endpoint verbieten
# - name: no-legacy-internal-api
#   pattern: 'https?://legacy-intern\.example\.local'
#   sprache: alle
#   quelle: 'projekt-policy'
#   action: block
```

**Anti-Patterns:**
- KEIN voller Semgrep-/SAST-Lauf im Hook — das ist Layer 2/3. Layer 0 ist ein schneller Reflex.
- KEINE Regex-Kommentar-/Statement-Erkennung mit Heuristik — nur direkte Muster-Treffer.
- KEIN Auto-Merge externer Muster in den aktiven Hook.
- KEIN Hard-Block als Default — `warn` ist Default, `BODYGUARD_STRICT=1` ist opt-in.

---

## .claude/environment.json (BOO-34 — Skill-Umgebungs-Awareness)

**Single Source of Truth fuer Umgebung, Tooling und Pfade seit BOO-34 (2026-05-06):** Ein Manifest pro Projekt, das jeder Skill in einem Schritt-0-Read auswertet, statt selbst Detection-Logik zu fahren. Drei Umgebungen (`mac` | `vps` | `ci`), eine Tool-Verfuegbarkeitsmatrix (eslint, semgrep, Test-Framework, SonarQube), Default-Pfade fuer Journal/Reports/Lessons/Specs.

> [!important] Warum eine Datei statt Detection pro Skill?
> Vor BOO-34 hat jeder Skill (implement, sprint-review, breakfix, ...) `uname` / `command -v` selbst aufgerufen — duplizierte Logik, inkonsistent gewartet. Mit `.claude/environment.json` fragt der Skill nur noch `cat .claude/environment.json | grep '"semgrep"'`. Generiert wird die Datei einmalig vom Bootstrap-Skill in Phase 4.4e und kann jederzeit per `--force` neu erzeugt werden, wenn sich die Umgebung aendert (z.B. Mac-Operator pusht erstmals auf VPS, Tooling neu installiert).

**Schema (Single Source of Truth fuer Felder und Werte):**

```json
{
  "environment": "mac",
  "tools_available": {
    "eslint": true,
    "semgrep": true,
    "tests": "vitest",
    "sonarqube_ide_plugin": false,
    "sonarqube_cloud": true
  },
  "paths": {
    "journal": "journal/",
    "reports_local": "journal/reports/local/",
    "reports_ci": "journal/reports/ci/",
    "lessons_l1": "journal/learnings.md",
    "lessons_l2_dir": "journal/",
    "lessons_l3": "journal/learnings.db",
    "specs": "specs/",
    "architecture_design": "ARCHITECTURE_DESIGN.md",
    "conventions": "CONVENTIONS.md",
    "intents": "intents/",
    "pitches": "pitch/"
  },
  "governance": {
    "mode": "standard",
    "execution_isolation": "write-scope",
    "worktree_required_for": ["agentic"],
    "write_scope_required_for": ["sub-agents"]
  },
  "thresholds": {
    "architecture_doc_freshness_days": 30,
    "token_warn_threshold": 70,
    "token_hard_threshold": 80
  },
  "metadata": {
    "created_at": "2026-05-06T14:30:00Z",
    "bootstrap_version": "3.3.0",
    "stack": "node-typescript"
  },
  "llm_proxy_url": null
}
```

**Felder:**

| Feld | Typ | Werte / Beschreibung |
|------|-----|---------------------|
| `environment` | string | `mac` (Darwin), `vps` (Linux ohne `$CI`), `ci` (env-var `CI` gesetzt — egal welcher Wert) |
| `tools_available.eslint` | bool | true wenn `command -v eslint` ODER lokal in `node_modules` (via `npm ls eslint`) |
| `tools_available.semgrep` | bool | true wenn `command -v semgrep` |
| `tools_available.tests` | string\|null | `"vitest"` / `"jest"` / `"mocha"` / `"pytest"` / `null` — erkannt aus `package.json` bzw. `pyproject.toml` |
| `tools_available.sonarqube_ide_plugin` | bool | Default `false`. CLI nicht erkennbar — Operator setzt manuell auf `true` wenn SonarLint VS-Code-Plugin aktiv. |
| `tools_available.sonarqube_cloud` | bool | Hardcoded `true` — Cloud-API ist von ueberall erreichbar. Zeigt nur "darf der Skill SonarCloud rufen?". Manuell auf `false` setzen wenn Projekt SonarCloud nicht nutzt. |
| `paths.*` | string | Default-Pfade relativ zum Projekt-Root. Skills lesen ueber diese Keys statt hardcoded Strings. |
| `governance.mode` | string | `lite` / `standard` / `heavy` — aus `CONVENTIONS.md`; steuert welche Gates als Pflicht gelten. |
| `governance.execution_isolation` | string | `none` / `write-scope` / `git-worktree` — aus `CONVENTIONS.md`; steuert ob parallele Agenten Worktrees oder disjunkte Write-Scopes brauchen. |
| `governance.worktree_required_for` | array | Execution-Modes, fuer die Git-Worktrees Pflicht sind. Default: `["agentic"]`. |
| `governance.write_scope_required_for` | array | Execution-Modes, fuer die mindestens disjunkte Write-Scopes Pflicht sind. Default: `["sub-agents"]`. |
| `thresholds.architecture_doc_freshness_days` | int | Default `30`. Maximales Alter (in Tagen) der `ARCHITECTURE_DESIGN.md`, bevor `/ideation` Schritt 0a einen weichen Pre-Flight-Reminder zeigt. Schnell evolvierende Systeme: 14. Stabile Systeme: 90. |
| `thresholds.token_warn_threshold` | int | Default `70`. Prozentwert des Context-Windows, ab dem `/implement` Schritt 0b einen weichen Hinweis zeigt ("noch eine kleine Story passt rein"). |
| `thresholds.token_hard_threshold` | int | Default `80`. Prozentwert ab dem `/implement` Schritt 0b Sprint-Ende empfiehlt (Sprint-Box-Grenze laut HANDBUCH Anhang G). Operator kann mit bewusster Entscheidung weiter — Vermerk landet in `meta.json.pre_flight_warning`. |
| `metadata.created_at` | string | ISO-8601 UTC, gesetzt beim ersten Generator-Lauf. |
| `metadata.bootstrap_version` | string | Aktive Bootstrap-Version zum Generator-Zeitpunkt. |
| `metadata.stack` | string | `node-typescript` / `node-javascript` / `python` / `mixed` / `unknown` — analog BOO-3-Stack-Detection. |
| `llm_proxy_url` | string\|null | **Optional (BOO-71).** Default `null` = direkter LLM-Call. Wenn gesetzt: HTTP(S)-Endpunkt eines Operator-seitigen Proxy-Servers (Anonymisierung, Logging, Souveraenitaets-Routing). Framework setzt das Routing NICHT um — Wert wird nur gelesen und in `meta.json.llm_routing` als Audit-Spur protokolliert. Details: HANDBUCH Anhang Q (Souveraenitaets-Stack + LLM-Proxy-Hook). |

**Reihenfolge der `environment`-Detection ist entscheidend:** CI-Check ZUERST, dann Mac, dann VPS — ein CI-Runner kann Linux **oder** Mac sein. Wuerde der Skill zuerst auf Darwin pruefen, wuerde ein Mac-CI-Job faelschlich als `mac` markiert.

**Konsumiert von:** Allen Sub-Skills via Schritt-0-Read (Rollout in BOO-34 Sub-Agent #2). Beispiel-Pattern fuer einen Skill:

```bash
# Schritt 0: Environment lesen
ENV_FILE=".claude/environment.json"
if [[ -f "$ENV_FILE" ]]; then
    HAS_SEMGREP=$(grep '"semgrep"' "$ENV_FILE" | grep -oE 'true|false')
    REPORTS_DIR=$(grep '"reports_local"' "$ENV_FILE" | sed -E 's/.*: "([^"]+)".*/\1/')
fi
```

**Anti-Patterns:**
- KEIN `jq` als Pflicht-Dependency — `grep` + `sed` reichen fuer die wenigen Reads, die ein Skill braucht. `jq` ist auf VPS/CI nicht garantiert, auf Mac muss `brew install jq` laufen. (Im HANDBUCH wird `jq` als optionaler Reader-Komfort erwaehnt.)
- KEIN Auto-Refresh bei Skill-Lauf — die Datei wird nur vom Bootstrap und manuellem `--force` geschrieben. Skills lesen ausschliesslich.
- KEIN Schreiben aus Sub-Skills heraus — Single Source of Truth bleibt der Generator. Sub-Agent #2 baut nur Reads ein.

---

## .claude/generate-environment-json.sh (BOO-34)

**Bash-Generator fuer das Environment-Manifest, BSD- und Linux-kompatibel.** Wird vom Bootstrap-Skill in Phase 4.4e aufgerufen, kann manuell mit `--force` neu erzeugt werden. Idempotent: schreibt nur, wenn die Datei fehlt oder `--force` gesetzt ist.

> [!important] Keine externen Dependencies
> Nur `bash`, `uname`, `command`, `cat`, `grep`, `sed`, `date` (POSIX-Standard) — explizit KEIN `jq`, KEIN `yq`, KEIN `python3`. JSON wird per Heredoc geschrieben. Damit laeuft der Generator auf jedem Mac-Operator-Geraet und jedem VPS/CI-Linux ohne Setup.

**BSD-Kompatibilitaet (PFLICHT):** `[[:space:]]+` statt `\s+`, `[[:digit:]]` statt `\d`, `grep -E` statt `grep -P`, `sed` ohne `-i` (wir schreiben Tempfile via Heredoc statt In-Place-Edit). Lauft auf macOS Darwin **und** Linux.

```bash
#!/usr/bin/env bash
# .claude/generate-environment-json.sh — Environment-Awareness-Generator (BOO-34)
# DE: Erzeugt .claude/environment.json mit Detection von Mac/VPS/CI, verfuegbaren
#     Tools (eslint, semgrep, Test-Framework) und Standard-Pfaden. BSD- und
#     Linux-kompatibel, ohne Abhaengigkeiten ausser bash, uname, command, cat,
#     grep, sed, date.
# EN: Generates .claude/environment.json with Mac/VPS/CI detection, available
#     tools (eslint, semgrep, test framework) and default paths. BSD- and
#     Linux-compatible, no deps beyond bash, uname, command, cat, grep, sed, date.
set -euo pipefail

# --- CLI-Flags ---
FORCE=0
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        --help|-h)
            cat <<'HLP'
Usage: bash .claude/generate-environment-json.sh [--force]
  --force   Overwrite existing .claude/environment.json
HLP
            exit 0 ;;
    esac
done

OUT=".claude/environment.json"
mkdir -p .claude

if [[ -f "$OUT" && $FORCE -eq 0 ]]; then
    echo "[ENV] $OUT existiert bereits — Skip (use --force to overwrite)."
    exit 0
fi

# --- environment: ci > mac > vps ---
# CI-Check ZUERST: ein CI-Runner kann Linux ODER Mac sein.
if [[ -n "${CI:-}" ]]; then
    ENVIRONMENT="ci"
elif [[ "$(uname -s)" = "Darwin" ]]; then
    ENVIRONMENT="mac"
else
    ENVIRONMENT="vps"
fi

# --- tools_available ---
# eslint: command -v ODER lokal in node_modules
HAS_ESLINT="false"
if command -v eslint >/dev/null 2>&1; then
    HAS_ESLINT="true"
elif [[ -f "package.json" ]] && command -v npm >/dev/null 2>&1; then
    if npm ls eslint --silent >/dev/null 2>&1; then
        HAS_ESLINT="true"
    fi
fi

# semgrep: nur via command -v (PATH)
HAS_SEMGREP="false"
if command -v semgrep >/dev/null 2>&1; then
    HAS_SEMGREP="true"
fi

# tests: erkennen aus package.json (vitest/jest/mocha) oder pyproject.toml (pytest)
TESTS="null"
if [[ -f "package.json" ]]; then
    if grep -q '"vitest"' package.json 2>/dev/null; then
        TESTS='"vitest"'
    elif grep -q '"jest"' package.json 2>/dev/null; then
        TESTS='"jest"'
    elif grep -q '"mocha"' package.json 2>/dev/null; then
        TESTS='"mocha"'
    fi
fi
if [[ "$TESTS" = "null" && -f "pyproject.toml" ]]; then
    if grep -qE '(pytest|^\[tool\.pytest)' pyproject.toml 2>/dev/null; then
        TESTS='"pytest"'
    fi
fi

# sonarqube_ide_plugin: nicht erkennbar via CLI — Default false, Operator ergaenzt manuell auf Mac.
SONAR_IDE="false"

# sonarqube_cloud: true wenn sonar-project.properties im Projekt-Root vorhanden.
# Bootstrap setzt es auf false wenn D.5 abgelehnt. Auf true wenn sonar-project.properties existiert.
if [ -f "sonar-project.properties" ]; then
  SONAR_CLOUD="true"
else
  SONAR_CLOUD="false"
fi

# --- metadata.stack: analog BOO-3 Semgrep-Stack-Erkennung ---
HAS_PKG=0
HAS_PY=0
[[ -f "package.json" ]] && HAS_PKG=1
[[ -f "pyproject.toml" ]] && HAS_PY=1

if [[ $HAS_PKG -eq 1 && $HAS_PY -eq 1 ]]; then
    STACK="mixed"
elif [[ $HAS_PKG -eq 1 ]]; then
    # TS vs JS: tsconfig.json oder "typescript" als devDep
    if [[ -f "tsconfig.json" ]] || grep -q '"typescript"' package.json 2>/dev/null; then
        STACK="node-typescript"
    else
        STACK="node-javascript"
    fi
elif [[ $HAS_PY -eq 1 ]]; then
    STACK="python"
else
    STACK="unknown"
fi

# --- metadata.created_at: ISO-8601 UTC ---
CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# --- metadata.bootstrap_version: aktuelle Bootstrap-Version ---
BOOTSTRAP_VERSION="3.3.0"

# --- JSON via Heredoc (kein jq noetig) ---
cat > "$OUT" <<EOF
{
  "environment": "${ENVIRONMENT}",
  "tools_available": {
    "eslint": ${HAS_ESLINT},
    "semgrep": ${HAS_SEMGREP},
    "tests": ${TESTS},
    "sonarqube_ide_plugin": ${SONAR_IDE},
    "sonarqube_cloud": ${SONAR_CLOUD}
  },
  "paths": {
    "journal": "journal/",
    "reports_local": "journal/reports/local/",
    "reports_ci": "journal/reports/ci/",
    "lessons_l1": "journal/learnings.md",
    "lessons_l2_dir": "journal/",
    "lessons_l3": "journal/learnings.db",
    "specs": "specs/",
    "architecture_design": "ARCHITECTURE_DESIGN.md",
    "conventions": "CONVENTIONS.md",
    "intents": "intents/",
    "pitches": "pitch/"
  },
  "governance": {
    "mode": "standard",
    "execution_isolation": "write-scope",
    "worktree_required_for": ["agentic"],
    "write_scope_required_for": ["sub-agents"]
  },
  "thresholds": {
    "architecture_doc_freshness_days": 30,
    "token_warn_threshold": 70,
    "token_hard_threshold": 80
  },
  "metadata": {
    "created_at": "${CREATED_AT}",
    "bootstrap_version": "${BOOTSTRAP_VERSION}",
    "stack": "${STACK}"
  }
}
EOF

echo "[ENV] $OUT geschrieben (environment=${ENVIRONMENT}, stack=${STACK})."
```

**Tests-Hinweis:** Skript muss auf macOS Darwin **und** Linux laufen, ohne externe Deps ausser `bash`, `uname`, `command`, `cat`, `grep`, `sed`, `date`. **Kein** `jq` (nicht ueberall installiert) — JSON wird per Heredoc geschrieben.

**Re-Generierung:** Wenn sich die Tooling-Lage aendert (z.B. `brew install semgrep` nachinstalliert, Test-Framework gewechselt von Jest auf Vitest), `bash .claude/generate-environment-json.sh --force` ausfuehren. Die Datei selbst sollte committed werden — `metadata.created_at` ist Audit-Spur fuer "wann hat dieses Projekt mit welcher Tooling-Annahme gearbeitet".

**Anti-Patterns:**
- KEIN automatisches Re-Run bei jedem Skill-Lauf — Datei ist Snapshot, nicht Live-Detection.
- KEIN `git add` aus dem Generator heraus — Operator entscheidet bewusst, ob committed oder gitignored.
- KEINE projekt-spezifischen Pfad-Overrides im Generator — Defaults sind Defaults; wenn ein Projekt eigene Pfade braucht, editiert der Operator die Datei nach dem ersten Generate.

---

## observability.md (BOO-14 — Observability-Skelett)

**Zentrale Observability-Doku im Projekt-Root**, eine Sektion pro Service. Definiert Logging-Schema, Metrics-Endpoint-Konvention, Alert-Rules-Verzeichnis und konkrete Beispiele fuer Node.js und Python. Wird beim Bootstrap einmalig angelegt und mit jedem neuen Service erweitert.

> [!important] Warum eine zentrale Datei?
> Operator und Skills brauchen einen einzigen Ort, an dem "was wird geloggt, was wird gemetrict, was alarmiert" steht. Pro-Service-Sektionen statt verstreute READMEs in jedem Service-Ordner — sonst driftet das Schema auseinander, sobald zwei Services sich unterscheiden duerfen ("bei uns ist das halt so"). Single Source of Truth, vom `architecture-review`-Skill und vom Operator gleichermassen lesbar.

**Stack-Scope:** nur Node.js und Python. Frontend hat keinen Server-Metrics-Endpoint — Frontend-Logs gehen ueber das Backend (oder Sentry / vergleichbar) und werden nicht in `observability.md` als eigener Service dokumentiert. Hinweis im Template (siehe unten).

```markdown
---
purpose: Observability-Skelett (Logging, Metrics, Alerts) pro Service
services: [auth-service]
last_updated: {{TODAY}}
metrics_port_base: 9091
logging_schema_version: 1
---

# Observability — {{PROJECT_NAME}}

Diese Datei dokumentiert das Observability-Skelett: **Logging-Schema**, **Metrics-Endpoint-Konvention** und **Alert-Rules** pro Service. Eine Sektion pro Service — Schema bleibt fuer alle Services identisch.

> [!note] Frontend
> Frontend-Apps haben **keinen** Server-Metrics-Endpoint. Frontend-Fehler und -Events gehen ueber das Backend (strukturierte Logs mit `service: "<frontend-app>"` plus `client_session_id`) oder ueber einen externen Error-Tracker (Sentry, Bugsnag, ...). Frontend wird daher hier **nicht** als eigene Pro-Service-Sektion gefuehrt.

---

## Logging-Schema (Pflicht-Felder)

Jeder Log-Eintrag (egal ob Node.js oder Python) ist **strukturiertes JSON** mit folgenden Pflicht-Feldern:

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `timestamp` | string (ISO 8601) | UTC, Millisekunden-Praezision (`2026-05-07T14:30:00.123Z`) |
| `level` | string | `debug` \| `info` \| `warn` \| `error` \| `fatal` |
| `service` | string | Service-Name aus dem Architecture-Block (z.B. `auth-service`) |
| `trace_id` | string | UUID v4 ODER W3C Trace Context Trace-ID — pro Request konstant |
| `message` | string | kurze, human-readable Zusammenfassung (kein Stacktrace) |
| `context` | object | strukturiertes JSON-Objekt mit zusaetzlichen Feldern (user_id, request_path, error_code, ...) |

**Beispiel-Output (eine Zeile, hier formatiert):**

```json
{
  "timestamp": "2026-05-07T14:30:00.123Z",
  "level": "error",
  "service": "auth-service",
  "trace_id": "550e8400-e29b-41d4-a716-446655440000",
  "message": "Login failed: invalid credentials",
  "context": {
    "user_id": "u_42",
    "request_path": "/api/login",
    "error_code": "INVALID_CREDENTIALS",
    "ip": "203.0.113.5"
  }
}
```

> [!important] Keine Klartext-Logs
> Logger werden **niemals** mit `console.log` / `print` / unstrukturiertem Format konfiguriert — Aggregation und Suche brechen sonst zusammen. Pflicht: pino (Node) bzw. structlog (Python) mit JSON-Renderer (siehe Stack-Beispiele unten).

---

## Metrics-Endpoint (Port-Konvention)

Jeder Service exponiert einen Prometheus-kompatiblen Metrics-Endpoint unter `GET /metrics`. **Port-Konvention:** `9090 + N`, wobei N pro Service hochgezaehlt wird.

| Service | Port | Metrics-URL |
|---------|------|-------------|
| (erster Service) | `9091` | `http://localhost:9091/metrics` |
| (zweiter Service) | `9092` | `http://localhost:9092/metrics` |
| (n-ter Service) | `9090 + n` | ... |

> [!note] Operator-Hinweis
> Wenn ein neuer Service hinzukommt, naechsten freien Port aus der Tabelle nehmen und den Eintrag pflegen. Prometheus-`scrape_configs` greift auf diese Tabelle als Single Source of Truth zu.

**Pflicht-Metriken pro Service:**

| Metrik | Typ | Labels | Zweck |
|--------|-----|--------|-------|
| `{service}_up` | Gauge (0/1) | — | Liveness-Heartbeat — `1` wenn Service-Prozess laeuft, sonst `0`. |
| `{service}_requests_total` | Counter | `method`, `route`, `status` | HTTP-Request-Zaehler nach Methode, Route-Template (nicht volle URL) und Status-Code. |
| `{service}_request_duration_seconds` | Histogram | `method`, `route` | Request-Dauer mit Default-Buckets `[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10]`. |
| `{service}_errors_total` | Counter | `error_type` | Fehler-Zaehler nach Typ (`validation`, `db`, `upstream_timeout`, `internal`, ...). |

`{service}` ist der Service-Name in `snake_case` (z.B. `auth_service`, nicht `auth-service`) — Prometheus-Convention.

---

## Alert-Rules (Pflicht-Alerts)

Pro Service drei Pflicht-Alerts unter `observability/alerts/<service>.yml` (siehe Template). Alle Alerts sind **routing-agnostisch** — Severity-Labels steuern, wohin Alertmanager sie weiterreicht (siehe `observability/.env.observability`).

| Alert | Bedingung | `for:` | Severity |
|-------|-----------|--------|----------|
| `{service}_down` | `up{service="..."} == 0` | `2m` | `critical` |
| `{service}_error_rate_high` | `rate(errors_total[5m]) / rate(requests_total[5m]) > 0.05` | `5m` | `warning` |
| `{service}_p95_slow` | `histogram_quantile(0.95, rate(request_duration_seconds_bucket[5m])) > 1` | `5m` | `warning` |

PromQL-Beispiele und Rule-Skeleton siehe `observability/alerts/<service>.yml` (Template weiter unten in dieser Datei).

> [!important] Validierung
> Alle Alert-Rule-Files muessen die Promtool-Validierung bestehen:
> ```bash
> promtool check rules observability/alerts/*.yml
> ```
> CI-Job soll diesen Check ausfuehren — Bootstrap legt nur die Rules an, fuegt den CI-Hook aber nicht automatisch hinzu (Operator-Entscheidung, je nach CI-Provider).

---

## Pro-Service-Sektion (Template)

Eine Sektion pro Service — beim Anlegen eines neuen Services duplizieren und ausfuellen. Beispiel hier: `auth-service`.

### auth-service

- **Sprache / Stack:** Node.js (TypeScript)
- **Metrics-Endpoint:** `http://localhost:9091/metrics`
- **Alert-Rules:** `observability/alerts/auth-service.yml`
- **Logger:** pino mit JSON-Renderer (`level: 'info'` in Production, `'debug'` lokal)
- **Trace-Propagation:** W3C Trace Context Header (`traceparent`) — `trace_id` aus Header oder neu generieren
- **Service-Label fuer Prometheus:** `auth_service` (snake_case)
- **Bekannte error_type-Werte:** `validation`, `db`, `upstream_timeout`, `internal`

---

## Stack-Beispiele

### Node.js — pino + prom-client

`package.json`-Dependencies (current major):

```json
{
  "dependencies": {
    "pino": "^9",
    "prom-client": "^15"
  }
}
```

Logger-Setup (`src/lib/logger.ts`):

```typescript
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  base: { service: 'auth-service' },
  timestamp: pino.stdTimeFunctions.isoTime,
  formatters: {
    level: (label) => ({ level: label }),
  },
});

// Usage
logger.error(
  { trace_id, context: { user_id, error_code: 'INVALID_CREDENTIALS' } },
  'Login failed: invalid credentials'
);
```

Metrics-Setup (`src/lib/metrics.ts`):

```typescript
import { Counter, Gauge, Histogram, register } from 'prom-client';

export const up = new Gauge({
  name: 'auth_service_up',
  help: '1 if auth-service is running, 0 otherwise',
});
up.set(1);

export const requests = new Counter({
  name: 'auth_service_requests_total',
  help: 'HTTP requests',
  labelNames: ['method', 'route', 'status'] as const,
});

export const requestDuration = new Histogram({
  name: 'auth_service_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route'] as const,
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
});

export const errors = new Counter({
  name: 'auth_service_errors_total',
  help: 'Errors by type',
  labelNames: ['error_type'] as const,
});

// /metrics endpoint (Express)
// app.get('/metrics', async (_req, res) => {
//   res.set('Content-Type', register.contentType);
//   res.end(await register.metrics());
// });
```

### Python — structlog + prometheus_client

`pyproject.toml`-Dependencies (current major):

```toml
[project]
dependencies = [
  "structlog>=24",
  "prometheus_client>=0.20",
]
```

Logger-Setup (`app/logger.py`):

```python
import logging
import structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso", utc=True, key="timestamp"),
        structlog.processors.JSONRenderer(),
    ],
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
)

logger = structlog.get_logger().bind(service="auth-service")

# Usage
logger.error(
    "Login failed: invalid credentials",
    trace_id=trace_id,
    context={"user_id": user_id, "error_code": "INVALID_CREDENTIALS"},
)
```

Metrics-Setup (`app/metrics.py`):

```python
from prometheus_client import Counter, Gauge, Histogram, start_http_server

up = Gauge("auth_service_up", "1 if auth-service is running, 0 otherwise")
up.set(1)

requests_total = Counter(
    "auth_service_requests_total",
    "HTTP requests",
    ["method", "route", "status"],
)

request_duration = Histogram(
    "auth_service_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "route"],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10),
)

errors_total = Counter(
    "auth_service_errors_total",
    "Errors by type",
    ["error_type"],
)

# Expose /metrics on configured port (9091 for auth-service)
# start_http_server(9091)
```

---

## Validierung

```bash
# Prometheus-Rules pruefen (Pflicht vor Merge)
promtool check rules observability/alerts/*.yml
```

Falls `promtool` lokal nicht verfuegbar ist: per Docker (`docker run --rm -v "$PWD/observability/alerts:/rules" prom/prometheus promtool check rules /rules`) oder im CI-Job pruefen. Operator-Entscheidung, wo der Check zuhause ist — Bootstrap legt die Rules an, der Check selbst ist Teil des Quality-Gates.
```

**Anti-Patterns:**
- KEINE Klartext-/`console.log`-/`print`-Logs in produktionsreifem Code — JSON-Renderer ist Pflicht.
- KEIN volles URL-Pfad-Templating als Label (z.B. `/users/12345`) — explodiert die Cardinality. Stattdessen Route-Template (`/users/:id`).
- KEINE `service`-Labels mit `Bindestrich` in Prometheus-Metrik-Namen — Prometheus erlaubt nur `[a-zA-Z_][a-zA-Z0-9_]*`. Service-Name in Logs `auth-service`, in Metrik-Namen `auth_service`.
- KEINE Frontend-Apps als eigene Pro-Service-Sektion — Frontend logged ueber Backend oder externen Error-Tracker.

---

## observability/alerts/<service>.yml (BOO-14)

**Prometheus-Alert-Rule-Template pro Service.** Drei Pflicht-Alerts (`{service}_down`, `{service}_error_rate_high`, `{service}_p95_slow`) mit Severity-Labels und Annotations. Routing-agnostisch — Alertmanager entscheidet anhand der Severity-Labels, wohin der Alert geht (siehe `.env.observability`).

> [!important] Service-Name ersetzen
> `{{SERVICE_NAME}}` ist die Heredoc-Variable und muss vom Bootstrap-Skill (oder manuell beim Anlegen) durch den Service-Namen in `snake_case` ersetzt werden — z.B. `auth_service`. Dateiname bleibt `auth-service.yml` (Kebab-Case fuers Filesystem), die Metrik-Praefixe drin sind `snake_case`.

```yaml
# observability/alerts/{{SERVICE_NAME_KEBAB}}.yml
# Prometheus Alert Rules fuer Service {{SERVICE_NAME}} (snake_case fuer Metrik-Namen).
# Validierung: promtool check rules observability/alerts/*.yml
groups:
  - name: {{SERVICE_NAME}}_alerts
    rules:
      - alert: {{SERVICE_NAME}}_down
        expr: {{SERVICE_NAME}}_up == 0
        for: 2m
        labels:
          severity: critical
          service: {{SERVICE_NAME}}
        annotations:
          summary: "{{SERVICE_NAME}} is down"
          description: |
            Service {{SERVICE_NAME}} reports up == 0 for more than 2 minutes.
            Check process, container or scrape target.

      - alert: {{SERVICE_NAME}}_error_rate_high
        expr: |
          (
            sum(rate({{SERVICE_NAME}}_errors_total[5m]))
            /
            sum(rate({{SERVICE_NAME}}_requests_total[5m]))
          ) > 0.05
        for: 5m
        labels:
          severity: warning
          service: {{SERVICE_NAME}}
        annotations:
          summary: "{{SERVICE_NAME}} error rate above 5%"
          description: |
            Error rate (errors_total / requests_total over 5m) is above 5%
            for more than 5 minutes. Inspect recent deploys and upstream
            dependencies.

      - alert: {{SERVICE_NAME}}_p95_slow
        expr: |
          histogram_quantile(
            0.95,
            sum(rate({{SERVICE_NAME}}_request_duration_seconds_bucket[5m])) by (le)
          ) > 1
        for: 5m
        labels:
          severity: warning
          service: {{SERVICE_NAME}}
        annotations:
          summary: "{{SERVICE_NAME}} p95 latency above 1s"
          description: |
            95th percentile request duration is above 1 second for more
            than 5 minutes. Check DB, upstream calls or recent code changes.
```

**Severity-Konvention:**
- `critical` — Service ist nicht erreichbar (Down, Crash). Pager / Telegram / sofortige Aktion.
- `warning` — Service laeuft, aber degradiert (Errors hoch, Latenz hoch). Slack / Email / nicht-blockierend.

**Anti-Patterns:**
- KEINE Pflicht-Alerts loeschen — wer `_down` wegnimmt, kriegt keinen Alarm wenn der Service stirbt.
- KEINE Alert-Schwellen "weicher" stellen ohne Begruendung im Spec — `> 0.05` und `> 1s` sind konservative Defaults; wer sie aendert, dokumentiert das Warum.
- KEIN routing-spezifisches Detail in der Rule-Datei (Telegram-Channel-IDs, Slack-Webhooks, ...) — gehoert in Alertmanager-Config, nicht in die Rule.

---

## observability/.env.observability (BOO-14)

**Routing-Config fuer Alertmanager-Receiver.** Listet Generic-Receiver-Konfiguration plus **Telegram als konkretes Beispiel**. Slack, Discord, Email, PagerDuty werden analog konfiguriert — siehe Alertmanager-Doku.

> [!warning] Secrets — gehoert in `.gitignore`
> Diese Datei enthaelt Bot-Tokens, Webhook-URLs, API-Keys. **Niemals** committen. Bootstrap-Skill traegt `.env.observability` automatisch in `.gitignore` ein. Eine `.env.observability.example` ohne echte Werte kann committed werden, falls Operator das wuenscht.

```bash
# observability/.env.observability
# Alertmanager-Receiver-Routing fuer {{PROJECT_NAME}}.
# Diese Datei NIEMALS committen — sie enthaelt Tokens und Webhooks.
# Telegram ist hier als konkretes Beispiel hinterlegt; Slack, Discord,
# Email, PagerDuty werden analog konfiguriert (siehe Alertmanager-Doku).

# --- Generic Receiver Routing (Pflicht) ---
# Welcher Receiver soll Alerts kriegen? Muss in alertmanager.yml als
# `receivers[].name` definiert sein.
ALERTMANAGER_RECEIVER="default"

# URL, unter der Alertmanager erreichbar ist (Prometheus-Side).
ALERTMANAGER_URL="http://localhost:9093"

# --- Telegram (Beispiel-Routing — eines von vielen) ---
# Bot-Token von @BotFather (https://core.telegram.org/bots#botfather).
TELEGRAM_BOT_TOKEN=""

# Chat-ID, an die Alerts gehen sollen (negativ fuer Gruppen).
TELEGRAM_CHAT_ID=""

# --- Andere Receiver-Typen (Platzhalter) ---
# Slack: SLACK_WEBHOOK_URL=""
# Discord: DISCORD_WEBHOOK_URL=""
# Email: SMTP_HOST="", SMTP_USER="", SMTP_PASS=""
# PagerDuty: PAGERDUTY_INTEGRATION_KEY=""
#
# Konfiguration aller Receiver siehe Alertmanager-Doku:
# https://prometheus.io/docs/alerting/latest/configuration/#receiver
```

**Anti-Patterns:**
- KEIN Commit dieser Datei — `.gitignore`-Eintrag ist Pflicht.
- KEIN Klartext-Token im Repo, auch nicht "kurz zum Testen".
- KEIN Hardcoding von Telegram als einzigem Receiver in Skills oder Hooks — `.env.observability` und Alertmanager-Config sind die Single Source of Truth fuer Routing, nicht ein Skill.

---

## Performance-Baseline-Gate (BOO-16 — P95 + 20%-Rueckfall-Alarm)

Zweiter Arm der Performance-Saeule. BOO-14 hat bereits den **Production-Alarm** etabliert (`{service}_p95_slow` ueber Prometheus, schlaegt an wenn der Live-Service p95 > 1s laeuft). BOO-16 ergaenzt den **Pre-Production-Gate**: bevor ein PR mergt, wird der Service in CI gegen eine **lebende Baseline** gebenchmarkt. Steigt p95 um mehr als 20 % gegenueber der Baseline, blockiert das Gate den Merge — Operator kann mit dokumentiertem Override ziehen, sonst muss die Regression vor Merge geklaert werden.

> [!important] Schrader, Code Crash, Kap. 3 §Production Readiness (Gate 3: Performance Baseline)
> Performance ist kein "messen wir spaeter mal" — sie ist ein Gate. Ohne Baseline kein Vergleich, ohne Vergleich keine Regression sichtbar. BOO-16 setzt die Baseline als versioniertes Architektur-Artefakt im Repo, nicht als fluechtigen Test-Output.

**Stack-Scope:** Node.js (a/c) und Python (d). Frontend (b) hat keinen Server-Endpoint — fuer Frontend-Performance laeuft Lighthouse CI getrennt (Folge-Issue, nicht BOO-16-Scope). Stack `e (Anderes)`: Operator entscheidet, Tool muss JSON-Output mit p50/p95/p99 produzieren.

**Vier Artefakte (in dieser Reihenfolge angelegt):**

1. `journal/perf-baseline.json` — lebende Baseline pro Service (committed)
2. `bench/<service>.bench.js` (Node) ODER `bench/<service>_bench.py` (Python) — Service-Benchmark
3. `.github/workflows/perf.yml` — CI-Gate, vergleicht aktuellen Bench-Lauf gegen Baseline
4. `journal/reports/perf/overrides.log` — append-only Operator-Override-Spur (entsteht erst beim ersten Override)

---

## journal/perf-baseline.json (BOO-16 — Living Performance Baseline)

**Lebende Baseline, ein Eintrag pro Service.** Wird beim Bootstrap initial leer (`services: []`) angelegt und nach dem ersten erfolgreichen Bench-Lauf vom Operator manuell befuellt. Wird bei jedem Release nach Operator-Freigabe aktualisiert — niemals automatisch ueberschrieben.

> [!important] Baseline ist Architektur-Artefakt, nicht Test-Output
> Diese Datei wird committed und reviewed wie jede andere Architektur-Entscheidung. Neue Werte pro Release manuell ersetzen — der CI-Gate liest, schreibt aber nie zurueck. Wer die Baseline anhebt, traegt das im Commit-Message als ADR-Begruendung ein ("Baseline angehoben weil neue Persistierungs-Schicht +15% kostet, akzeptiert weil X").

**Schema (ein Eintrag pro Service):**

| Feld | Typ | Beschreibung |
|------|-----|--------------|
| `service` | string | Service-Name in Kebab-Case, identisch zur `observability.md`-Sektion |
| `p50_ms` | number | Median-Latenz in Millisekunden |
| `p95_ms` | number | 95-Percentile-Latenz in Millisekunden (siehe Anti-Patterns: bei autocannon Approximation via p97_5) |
| `p99_ms` | number | 99-Percentile-Latenz in Millisekunden |
| `req_per_sec` | number | Mittlerer Durchsatz waehrend des Bench-Laufs |
| `recorded_at` | string (ISO 8601) | UTC-Zeitstempel der Messung |
| `commit_sha` | string | Git-Commit-SHA (40 Zeichen), unter dem die Baseline gemessen wurde |
| `bench_tool` | string | `autocannon` \| `pytest-benchmark` \| `other` |

```json
{
  "$schema_version": 1,
  "services": [
    {
      "service": "auth-service",
      "p50_ms": 12.4,
      "p95_ms": 38.7,
      "p99_ms": 84.2,
      "req_per_sec": 2150.0,
      "recorded_at": "2026-05-07T14:30:00Z",
      "commit_sha": "a1b2c3d4e5f6789012345678901234567890abcd",
      "bench_tool": "autocannon"
    },
    {
      "service": "api-gateway",
      "p50_ms": 8.1,
      "p95_ms": 22.3,
      "p99_ms": 51.0,
      "req_per_sec": 3400.0,
      "recorded_at": "2026-05-07T14:32:00Z",
      "commit_sha": "a1b2c3d4e5f6789012345678901234567890abcd",
      "bench_tool": "autocannon"
    }
  ]
}
```

> [!note] Erstbefuellung
> Beim Bootstrap legt der Skill `services: []` an. Solange die Baseline leer ist, **skippt** der Perf-Workflow seine Benchmarks via Prerequisite-Check (BOO-143) und das Gate bleibt **gruen** — ein frisches Repo bricht nicht mehr am Perf-Gate ab. Sobald der Operator nach einem ersten Bench-Lauf das `journal/reports/perf/<service>-bench-<sha>.json`-Artefakt herunterlaedt, die p50/p95/p99/req_per_sec-Werte in die Baseline kopiert und als "BOO-16: initial baseline for <service>" committed, laeuft das Gate ab dem naechsten Lauf normal (Vergleich gegen Baseline).

**Anti-Patterns:**
- KEINE automatische Ueberschreibung der Baseline durch CI — nur Operator. Sonst ist das Gate sinnlos (Baseline waechst mit jeder Regression mit).
- KEINE Baseline ohne `commit_sha` — der SHA ist die Auditspur, ohne die niemand spaeter rekonstruieren kann, mit welchem Code-Stand gemessen wurde.
- KEINE Mittelwerte ueber mehrere Laeufe einkippen ohne Doku — wenn Baseline aus 3 Laeufen entsteht, dann im Commit-Message benennen ("avg of 3 runs, stddev=Xms").

---

## bench/<service>.bench.js (BOO-16 — Node.js Service-Benchmark mit autocannon)

**Service-Benchmark fuer Node.js-Services mit autocannon (programmatische API).** Schreibt einen JSON-Report in `journal/reports/perf/<service>-bench-<sha>.json` mit demselben Schema wie ein Eintrag in `perf-baseline.json` — der Comparator-Step in `perf.yml` liest das ohne Konvertierung.

**Devdep:**

```bash
npm install --save-dev autocannon
```

(autocannon 7.x — generische programmatische API, siehe `mcollina/autocannon` README).

> [!important] Kein nativer p95 in autocannon
> autocannon's `result.latency` ist ein `hdr-histogram-percentiles-obj` und exponiert die Percentile `p2_5, p50, p75, p90, p97_5, p99, p99_9, p99_99, p99_999` — **es gibt kein direktes `p95`**. Wir nutzen `p97_5` als konservative Approximation (worst-case Bias nach oben — eine echte Regression wird trotzdem erkannt, harmlose Schwankungen werden ggf. groesser dargestellt). Das ist explizite Operator-Choice, dokumentiert in der Baseline als `bench_tool: "autocannon"`.

**Naming-Konventionen:**
- Datei: Kebab-Case, identisch zum Service-Namen — `bench/auth-service.bench.js`
- Service-Name in JSON-Output: Kebab-Case (`"service": "auth-service"`) — identisch zu `observability.md`
- Report-Pfad: `journal/reports/perf/<service>-bench-<short-sha>.json` (short-sha = erste 7 Zeichen des Git-SHA)

```javascript
// bench/{{SERVICE_NAME_KEBAB}}.bench.js
// BOO-16 Service-Benchmark — laeuft in CI ueber .github/workflows/perf.yml.
// Voraussetzung: Service laeuft auf {{PORT}} unter {{PATH}} (siehe README).

const autocannon = require('autocannon');
const fs = require('node:fs');
const path = require('node:path');
const { execSync } = require('node:child_process');

const SERVICE_NAME = '{{SERVICE_NAME_KEBAB}}';
const TARGET_URL = process.env.BENCH_URL || 'http://localhost:{{PORT}}{{PATH}}';
const CONNECTIONS = Number(process.env.BENCH_CONNECTIONS || 10);
const DURATION = Number(process.env.BENCH_DURATION || 30); // Sekunden

async function main() {
  // Warmup: 5 Sekunden, Resultat verworfen — schuetzt vor JIT-/Cache-Effekten in der Messung.
  await autocannon({ url: TARGET_URL, connections: CONNECTIONS, duration: 5 });

  const result = await autocannon({
    url: TARGET_URL,
    connections: CONNECTIONS,
    duration: DURATION,
  });

  // autocannon hat kein natives p95 — p97_5 ist die naechste verfuegbare Percentile (>=95).
  // Konservative Approximation, dokumentiert in journal/perf-baseline.json -> bench_tool: "autocannon".
  const sha = execSync('git rev-parse HEAD').toString().trim();
  const shortSha = sha.slice(0, 7);

  const report = {
    service: SERVICE_NAME,
    p50_ms: result.latency.p50,
    p95_ms: result.latency.p97_5, // Approximation, siehe Kommentar oben
    p99_ms: result.latency.p99,
    req_per_sec: result.requests.average,
    recorded_at: new Date().toISOString(),
    commit_sha: sha,
    bench_tool: 'autocannon',
  };

  const outDir = path.join('journal', 'reports', 'perf');
  fs.mkdirSync(outDir, { recursive: true });
  const outPath = path.join(outDir, `${SERVICE_NAME}-bench-${shortSha}.json`);
  fs.writeFileSync(outPath, JSON.stringify(report, null, 2));

  console.log(`[BOO-16] Bench-Report: ${outPath}`);
  console.log(JSON.stringify(report, null, 2));
}

main().catch((err) => {
  console.error('[BOO-16] Bench failed:', err);
  process.exit(1);
});
```

> [!note] Service-Start ist Operator-Choice
> Das Bench-Skript erwartet einen laufenden Service auf `BENCH_URL`. Ob der Service in CI per `npm run start:{{SERVICE_NAME}} &`, per Docker-Compose oder per `node dist/server.js &` gestartet wird, entscheidet der Operator pro Projekt. Im Workflow-Template (siehe `perf.yml` weiter unten) ist der Service-Start als Platzhalter mit Kommentar markiert.

**Anti-Patterns:**
- KEINE Microbench-Tools (`tinybench`, `benchmark.js`) als HTTP-Service-Bench einsetzen — die messen Funktions-Latenz im Prozess, nicht den vollen Stack inkl. Netzwerk-Stack, Serialisierung und Middleware.
- KEINE Bench-Laeufe ohne Warmup — JIT-Compilation und Cache-Effekte verzerren die ersten Sekunden um Faktor 2-5.
- KEINE 1-Sekunden-Messungen — die Statistik ist nicht stabil, p95 schwankt um +/-50 %. Mindestens 30s, besser 60s.
- KEINE Bench-Laeufe gegen Production-URL aus CI — fuehrt zu DDoS-Verdacht und Kosten-Explosion. Service muss lokal im Runner gestartet werden.

---

## bench/<service>_bench.py (BOO-16 — Python Service-Benchmark mit pytest-benchmark)

**Service-Benchmark fuer Python-Services mit pytest-benchmark + httpx.** pytest-benchmark misst Funktions-Latenz statistisch sauber (mehrere Rounds, Median, Stddev), wir wrappen einen HTTP-Call gegen den lokalen Service.

**Devdeps (`pyproject.toml`):**

```toml
[project.optional-dependencies]
test = [
  "pytest>=8",
  "pytest-benchmark>=5",
  "httpx>=0.27",
]
```

> [!important] pytest-benchmark misst Latenz, nicht Throughput
> pytest-benchmark exportiert per Default `min, max, mean, stddev, median, iqr, outliers, rounds, iterations` — also keine echten Quantile, sondern Verteilungs-Statistiken. Wir mappen `p50 = median` direkt. Fuer `p95` gibt es zwei Wege:
> - **Operator-Choice A (Default, empfohlen):** Approximation `p95 ≈ mean + 1.645 * stddev` (Normalverteilungs-Annahme). Schnell, robust bei homogenen Latenzen, biased nach oben bei Long-Tail-Verteilungen.
> - **Operator-Choice B:** Eigene Histogram-Aufzeichnung in der Test-Function (siehe Snippet unten), liefert echte Quantile, kostet aber Boilerplate. Empfohlen wenn der Service bekanntermassen Long-Tail-Latenzen hat (z.B. DB-Queries mit Cache-Miss-Spikes).
>
> Wahl wird in `journal/perf-baseline.json` ueber `bench_tool: "pytest-benchmark"` dokumentiert. Wer Choice B nimmt, traegt zusaetzlich `bench_tool: "pytest-benchmark+histogram"` ein.

**Throughput-Caveat:** pytest-benchmark misst pro Round eine einzelne Funktions-Ausfuehrung — daraus laesst sich `req_per_sec` nur **synthetisch** ableiten (`1000 / mean_ms`). Fuer echten Concurrent-Throughput (mehrere Connections parallel) braucht es ein separates Tool wie `locust` oder `wrk` — bewusst aus BOO-16-Scope ausgeschlossen, ggf. Folge-Issue BOO-XX.

```python
# bench/{{SERVICE_NAME_SNAKE}}_bench.py
# BOO-16 Service-Benchmark — laeuft in CI ueber .github/workflows/perf.yml.
# Aufruf: pytest bench/ --benchmark-json=journal/reports/perf/{{SERVICE_NAME_KEBAB}}-bench.json

import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path

import httpx
import pytest

SERVICE_NAME = "{{SERVICE_NAME_KEBAB}}"
TARGET_URL = os.environ.get("BENCH_URL", "http://localhost:{{PORT}}{{PATH}}")


@pytest.fixture(scope="module")
def client():
    with httpx.Client(timeout=10.0) as c:
        # Warmup: 50 Requests, Resultat verworfen.
        for _ in range(50):
            c.get(TARGET_URL).raise_for_status()
        yield c


def test_request_latency(benchmark, client):
    """Misst Latenz pro HTTP-Call. p50 = median, p95 ueber Approximation (siehe Header)."""
    result = benchmark(lambda: client.get(TARGET_URL).raise_for_status())
    # pytest-benchmark schreibt stats automatisch via --benchmark-json.
    # Der Comparator-Step in perf.yml konvertiert stats -> p50/p95/p99 (siehe perf.yml).
    return result


# Optional: Operator-Choice B — eigene Histogram-Aufzeichnung fuer echte Quantile.
# Aktivieren durch Auskommentieren und in perf.yml den Konvertierungs-Pfad anpassen.
#
# def test_request_latency_with_histogram(client):
#     import time
#     samples_ms: list[float] = []
#     for _ in range(1000):
#         t0 = time.perf_counter()
#         client.get(TARGET_URL).raise_for_status()
#         samples_ms.append((time.perf_counter() - t0) * 1000)
#     samples_ms.sort()
#     report = _build_report(
#         p50=samples_ms[len(samples_ms) // 2],
#         p95=samples_ms[int(len(samples_ms) * 0.95)],
#         p99=samples_ms[int(len(samples_ms) * 0.99)],
#         req_per_sec=1000.0 / (sum(samples_ms) / len(samples_ms) / 1000),
#     )
#     _write_report(report, bench_tool="pytest-benchmark+histogram")


def _build_report(p50: float, p95: float, p99: float, req_per_sec: float) -> dict:
    sha = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()
    return {
        "service": SERVICE_NAME,
        "p50_ms": p50,
        "p95_ms": p95,
        "p99_ms": p99,
        "req_per_sec": req_per_sec,
        "recorded_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "commit_sha": sha,
        "bench_tool": "pytest-benchmark",
    }


def _write_report(report: dict, bench_tool: str = "pytest-benchmark") -> None:
    report["bench_tool"] = bench_tool
    out_dir = Path("journal/reports/perf")
    out_dir.mkdir(parents=True, exist_ok=True)
    short_sha = report["commit_sha"][:7]
    out_path = out_dir / f"{SERVICE_NAME}-bench-{short_sha}.json"
    out_path.write_text(json.dumps(report, indent=2))
```

> [!note] Konvertierungs-Schritt
> Der Default-Pfad (Choice A) erzeugt einen pytest-benchmark-JSON-Output (`--benchmark-json=...`). Der Comparator-Step in `perf.yml` macht dann eine Konvertierung `stats.median -> p50_ms`, `stats.mean + 1.645*stats.stddev -> p95_ms`, `stats.max -> p99_ms` (Approximation: max ist konservative obere Schranke fuer p99 bei kleinen Sample-Groessen). Wer Choice B aktiviert, schreibt direkt das Baseline-Schema und ueberspringt die Konvertierung.

**Anti-Patterns:**
- KEINE pytest-benchmark fuer Throughput-Messungen einsetzen — `rounds` ist sequentiell, nicht concurrent. `req_per_sec` aus Mean-Latenz ist Single-Connection-Approximation, nicht Multi-Connection-Capacity.
- KEINE pytest-benchmark gegen Production-URL — siehe Node.js-Anti-Pattern, Service muss im Runner laufen.
- KEINE Test-Functions mit `assert response.status_code == 200` und `benchmark()` zugleich — der Assert wird N-mal ausgefuehrt, das verfaelscht die Messung. Stattdessen `raise_for_status()` im Lambda.

---

## .github/workflows/perf.yml (BOO-16 — CI-Performance-Gate)

**Pre-Production-Gate**, laeuft auf jedem PR gegen `main` plus manuell via `workflow_dispatch`. Drei Schwellen, eine Override-Mechanik, Bench-Output als Artefakt.

> [!important] GitHub-Hosted-Runner-Varianz
> GitHub-Hosted-Runner sind Shared-Hardware mit Noisy-Neighbor-Effekt. Empirische Messungen zeigen +/- 30 % Varianz zwischen identischen Laeufen. Der **20%-Threshold** in BOO-16 ist absichtlich generoes gewaehlt, um diesen Noise zu absorbieren — eine echte Regression sticht erst bei >20 % heraus. Empfehlung als Folge-Issue (BOO-XX): **Self-Hosted-Runner** mit reservierter CPU/Memory, dort kann der Threshold auf 10 % geschaerft werden. Bis dahin ist der 20%-Threshold der pragmatische Default.

**Schwellen (Comparator-Logik, ratio = current_p95 / baseline_p95):**

| Ratio | Outcome | Mechanik |
|-------|---------|----------|
| `<= 1.05` | PASS | Gruene Ausgabe, exit 0 |
| `> 1.05 && <= 1.20` | WARNING | PR-Comment via `actions/github-script@v7`, exit 0 |
| `> 1.20` | FAIL | exit 1 — ausser Operator-Override (siehe unten) |
| Baseline fehlt | FAIL | exit 1, Hinweis "Baseline fehlt — manuell aus Bench-Output uebernehmen + Operator-Freigabe" |

**Override-Mechanik (zwei Wege, beide loggen in `journal/reports/perf/overrides.log`):**
- PR-Label `perf-override` setzen (Web-UI, schneller Path)
- Commit-Message-Trailer `Perf-Override: <begruendung>` (Audit-freundlicher Path, im Git-History sichtbar)

```yaml
# .github/workflows/perf.yml
# BOO-16 Performance-Baseline-Gate — vergleicht aktuellen Bench-Lauf gegen
# journal/perf-baseline.json. Schwellen: <=5% PASS, 5-20% WARNING, >20% FAIL.

name: Performance

on:
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  bench:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        # Operator pflegt Service-Liste hier — synchron zu observability.md.
        service: [auth-service]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # --- Prerequisite-Check (BOO-143): leere/fehlende Baseline => Benchmarks skippen, Gate gruen ---
      # Ein frisches Projekt hat journal/perf-baseline.json mit services: [] — ohne diesen Check
      # bricht der erste CI-Lauf am Service-Start/Bench ab. Sobald die Baseline befuellt ist, laeuft das Gate normal.
      - name: Check prerequisites
        id: prereq
        run: |
          if [ ! -f journal/perf-baseline.json ]; then
            echo "INFO: journal/perf-baseline.json fehlt — Benchmarks werden uebersprungen (Gate gruen)."
            echo "skip=true" >> "$GITHUB_OUTPUT"
            exit 0
          fi
          SERVICES=$(python3 -c "import json; print(len(json.load(open('journal/perf-baseline.json')).get('services', [])))" 2>/dev/null || echo 0)
          if [ "$SERVICES" = "0" ]; then
            echo "INFO: Baseline noch leer (services: []) — Benchmarks uebersprungen, bis die Baseline befuellt ist (Gate gruen)."
            echo "skip=true" >> "$GITHUB_OUTPUT"
          else
            echo "skip=false" >> "$GITHUB_OUTPUT"
          fi

      # --- Stack-Setup: eines von beiden, je nach Stack-Choice (Block A) ---
      - name: Setup Node.js
        if: ${{ hashFiles('package.json') != '' }}
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Setup Python
        if: ${{ hashFiles('pyproject.toml') != '' }}
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install deps (Node)
        if: ${{ hashFiles('package.json') != '' }}
        run: npm ci

      - name: Install deps (Python)
        if: ${{ hashFiles('pyproject.toml') != '' }}
        run: pip install -e '.[test]'

      # --- Service starten — Operator passt Command pro Projekt an ---
      # Annahme: Service horcht auf Port 8080. Fuer Multi-Service-Projekte
      # pro Service einen eigenen Workflow-Job mit eigenem Port.
      - name: Start service (background)
        if: steps.prereq.outputs.skip == 'false'
        run: |
          # TODO Operator: hier den Start-Command fuer ${{ matrix.service }} eintragen.
          # Beispiele:
          #   Node:   npm run start:${{ matrix.service }} &
          #   Python: python -m {{MODULE}} &
          echo "Operator: Start-Command fuer ${{ matrix.service }} hier eintragen" && exit 1

      - name: Wait for service
        if: steps.prereq.outputs.skip == 'false'
        run: |
          for i in $(seq 1 30); do
            if curl -sf http://localhost:8080/health > /dev/null; then
              echo "Service ready"; exit 0
            fi
            sleep 1
          done
          echo "Service did not start within 30s"; exit 1

      # --- Bench laufen lassen (eines von beiden) ---
      - name: Run bench (Node)
        if: ${{ steps.prereq.outputs.skip == 'false' && hashFiles('package.json') != '' }}
        env:
          BENCH_URL: http://localhost:8080/
          BENCH_DURATION: '30'
        run: node bench/${{ matrix.service }}.bench.js

      - name: Run bench (Python)
        if: ${{ steps.prereq.outputs.skip == 'false' && hashFiles('pyproject.toml') != '' }}
        env:
          BENCH_URL: http://localhost:8080/
        run: |
          mkdir -p journal/reports/perf
          pytest bench/ \
            --benchmark-json=journal/reports/perf/${{ matrix.service }}-bench-raw.json

      # --- Comparator: Ratio current_p95 / baseline_p95 ---
      - name: Compare against baseline
        id: compare
        if: steps.prereq.outputs.skip == 'false'
        env:
          SERVICE: ${{ matrix.service }}
          PR_LABELS: ${{ toJson(github.event.pull_request.labels.*.name) }}
          COMMIT_MSG: ${{ github.event.pull_request.title }}
        run: |
          set -euo pipefail
          SHORT_SHA=$(git rev-parse --short HEAD)
          REPORT_PATH="journal/reports/perf/${SERVICE}-bench-${SHORT_SHA}.json"

          # Python-Stack: stats -> Baseline-Schema konvertieren (Operator-Choice A).
          if [ -f "journal/reports/perf/${SERVICE}-bench-raw.json" ] && [ ! -f "$REPORT_PATH" ]; then
            python3 - <<PY
          import json, subprocess
          from datetime import datetime, timezone
          raw = json.load(open("journal/reports/perf/${SERVICE}-bench-raw.json"))
          stats = raw["benchmarks"][0]["stats"]
          sha = subprocess.check_output(["git","rev-parse","HEAD"]).decode().strip()
          mean_ms = stats["mean"] * 1000
          stddev_ms = stats["stddev"] * 1000
          report = {
            "service": "${SERVICE}",
            "p50_ms": stats["median"] * 1000,
            "p95_ms": mean_ms + 1.645 * stddev_ms,
            "p99_ms": stats["max"] * 1000,
            "req_per_sec": 1000.0 / mean_ms if mean_ms > 0 else 0.0,
            "recorded_at": datetime.now(timezone.utc).isoformat().replace("+00:00","Z"),
            "commit_sha": sha,
            "bench_tool": "pytest-benchmark",
          }
          json.dump(report, open("${REPORT_PATH}","w"), indent=2)
          PY
          fi

          if [ ! -f "$REPORT_PATH" ]; then
            echo "FAIL: Bench-Report fehlt: $REPORT_PATH"; exit 1
          fi

          CURRENT=$(python3 -c "import json; print(json.load(open('$REPORT_PATH'))['p95_ms'])")
          BASELINE=$(python3 -c "
          import json, sys
          data = json.load(open('journal/perf-baseline.json'))
          for s in data.get('services', []):
              if s['service'] == '${SERVICE}':
                  print(s['p95_ms']); sys.exit(0)
          sys.exit(2)
          " || echo "MISSING")

          if [ "$BASELINE" = "MISSING" ]; then
            echo "FAIL: Baseline fuer ${SERVICE} fehlt in journal/perf-baseline.json."
            echo "Bench-Output: $REPORT_PATH — Werte manuell uebernehmen + Operator-Freigabe."
            exit 1
          fi

          RATIO=$(python3 -c "print(${CURRENT} / ${BASELINE})")
          echo "ratio=${RATIO}" >> "$GITHUB_OUTPUT"
          echo "current=${CURRENT}" >> "$GITHUB_OUTPUT"
          echo "baseline=${BASELINE}" >> "$GITHUB_OUTPUT"

          PASS=$(python3 -c "print('1' if ${RATIO} <= 1.05 else '0')")
          WARN=$(python3 -c "print('1' if ${RATIO} > 1.05 and ${RATIO} <= 1.20 else '0')")
          FAIL=$(python3 -c "print('1' if ${RATIO} > 1.20 else '0')")

          if [ "$PASS" = "1" ]; then
            echo "PASS: p95 ratio ${RATIO} (<= 1.05)"; exit 0
          fi
          if [ "$WARN" = "1" ]; then
            echo "WARNING: p95 ratio ${RATIO} (5-20% above baseline)"
            echo "outcome=warning" >> "$GITHUB_OUTPUT"
            exit 0
          fi
          # FAIL-Pfad — Override pruefen
          if echo "$PR_LABELS" | grep -q '"perf-override"' \
             || git log -1 --pretty=%B | grep -qi '^Perf-Override:'; then
            echo "FAIL overridden by operator. Logging to overrides.log."
            mkdir -p journal/reports/perf
            REASON=$(git log -1 --pretty=%B | grep -i '^Perf-Override:' | head -1 || echo "via PR label")
            echo "$(date -u +%FT%TZ) | ${SERVICE} | ratio=${RATIO} | sha=$(git rev-parse HEAD) | ${REASON}" \
              >> journal/reports/perf/overrides.log
            exit 0
          fi
          echo "FAIL: p95 ratio ${RATIO} > 1.20 (no override)"
          exit 1

      - name: Comment on PR (warning only)
        if: steps.compare.outputs.outcome == 'warning' && github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const ratio = '${{ steps.compare.outputs.ratio }}';
            const current = '${{ steps.compare.outputs.current }}';
            const baseline = '${{ steps.compare.outputs.baseline }}';
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `BOO-16 Perf-Warning: \`${{ matrix.service }}\` p95 ratio **${ratio}** ` +
                    `(current ${current} ms vs baseline ${baseline} ms). ` +
                    `Below 1.20 FAIL-Threshold but above 1.05 PASS-Threshold — review recommended.`
            });

      - name: Upload bench artifact
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: perf-bench-${{ matrix.service }}
          path: journal/reports/perf/
          retention-days: 30
```

> [!warning] Override-Log ist append-only Audit-Spur
> `journal/reports/perf/overrides.log` wird vom CI-Job angehaengt und committed (manuell durch den Operator beim Merge — der CI-Job kann nicht in den PR pushen). Wer ein Override zieht, ist im Log fuer immer sichtbar. Das ist Absicht: Override darf einfach sein, aber niemals unsichtbar.

**Anti-Patterns:**
- KEIN Bench-Lauf in einem Container ohne reservierte Ressourcen (Standard-GitHub-Hosted-Runner sind shared) ohne entsprechend generoese Schwellen — sonst flackert das Gate zwischen PASS und FAIL bei identischem Code.
- KEINE Schwellen unter 5 % auf Hosted-Runnern — der Noise-Floor allein ist 10-30 %.
- KEINE Override-Mechanik ohne Logging — sonst verkommt das Gate zu einer "skip if annoying"-Geste, und die Baseline driftet stillschweigend nach oben.
- KEIN automatisches Update der Baseline durch den Comparator-Step — siehe `perf-baseline.json`-Sektion. Baseline-Update ist immer Operator-Decision mit ADR-Begruendung.
- KEIN Bench-Lauf gegen Production-URL aus CI — Service muss lokal im Runner laufen.

---

## lighthouserc.json (BOO-45 — Frontend-Performance-Budgets)

Wird von `/bootstrap` A.1b generiert wenn `LIGHTHOUSE_CHOICE=yes` und `STACK_CHOICE` in `b` oder `c`.
Pendant zu BOO-16 `perf-baseline.json`, aber fuer Browser-Apps statt Backend-Services.

```json
{
  "ci": {
    "collect": {
      "url": ["http://localhost:3000/"],
      "numberOfRuns": 3,
      "settings": {
        "preset": "desktop",
        "throttlingMethod": "simulate"
      }
    },
    "assert": {
      "preset": "lighthouse:recommended",
      "assertions": {
        "categories:performance": ["error", {"minScore": 0.9}],
        "categories:accessibility": ["error", {"minScore": 0.9}],
        "categories:best-practices": ["warn", {"minScore": 0.9}],
        "categories:seo": ["warn", {"minScore": 0.9}],
        "largest-contentful-paint": ["error", {"maxNumericValue": 2500}],
        "cumulative-layout-shift": ["error", {"maxNumericValue": 0.1}],
        "total-blocking-time": ["error", {"maxNumericValue": 300}]
      }
    },
    "upload": {
      "target": "filesystem",
      "outputDir": "journal/reports/ci/lighthouse-out"
    }
  }
}
```

**Operator-Tasks beim Setup (manuell, im HANDBUCH Anhang H dokumentiert):**
- `ci.collect.url` pro Environment eintragen (preview-deploy, staging, prod) — die Default-URL `http://localhost:3000/` ist nur fuer den ersten Smoke-Test
- `ci.collect.settings.preset` auswaehlen: `desktop` (kein Throttling) vs. `mobile` (Lighthouse-default 3G-slow + 4x CPU-Throttle)
- Performance-Budgets justieren: Defaults sind branchenueblich, aber bei viel Drittanbieter-Code (Analytics, Ads) sind 2.5s LCP eng. Operator entscheidet `minScore` + `maxNumericValue` pro Projekt-Realitaet
- `ci.upload.target` umstellen wenn Lighthouse-Server-Backend gewuenscht (default `filesystem` schreibt in `journal/reports/ci/lighthouse-out/`)

---

## .github/workflows/lighthouse.yml (BOO-45 — Lighthouse-CI Frontend-Performance-Gate)

```yaml
name: Lighthouse CI

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }

      - name: Install dependencies
        run: npm ci

      - name: Build frontend
        run: npm run build

      - name: Start preview server in background
        run: |
          # Operator: an Build-Output anpassen — z.B. 'npx serve dist' oder 'npm run preview'
          npx serve -s dist -l 3000 &
          # Auf Server warten
          npx wait-on http://localhost:3000 --timeout 60000

      - name: Run Lighthouse CI
        run: |
          npm install -g @lhci/cli@0.14.x
          lhci autorun --config=./lighthouserc.json
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}

      - name: Collect reports for Hermes (BOO-32)
        if: always()
        run: |
          mkdir -p journal/reports/ci/run-${{ github.run_id }}
          cp -rf journal/reports/ci/lighthouse-out/* journal/reports/ci/run-${{ github.run_id }}/ 2>/dev/null || true
          # Aggregierte Score-Summary als lighthouse.json
          if [ -f "journal/reports/ci/lighthouse-out/manifest.json" ]; then
            cp -f journal/reports/ci/lighthouse-out/manifest.json journal/reports/ci/run-${{ github.run_id }}/lighthouse.json
          fi

      - name: Upload reports as artifact
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ci-reports-${{ github.run_id }}
          path: journal/reports/ci/run-${{ github.run_id }}/
          retention-days: 30
```

**Operator-Tasks (im HANDBUCH Anhang H):**
- Build-Command pro Stack anpassen — `npm run build` ist Default, aber Vite/Astro/Next haben andere Outputs
- Preview-Server-Command anpassen (Zeile `npx serve -s dist -l 3000`) — bei Next.js z.B. `npm run start`
- Bei statischem Hosting (Deploy auf Netlify/Vercel) kann der Step entfallen, Lighthouse direkt gegen die Preview-Deploy-URL laufen
- `LHCI_GITHUB_APP_TOKEN` Secret optional — nur fuer Lighthouse-CI-Server-Status-Checks (sonst Filesystem-Reports)

**Hermes-Konsumtion:** `lighthouse.json` ist die aggregierte Score-Summary (`manifest.json` von Lighthouse-CI), `journal/reports/ci/lighthouse-out/*.json` sind die Roh-Reports pro URL+Run.

---

## Reliability-Skelett (BOO-25 — 5 Invarianten Idempotenz/Retry/Circuit-Breaker/Graceful-Degradation/SLO)

Sechste Saeule des Schrader-Modells: Reliability als Architektur-Eigenschaft, nicht als Hoffnung. Die Saeule besteht aus fuenf Invarianten, die jeder produktive Service erfuellen sollte:

1. **Idempotenz** — schreibende Endpunkte koennen ohne Schaden wiederholt werden (Idempotency-Key-Middleware).
2. **Retry mit Backoff + Jitter** — transiente Fehler werden begrenzt automatisch wiederholt, kein Thundering Herd.
3. **Circuit Breaker / Bulkhead** — externe Abhaengigkeiten failen schnell, statt den Caller zu blockieren.
4. **Graceful Degradation** — bei Teilausfall liefert der Service ein reduziertes, aber definiertes Verhalten.
5. **SLO + Error Budget** — die Reliability-Erwartung ist gemessen, nicht versprochen.

> [!important] Schrader, Code Crash, Kap. 4 §Run the System (Saeule 6 Reliability)
> Reliability ist die Differenz zwischen "es lief beim Start" und "es laeuft Monat zwei". Sie entsteht nicht durch Glueck, sondern durch vier Code-Patterns plus ein Mess-Manifest. Wer sie weglaesst, baut einen Demo, kein System.

**Stack-Scope:** Node.js (a/c) und Python (d) bekommen vier konkrete Skelett-Dateien (Idempotency, Retry, Circuit Breaker, SLO). Frontend (b) hat keinen serverseitigen Idempotency-/Retry-/Breaker-Layer — Backend uebernimmt das. Stack `e (Anderes)`: Operator-Choice, SLO-Manifest bleibt aber Pflicht (Tool-unabhaengig).

**Vier Artefakte (in dieser Reihenfolge angelegt):**

1. `docs/SLO.md` — Service Level Objective Manifest (committed, alle Stacks).
2. `lib/idempotency.{js,py}` — Idempotency-Key-Middleware fuer schreibende Endpunkte.
3. `lib/retry.{js,py}` — Retry-Helper mit Backoff + Jitter.
4. `lib/circuit-breaker.{js,py}` — Circuit-Breaker-Wrapper, ein Breaker pro externe Abhaengigkeit.

> [!note] Optionalitaet
> Nicht jeder Service braucht alle vier Skelette ab Tag 0. Ein reiner Read-only-Lookup-Service braucht keinen Idempotency-Layer. Die Phase 4.4h im Bootstrap fragt explizit pro Skelett ab — siehe `SKILL.md` Phase 4.4h. Empfehlung fuer Backend-Services mit externer Abhaengigkeit: alle vier setzen.

---

## docs/SLO.md (BOO-25 — Service Level Objective Manifest)

**Reliability-Erwartung als versioniertes Architektur-Artefakt.** Beschreibt pro Service drei SLIs (Service Level Indicators) und die zugehoerigen SLOs (Objectives), inklusive Error-Budget-Tabelle pro Quartal mit Verbrauchs-Tracker. Wird in `/sprint-review` einmal monatlich gegengelesen — verbleibendes Budget entscheidet, ob Reliability-Investment vor Feature-Investment kommt.

> [!important] SLO ist Architektur-Artefakt, kein Marketing-Versprechen
> Wer "99,99 % Verfuegbarkeit" in den Vertrag schreibt, ohne Multi-Region oder Active-Passive-Failover zu betreiben, ist unehrlich — die Mathematik laesst das auf Single-Region-Hardware nicht zu. Default-Empfehlungen: **99,9 %** fuer Single-Region-Service (43,8 min Downtime/Monat), **99,95 %** mit dokumentiertem Failover (21,9 min/Monat), **99,99 %** nur mit Multi-Region + regelmaessigen Chaos-Tests (4,4 min/Monat). Hoeher ist eine Luege, bis das Gegenteil bewiesen ist.

**Mess-Methode:** Die drei SLIs lesen aus dem Prometheus-Metrics-Endpoint, der in BOO-14 (`observability.md` §Metrics-Endpoint) bereits angelegt wurde. Keine separaten Mess-Tools — Single Source of Truth.

```markdown
# SLO — {{SERVICE_NAME}}

> Architektur-Artefakt nach BOO-25 (Saeule 6 Reliability). Dieses Dokument
> definiert die gemessene Reliability-Erwartung. Aenderungen sind ADR-pflichtig
> und werden im Commit-Message begruendet ("SLO erhoeht von X auf Y weil ...").

## Service

- **Name:** {{SERVICE_NAME}}
- **Owner:** {{OWNER}}
- **Stack:** {{STACK}}
- **Metrics-Endpoint:** `/metrics` (Port {{PORT}}) — siehe `observability.md`
- **Status:** draft | active | deprecated

## Service Level Objectives

| SLI | Mess-Methode (PromQL) | Ziel (SLO) | Mess-Fenster |
|-----|----------------------|-----------|--------------|
| **Availability** | `(1 - rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])) * 100` | >= 99.9 % | rolling 30d |
| **Latency P95** | `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))` | < 1.0 s | rolling 30d |
| **Error Rate** | `rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100` | < 0.5 % | rolling 30d |

## Error-Budget-Tabelle

Bei SLO 99.9 % Availability = 0.1 % Error-Budget = **43,8 min Downtime / 30 Tage**.

| Quartal | Budget total | Verbraucht | Verbleibend | Status |
|---------|-------------|------------|-------------|--------|
| Q1 {{YEAR}} | 131,4 min | 0 min | 131,4 min | green |
| Q2 {{YEAR}} | 131,4 min | — | — | — |
| Q3 {{YEAR}} | 131,4 min | — | — | — |
| Q4 {{YEAR}} | 131,4 min | — | — | — |

**Verbrauch-Tracker:** Jeder Incident, der Availability unter den SLO-Wert druckt, wird hier eingetragen — Datum, Dauer, Ursache, ADR-Link.

| Datum (UTC) | Dauer | Ursache | ADR / Postmortem |
|-------------|-------|---------|------------------|
| — | — | — | — |

## Review-Cadence

- **Monatlich** in `/sprint-review` — Budget-Verbrauch ablesen, gegen Ziel halten.
- **Bei Budget < 25 % verbleibend:** naechstes Sprint-Slot fuer Reliability-Arbeit reservieren (kein Feature).
- **Bei Budget < 0:** Feature-Freeze bis Budget wiederhergestellt — siehe Schrader, Code Crash, Kap. 4 §Run the System.

## Verlauf / Aenderungen

- {{YYYY-MM-DD}} — Initial-Setup ueber `/bootstrap` Phase 4.4h.
```

**Anti-Patterns:**
- KEIN SLO ohne Error-Budget — der SLO-Wert allein ist Marketing, das Budget ist der Hebel.
- KEIN SLO ohne Mess-Methode (PromQL/Query) — sonst wird die Zahl gefuehlt, nicht gemessen.
- KEIN 99.99 %-SLO ohne Multi-Region und Chaos-Tests — die Hardware-Mathematik gibt das auf einer Single-Region nicht her.
- KEIN Auto-Update der Verbrauch-Tabelle aus Monitoring — Incident-Eintraege brauchen Operator-Review (Ursache + ADR-Link). Auto-Append macht aus dem Manifest ein Log und niemand liest es.

---

## lib/idempotency.{js,py} (BOO-25 — Idempotency-Key-Middleware)

**Schreibende Endpunkte gegen Wiederholung absichern.** Liest den Header `Idempotency-Key` (UUID v4), persistiert Request-Hash + Response in Redis (Default) oder Postgres (Fallback) fuer 24h TTL. Bei Wiederholung mit gleichem Key: cached Response zurueck (kein erneutes Schreiben). Bei gleichem Key + abweichendem Body: HTTP 422 (Conflict — Client hat Bug).

> [!important] Idempotency NUR fuer schreibende Endpunkte
> Anwenden auf POST / PUT / PATCH / DELETE. NICHT auf GET — GET ist per HTTP-Spec idempotent, ein Layer ist Overhead ohne Nutzen. Auch nicht global fuer alle Routes — nur dort, wo Side-Effects passieren (Datenbank-Writes, externe API-Calls, Geld-Bewegung).

**Stack-Scope:** Node.js (a/c) als Express-Middleware, Python (d) als FastAPI-Dependency. Frontend (b) hat keinen serverseitigen Endpoint — Backend uebernimmt. Stack e: Operator-Choice, gleiche Logik in eigenes Framework portieren.

### Node.js — `lib/idempotency.js`

**Devdep:**

```bash
npm install redis
```

(redis 5.x — offizieller Node-Client, siehe `redis/node-redis` README.)

```javascript
// lib/idempotency.js
// BOO-25 Idempotency-Key-Middleware fuer Express.
// Wird NUR auf schreibenden Routes (POST/PUT/PATCH/DELETE) registriert,
// nicht global. Beispiel: app.post('/orders', idempotency(), createOrder)

const crypto = require('node:crypto');
const { createClient } = require('redis');

const TTL_SECONDS = 24 * 60 * 60; // 24h
const KEY_PREFIX = 'idem:';
const UUID_V4_REGEX =
  /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

let _redis;
async function getRedis() {
  if (!_redis) {
    _redis = createClient({ url: process.env.REDIS_URL || 'redis://localhost:6379' });
    _redis.on('error', (err) => console.error('[idempotency] redis error', err));
    await _redis.connect();
  }
  return _redis;
}

function hashBody(body) {
  return crypto
    .createHash('sha256')
    .update(JSON.stringify(body || {}))
    .digest('hex');
}

function idempotency() {
  return async function idempotencyMiddleware(req, res, next) {
    const key = req.header('Idempotency-Key');
    if (!key) {
      return res.status(400).json({
        error: 'idempotency_key_required',
        message: 'Idempotency-Key header is required for write operations',
      });
    }
    if (!UUID_V4_REGEX.test(key)) {
      return res.status(400).json({
        error: 'idempotency_key_invalid',
        message: 'Idempotency-Key must be UUID v4',
      });
    }

    const redis = await getRedis();
    const storeKey = `${KEY_PREFIX}${key}`;
    const bodyHash = hashBody(req.body);
    const cached = await redis.get(storeKey);

    if (cached) {
      const entry = JSON.parse(cached);
      if (entry.bodyHash !== bodyHash) {
        return res.status(422).json({
          error: 'idempotency_key_conflict',
          message: 'Same Idempotency-Key used with different request body',
        });
      }
      // Replay cached response.
      res.status(entry.status).set(entry.headers).send(entry.body);
      return;
    }

    // Capture response to cache after handler runs.
    const originalSend = res.send.bind(res);
    res.send = function captureSend(body) {
      // Persist async, do not block response.
      redis
        .setEx(
          storeKey,
          TTL_SECONDS,
          JSON.stringify({
            bodyHash,
            status: res.statusCode,
            headers: res.getHeaders(),
            body: typeof body === 'string' ? body : JSON.stringify(body),
          }),
        )
        .catch((err) => console.error('[idempotency] store error', err));
      return originalSend(body);
    };

    next();
  };
}

module.exports = { idempotency };
```

### Python — `lib/idempotency.py`

**Devdep:**

```toml
# pyproject.toml
[project]
dependencies = [
  "redis>=5.0",
  "fastapi>=0.110",
]
```

(redis-py >=5.0 — offizieller Python-Client mit asyncio-Support.)

```python
# lib/idempotency.py
# BOO-25 Idempotency-Key-Dependency fuer FastAPI.
# Wird NUR an schreibenden Routes (POST/PUT/PATCH/DELETE) gebunden,
# nicht global. Beispiel:
#     @app.post("/orders", dependencies=[Depends(idempotency)])
#     async def create_order(...): ...

import hashlib
import json
import os
import re
from typing import Any

import redis.asyncio as redis_asyncio
from fastapi import HTTPException, Request

TTL_SECONDS = 24 * 60 * 60  # 24h
KEY_PREFIX = "idem:"
UUID_V4_REGEX = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
    re.IGNORECASE,
)

_redis: redis_asyncio.Redis | None = None


async def _get_redis() -> redis_asyncio.Redis:
    global _redis
    if _redis is None:
        url = os.environ.get("REDIS_URL", "redis://localhost:6379")
        _redis = redis_asyncio.from_url(url, decode_responses=True)
    return _redis


def _hash_body(body: Any) -> str:
    payload = json.dumps(body, sort_keys=True, default=str).encode()
    return hashlib.sha256(payload).hexdigest()


async def idempotency(request: Request) -> None:
    """FastAPI dependency. Raises HTTPException on conflict, replays on hit."""
    key = request.headers.get("Idempotency-Key")
    if not key:
        raise HTTPException(
            status_code=400,
            detail={
                "error": "idempotency_key_required",
                "message": "Idempotency-Key header is required for write operations",
            },
        )
    if not UUID_V4_REGEX.match(key):
        raise HTTPException(
            status_code=400,
            detail={
                "error": "idempotency_key_invalid",
                "message": "Idempotency-Key must be UUID v4",
            },
        )

    body_bytes = await request.body()
    try:
        body_json = json.loads(body_bytes) if body_bytes else {}
    except json.JSONDecodeError:
        body_json = {"_raw": body_bytes.decode(errors="replace")}
    body_hash = _hash_body(body_json)

    r = await _get_redis()
    store_key = f"{KEY_PREFIX}{key}"
    cached = await r.get(store_key)

    if cached:
        entry = json.loads(cached)
        if entry["bodyHash"] != body_hash:
            raise HTTPException(
                status_code=422,
                detail={
                    "error": "idempotency_key_conflict",
                    "message": "Same Idempotency-Key used with different request body",
                },
            )
        # Replay: stash cached response on request.state — handler reads it.
        request.state.idempotency_replay = entry
        return

    # First seen — handler runs; response capture happens in middleware/wrapper.
    request.state.idempotency_key = store_key
    request.state.idempotency_body_hash = body_hash


async def store_response(request: Request, status: int, body: Any) -> None:
    """Call from a response middleware after the handler returns."""
    store_key = getattr(request.state, "idempotency_key", None)
    body_hash = getattr(request.state, "idempotency_body_hash", None)
    if not store_key or not body_hash:
        return
    r = await _get_redis()
    await r.setex(
        store_key,
        TTL_SECONDS,
        json.dumps({
            "bodyHash": body_hash,
            "status": status,
            "body": body if isinstance(body, str) else json.dumps(body),
        }),
    )
```

**Anti-Patterns:**
- KEIN Idempotency-Layer fuer GET — GET ist per HTTP-Spec idempotent, der Layer ist Overhead ohne Nutzen.
- KEIN globaler Layer fuer alle Routes — nur fuer schreibende Endpunkte mit Side-Effects (DB-Writes, externe Calls, Geld). Sonst Cache-Pollution und 422-Konflikte bei harmlosen Read-Replays.
- KEIN Speicher in Process-Memory (`Map`, `dict`) — geht beim Restart verloren, skaliert nicht ueber mehrere Instanzen. Redis oder Postgres, sonst gar nicht.
- KEINE TTL > 7 Tage — Keys werden ewig gespeichert, Speicher waechst monoton. 24h ist der Default, max 7d mit Begruendung.
- KEINE eigene UUID-Generierung server-seitig — Idempotency-Key kommt vom Client, sonst ist die ganze Idee kaputt (Client kann nicht erkennen ob ein Retry ein neuer oder ein wiederholter Call ist).

---

## lib/retry.{js,py} (BOO-25 — Retry-Helper mit exponential Backoff + Jitter)

**Transiente Fehler werden begrenzt automatisch wiederholt.** Default: max 3 Retries, exponential Backoff (Faktor 2), Jitter zur Vermeidung von Thundering Herd. **Hard Constraint:** Retry NUR bei transienten Fehlern (5xx, Timeout, Connection-Reset). KEIN Retry bei 4xx (Client-Fehler), 422 (Validation) oder Idempotency-Konflikten — die werden durch Wiederholung nicht besser.

> [!important] Retry-Policy ist Status-Code-spezifisch
> Ein 500 lohnt einen Retry (Server-Hickup). Ein 400 nicht (Client-Bug — derselbe Request scheitert wieder). Ein 422 schon gar nicht (Validation-Fehler — der Body ist falsch, nicht das Netzwerk). Der Wrapper unten filtert explizit, was retry-faehig ist.

### Node.js — `lib/retry.js`

**Devdep:**

```bash
npm install p-retry
```

(p-retry 8.x — Wrapper um `retry` mit AbortSignal-Support. ESM-only, daher in Node.js-Projekten mit `import` oder dynamischem `require`.)

```javascript
// lib/retry.js
// BOO-25 Retry-Wrapper mit exponential Backoff + Jitter.
// Default: 3 Retries, factor=2, minTimeout=100ms, maxTimeout=10000ms, randomize=true.
// HARD CONSTRAINT: nur transiente Fehler werden retried — siehe shouldRetry().

// p-retry ist ESM-only — in CommonJS via dynamic import.
const TRANSIENT_STATUS = new Set([408, 429, 500, 502, 503, 504]);

function isTransientError(err) {
  // Network / timeout
  if (err && (err.code === 'ECONNRESET' || err.code === 'ETIMEDOUT' || err.code === 'ENOTFOUND')) {
    return true;
  }
  // HTTP-status-coded errors (axios/fetch wrapper convention)
  const status = err?.response?.status ?? err?.status;
  if (typeof status === 'number') {
    return TRANSIENT_STATUS.has(status);
  }
  // Unknown -> conservative: do not retry, surface immediately.
  return false;
}

async function withRetry(fn, options = {}) {
  const { default: pRetry, AbortError } = await import('p-retry');
  const opts = {
    retries: options.retries ?? 3,
    factor: options.factor ?? 2,
    minTimeout: options.minTimeout ?? 100,
    maxTimeout: options.maxTimeout ?? 10000,
    randomize: options.randomize ?? true, // Jitter
    onFailedAttempt: options.onFailedAttempt,
  };

  return pRetry(async () => {
    try {
      return await fn();
    } catch (err) {
      // Non-transient -> AbortError stops retry loop immediately.
      if (!isTransientError(err)) {
        throw new AbortError(err);
      }
      throw err;
    }
  }, opts);
}

module.exports = { withRetry, isTransientError };
```

### Python — `lib/retry.py`

**Devdep:**

```toml
# pyproject.toml
[project]
dependencies = [
  "tenacity>=9.0",
]
```

(tenacity >=9.0 — siehe `jd/tenacity` README, aktuelle Major-Linie.)

```python
# lib/retry.py
# BOO-25 Retry-Wrapper mit exponential Backoff + Jitter via tenacity.
# Default: 3 Versuche, exponential mit Multiplikator 0.1s, max 10s.
# HARD CONSTRAINT: nur transiente Fehler werden retried — siehe is_transient().

import logging
from typing import Any, Callable

import httpx
from tenacity import (
    retry,
    retry_if_exception,
    stop_after_attempt,
    wait_random_exponential,
)

log = logging.getLogger(__name__)
TRANSIENT_STATUS = {408, 429, 500, 502, 503, 504}


def is_transient(exc: BaseException) -> bool:
    """True if the exception represents a retryable, transient failure."""
    # Network / timeout layer
    if isinstance(exc, (httpx.ConnectError, httpx.ReadTimeout, httpx.WriteTimeout)):
        return True
    # HTTP-status-coded layer
    if isinstance(exc, httpx.HTTPStatusError):
        return exc.response.status_code in TRANSIENT_STATUS
    # Unknown -> conservative: do not retry.
    return False


def with_retry(
    fn: Callable[..., Any] | None = None,
    *,
    attempts: int = 3,
    multiplier: float = 0.1,
    max_wait: float = 10.0,
):
    """Decorator factory: retry transient failures with exponential backoff + jitter."""
    decorator = retry(
        stop=stop_after_attempt(attempts),
        wait=wait_random_exponential(multiplier=multiplier, max=max_wait),
        retry=retry_if_exception(is_transient),
        before_sleep=lambda rs: log.warning(
            "retry attempt=%s waiting=%.2fs reason=%s",
            rs.attempt_number,
            rs.next_action.sleep if rs.next_action else 0,
            rs.outcome.exception() if rs.outcome else None,
        ),
        reraise=True,
    )
    if fn is None:
        return decorator
    return decorator(fn)
```

**Anti-Patterns:**
- KEIN unendlicher Retry — Default ist 3 Versuche, hart begrenzt. "Retry bis es klappt" macht aus einem 30-Sekunden-Outage einen 3-Stunden-Outage und blockt den Caller.
- KEIN Retry ohne Jitter — alle Clients retryen synchron, der wieder hochfahrende Backend-Server bekommt N-faches Load-Spike (Thundering Herd).
- KEIN Retry bei 4xx/422 — Client-Fehler werden durch Wiederholung nicht besser. Der Status-Code-Filter ist Pflicht.
- KEIN Retry bei Idempotency-Key-Konflikten (HTTP 422 aus `lib/idempotency.{js,py}`) — der Server sagt explizit "anderer Body mit gleichem Key", Wiederholung verschlimmert nichts, aber loest auch nichts.
- KEIN Retry-Wrapper um nicht-idempotente Operationen ohne Idempotency-Key — sonst entsteht beim ersten Retry der Doppel-Charge / die Doppel-Buchung. Retry und Idempotency sind ein Paar.

---

## lib/circuit-breaker.{js,py} (BOO-25 — Circuit-Breaker-Wrapper pro externe Abhaengigkeit)

**Externe Abhaengigkeit failed schnell statt langsam.** Ein Circuit Breaker um jeden Aufruf zu DB / externer API / Message Bus. Drei Zustaende: **Closed** (Normal), **Open** (Fehler erkannt — sofortiger Fail ohne Call), **Half-Open** (nach Reset-Timeout: Test-Anfragen, ob die Abhaengigkeit wieder lebt).

> [!important] Pro externe Abhaengigkeit ein eigener Breaker
> KEIN globaler Breaker fuer "alles externe". Wenn die DB langsam ist und der Auth-Service schnell ist, soll Auth nicht mit-failen, weil DB den globalen Breaker oeffnet. Pattern: `dbBreaker`, `paymentApiBreaker`, `s3Breaker` — separate Instanzen mit eigenen Schwellen. Schwellen pro Abhaengigkeit anpassen: DB darf langsamer sein als Auth-Service.

> [!note] Bulkhead-Pattern als Folge
> Ein Breaker pro Abhaengigkeit ist die Light-Variante eines Bulkheads — die Abhaengigkeiten sind voneinander isoliert. Echtes Bulkhead-Pattern (separate Thread-Pools / Connection-Pools pro Abhaengigkeit) ist eine Stufe darueber und nicht Teil von BOO-25 — Folge-Issue, wenn der Service mehrere parallele Pools rechtfertigt.

### Node.js — `lib/circuit-breaker.js`

**Devdep:**

```bash
npm install opossum
```

(opossum 9.x — siehe `nodeshift/opossum` README, aktuelle Major-Linie.)

```javascript
// lib/circuit-breaker.js
// BOO-25 Circuit-Breaker-Wrapper. Eine Instanz pro externer Abhaengigkeit.
// Beispiel:
//   const dbBreaker = createBreaker(callDb, { name: 'db', timeout: 2000 });
//   const result = await dbBreaker.fire(query);

const CircuitBreaker = require('opossum');

const DEFAULTS = {
  timeout: 3000,                  // ms — wenn Call laenger braucht, gilt er als Fehler
  errorThresholdPercentage: 50,   // % Fehler -> Open
  resetTimeout: 30000,            // ms in Open, dann Half-Open
  volumeThreshold: 10,            // min Calls bevor Fehler-Quote zaehlt
};

function createBreaker(fn, options = {}) {
  const name = options.name || fn.name || 'anonymous';
  const breaker = new CircuitBreaker(fn, { ...DEFAULTS, ...options });

  breaker.on('open', () =>
    console.warn(`[circuit-breaker] OPEN dependency=${name}`));
  breaker.on('halfOpen', () =>
    console.info(`[circuit-breaker] HALF_OPEN dependency=${name}`));
  breaker.on('close', () =>
    console.info(`[circuit-breaker] CLOSED dependency=${name}`));
  breaker.on('reject', () =>
    console.warn(`[circuit-breaker] REJECT dependency=${name} (open, fail-fast)`));

  // Fallback ist Operator-Choice — pro Breaker setzen falls Graceful Degradation moeglich.
  // Beispiel: dbBreaker.fallback(() => cachedResult);
  return breaker;
}

module.exports = { createBreaker };
```

### Python — `lib/circuit-breaker.py`

**Devdep:**

```toml
# pyproject.toml
[project]
dependencies = [
  "pybreaker>=1.0",
  # Fuer asyncio-Stacks alternativ: "aiobreaker>=1.2" (eigener Wrapper notwendig)
]
```

(pybreaker 1.x — siehe `danielfm/pybreaker` README. Fuer reine asyncio-Workloads ist `aiobreaker` eine separate Lib mit kompatibler API; Operator-Choice.)

```python
# lib/circuit_breaker.py
# BOO-25 Circuit-Breaker-Wrapper. Eine Instanz pro externer Abhaengigkeit.
# Beispiel:
#     db_breaker = create_breaker(name="db", fail_max=5, reset_timeout=30)
#
#     @db_breaker
#     def query_db(...): ...

import logging
from typing import Iterable

import pybreaker

log = logging.getLogger(__name__)


class _Listener(pybreaker.CircuitBreakerListener):
    def __init__(self, name: str) -> None:
        self.name = name

    def state_change(self, cb, old_state, new_state):
        log.warning(
            "circuit_breaker dependency=%s old=%s new=%s",
            self.name,
            getattr(old_state, "name", old_state),
            getattr(new_state, "name", new_state),
        )

    def failure(self, cb, exc):
        log.info("circuit_breaker dependency=%s failure=%r", self.name, exc)


def create_breaker(
    name: str,
    *,
    fail_max: int = 5,
    reset_timeout: int = 30,
    exclude: Iterable[type[BaseException]] = (),
) -> pybreaker.CircuitBreaker:
    """One breaker per external dependency. Schwellen je nach Abhaengigkeit anpassen."""
    return pybreaker.CircuitBreaker(
        fail_max=fail_max,
        reset_timeout=reset_timeout,
        exclude=list(exclude),
        listeners=[_Listener(name)],
        name=name,
    )
```

**Graceful Degradation als Fallback-Hook:** Wenn der Breaker `Open` ist, geht jeder Call sofort in den Fallback. Der Fallback ist Operator-Choice pro Abhaengigkeit:

- **Cache-Read** statt DB-Read (Stale-Daten ok kurz).
- **Default-Wert** statt externer API (Beispiel: leere Empfehlungen statt 500).
- **Queue + Async-Verarbeitung** statt Sync-Call (Anfrage spaeter zustellen).
- **HTTP 503 + `Retry-After`-Header** wenn keine andere Strategie passt — mindestens dem Client signalisieren.

**Anti-Patterns:**
- KEIN globaler Breaker fuer alle externen Calls — siehe Header-Callout. Pro Abhaengigkeit eine Instanz.
- KEIN Breaker fuer interne Funktion-Calls (in-Process) — Breaker schuetzen vor langsamen externen Aufrufen, nicht vor lokalen Fehlern. Lokale Fehler sind Bugs und sollen sofort sichtbar sein.
- KEINE einheitliche Konfig fuer alle Breaker — DB darf langsamer sein als Auth-Service. Schwellen pro Abhaengigkeit, dokumentiert im Code.
- KEIN Breaker ohne Logging — der State-Wechsel (Closed -> Open -> Half-Open) muss in den Logs erscheinen, sonst ist der Breaker ein Black Box. Logging via Pino (Node) / structlog (Python) aus BOO-14.
- KEIN Breaker ohne Fallback und ohne 503-Antwort — sonst ist "Open" fuer den Client ununterscheidbar von "Service kaputt". Mindestens 503 mit `Retry-After` zurueckgeben.

---

## Decisions/ADR-Template

Vorlage fuer eine einzelne Entscheidungs-Datei unter `Decisions/` (Obsidian) oder `docs/decisions/` (Repo-only).

```markdown
---
title: "[Kurztitel der Entscheidung]"
datum: {{TODAY}}
status: offen  # offen | entschieden | verworfen
type: entscheidung  # entscheidung | fachliche-entscheidung
---

# ADR-XX: [Titel]

## Kontext

[Was ist der Hintergrund? Warum muss diese Entscheidung getroffen werden?]

## Optionen

1. **[Option A]** — [Kurzbeschreibung + Pro/Contra]
2. **[Option B]** — [Kurzbeschreibung + Pro/Contra]

## Entscheidung

[Welche Option wurde gewaehlt und warum?]

## Konsequenzen

- [Was aendert sich durch diese Entscheidung?]
- [Welche Folge-Issues entstehen?]
```

---

### `sonar-project.properties (BOO-5 — SonarQube Cloud Config)`

Wird von `/bootstrap` Block D §D.5 generiert wenn SonarQube Cloud aktiviert.
Platzierung: Projekt-Root.

```properties
# SonarQube Cloud — generiert von /bootstrap BOO-5
# Anpassen: sonar.projectKey und sonar.organization auf deine GitHub-Org und Repo setzen.

sonar.projectKey={{GITHUB_ORG}}_{{REPO_NAME}}
sonar.organization={{GITHUB_ORG}}

# Quellen — Node/Python Standard:
sonar.sources=src
sonar.exclusions=node_modules/**,dist/**,build/**,coverage/**,.semgrep/**

# Optional — Coverage-Report einbinden (aus /implement Coverage-Gate BOO-15):
# Node (Vitest/Jest):
#   sonar.javascript.lcov.reportPaths=coverage/lcov.info
# Python (pytest-cov):
#   sonar.python.coverage.reportPaths=coverage.xml

# Optional — Test-Quellen:
# sonar.tests=tests
# sonar.test.exclusions=**/*.test.js,**/*.spec.js
```

**Platzhalter ersetzen:**
| Platzhalter | Wert |
|-------------|------|
| `{{GITHUB_ORG}}` | GitHub-Organisations- oder Nutzer-Name |
| `{{REPO_NAME}}` | Repository-Name |

**Hinweis:** Projekt-Key und Organisation muessen exakt mit dem SonarCloud-Projekt uebereinstimmen (angelegt unter https://sonarcloud.io).

---

### `.github/workflows/sonar.yml (BOO-5 — SonarQube Cloud CI Gate)`

Wird von `/bootstrap` Block D §D.5 generiert wenn SonarQube Cloud aktiviert.
Voraussetzung: `SONAR_TOKEN` als GitHub Repository Secret (via `gh secret set SONAR_TOKEN`).

```yaml
# SonarQube Cloud CI Gate — generiert von /bootstrap BOO-5
# Trigger: Push auf main + alle Pull Requests

name: SonarQube Cloud

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  sonarqube:
    name: SonarQube Scan
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Pflicht fuer SonarQube Blame-Analyse

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v4
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

**Erweiterung mit Coverage (empfohlen nach BOO-15 Coverage-Gate):**

Node.js (Vitest):
```yaml
      - name: Install dependencies
        run: npm ci

      - name: Run tests with coverage
        run: npx vitest run --coverage

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v4
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```
Zusatz in `sonar-project.properties`: `sonar.javascript.lcov.reportPaths=coverage/lcov.info`

Python (pytest):
```yaml
      - name: Install dependencies
        run: pip install -r requirements.txt pytest pytest-cov

      - name: Run tests with coverage
        run: pytest --cov=src --cov-report=xml

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v4
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```
Zusatz in `sonar-project.properties`: `sonar.python.coverage.reportPaths=coverage.xml`

`type: fachliche-entscheidung` — fuer fachliche/regulatorische ADRs (z.B. "warum FIFO-Accounting", "warum strikte KYC-Regel X"). `/sprint-review` zaehlt beide Typen in der Decision-Rate.

---

### `.claude/sensitive-paths.json (BOO-18 — Mandatory Human Review)`

Wird von `/bootstrap` Phase 4.4i angelegt wenn der Operator sensible Pfade konfiguriert.
Platzierung: `.claude/sensitive-paths.json` (im `.gitignore` NICHT — explizit committen für Audit-Trail).

```json
{
  "patterns": [
    "auth/**",
    "authn/**",
    "authz/**",
    "payment/**",
    "billing/**",
    "**/*credential*",
    "**/*personal*",
    "**/*pii*",
    "**/*gdpr*",
    "n8n/**",
    "workflows/**/*.json",
    "infra/**",
    "**/*.tf",
    "**/*.tfvars",
    "config/production/**",
    ".env.production",

    "**/eslint.config.*",
    "**/.eslintrc*",
    "**/ruff.toml",
    "**/pyproject.toml",
    "**/.semgrep.yml",
    "**/.semgrep.yaml",
    "**/phpstan.neon",
    "**/phpstan.neon.dist",
    "**/.coveragerc",
    "**/jest.config.*",
    "**/vitest.config.*",
    "**/sonar-project.properties"
  ],
  "review_required_by": ["{{OPERATOR_NAME}}"],
  "human_review_reminder": "Diese Story berührt sensitive Pfade — bitte Zeile-für-Zeile prüfen, nicht nur Plan freigeben."
}
```

> **Gruppe „Gate-Config / Quality-Threshold" (BOO-176):** Die letzten 12 Patterns
> (`**/eslint.config.*` … `**/sonar-project.properties`) sind **Gate-Config-Dateien** — sie
> definieren die Qualitäts-Schwelle (Linter-Regeln, Coverage-Schwelle, PHPStan-Level,
> Semgrep-Regeln). **Jede** Änderung daran löst einen Human-Review-Block (`review-ok`) aus:
> Gate-Configs definieren die Qualitäts-Schwelle — Änderung nur mit Operator-Freigabe (BOO-176).
> Der Agent fixt Code ✅ — er senkt nicht die Messlatte ❌. Ergänzend flaggt der
> `gate-configs.yml`-Bodyguard verdächtige Regel-Deaktivierungen schon beim Schreiben.

**Platzhalter ersetzen:**
| Platzhalter | Wert |
|-------------|------|
| `{{OPERATOR_NAME}}` | GitHub-Handle oder Name des verantwortlichen Reviewers |

**Hinweis:** Die Pattern-Liste ist ein Minimal-Default. Die Non-Code-Patterns (`n8n/**`, `workflows/**/*.json`, `infra/**`, `**/*.tf`, `**/*.tfvars`, `config/production/**`, `.env.production`) wurden mit BOO-68 hinzugefuegt — sie sind Pflicht, wenn das Projekt Non-Code-Stories (workflow / infrastructure / config) erwartet. Die Gate-Config-Patterns (`**/eslint.config.*` … `**/sonar-project.properties`) kamen mit BOO-176 hinzu — sie sind Pflicht für JS/TS- und Python-Stacks (die abgedeckten Stacks); nicht-abgedeckte Stacks tragen ihre Gate-Configs via Stack-Runbook (BOO-178) nach. Operator ergänzt projektspezifische sensitive Pfade (z.B. `src/api/**` für kritische API-Endpunkte, `stripe/**` für Payment-Integration).

### `.claude/personal-data-paths.json (BOO-69 — Personal-Data-Paths-Gate)`

Wird von `/bootstrap` Phase 4.4n angelegt, wenn der Operator das Privacy-Add-on aktiviert hat.
Platzierung: `.claude/personal-data-paths.json` (analog zu sensitive-paths.json, NICHT in `.gitignore` — Audit-Trail-Pflicht).

```json
{
  "patterns": [
    "**/user*",
    "**/customer*",
    "**/profile*",
    "**/*pii*",
    "**/auth/profile/**",
    "**/billing/**",
    "**/onboarding/**",
    "**/consent/**",
    "**/tracking/**",
    "**/analytics/**",
    "db/migrations/*personal*",
    "db/migrations/*user*",
    "**/email-templates/**"
  ],
  "review_required_by": ["{{OPERATOR_NAME}}"],
  "privacy_review_reminder": "Diese Story berührt personenbezogene Daten — DPO REVIEW-Modus empfohlen (`/dpo --mode review`), oder manuelle Pruefung mit `privacy-ok`.",
  "dpo_skill_path": "~/.claude/skills/dpo/"
}
```

**Platzhalter ersetzen:**

| Platzhalter | Wert |
|-------------|------|
| `{{OPERATOR_NAME}}` | GitHub-Handle oder Name des verantwortlichen Reviewers (kann mit `sensitive-paths.json` identisch sein) |

**Hinweis:** Die Pattern-Liste ist ein Minimal-Default. Operator ergaenzt projektspezifische Personal-Data-Pfade (z.B. `src/auth/**` fuer Authentifizierung mit PII, `webhooks/stripe/**` fuer Zahlungsdaten, `crm/**` fuer Kundendaten). Bei Ueberschneidung mit `sensitive-paths.json` (z.B. `**/*pii*` taucht in beiden auf): beide Gates greifen — erst `review-ok`, dann `privacy-ok`. Doppel-Bestaetigung ist beabsichtigt, weil security und privacy unterschiedliche Disziplinen pruefen.

---

## .claude/settings.local.json (BOO-203 — Bash-Auto-Allow für Sprint-Run-Gates)

Wird von `/bootstrap` angelegt, wenn der Operator den autonomen Sprint-Lauf (`/sprint-run` 2.0.0 mit `/goal`-Engine) nutzen will. Platzierung: `.claude/settings.local.json` (lokale, **nicht** committete Operator-Settings — gehoert in `.gitignore`).

**Zweck:** `/sprint-run` ueberprueft diese Allowlist als **erste der drei Sicherheits-Voraussetzungen** vor dem `/goal`-Aufruf. `/goal` und seine native Subagents fahren die Quality-Gates unbeaufsichtigt — ohne die Allowlist blockiert jede Gate-Ausfuehrung an einem Permission-Prompt. Die Eintraege folgen dem realen Claude-Code-Format: `permissions.allow` ist eine Liste von `Bash(<pattern>)`-Tools mit Prefix-Match (`:*` = beliebige Argumente).

```json
{
  "permissions": {
    "allow": [
      "Bash(semgrep:*)",
      "Bash(npx semgrep:*)",
      "Bash(eslint:*)",
      "Bash(npx eslint:*)",
      "Bash(pytest:*)",
      "Bash(python -m pytest:*)",
      "Bash(ruff:*)",
      "Bash(gh run watch:*)",
      "Bash(gh run view:*)",
      "Bash(gh run list:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(git worktree:*)",
      "Bash(git merge:*)",
      "Bash(git branch:*)"
    ]
  }
}
```

**Sicherheits-Hinweise:**

- **KEINE Secrets** in dieser Datei — sie enthaelt ausschliesslich Bash-Pattern-Allowlists, keine Tokens/Keys.
- **Bewusst eng gefasst:** Nur die Gate- und Git-Mechanik-Commands aus dem Sprint-Lauf. **Kein** `Bash(*)`-Wildcard — das wuerde die Allowlist sinnlos machen und ist ein Anti-Pattern.
- **`git push`** ist enthalten, weil der Story-Subagent den Feature-Branch pushen muss (Remote-CI). Der Merge nach `main` laeuft ueber `git merge` / PR — `main` bleibt durch die Pre-Flight-Checks (clean tree) und die Gate-Assertion geschuetzt.
- **Lokal, nicht committet:** `settings.local.json` ist Operator-spezifisch (Allowlist-Toleranz kann pro Maschine variieren) und gehoert in `.gitignore`. Die committete `.claude/settings.json` traegt nur die projektweiten Hooks (spec-gate, doc-version-sync, pre-edit-bodyguard).
- **Stack-Anpassung:** Python-only-Projekte koennen die ESLint-Zeilen weglassen, Node-only die `pytest`/`ruff`-Zeilen. Die `semgrep`-, `gh run`- und `git`-Zeilen sind stack-uebergreifend Pflicht.
