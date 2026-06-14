# Sprint 3 — Build-vs-Buy-Pivot: /sprint-run fährt jetzt auf `/goal` (v0.11.0)

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](sprint-3.en.md)

> Sprint-Release-Note nach der Konvention aus [`_template-sprint.md`](_template-sprint.md) (BOO-216). Sprint 3 endet am 80%-Token-Boundary und wird auf **v0.11.0** getaggt. Versions-Overview (GitHub-Release-Body): [`v0.11.0-overview.md`](v0.11.0-overview.md).

## Highlights

- **Build-vs-Buy-Pivot (ADR-1):** Das Framework baut nicht mehr nach, was Anthropic nativ liefert. Die Sprint-Termination-Schleife wandert vom Eigenbau-Daemon auf die **Anthropic-native `/goal`-Engine** — Framework = Governance-Skelett, Anthropic = Motor.
- **`/sprint-run` 2.0.0:** Vom Hybrid-Container-Daemon-Loop zum schlanken **Konfigurator + `/goal`-Wrapper**. `/sprint-run` bereitet vor (Specs, Worktrees, Token-Budget, Subagent-Files) und übergibt die Ausführung an `/goal`.
- **Neue `/goal`-Doku (`goal/`):** Eigener Ordner, der die native Termination-Engine im Code-Crash-Workflow dokumentiert — bewusst **ohne `SKILL.md`**, weil `/goal` kein Framework-Skill ist.
- **Doku- und Release-Standards:** Doku-Konsistenz-Checkliste + Story-Template-Pflichtblock (BOO-214) und die Release-Konvention mit Sprint-/Major-Notes (BOO-216) sind jetzt verankert.

## Was sich ändert

- **BOO-198 — ADR-1 Build-vs-Buy-Doktrin.** Neue Doktrin (HANDBUCH **Anhang AG**) steuert, *was* das Framework überhaupt baut: native Fähigkeit vorhanden → buy; Lücke → build. Substituierbarer Eigenbau wird ausgedünnt.
- **BOO-201 — ADR-4 `/goal` supersedes Hybrid.** Das bisherige Hybrid-Container-Daemon-Modell ist ab v0.11.0 **superseded**; die drei früheren Container-Boundaries werden ersetzt (Worktree statt Container-Volume, Allowlist statt Container-Permissions, Bodyguard statt Container-Sandbox).
- **BOO-203 — `/sprint-run`-Refactor (v2.0.0).** Der Skill schrumpft auf Konfigurator + `/goal`-Wrapper; die Ausführungs-Schleife gehört der nativen Engine. `/implement`, `/backlog`, `/sprint-review` bleiben unverändert.
- **BOO-210 — `/goal`-Doku + `goal/README`.** `goal/README.md` (+ `.en.md`) beschreibt Einsatz 1 (Sprint-Termination via `/sprint-run`) und Einsatz 2 (Story-Termination in langen `/implement`-Läufen). HANDBUCH **Anhang AH** + neue `sprint-run/references/goal-termination-phrases` und `goal-e2e-protocol`.
- **BOO-212 — Cleanup alte Hybrid-Doku.** Das Daemon-Loop-Runbook (`docs/runbooks/sprint-run.md`) trägt jetzt einen *Veraltet-seit-v0.11.0*-Hinweis und verweist auf ADR-4; Container-/Daemon-Begriffe in der Skill-/HANDBUCH-Doku sind auf das `/goal`-Modell umgestellt.
- **BOO-214 — Doku-Konsistenz-Standard.** Neu `docs/standards/doku-consistency-checklist.md` (+ `.en.md`) + Pflicht-Block im `docs/templates/story-template.md` (+ `.en.md`); HANDBUCH **Anhang AI**.
- **BOO-216 — Release-Notes-Standard.** Neu `_template-sprint.md` + `_template-major.md` + `_index.md` (je `.en.md`); HANDBUCH **Anhang AJ**. Diese Sprint-Note ist die erste Anwendung.

## Breaking Changes

