# Runbook: /sprint-run — einen ganzen Sprint vollautomatisch fahren

> [!warning] Veraltet seit v0.11.0 — siehe ADR-4 (Sprint-Run mit `/goal`)
> Dieses Runbook beschreibt das **Daemon-Loop-Modell** (`/implement` pro Story), gültig bis v0.10.x. Ab **v0.11.0 (BOO-203, Build-vs-Buy-Pivot)** ist `/sprint-run` ein **Konfigurator + `/goal`-Wrapper** (native Termination-Engine statt Eigenbau-Loop). Maßgeblich sind jetzt: Skill [`sprint-run`](../../sprint-run/SKILL.md) (v2.0.0), [`goal/README.md`](../../goal/README.md) und **HANDBUCH Anhang AD/AH**. Das Folgende bleibt historische Referenz, bis das Runbook neu geschrieben ist.

> Für Operatoren, die einen Sprint nicht mehr Story für Story von Hand steuern wollen: `/sprint-run` wählt Stories aus dem priorisierten Backlog, setzt jede per `/implement` im Daemon-Modus um (eigener `git worktree` + Branch), pflegt Linear, wartet auf grüne CI, merged, räumt auf und schließt mit `/sprint-review` ab. EN: [`sprint-run.en.md`](sprint-run.en.md).

## Wann dieses Runbook?

Du hast einen priorisierten Backlog mit fertig spezifizierten Stories und willst den Sprint **am Stück** fahren — ohne nach jeder Story manuell die nächste anzustoßen. Das ist der **Sprint-Automations-Fall**.

Abgrenzung:
- **Eine** Story gezielt umsetzen → `/implement` direkt.
- Sprint **planen/priorisieren** (noch nicht umsetzen) → `/backlog`.
- Sprint **auswerten** (Lessons, Metriken) → `/sprint-review` (ruft `/sprint-run` am Ende selbst auf).

## Die komplette Skill-Kette

```
intent  →  ideation  →  backlog  →  sprint-run  →  ( implement )*  →  sprint-review
  │           │            │            │               │                  │
Richtung   Story+Spec   Reihenfolge  Orchestrator   pro Story         Lessons +
+ Why      + ADD        + Prioritaet  (Daemon)      Code + CI         Metriken
```

`/sprint-run` ist das Bindeglied: es konsumiert die priorisierte Liste aus `/backlog`, ruft `/implement` pro Story auf und übergibt am Sprint-Ende an `/sprint-review`.

## Vor dem Sprint — Checkliste

- [ ] **Backlog priorisiert** — `/backlog` gelaufen, Reihenfolge steht.
- [ ] **Specs vollständig** — für jede Sprint-Story existiert `specs/<ISSUE>.md` (Schrader-vollständig, mit `Execution Isolation`-Block: `execution_mode`, `worktree_strategy`, `token_estimate`).
- [ ] **Governance-Gates grün** — `sensitive-paths.json` / `personal-data-paths.json` konfiguriert; du weißt, dass der Daemon bei Treffern **pausiert**.
- [ ] **Werkzeug bereit** — `git worktree` verfügbar, `gh` authentifiziert, `main` clean.

## Schritt 1 — Beispiel-Session (vom Intent bis zum Sprint)

```text
# 1. Richtung setzen (einmalig)
/intent        → Produkt-Intent + Why festhalten

# 2. Stories erzeugen (pro Idee)
/ideation      → Story + Spec (specs/BOO-XX.md) + ADD

# 3. Sprint planen
/backlog       → priorisierte Reihenfolge, Abhaengigkeiten aufgeloest

# 4. Sprint fahren  ← dieses Runbook
/sprint-run    → Daemon-Loop ueber die Top-N Stories

# 5. Sprint auswerten (vom Daemon am 80%-Boundary getriggert)
/sprint-review → Lessons + Metriken
```

## Schritt 2 — `/sprint-run` aufrufen

