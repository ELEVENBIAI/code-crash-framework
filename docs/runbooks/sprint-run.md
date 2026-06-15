# Runbook: /sprint-run — einen ganzen Sprint mit `/goal` fahren

> Für Operatoren, die einen Sprint nicht mehr Story für Story von Hand steuern wollen: `/sprint-run` bereitet den Sprint vor (Pre-Flight, Specs, Worktree pro Story, Subagent-Definitionen, Token-Budget) und übergibt die Ausführung an die native Termination-Engine `/goal`. `/goal` orchestriert die Stories parallel als native Subagents, fixt rote Gates, pausiert bei sensiblen Pfaden und terminiert, wenn die Termination-Phrase erfüllt ist. EN: [`sprint-run.en.md`](sprint-run.en.md).

> **Historie:** Bis v0.10.x war `/sprint-run` ein Daemon-Loop (`/implement` pro Story); seit v0.11.0/2.0.0 native `/goal`-Engine — siehe ADR-4.

## Wann dieses Runbook?

Du hast einen priorisierten Backlog mit fertig spezifizierten Stories und willst den Sprint **am Stück** fahren — ohne nach jeder Story manuell die nächste anzustoßen. Das ist der **Sprint-Automations-Fall**. `/sprint-run` konfiguriert den Sprint und ruft `/goal` auf; der unbeaufsichtigte Lauf entsteht dadurch, dass `/goal` nach erfüllten drei Sicherheits-Voraussetzungen plus Allowlist autonom läuft — nicht durch einen skill-eigenen Daemon.

Abgrenzung:
- **Eine** Story gezielt umsetzen → `/implement` direkt (lange Stories können `/goal` als Termination nutzen).
- Sprint **planen/priorisieren** (noch nicht umsetzen) → `/backlog`.
- Sprint **auswerten** (Lessons, Metriken) → `/sprint-review`.

## Die komplette Skill-Kette

```
intent  →  ideation  →  backlog  →  sprint-run  →  /goal ( native Subagents )*  →  sprint-review
  │           │            │            │                    │                          │
Richtung   Story+Spec   Reihenfolge  Konfigurator       Termination-Engine          Lessons +
+ Why      + ADD        + Prioritaet  + /goal-Wrapper     parallele Stories           Metriken
```

`/sprint-run` ist das Bindeglied: es konsumiert die priorisierte Liste aus `/backlog`, bereitet pro Story Worktree + Agent-Definition vor und übergibt die Ausführung an `/goal`. Die Termination-Loop (Worker fixt → Gate erneut → Evaluator prüft) gehört `/goal`, nicht `/sprint-run`.

## Vor dem Sprint — Checkliste

- [ ] **Backlog priorisiert** — `/backlog` gelaufen, Reihenfolge steht.
- [ ] **Specs vollständig** — für jede Sprint-Story existiert `specs/<ISSUE>.md` (Schrader-vollständig, mit `Execution Isolation`-Block: `execution_mode`, `worktree_strategy`, `write_scopes` — **und** einer Subagent-Sektion, aus der die Agent-Definition generiert wird).
- [ ] **Pre-Flight grün** — `/quality-gate-audit --trigger pre-sprint` läuft ohne `blind`-Gate durch (sonst STOPP).
- [ ] **Drei Sicherheits-Voraussetzungen erfüllt** — (1) Allowlist mit Gate-Commands in `.claude/settings.local.json`, (2) `execution_isolation=worktree` in CONVENTIONS, (3) Layer-0 `pre-edit-bodyguard`-Hook live.
- [ ] **Werkzeug bereit** — `git worktree` verfügbar, `gh` authentifiziert, `main` clean.

## Schritt 1 — Beispiel-Session (vom Intent bis zum Sprint)

```text
# 1. Richtung setzen (einmalig)
/intent        → Produkt-Intent + Why festhalten

# 2. Stories erzeugen (pro Idee)
/ideation      → Story + Spec (specs/BOO-XX.md, inkl. Subagent-Sektion) + ADD

# 3. Sprint planen
/backlog       → priorisierte Reihenfolge, Abhaengigkeiten aufgeloest

# 4. Sprint vorbereiten + /goal aufrufen  ← dieses Runbook
/sprint-run    → Pre-Flight, Worktrees + Agent-Definitionen, Token-Budget, dann /goal

# 5. Sprint auswerten (nach /goal-Terminierung)
/sprint-review → Lessons + Metriken
```

## Schritt 2 — `/sprint-run` aufrufen

Öffne Claude Code **im Projektordner** und tippe `/sprint-run`. Der Skill arbeitet die Phasen ab:

- **Phase A (Vorbereitung):** Environment + Sprint-Kontext laden, Sprint-Pre-Flight (Hard-Gate inkl. `/quality-gate-audit --trigger pre-sprint`), die drei Sicherheits-Voraussetzungen prüfen, Token-Budget (80 % des Context-Windows) planen, pro Story `git worktree add` + `.claude/agents/<story>-<agent>.md` generieren.
- **Phase B (`/goal`-Aufruf):** `/goal` mit einer **Termination-Phrase** starten, die das Sprint-Ende maschinell definiert:

```text
/goal "Sprint <id> closed: alle Linear-Issues status:done, alle Quality-Gates grün
(Semgrep, ESLint, Coverage>=80%, GitHub Actions), journal/sprint-<date>.md geschrieben,
keine offenen Subagent-Tasks"
```

Ab hier orchestriert `/goal`: native Subagents parallel pro Story (Worktree-isoliert, `parallel_story_limit` aus CONVENTIONS begrenzt die gleichzeitigen Worker), Gate-Failure-Recovery, Pause bei Sensitive-Path, Post-Story-Gate-Assertion vor jedem Merge, Terminierung bei erfüllter Phrase oder an der 80%-Token-Boundary.

> **Claude-Code-Modus:** beaufsichtigt → `acceptEdits`; unbeaufsichtigt → `dontAsk` + Allowlist (`.claude/settings.local.json`). **Nicht** Plan Mode (read-only, blockiert die Umsetzung). Die Termination-Phrase enthält **keine** Manuell-Schritte (Approval-Pausen gehören ins Gate-Block-Protokoll, nicht in die Phrase) — sonst terminiert `/goal` nie.

## Typische Fehlerszenarien + Lösungen

| Szenario | Was `/goal` / Pre-Flight tut | Was du tust |
|---|---|---|
| Story ohne Spec / ohne Subagent-Sektion | Pre-Flight (Phase A) nimmt sie aus dem Sprint oder STOPP | `/ideation` nachholen oder Spec ergänzen |
| `blind`-Gate im Pre-Sprint-Audit | Pre-Flight STOPP — `/goal` wird nicht gestartet | Reparatur-Hinweis im Audit-Report, dann erneut; Override nur bewusst (`--override-gate` / Report-Frontmatter) |
| Allowlist / Worktree-Isolation / Bodyguard fehlt | Sicherheits-Voraussetzung nicht erfüllt → Abbruch/Pause vor `/goal` | Template aus `/bootstrap` anwenden, `execution_isolation=worktree` setzen, Bodyguard-Hook verdrahten |
| Sensitive-Path-Treffer | `/goal` **pausiert** + Notify (Story-ID + Pfad) | prüfen, dann `review-ok: <name> - <kommentar>` |
| Personal-Data-Treffer | `/goal` **pausiert** + Notify (DSGVO) | DPO-Review, dann `privacy-ok: ...` |
| Quality-Gate rot | Worker-Agent fixt und ruft das Gate erneut; Evaluator sieht „noch nicht erfüllt" → Loop bis grün | nichts — nur bei Dauer-Rot eingreifen (Logauszug `gh run view --log-failed`) |
| Unbegründeter Gate-Skip / fehlende `meta.json` | Post-Story-Gate-Assertion failt → Story nicht gemerged + Notify | `meta.json` prüfen; Gate nachholen oder Override begründen |
| 80%-Token-Boundary erreicht | `/goal` terminiert den Sprint, offene Stories bleiben im Backlog | nächsten Sprint planen (`/backlog`) |
| `main` nicht clean | Pre-Flight STOPP vor `/goal` | Arbeitsbaum aufräumen, neu starten |

## Sicherheit & Idempotenz

- **Gate-Blocks werden nie automatisch überbrückt** — kein Bypass, kein Timeout-Resume; jede Freigabe gilt für genau einen Block.
- **Kein Merge ohne grüne Remote-CI** und ohne saubere Gate-Assertion (`meta.json`).
- **Worktree als Sicherheits-Boundary** — native Subagents schreiben nur in Worktree-isolierten Arbeitsbäumen parallel; ohne `execution_isolation=worktree` startet `/goal` nicht. Verwaiste Worktrees vor dem nächsten Lauf aufräumen (`git worktree prune`).
- **Layer-0 Bodyguard** blockiert Secrets und sensible Pfade vor dem Schreiben; ist er nicht live, läuft `/goal` nicht.
- **`.env`/Secrets/lokale Reports** nie anfassen, nie committen.
- **Wiederholbar:** Ein abgebrochener Sprint kann neu gestartet werden — bereits gemergte Stories sind `Done`, `/goal` nimmt die nächsten offenen.

## Danach

- Nach `/goal`-Terminierung aggregiert `/sprint-run` (bzw. `/sprint-review`) die `journal/reports/local/*/meta.json` zu `journal/sprint-<date>.md` und gibt den Sprint-Report aus (Story · Status · Token · Gates · Worktree, Gesamt-Token in % des Budgets, Approval-Pausen, verbleibende Stories).
- Optionaler Kosten-Snapshot (Soft-Gate): `bash .claude/hooks/ccusage-capture.sh "/sprint-run <sprint>"` — schlägt er fehl, nur warnen.
- `/sprint-review`-Ergebnis lesen, verbliebene Stories für den nächsten Sprint neu priorisieren (`/backlog`).

## Verweise

`sprint-run/SKILL.md` (Workflow, v2.0.0) · `goal/README.md` (native Termination-Engine) · `sprint-run/references/{orchestration-checklist,goal-termination-phrases,goal-e2e-protocol,gate-block-handling,gate-assertion,worktree-flow,token-boundary}.md` · HANDBUCH Anhang AD (Kapitel + Sketches) · Anhang AH · Anhang G (Sprint-Sizing) · [Sprint unbeaufsichtigt per tmux fahren](sprint-unattended-tmux.md).