- **`/sprint-run`-Mechanik (v1.x → v2.0.0):** Der eigene **Daemon-Loop** (eine Story nach der anderen via `/implement` im Daemon-Modus) entfällt. Die Sprint-Ausführung läuft jetzt über die native `/goal`-Engine mit einer maschinell prüfbaren **Termination-Phrase**. Skripte/Runbooks, die auf den alten Loop bauen, sind nicht mehr gültig.
- **Container-Logik entfällt:** Das **Hybrid-Container-Modell** (Dockerfile / `devcontainer.json` / Container-Lifecycle / Lazy-Bootstrap / Hybrid-Driver-Approval) ist superseded. An seine Stelle treten die drei `/goal`-Boundaries (Worktree-Isolation, Bash-Allowlist, Layer-0-Bodyguard).
- **Altes `/sprint-run`-Runbook superseded:** `docs/runbooks/sprint-run.md` beschreibt das Daemon-Loop-Modell (gültig bis v0.10.x) und bleibt nur als historische Referenz.

## Migrations-Anleitung

Bestehende Projekte ziehen idempotent/nicht-destruktiv nach (Muster `inspect → apply-safe → apply-with-confirmation`, siehe `bootstrap/references/framework-upgrade.md`):

1. **Bash-Auto-Allow anlegen.** In `.claude/settings.local.json` eine **Allowlist** mit den Gate-Commands (`semgrep`, `eslint`, `pytest`, `gh run`, `git`) eintragen, damit `/goal` und seine Subagents die Quality-Gates unbeaufsichtigt fahren, ohne an einem Permission-Prompt hängenzubleiben. (`/bootstrap` legt das Template an.)
2. **`execution_isolation=worktree` setzen.** Native Subagents schreiben nur Worktree-isoliert kollisionsfrei parallel. Ist die Isolation nicht `worktree`, **bricht** `/sprint-run` vor dem `/goal`-Aufruf ab.
3. **Layer-0-Bodyguard aktiv halten.** Der `pre-edit-bodyguard`-Hook (PreToolUse auf `Edit|Write`) muss live sein — sonst **pausiert** `/sprint-run` und ruft `/goal` nicht auf.
4. **Altes Daemon-/Container-Runbook nicht mehr verwenden.** `docs/runbooks/sprint-run.md` ist *superseded*; maßgeblich sind `sprint-run/SKILL.md` (v2.0.0), `goal/README.md` und HANDBUCH **Anhang AD/AH**.

Keine Datei wird gelöscht oder überschrieben; die drei Voraussetzungen waren bereits für den Daemon-Modus empfohlen und werden ab v0.11.0 zur Pflicht für den `/goal`-Aufruf.

## Schalter & Konfiguration

- **`.claude/settings.local.json` — Bash-Allowlist** (Gate-Commands): Voraussetzung 1 für den `/goal`-Aufruf.
- **`execution_isolation=worktree`**: harte Voraussetzung — sonst Abbruch.
- **`pre-edit-bodyguard`-Hook**: harte Voraussetzung — sonst Pause.

Keine neuen Opt-in-/Opt-out-Setup-Fragen; die Schalter sind die drei `/goal`-Boundaries, die `/sprint-run` vor der Übergabe prüft.

## Doku-Updates

- **HANDBUCH** (DE + EN): **Anhang AD** (`/sprint-run` als Konfigurator + `/goal`-Engine), **Anhang AG** (Build-vs-Buy-Doktrin, ADR-1), **Anhang AH** (`/goal`-Engine, BOO-210), **Anhang AI** (Doku-Konsistenz, BOO-214), **Anhang AJ** (Release-Konvention, BOO-216) + `/sprint-run`-Eintrag in §6.
- **`goal/`** (neu): `README.md` (+ `.en.md`) — Einsatz, Grenzen, Voraussetzungen der nativen Engine.
- **`sprint-run/`**: `SKILL.md` + `README.md` auf **v2.0.0**, `references/` aktualisiert + neu `goal-termination-phrases.md` und `goal-e2e-protocol.md` (je `.en.md`).
- **Standards/Templates**: `docs/standards/doku-consistency-checklist.md`, `docs/templates/story-template.md`, `docs/releases/_template-sprint.md`, `_template-major.md`, `_index.md` (je `.en.md`).
- **Runbook**: `docs/runbooks/sprint-run.md` (+ `.en.md`) mit *Veraltet-seit-v0.11.0*-Hinweis; `docs/INDEX.md`, `README.md`, `CONVENTIONS.md` nachgezogen.

