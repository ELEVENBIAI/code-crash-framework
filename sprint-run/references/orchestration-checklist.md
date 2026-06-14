# Orchestration-Checklist — Sprint-Pre-Flight + Pre-/goal-Checks

Referenz zu `/sprint-run` Schritt 1 (Sprint-Pre-Flight, HARD GATE), Schritt 2 (drei
Sicherheits-Voraussetzungen) und Schritt 4 (Vorbereitung pro Story). `/goal` darf erst gestartet
werden, wenn **alle** Pre-Flight-Punkte **und** alle drei Sicherheits-Voraussetzungen gruen sind.

## Sprint-Pre-Flight (Schritt 1) ⛔

| Check | Pass-Kriterium | Bei Verstoss |
|---|---|---|
| Backlog priorisiert | `/backlog` liefert geordnete Kandidaten (`Todo`/`Backlog`, Reihenfolge) | STOPP — erst `/backlog` fahren |
| Spec pro Story | `specs/<ISSUE>.md` existiert (Spec-Gate) | Story aus Sprint nehmen / STOPP |
| Schrader-vollstaendig | Insight, Constraints, Erfolgskriterien, Gewuenschtes Ergebnis je ≥20 Zeichen | Story aus Sprint nehmen |
| Execution-Isolation-Block | Spec traegt `execution_mode`, `worktree_strategy`, `write_scopes` | Story aus Sprint nehmen |
| Subagent-Sektion | Spec traegt eine Subagent-Sektion (Quelle der Agent-Definition, Schritt 4.2) | Story aus Sprint nehmen |
| Governance-Gates | `governance_mode` aus CONVENTIONS; sensitive-paths/personal-data konfiguriert | Pause-Verhalten klaeren |
| Quality-Gates verdrahtet | `/quality-gate-audit --trigger pre-sprint` Exit 0 (BOO-183) | STOPP — Audit-Report-Remediation |
| Werkzeug | `git worktree` da, `gh` authentifiziert, `main` clean | STOPP |

> Der Pre-Flight ist die Bedingung dafuer, dass `/goal` danach ohne Rueckfragen laeuft.

## Drei Sicherheits-Voraussetzungen (Schritt 2) ⛔

Direkt vor dem `/goal`-Aufruf. Fehlt eine → `/goal` wird **nicht** gestartet.

| Voraussetzung | Pass-Kriterium | Bei Verstoss |
|---|---|---|
| Bash-Allowlist | `.claude/settings.local.json` hat `permissions.allow` mit `semgrep`/`eslint`/`pytest`/`gh run`/`git` | STOPP — Template aus `bootstrap/references/file-templates.md` (BOO-203) |
| Worktree-Boundary | `execution_isolation=worktree` (CONVENTIONS) | **Abbruch** — native Subagents brauchen Worktree-Isolation |
| Layer-0 Bodyguard | `pre-edit-bodyguard`-Hook in `.claude/settings.json` `hooks` + Datei vorhanden | **Pause** — „Bodyguard nicht aktiv" |

## Vorbereitung pro Story (Schritt 4)

- [ ] Worktree angelegt: `git worktree add ../wt-<ISSUE> -b feat/boo-<n>-<slug>`
- [ ] Arbeitsbaum im Worktree clean
- [ ] Subagent-Definition `.claude/agents/<story>-<agent>.md` aus der Spec-Subagent-Sektion generiert
- [ ] (optional) Linear-Status auf `In Progress` gesetzt

## Was `/goal` uebernimmt (nicht mehr `/sprint-run`)

Die folgende Mechanik gehoert seit 2.0.0 (ADR-4) `/goal`, nicht mehr dem Skill:

- Spawn der native Subagents pro Story (parallel, bis `parallel_story_limit`)
- Gate-Failure-Recovery (Worker fixt → Gate erneut → Evaluator prueft → Loop bis gruen)
- Remote-CI-Wait + Merge nur bei gruener CI
- Post-Story-Gate-Assertion gegen `meta.json` (siehe `gate-assertion.md`)
- Sensitive-Path-/Personal-Data-Pause (siehe `gate-block-handling.md`)
- 80%-Token-Boundary als Teil der Termination (siehe `token-boundary.md`)

## Anti-Pattern

- **Story ohne Spec/Subagent-Sektion in den Sprint nehmen** — `/goal` kann ohne Agent-Definition
  keinen Story-Subagent spawnen. Im Pre-Flight abfangen.
- **`/goal` ohne geprueften `execution_isolation=worktree` starten** — Kollisionsgefahr zwischen
  parallelen Subagents (Ebene 2, siehe `docs/kollisionsschutz-drei-ebenen.md`).
- **Container/Dockerfile fuer den Sprint-Run-Zweck verdrahten** — entfaellt seit 2.0.0 (ADR-4).
- **Einen skill-eigenen Daemon-Loop bauen** — die Ausfuehrungs-Schleife lebt jetzt in `/goal`.
