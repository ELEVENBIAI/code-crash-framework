---
name: sprint-run
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Sprint-Orchestrator: faehrt einen ganzen Sprint vollautomatisch. Waehlt Stories aus dem
  priorisierten Backlog, ruft `/implement` pro Story im Daemon-Modus (eigener `git worktree`
  + Branch), aktualisiert den Linear-Status, wartet auf gruene Remote-CI, merged, raeumt den
  Worktree ab und triggert am 80%-Token-Boundary automatisch `/sprint-review`. Reiner
  Orchestrator — `/implement`, `/backlog`, `/sprint-review` bleiben unveraendert.
  Verwenden wenn der Operator "Sprint laufen lassen", "fahr den Sprint", "automation-cycle"
  oder "/sprint-run" sagt. Auch vom Automation-Daemon (ohne Human-in-the-Loop) nutzbar.
version: 1.2.0
metadata:
  hermes:
    category: governance
    tags: [orchestration, sprint-automation, execution-isolation, token-boundary, gate-block-safety]
    requires_toolsets: [terminal, git, linear]
    related_skills: [backlog, implement, sprint-review, ideation]
---

# Sprint-Run

Orchestriert einen kompletten Sprint: von der Story-Auswahl aus dem priorisierten Backlog
ueber die vollautomatische Umsetzung jeder Story (`/implement` im Daemon-Modus, je in einem
eigenen `git worktree`) bis zum Sprint-Abschluss (`/sprint-review`). `/sprint-run` schreibt
**keinen** eigenen Produktcode und veraendert die orchestrierten Skills nicht — es **verkettet**
sie und uebernimmt die Sprint-Mechanik (Reihenfolge, Worktrees, Linear-Status, CI-Wait,
Token-Boundary, Gate-Block-Pause).

> **Abgrenzung zu `/implement`:** `/implement` setzt **eine** Story um. `/sprint-run` faehrt
> **N** Stories als Sprint und ruft `/implement` pro Story auf. Wer eine einzelne Story
> umsetzen will, nimmt `/implement` direkt.

## Workflow (Schritte 0–7)

### Schritt 0: Environment + Sprint-Kontext laden

- `.claude/environment.json` lesen: `thresholds.token_warn_threshold`, `token_hard_threshold`
  (Default 70/80), `tools_available.{git,gh,linear}`, Pfade.
- `CONVENTIONS.md` lesen: `backlog_adapter` (Linear/GitHub/none), `governance_mode`,
  `execution_isolation`, `worktree_strategy`.
- Modus erkennen: interaktiv (Default) vs. Daemon (`/sprint-run --auto` oder Webhook) —
  im Daemon-Modus entfaellt die Operator-Freigabe in Schritt 3 (analog `/implement` Schritt 4).
- Fallback: fehlt `environment.json`, mit Defaults weiterfahren und warnen (Soft).

### Schritt 1: Sprint-Pre-Flight ⛔ HARD GATE

Pro Sprint genau einmal — der Daemon darf **nicht** mit einem unsauberen Sprint starten.
Pruefen und bei Verstoss STOPP mit konkretem Remediation-Hinweis:

- **Backlog priorisiert?** `/backlog` liefert eine geordnete Kandidatenliste (Status `Todo`/`Backlog`,
  Reihenfolge nach Prioritaet). Leer → STOPP.
- **Specs vollstaendig?** Fuer **jede** Kandidaten-Story existiert `specs/<ISSUE>.md` (Spec-Gate),
  ist Schrader-vollstaendig (Insight, Constraints, Erfolgskriterien, Gewuenschtes Ergebnis) und
  traegt den `Execution Isolation`-Block (`execution_mode`, `worktree_strategy`, `write_scopes`).
  Fehlt etwas → Story aus dem Sprint nehmen oder STOPP (Daemon: Story skippen + protokollieren).