## Vertraute Sprache / Glossar

- **Termination-Phrase** — maschinell prüfbarer Satz, der das objektiv beobachtbare End-Ergebnis beschreibt (alle Issues *Done*, Gates grün, Journal geschrieben); steuert, wann `/goal` terminiert.
- **Konfigurator + `/goal`-Wrapper** — die neue Rolle von `/sprint-run`: vorbereiten und an die native Engine übergeben, statt selbst zu schleifen.
- **Build-vs-Buy-Doktrin** — Entscheidungsregel, *was* das Framework baut: native Fähigkeit vorhanden → buy; Lücke → build.

Verweis: HANDBUCH Anhang C + `docs/glossar.md`.

## Bekannte Limitierungen

- **`/goal`-E2E ist ein manuelles Operator-Protokoll.** Ein End-to-End-Lauf der nativen Engine lässt sich nicht als CI-Bash-Smoke-Test skripten (LLM-Skills sind nicht skriptbar). Das manuelle 1-Story-E2E-Protokoll liegt in `sprint-run/references/goal-e2e-protocol.md` (+ `.en.md`).
- **Daemon-Loop-Runbook bewusst nur historische Referenz** — Neuschrift des Runbooks auf das `/goal`-Modell folgt separat.
- **Der `/goal`-Evaluator liest nur das Transkript** — Gate-Ergebnisse müssen als beobachtbare Fakten im Verlauf stehen; keine Manuell-Schritte in der Termination-Phrase.

## Stories-Mapping

| BOO | Titel | Label | Note |
|-----|-------|-------|------|
| BOO-198 | ADR-1 Build-vs-Buy-Doktrin (HANDBUCH Anhang AG) | governance | HANDBUCH Anhang AG |
| BOO-201 | ADR-4 — `/goal` supersedes Hybrid-Container-Modell | governance | HANDBUCH Anhang AD/AH |
| BOO-203 | `/sprint-run`-Refactor auf Konfigurator + `/goal` (v2.0.0) | feature | `sprint-run/SKILL.md` v2.0.0 |
| BOO-210 | `/goal`-Doku + `goal/README` (Anhang AH) | doku | `goal/README.md` |
| BOO-212 | Cleanup alte Hybrid-Doku (Runbook superseded) | doku | `docs/runbooks/sprint-run.md` |
| BOO-214 | Doku-Konsistenz-Standard + Story-Template (Anhang AI) | governance | `docs/standards/doku-consistency-checklist.md` |
| BOO-216 | Release-Notes-Standard (Sprint-/Major-Note, Anhang AJ) | governance | `docs/releases/_template-sprint.md` |

## ADR-Verweise

- **ADR-1 — Build-vs-Buy-Doktrin** (HANDBUCH **Anhang AG**, BOO-198): das Framework baut nicht nach, was Anthropic nativ liefert.
- **ADR-4 — Sprint-Run mit `/goal`** (HANDBUCH **Anhang AD/AH**, BOO-201/203): Hybrid-Container-Daemon-Modell superseded zugunsten der nativen `/goal`-Engine.

## Verifikation

`docs-drift-check` grün (0 Befunde) · DE/EN-Parität · `sprint-run` SKILL↔README v2.0.0 gleichstand.

---

# 🇬🇧 English Version

# Sprint 3 — build-vs-buy pivot: /sprint-run now runs on `/goal` (v0.11.0)

> Sprint release note following the convention in [`_template-sprint.en.md`](_template-sprint.en.md) (BOO-216). Sprint 3 ends at the 80% token boundary and is tagged on **v0.11.0**. Version overview (GitHub release body): [`v0.11.0-overview.md`](v0.11.0-overview.md).

## Highlights

- **Build-vs-buy pivot (ADR-1):** the framework no longer rebuilds what Anthropic delivers natively. The sprint termination loop moves from a home-grown daemon to the **Anthropic-native `/goal` engine** — framework = governance skeleton, Anthropic = engine.
- **`/sprint-run` 2.0.0:** from a hybrid-container daemon loop to a lean **configurator + `/goal` wrapper**. `/sprint-run` prepares (specs, worktrees, token budget, subagent files) and hands execution to `/goal`.
- **New `/goal` docs (`goal/`):** a dedicated folder documenting the native termination engine in the Code-Crash workflow — deliberately **without a `SKILL.md`**, because `/goal` is not a framework skill.
- **Documentation and release standards:** the documentation-consistency checklist + story-template mandatory block (BOO-214) and the release convention with sprint/major notes (BOO-216) are now anchored.

