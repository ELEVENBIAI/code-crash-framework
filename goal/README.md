<a name="deutsch"></a>

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English version](README.en.md)

# /goal — native Termination-Engine im Code-Crash-Framework

> `/goal` ist die **Anthropic-native** Termination-Engine von Claude Code. Sie nimmt eine
> maschinell pruefbare **Termination-Phrase** entgegen, orchestriert native Subagents und laeuft
> Turn fuer Turn, bis ein Evaluator die Phrase als erfuellt sieht. Im Code-Crash-Framework ist
> `/goal` seit **ADR-4** die **Sprint-Engine** hinter [`/sprint-run`](../sprint-run/README.md) —
> und alternativ die **Story-Engine** fuer lange [`/implement`](../implement/README.md)-Laeufe.

**Anthropic-Native — im Framework hier dokumentiert, nicht selbst gebaut.**

> [!info] Kein Framework-Skill
> `/goal` ist **kein** Skill dieses Repos: es gibt **keinen** `goal/SKILL.md`, keinen eigenen
> Code, keine eigene Version. Dieser Ordner **dokumentiert nur**, wie die native Engine im
> Code-Crash-Workflow eingesetzt wird. Build-vs-Buy-Doktrin (ADR-1): das Framework baut nicht
> nach, was Anthropic bereits nativ liefert — es nutzt es und dokumentiert die Einbettung.

---

## Was `/goal` ist (und was nicht)

`/goal` ist eine **Termination-Schleife** mit Evaluator. Du gibst ihr eine Phrase, die das
gewuenschte End-Ergebnis **objektiv pruefbar** beschreibt (alle Issues *Done*, alle Gates gruen,
Journal geschrieben). `/goal` arbeitet selbstaendig weiter — orchestriert dabei native Subagents,
laesst Worker rote Gates fixen, prueft erneut — bis der Evaluator die Phrase erfuellt sieht oder
ein Limit (Token-Budget) erreicht ist.

`/goal` ist **kein** Sprint-Planer, **kein** Spec-Generator und **kein** Worktree-Verwalter. Diese
Vorbereitung leistet das Framework (`/sprint-run`); `/goal` bekommt die **fertig vorbereitete
Umgebung** plus die **Phrase** und fuehrt aus.

---

## Einsatz 1 — Sprint-Termination (gerufen von `/sprint-run`)

Der Regelfall im Framework. `/sprint-run` ist ein **Konfigurator + Wrapper**: er bereitet den
Sprint vor (Pre-Flight, Specs, Worktree pro Story, Subagent-Definitionen, Token-Budget) und
**uebergibt die Ausfuehrung an `/goal`**. Ab dann gehoert die Schleife `/goal`:

```
/goal "Sprint <id> closed: alle Linear-Issues status:done, alle Quality-Gates grün
(Semgrep, ESLint, Coverage>=80%, GitHub Actions), journal/sprint-<date>.md geschrieben,
keine offenen Subagent-Tasks"
```

