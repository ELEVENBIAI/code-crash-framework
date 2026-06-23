# {{PROJECT_NAME}} — Developer Onboarding

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}
**Repository:** {{GITHUB_REPO}}

> Ziel dieses Dokuments: Ein voellig fremdes Entwicklungsteam soll das Projekt uebernehmen, lokal starten, die Architektur verstehen und die naechste Story sicher umsetzen koennen.

## Zweck

Dieses Onboarding ist das Uebergabe-Artefakt fuer Menschen und KI-gestuetzte Entwicklerumgebungen. Es ist bewusst tool-neutral: Ein Team soll mit Claude Code, Codex, Cursor, GitHub Copilot, Google Antigravity oder einem klassischen Editor/Terminal arbeitsfaehig werden, ohne implizites Vorwissen aus frueheren Chats.

## Single Sources of Truth

| Artefakt | Zweck |
|---|---|
| `{{PROJECT_HUB_PATH}}` | Projekt-Hub: Status, Ziele, Entscheidungen, naechste Schritte |
| `ARCHITECTURE_DESIGN.md` | Zielarchitektur, ADRs, Quality Attributes, Referenzen |
| `SECURITY.md` | Security-Regeln, Secrets, Threat-Surface, Pflichtchecks |
| `CONVENTIONS.md` | Projektvertrag: Governance-Modus, Execution-Isolation, Gates |
| `docs/backlog/` oder Backlog-Tool | priorisierte Arbeit, Abhaengigkeiten, Status |
| `specs/` | lokale Story-Specs und Spec-Packs |

## Projekt in einem Satz

{{PROJECT_ONE_SENTENCE}}

## Zielarchitektur

{{TARGET_ARCHITECTURE_SUMMARY}}

Pflicht: Diese Kurzfassung muss auf `ARCHITECTURE_DESIGN.md` verweisen und darf keine zweite, abweichende Architektur-Wahrheit aufbauen.

## Pflichtlektuere

Vor jeder Umsetzung lesen:

1. `CONVENTIONS.md`
2. `ARCHITECTURE_DESIGN.md`
3. `SECURITY.md`
4. `{{PROJECT_HUB_PATH}}`
5. relevante Story-Spec in `specs/`
6. relevante Runtime-, Tool- oder Komponenten-Dokumentation

## Startpunkt Umsetzung

1. Branch und Arbeitsbaum pruefen: aktueller Branch, offene Diffs, fremde Aenderungen.
2. Backlog-Record oder lokale Story-Spec identifizieren.
3. T0-Preflight aus der Story-Spec ausfuehren.
4. Relevante Dateien lesen, bevor sie geaendert werden.
5. Schreibbereich festlegen, besonders bei Subagents oder paralleler Arbeit.

## Backlog- und Issue-Arbeitsweise

- Jede Umsetzung braucht einen Backlog-Record oder eine Adapter-Story.
- Jede Umsetzung braucht eine lokale Spec (`specs/{{PREFIX}}XXX.md`) oder ein explizit freigegebenes Spec-Pack.
- Abhaengigkeiten und Blocker vor Start pruefen.
- Reihenfolge aus Backlog/Project Hub respektieren; Abweichungen dokumentieren.
- Abschluss erst nach Verifikation, Doku-Impact-Pruefung und Backlog-Kommentar.

## Security

- Keine Secrets in Code, Logs, Commits, Screenshots oder Chat.
- `.env` bleibt lokal und gitignored; nur `.env.example` wird dokumentiert.
- Bei Auth, API, externem Input, Datenfluesse, Dependencies, CI oder Governance immer `SECURITY.md` und die Story-Security-Validation pruefen.
- Sensitive Pfade nur mit dokumentierter Human Review aendern, wenn das Projekt sie definiert.

## Entwicklungsregeln

- Datei erst lesen, dann aendern.
- Bestehende Patterns und lokale Helper verwenden.
- Keine neuen Frameworks, Services oder Runtime-Dependencies ohne Begruendung und Freigabe.
- Neue Dateien in Architektur-/Index-Referenzen eintragen.
- Tests, Linting, Semgrep und Smoke Checks nach Projektkonvention ausfuehren oder begruendet ueberspringen.

## Runtime- und Tool-Hinweise

| Bereich | Hinweis |
|---|---|
| Runtime | {{RUNTIME_HINTS}} |
| Install/Setup | {{SETUP_COMMANDS}} |
| Tests | {{TEST_COMMANDS}} |
| Lint/SAST | {{QUALITY_COMMANDS}} |
| Lokale Services | {{LOCAL_SERVICE_HINTS}} |
| Deploy/Release | {{DEPLOYMENT_HINTS}} |

Toolwechsel-Kontext:

- Claude Code: Skills, Hooks und `.claude/environment.json` beachten, falls vorhanden.
- Codex: `AGENTS.md`, Sandbox/Approvals, Write-Scope und lokale Skill-Anweisungen beachten.
- Cursor/GitHub Copilot/Google Antigravity: Dieses Dokument plus SSoTs als Projektkontext laden; keine Chat-Historie voraussetzen.
- Klassisches Dev-Team: Backlog, Spec, Architektur und Security reichen als Einstieg; fehlende implizite Annahmen hier nachtragen.

## Optionale Add-ons / Naechste Schritte

Optionale, **opt-in** Betriebs-/Governance-Add-ons sind nach dem Setup **nicht** eingerichtet und **bewusst nicht** im Interview abgefragt (Leichtgewicht-Designprinzip). Bei Bedarf im Nachgang ueber das jeweilige Framework-Runbook aktivieren (Hintergrund + Erweiterungs-Regel: HANDBUCH Anhang AT):

- **Unabhaengiger Code-Reviewer (Codex)** — zweiter Review-Pass von einem anderen Anbieter (kein Interessenkonflikt, kein Gate). Runbook `codex-reviewer`.
- **Daily-Bug-Scanner** — getriggerte Repo-Suche nach Bugs/Regressions (Report-only). Runbook `daily-bug-scanner`.
- **Headless-VPS** — Sprints unbeaufsichtigt (`claude -p` als cron/systemd). Runbook `headless-vps`.
- **Developer-VPS vom Handy** — Fernsteuerung via Remote Control + tmux. Runbook `vps-vom-handy`.

Die Liste ist erweiterbar: neue Opt-in-Features kommen hier (und in der Bootstrap-Post-Install-Sektion §7.7) dazu, statt als Interview-Frage.

## Pflegepflicht

Dieses Dokument wird aktualisiert, wenn sich eines der folgenden Dinge aendert:

- Zielarchitektur, ADRs oder zentrale Komponenten
- Runtime, Setup, Test-, Lint- oder Deploy-Kommandos
- Backlog-/Issue-Arbeitsweise, Spec-Pflicht oder Gates
- Security-Regeln, Secrets-Handling oder sensitive Pfade
- Toolwechsel-relevante Hinweise fuer Claude Code, Codex, Cursor, GitHub Copilot, Google Antigravity oder klassische Dev-Teams

Am Ende jeder Implementation prueft `/implement`, ob dieses Onboarding oder der Project Hub aktualisiert werden muss. Wenn keine Aenderung noetig ist, wird das im Abschluss als "Onboarding/Hub: keine Aktualisierung noetig" dokumentiert.