## What changes

- **BOO-198 — ADR-1 build-vs-buy doctrine.** A new doctrine (HANDBUCH **Appendix AG**) governs *what* the framework builds at all: native capability exists → buy; gap → build. Substitutable home-grown code is thinned out.
- **BOO-201 — ADR-4 `/goal` supersedes hybrid.** The previous hybrid-container daemon model is **superseded** from v0.11.0; the three former container boundaries are replaced (worktree instead of container volume, allowlist instead of container permissions, bodyguard instead of container sandbox).
- **BOO-203 — `/sprint-run` refactor (v2.0.0).** The skill shrinks to configurator + `/goal` wrapper; the execution loop belongs to the native engine. `/implement`, `/backlog`, `/sprint-review` stay unchanged.
- **BOO-210 — `/goal` docs + `goal/README`.** `goal/README.md` (+ `.en.md`) describes use 1 (sprint termination via `/sprint-run`) and use 2 (story termination in long `/implement` runs). HANDBUCH **Appendix AH** + new `sprint-run/references/goal-termination-phrases` and `goal-e2e-protocol`.
- **BOO-212 — cleanup of old hybrid docs.** The daemon-loop runbook (`docs/runbooks/sprint-run.md`) now carries a *deprecated-since-v0.11.0* notice and points to ADR-4; container/daemon terms in the skill/HANDBUCH docs are switched to the `/goal` model.
- **BOO-214 — documentation-consistency standard.** New `docs/standards/doku-consistency-checklist.md` (+ `.en.md`) + mandatory block in `docs/templates/story-template.md` (+ `.en.md`); HANDBUCH **Appendix AI**.
- **BOO-216 — release-notes standard.** New `_template-sprint.md` + `_template-major.md` + `_index.md` (each `.en.md`); HANDBUCH **Appendix AJ**. This sprint note is the first application.

## Breaking changes

- **`/sprint-run` mechanics (v1.x → v2.0.0):** the home-grown **daemon loop** (one story after another via `/implement` in daemon mode) is removed. Sprint execution now runs through the native `/goal` engine with a machine-checkable **termination phrase**. Scripts/runbooks built on the old loop are no longer valid.
- **Container logic removed:** the **hybrid-container model** (Dockerfile / `devcontainer.json` / container lifecycle / lazy bootstrap / hybrid-driver approval) is superseded. It is replaced by the three `/goal` boundaries (worktree isolation, bash allowlist, layer-0 bodyguard).
- **Old `/sprint-run` runbook superseded:** `docs/runbooks/sprint-run.en.md` describes the daemon-loop model (valid up to v0.10.x) and remains a historical reference only.

## Migration guide

Existing projects catch up idempotently/non-destructively (pattern `inspect → apply-safe → apply-with-confirmation`, see `bootstrap/references/framework-upgrade.en.md`):

1. **Create the bash auto-allow.** In `.claude/settings.local.json` add an **allowlist** with the gate commands (`semgrep`, `eslint`, `pytest`, `gh run`, `git`) so `/goal` and its subagents run the quality gates unattended without stalling on a permission prompt. (`/bootstrap` lays down the template.)
2. **Set `execution_isolation=worktree`.** Native subagents only write collision-free in parallel when worktree-isolated. If isolation is not `worktree`, `/sprint-run` **aborts** before the `/goal` call.
3. **Keep the layer-0 bodyguard active.** The `pre-edit-bodyguard` hook (PreToolUse on `Edit|Write`) must be live — otherwise `/sprint-run` **pauses** and does not call `/goal`.
4. **Stop using the old daemon/container runbook.** `docs/runbooks/sprint-run.en.md` is *superseded*; the sources of truth are `sprint-run/SKILL.md` (v2.0.0), `goal/README.en.md` and HANDBUCH **Appendix AD/AH**.

No file is deleted or overwritten; the three prerequisites were already recommended for daemon mode and become mandatory for the `/goal` call from v0.11.0.