Öffne Claude Code **im Projektordner** und tippe `/sprint-run` (interaktiv, mit Sprint-Plan-Freigabe) — oder für den unbeaufsichtigten Lauf:

```text
/sprint-run --auto
```

Der Daemon zeigt zuerst den Sprint-Plan (Stories, Reihenfolge, projiziertes Token-Budget) und fährt dann pro Story: `git worktree add` → `/implement` (Daemon) → `gh run watch` → Merge (nur grün) → Linear → Done → `git worktree remove`. Bei `--auto` entfällt die Plan-Freigabe — **außer** an Gate-Blocks, die immer anhalten.

> **Beide Modi führen den Sprint real aus** (inkl. Merge nach `main`); `--auto` lässt nur die einmalige Plan-Freigabe weg — es gibt keinen reinen „Nur-Prüfen"-Modus. **Claude-Code-Modus:** beaufsichtigt → `acceptEdits`, unbeaufsichtigt → `dontAsk` + Allowlist; **nicht** Plan Mode (read-only, blockiert die Umsetzung). Der Sprint-Plan ist der Plan des Skills, **nicht** der Claude-Code-Planungsmodus. Details: HANDBUCH §6 „Claude-Code-Modus".

## Typische Fehlerszenarien + Lösungen

| Szenario | Was der Daemon tut | Was du tust |
|---|---|---|
| Story ohne Spec | Pre-Flight nimmt sie aus dem Sprint (protokolliert) | `/ideation` nachholen oder Spec ergänzen |
| Sensitive-Paths-Treffer | **Pause** + Notify (Story-ID + Pfad) | prüfen, dann `review-ok: <name> - <kommentar>` |
| Personal-Data-Treffer | **Pause** + Notify (DSGVO) | DPO-Review, dann `privacy-ok: ...` |
| Remote-CI bleibt rot (3×) | kein Merge, Eskalation, Story bleibt In Progress | Logauszug prüfen (`gh run view --log-failed`), fixen |
| `/implement` schlägt fehl | Story zurück auf Backlog; `daemon_fail_policy` (stop/continue) | Ursache klären, Story erneut einplanen |
| Unbegründeter Gate-Skip / fehlende `meta.json` (4.5b) | Assertion failt → Story zurück auf Backlog + Notify | `meta.json` prüfen; Gate nachholen oder Override begründen |
| 80%-Token-Boundary erreicht | Loop-Ende + `/sprint-review` + Hinweis | nächsten Sprint planen |
| `main` nicht clean | STOPP vor Merge | Arbeitsbaum aufräumen, neu starten |

## Sicherheit & Idempotenz

- **Gate-Blocks werden nie automatisch überbrückt** — kein Bypass, kein Timeout-Resume; jede Freigabe gilt für genau einen Block.
- **Kein Merge ohne grüne Remote-CI** (BOO-148).
- **`.env`/Secrets/lokale Reports** nie anfassen, nie committen.
- **Worktrees** werden nach jedem Story-Lauf entfernt; verwaiste Worktrees vor dem nächsten Lauf aufräumen (`git worktree prune`).
- **Wiederholbar:** Ein abgebrochener Sprint kann neu gestartet werden — bereits gemergte Stories sind `Done`, der Daemon nimmt die nächsten offenen.

## Danach

- `/sprint-review`-Ergebnis lesen (`journal/sprint-<date>.md`): Lessons, Metriken, Token-Verbrauch.
- Verbliebene Stories für den nächsten Sprint neu priorisieren (`/backlog`).

## Verweise

`sprint-run/SKILL.md` (Workflow) · `sprint-run/references/{orchestration-checklist,gate-block-handling,worktree-flow,token-boundary}.md` · HANDBUCH Anhang AD (Kapitel + Sketches) · Anhang G (Sprint-Sizing) · `bootstrap/references/framework-upgrade.md` · BOO-148 (Remote-CI-Loop) · BOO-157 · [Sprint unbeaufsichtigt per tmux fahren](sprint-unattended-tmux.md).