`/goal` orchestriert die Stories parallel als native Subagents (jede in ihrer eigenen Worktree),
fixt rote Gates, pausiert bei sensiblen Pfaden und terminiert beim Erfuellen der Phrase oder an der
80 %-Token-Boundary. Den vollen Ablauf beschreibt [`/sprint-run`](../sprint-run/README.md) (Schritt
5) und das ADR [Sprint-Run mit `/goal`](#querverweise).

---

## Einsatz 2 — Story-Termination (direkt in `/implement` fuer lange Stories)

Fuer eine **einzelne, lange** Story kann `/goal` auch direkt eingesetzt werden — ohne den vollen
Sprint-Apparat von `/sprint-run`. Die Phrase beschreibt dann das **Story-Ende** statt das
Sprint-Ende:

```
/goal "Story <ISSUE> closed: Linear status:done, alle Quality-Gates grün (Semgrep, ESLint,
Coverage>=80%, GitHub Actions), nach main gemerged, meta.json ohne unbegruendeten skipped_gates"
```

So laeuft eine Story, die viele Iterationen braucht (rotes Gate → fixen → erneut pruefen),
selbstaendig bis zum gruenen Ende durch, statt jeden Schritt manuell anzustossen. Das manuelle
1-Story-E2E-Protokoll dazu liegt in
[`sprint-run/references/goal-e2e-protocol.md`](../sprint-run/references/goal-e2e-protocol.md).

---

## Termination-Phrasen-Bibliothek

Eine **Termination-Phrase** ist gut, wenn jeder Teilsatz **objektiv pruefbar** ist
(Issue-Status, Gate-Exit-Codes, Datei vorhanden) — nicht „Sprint fertig", sondern konkrete,
beobachtbare Zustaende. Vage Begriffe („sauber", „gut") kann der Evaluator nicht pruefen; der Loop
terminiert dann nie oder zu frueh.

Die kuratierte **Phrasen-Bibliothek pro Phase** (Standard-Sprint, Python-Stack, Einzel-Story,
Token-Boundary als expliziter Terminator, Anti-Pattern) liegt bei `/sprint-run`:

- **DE:** [`sprint-run/references/goal-termination-phrases.md`](../sprint-run/references/goal-termination-phrases.md)
- **EN:** [`sprint-run/references/goal-termination-phrases.en.md`](../sprint-run/references/goal-termination-phrases.en.md)

---

## Grenzen

- **Der Evaluator liest nur das Transkript.** `/goal` bewertet die Termination-Phrase anhand des
  **Gespraechsverlaufs** — er macht **keine eigenen Bash-Calls**, um z. B. ein Gate selbst
  nachzufahren. Die Gate-Ergebnisse muessen also als **beobachtbare Fakten im Transkript** stehen
  (Worker-Subagent fuehrt das Gate aus, das Ergebnis erscheint im Verlauf). Eine Phrase, deren
  Erfuellung sich nicht aus dem Transkript ablesen laesst, terminiert nicht zuverlaessig.
- **Keine Manuell-Schritte in der Phrase.** Approval-Pausen („Operator hat reviewed") gehoeren
  ins Gate-Block-Protokoll, nicht in die Termination-Phrase — sonst terminiert `/goal` nie.
- **Vorbereitung ist nicht `/goal`s Job.** Specs, Worktrees und Agent-Files liefert `/sprint-run`.

---

## Voraussetzungen

Damit `/goal` selbstaendig und sicher bis zum Sprint-/Story-Ende laeuft, muessen dieselben drei
Sicherheits-Voraussetzungen erfuellt sein, die `/sprint-run` vor dem `/goal`-Aufruf prueft:

1. **Bash-Permission auf auto-allow.** `.claude/settings.local.json` traegt eine **Allowlist** mit
   den Gate-Commands (`semgrep`, `eslint`, `pytest`, `gh run`, `git`), damit `/goal` und seine
   Subagents die Quality-Gates unbeaufsichtigt fahren, ohne an einem Permission-Prompt
   haengenzubleiben. Das Template legt `/bootstrap` an.
2. **`execution_isolation=worktree`.** Native Subagents schreiben nur in Worktree-isolierten
   Arbeitsbaeumen kollisionsfrei parallel. Ist die Isolation nicht `worktree`, **bricht**
   `/sprint-run` vor dem `/goal`-Aufruf ab.
3. **Layer-0 Bodyguard aktiv.** Der `pre-edit-bodyguard`-Hook (PreToolUse auf `Edit|Write`)
   blockiert Secrets und sensible Pfade vor dem Schreiben. Ist er nicht live, **pausiert**
   `/sprint-run` und ruft `/goal` nicht auf.

Diese drei ersetzen die frueheren Container-Boundaries (ADR-4): Worktree statt Container-Volume,
Allowlist statt Container-Permissions, Bodyguard statt Container-Sandbox.

---

## Querverweise

- **Sprint-Engine (Wrapper):** [`/sprint-run`](../sprint-run/README.md) — bereitet den Sprint vor
  und ruft `/goal` mit der Termination-Phrase auf.
- **Story-Engine (Einzel-Story):** [`/implement`](../implement/README.md) — 8-Schritte-Protokoll
  fuer eine Story; lange Laeufe koennen `/goal` als Termination nutzen.
- **Phrasen-Bibliothek:** [`sprint-run/references/goal-termination-phrases.md`](../sprint-run/references/goal-termination-phrases.md) (+ `.en.md`).
- **Manuelles 1-Story-E2E-Protokoll:** [`sprint-run/references/goal-e2e-protocol.md`](../sprint-run/references/goal-e2e-protocol.md).
- **Dokumenten-Index:** [`docs/INDEX.md`](../docs/INDEX.md).

Kette: `intent → ideation → backlog → sprint-run → /goal ( native Subagents )* → sprint-review`.

---

## Dateistruktur

```
goal/
├── README.md      ← diese Datei (Einsatz von /goal im Framework, DE)
└── README.en.md   ← englischer Zwilling

Kein SKILL.md — /goal ist Anthropic-native, kein Framework-Skill.
Die Phrasen- und E2E-Referenzen liegen bei /sprint-run (references/).
```