## Switches & configuration

- **`.claude/settings.local.json` — bash allowlist** (gate commands): prerequisite 1 for the `/goal` call.
- **`execution_isolation=worktree`**: hard prerequisite — otherwise abort.
- **`pre-edit-bodyguard` hook**: hard prerequisite — otherwise pause.

No new opt-in/opt-out setup questions; the switches are the three `/goal` boundaries that `/sprint-run` checks before handing over.

## Documentation updates

- **HANDBUCH** (DE + EN): **Appendix AD** (`/sprint-run` as configurator + `/goal` engine), **Appendix AG** (build-vs-buy doctrine, ADR-1), **Appendix AH** (`/goal` engine, BOO-210), **Appendix AI** (documentation consistency, BOO-214), **Appendix AJ** (release convention, BOO-216) + `/sprint-run` entry in §6.
- **`goal/`** (new): `README.md` (+ `.en.md`) — use, limits, prerequisites of the native engine.
- **`sprint-run/`**: `SKILL.md` + `README.md` to **v2.0.0**, `references/` updated + new `goal-termination-phrases.md` and `goal-e2e-protocol.md` (each `.en.md`).
- **Standards/templates**: `docs/standards/doku-consistency-checklist.md`, `docs/templates/story-template.md`, `docs/releases/_template-sprint.md`, `_template-major.md`, `_index.md` (each `.en.md`).
- **Runbook**: `docs/runbooks/sprint-run.md` (+ `.en.md`) with a *deprecated-since-v0.11.0* notice; `docs/INDEX.md`, `README.md`, `CONVENTIONS.md` updated.

## Familiar language / glossary

- **Termination phrase** — a machine-checkable sentence describing the objectively observable end result (all issues *Done*, gates green, journal written); governs when `/goal` terminates.
- **Configurator + `/goal` wrapper** — the new role of `/sprint-run`: prepare and hand over to the native engine instead of looping itself.
- **Build-vs-buy doctrine** — the decision rule for *what* the framework builds: native capability exists → buy; gap → build.

Reference: HANDBUCH Appendix C + `docs/glossar.en.md`.

## Known limitations

- **`/goal` E2E is a manual operator protocol.** An end-to-end run of the native engine cannot be scripted as a CI bash smoke test (LLM skills are not scriptable). The manual 1-story E2E protocol is in `sprint-run/references/goal-e2e-protocol.en.md`.
- **Daemon-loop runbook deliberately a historical reference only** — a rewrite of the runbook to the `/goal` model follows separately.
- **The `/goal` evaluator reads only the transcript** — gate results must appear as observable facts in the conversation; no manual steps in the termination phrase.

## Stories mapping

| BOO | Title | Label | Note |
|-----|-------|-------|------|
| BOO-198 | ADR-1 build-vs-buy doctrine (HANDBUCH Appendix AG) | governance | HANDBUCH Appendix AG |
| BOO-201 | ADR-4 — `/goal` supersedes hybrid-container model | governance | HANDBUCH Appendix AD/AH |
| BOO-203 | `/sprint-run` refactor to configurator + `/goal` (v2.0.0) | feature | `sprint-run/SKILL.md` v2.0.0 |
| BOO-210 | `/goal` docs + `goal/README` (Appendix AH) | docs | `goal/README.en.md` |
| BOO-212 | cleanup of old hybrid docs (runbook superseded) | docs | `docs/runbooks/sprint-run.en.md` |
| BOO-214 | documentation-consistency standard + story template (Appendix AI) | governance | `docs/standards/doku-consistency-checklist.en.md` |
| BOO-216 | release-notes standard (sprint/major note, Appendix AJ) | governance | `docs/releases/_template-sprint.en.md` |

## ADR references

- **ADR-1 — build-vs-buy doctrine** (HANDBUCH **Appendix AG**, BOO-198): the framework does not rebuild what Anthropic delivers natively.
- **ADR-4 — sprint-run with `/goal`** (HANDBUCH **Appendix AD/AH**, BOO-201/203): hybrid-container daemon model superseded in favor of the native `/goal` engine.

## Verification

`docs-drift-check` green (0 findings) · DE/EN parity · `sprint-run` SKILL↔README v2.0.0 in lockstep.