- **Governance-Gates grün?** `governance_mode` aus CONVENTIONS; aktive Gates (sensitive-paths,
  personal-data) sind konfiguriert und der Daemon kennt das Pause-Verhalten (Schritt 4.4).
- **Werkzeug bereit?** `git worktree` verfuegbar, `gh` authentifiziert (fuer Remote-CI-Wait),
  Arbeitsbaum auf `main` clean.
- **Quality Gates verdrahtet?** (BOO-183) `/quality-gate-audit --trigger pre-sprint` aufrufen —
  prueft, ob die deklarierten Gates (Semgrep-Wiring, Coverage, Slopsquatting, Layer-0-Bodyguard)
  tatsaechlich verdrahtet sind, nicht nur nominell konfiguriert. Engine: `quality-gate-audit/scripts/gate-checks.sh`,
  Exit `0` = alle `verdrahtet`/akzeptiert ueberschrieben, Exit `1` = mindestens ein Gate `blind`.
  **Mindestens ein Gate `blind` → STOPP** mit Verweis auf den Reparatur-Hinweis im Audit-Report
  (`docs/audits/YYYY-MM-DD-quality-gate-audit.md`). Override nur bewusst:
  `/quality-gate-audit --override-gate <name> --reason "..."` (transient) oder Report-Frontmatter
  `override_blind: true` + `reason` (persistent). Im Daemon-Modus (`--auto`) ohne Override → Abbruch.

> Dieser Gate ist die Voraussetzung dafuer, dass der Loop danach ohne Rueckfragen laufen darf.
> Details: [references/orchestration-checklist.md](references/orchestration-checklist.md).
> Cross-Link: der Pre-Sprint-Trigger wird im Skill [quality-gate-audit](../quality-gate-audit/SKILL.md) definiert.

### Schritt 2: Sprint-Token-Budget planen (BOO-38/40)

- Sprint = **80 % des Context-Windows** des verwendeten Modells (Token-Box statt Zeit-Box,
  HANDBUCH Anhang G). Kein Burndown, keine Velocity.
- Summe der `token_estimate` aller Kandidaten-Stories gegen das 80%-Budget projizieren.
  Stories, die das Budget sprengen, in den naechsten Sprint verschieben (Hinweis, kein Abbruch).
- Reihenfolge festlegen: Abhaengigkeiten (`blockedBy`) zuerst, dann Prioritaet.
- Ergebnis: geordnete Sprint-Liste + projiziertes Budget. Details:
  [references/token-boundary.md](references/token-boundary.md).

### Schritt 3: Sprint-Plan + Operator-Freigabe

- Plan zeigen: Stories in Reihenfolge, je `token_estimate` + `execution_mode`, Gesamt-Budget,
  `daemon_fail_policy` (stop|continue).
- **Auf Operator-Freigabe warten** (Human-in-the-Loop).
- **Daemon-Modus (`--auto`): diesen Schritt ueberspringen** — analog `/implement` Schritt 4.

### Schritt 4: Daemon-Loop pro Story

Fuer jede Story in der Sprint-Reihenfolge:

| # | Aktion |
|---|--------|
| 4.1 | **Linear → In Progress** setzen (Adapter aus CONVENTIONS; bei `none` lokal protokollieren). |
| 4.2 | **Worktree anlegen:** `git worktree add ../wt-<ISSUE> -b feat/boo-<n>-<slug>` (eigener Branch je Story). |
| 4.3 | **`/implement` im Daemon-Modus** im Worktree als **Subprozess** starten — Modell + Modus aufgeloest (BOO-170, s.u.): `claude -p "/implement <ISSUE>" --model "$(python3 <skill-dir>/scripts/resolve-model.py implement --repo-root .)" --permission-mode dontAsk`. Schritt-4-Freigabe uebersprungen; Operator-`--model`-Override hat Vorrang. Alle `/implement`-Gates bleiben aktiv. |
| 4.4 | **Gate-Block-Pause** (s.u.) — bei Sensitive-Paths/Personal-Data-STOPP: pausieren, Operator benachrichtigen, **nie** automatisch ueberbruecken. |
| 4.5 | **Remote-CI-Wait (BOO-148):** `/implement` Schritt 6h (`gh run watch --exit-status`). Rot → max 3 Fix-Iterationen, sonst Eskalation. |
| 4.5b | **Post-Story-Gate-Assertion** (s.u.) — `meta.json` des Story-Runs lesen; unbegruendeter `skipped_gates`-Eintrag **oder** fehlende `meta.json` → Story-Fail. Merge nur bei gruener Assertion. |
| 4.6 | **Merge nur bei gruener CI** → `main`; danach `git worktree remove ../wt-<ISSUE>` + Branch aufraeumen. |
| 4.7 | **Linear → Done** (mit AC-Evidenz-Kommentar). Bei Fehler: Story zurueck (`In Progress → Backlog`) + `daemon_fail_policy` anwenden. |
| 4.8 | **Token-Check:** aktueller Verbrauch gegen 80%-Boundary. Ueberschritten → Loop verlassen → Schritt 6. |

### Schritt 4.3: Modell-/Modus-Routing (BOO-170)

Damit jede Story mit dem **empfohlenen Modell** und im **unbeaufsichtigten Modus** laeuft, startet der
Daemon `/implement` als **eigenen Subprozess** mit aufgeloesten Flags — nicht inline im Loop-Modell:

```bash
MODEL="$(python3 <skill-dir>/scripts/resolve-model.py implement --repo-root .)"
claude -p "/implement <ISSUE>" --model "$MODEL" --permission-mode dontAsk
```

- **Modell:** `scripts/resolve-model.py <skill>` loest die Kette `<skill>/SKILL.md recommended_model`
  (Tier) → `bootstrap/references/model-tiers.json current_version` (Version) auf — bestehende SSoT,
  kein neues Konfig-Feld. Fallback: `sonnet`. Beispiel: `implement` → `claude-opus-4-7` (BOO-170:
  Produktcode auf bestem Modell).
- **Permission-Modus:** im Daemon konstant **`dontAsk`** + Allowlist (unbeaufsichtigt). `bypassPermissions`
  nur in echter Isolation (Container/VM). Entspricht HANDBUCH §6 Zeile „Umsetzen, unbeaufsichtigt".
- **Override-Hierarchie gewahrt:** ein dem Daemon explizit vorgegebenes `--model` (oder `CLAUDE.md`
  `model_overrides`) schlaegt den Skill-Default; der Entscheid wird in `meta.json` (`model_used`,
  `override_origin`) protokolliert.
- **Bekannte Grenze — `implement` ist Multi-Tier:** `implement` routet intern haiku (Iterations-Loops)
  und opus (Security-Findings, Schritt 6e). Ein einzelnes `--model` pro Subprozess bildet das **nicht**
  ab — es setzt das Top-Level-Modell (opus, fuer den Code-Kern). Die feinere Loop-/Findings-Trennung
  erfordert implement-**internes** Subagent-Routing (`model:` je Subagent) und ist eine **Folge-Story**.
- **Effort:** kein CLI-Flag — bleibt Session-/`/config`-Einstellung (nicht pro Story erzwingbar).
- **Nur Daemon (`--auto`):** Dieses Routing gilt fuer den unbeaufsichtigten Lauf. **Interaktiv** laeuft
  der Loop im Modell/Modus deiner Session; dort ist die §6-Zuordnung eine **Empfehlung** (Shift+Tab),
  kein Zwang — Claude Code kann das Modell des laufenden Loops nicht per Skill wechseln.

### Schritt 4.4: Gate-Block-Verhalten ⛔ (sicherheitskritisch)

Loest `/implement` einen **Sensitive-Paths-Gate** (Schritt 5.5) oder **Personal-Data-Gate**
(Schritt 5.5b) aus, gilt **immer**:

1. Daemon **pausiert** sofort (kein Merge, kein Weiter).
2. Operator-Notify mit **Story-ID + Grund** (welcher Pfad, welcher Gate).
3. Resume **nur** nach explizitem `review-ok` (technisch) bzw. `privacy-ok` (rechtlich, DSGVO Art. 25).
4. **Kein** automatischer Bypass, **kein** Timeout-Resume. Auch im `--auto`-Modus haelt der
   Daemon hier an.

Details: [references/gate-block-handling.md](references/gate-block-handling.md).

### Schritt 4.5b: Post-Story-Gate-Assertion ⛔ (maschinelle Verifikation)

`/implement` schreibt in Schritt 6f-bis eine `journal/reports/local/<run>/meta.json` (BOO-36/84)
mit u.a. `skipped_gates`, `change_type`, `override_audit`. `/sprint-run` liest sie **nach jedem
Story-Lauf** und verifiziert, dass kein Pflicht-Gate **still** uebersprungen wurde — die maschinelle
Ergaenzung zur prompt-getriebenen Gate-Ausfuehrung (Ebene 1) und zum Remote-CI-Gate (Ebene 2).

**Regel:** jeder Eintrag in `skipped_gates` muss **legitim** sein, sonst → Story-Fail (zurueck auf
`Backlog`) + Operator-Notify (Story-ID + welches Gate). **Fehlt `meta.json` ganz → Fail** (kein
„leise gruen"). Merge (Schritt 4.6) erst nach gruener Assertion.

| Befund | Legitim? | Aktion |
|---|---|---|
| `skipped_gates` leer | ✅ | weiter |
| Skip durch `change_type` gedeckt (Non-Code 5.7: workflow/config/infrastructure/content) | ✅ | weiter |
| Skip mit Eintrag in `override_audit` (z.B. Coverage-Override mit Begruendung) | ✅ | weiter |
| Skip ohne Deckung/Override | ❌ | **Story-Fail** → Backlog + Notify |
| `meta.json` fehlt | ❌ | **Story-Fail** |
| Non-Code-Story: 6c/6d/6e ohne Evidenz | ❌ | **Story-Fail** |

Details: [references/gate-assertion.md](references/gate-assertion.md).

### Schritt 5: Fehlerbehandlung

- **`/implement` schlaegt fehl:** Story zurueck auf `Backlog`, Worktree nach Policy entfernen
  oder fuer Diagnose behalten. `daemon_fail_policy`: `stop` (Default — Sprint anhalten,
  Operator-Notify) oder `continue` (naechste Story).
- **CI bleibt rot** nach 3 Iterationen: kein Merge, Story bleibt `In Progress`, Eskalation
  an Operator mit Log-Auszug (`gh run view --log-failed`).
- **Worktree-Konflikt / dirty `main`:** STOPP — niemals mit unsauberem Baum mergen.

### Schritt 6: Sprint-Boundary → `/sprint-review`

Ausloeser (einer reicht): 80%-Token-Boundary erreicht · Backlog leer · `stop-on-fail` gegriffen.

- `/sprint-review` triggern — aggregiert `journal/reports/local/*/meta.json` der Story-Laeufe
  zu `journal/sprint-<date>.md` (Metriken, Learning-Loop).
- Bei Token-Boundary: Operator-Hinweis **"Sprint-Boundary erreicht"**.

### Schritt 7: Sprint-Report (Pflicht-Output)

Abschluss-Tabelle:

| Story | Status | Token | CI | Worktree |
|---|---|---|---|---|
| BOO-XX | Done / Failed / Skipped | ~Xk | gruen/rot | aufgeraeumt |

Plus: Gesamt-Token-Verbrauch (% des Budgets), Gate-Block-Pausen, verbleibende Backlog-Stories,
Verweis auf das `/sprint-review`-Ergebnis.

## Daemon-Modus

**Default vs. `--auto` — beide fuehren aus.** Im interaktiven Default-Lauf zeigt `/sprint-run` in
Schritt 3 den Sprint-Plan und wartet **einmal** auf Freigabe; **danach** laeuft der Loop (Schritt 4)
ohne weitere Zwischenfragen durch. `--auto` (Webhook/Daemon) ueberspringt **nur** diese eine
Freigabe — sonst identisch. Es gibt **keinen** reinen Pruef-Modus; beide setzen den Sprint real um.

Wie `/implement` kennt `/sprint-run` einen Daemon-Modus (`--auto` / Webhook): die
**Operator-Freigabe in Schritt 3 wird uebersprungen**, der Loop laeuft ohne Zwischenfragen —
**ausser** an Gate-Blocks (Schritt 4.4), die **immer** anhalten. Alle `/implement`-Gates
(Spec-Gate, Quality-Gates, CI-Loop) bleiben in jeder Story aktiv, und Schritt 4.5b verifiziert
nach jedem Lauf **maschinell** gegen `meta.json`, dass kein Gate still uebersprungen wurde.

> **Claude-Code-Modus (nicht verwechseln):** Der „Plan" in Schritt 3 ist der **Sprint-Plan des
> Skills**, **nicht** der Claude-Code-Planungsmodus — der ist read-only und wuerde die Umsetzung
> blockieren. Empfehlung: beaufsichtigt → `acceptEdits`, unbeaufsichtigt (`--auto`) → `dontAsk` +
> Allowlist; nie Plan Mode fuer die Umsetzung. Details: HANDBUCH §6 „Claude-Code-Modus".

## Integration mit anderen Skills

| Upstream | Was geliefert wird | Downstream | Was wir liefern |
|----------|--------------------|------------|------------------|
| `ideation` | Stories + Specs + ADD | `implement` (pro Story) | Story-ID, Worktree, Daemon-Trigger |
| `backlog` | Priorisierte Sprint-Liste | `sprint-review` (Sprint-Ende) | Aggregierte Story-Metriken (meta.json) |

Kette: `intent → ideation → backlog → sprint-run → ( implement )* → sprint-review`.

## Trigger-Phrasen

- `/sprint-run`
- "Sprint laufen lassen"
- "fahr den Sprint"
- "automation-cycle"

## Konfiguration

Felder (in `.claude/environment.json` bzw. `CONVENTIONS.md`, plus pro Story im Spec-`Execution Isolation`-Block):

| Feld | Bedeutung | Default |
|---|---|---|
| `token_hard_threshold` | Sprint-Boundary in % des Context-Windows | `80` |
| `daemon_fail_policy` | Verhalten bei Story-Fehler: `stop` / `continue` | `stop` |
| `worktree_strategy` | Isolation pro Story | `git-worktree` |
| `parallel_story_limit` | Max. parallele Story-Worktrees (1 = sequentiell) | `1` |

## Dateistruktur

```
sprint-run/
├── SKILL.md                                  ← Skill-Definition (1.1.0)
├── SKILL.en.md                               ← English Mirror
├── README.md                                 ← Deutsch README (Version: 1.1.0)
├── README.en.md                              ← English README
├── overview.excalidraw / .png                ← Skill-Overview-Sketch (+ .en)
└── references/
    ├── orchestration-checklist.md            ← Sprint-Pre-Flight + Loop-Checks (+ .en.md)
    ├── gate-block-handling.md                ← Pause/Resume-Protokoll (+ .en.md)
    ├── gate-assertion.md                     ← Post-Story-Gate-Assertion (meta.json) (+ .en.md)
    ├── worktree-flow.md                      ← Worktree pro Story: add → merge → remove (+ .en.md)
    └── token-boundary.md                     ← 80%-Boundary-Logik + Sprint-Budget (+ .en.md)
```
