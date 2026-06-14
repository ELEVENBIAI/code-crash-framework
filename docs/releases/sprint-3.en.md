# Sprint 3 — build-vs-buy pivot: /sprint-run now runs on `/goal` (v0.11.0)

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](sprint-3.md)

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
- **BOO-210 — `/goal` docs + `goal/README`.** `goal/README.en.md` (+ `.md`) describes use 1 (sprint termination via `/sprint-run`) and use 2 (story termination in long `/implement` runs). HANDBUCH **Appendix AH** + new `sprint-run/references/goal-termination-phrases` and `goal-e2e-protocol`.
- **BOO-212 — cleanup of old hybrid docs.** The daemon-loop runbook (`docs/runbooks/sprint-run.en.md`) now carries a *deprecated-since-v0.11.0* notice and points to ADR-4; container/daemon terms in the skill/HANDBUCH docs are switched to the `/goal` model.
- **BOO-214 — documentation-consistency standard.** New `docs/standards/doku-consistency-checklist.en.md` (+ `.md`) + mandatory block in `docs/templates/story-template.en.md` (+ `.md`); HANDBUCH **Appendix AI**.
- **BOO-216 — release-notes standard.** New `_template-sprint.en.md` + `_template-major.en.md` + `_index.en.md` (each with `.md`); HANDBUCH **Appendix AJ**. This sprint note is the first application.

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
- **`goal/`** (new): `README.en.md` (+ `.md`) — use, limits, prerequisites of the native engine.
- **`sprint-run/`**: `SKILL.md` + `README.md` to **v2.0.0**, `references/` updated + new `goal-termination-phrases.md` and `goal-e2e-protocol.md` (each `.en.md`).
- **Standards/templates**: `docs/standards/doku-consistency-checklist.en.md`, `docs/templates/story-template.en.md`, `docs/releases/_template-sprint.en.md`, `_template-major.en.md`, `_index.en.md` (each with `.md`).
- **Runbook**: `docs/runbooks/sprint-run.en.md` (+ `.md`) with a *deprecated-since-v0.11.0* notice; `docs/INDEX.en.md`, `README.md`, `CONVENTIONS.md` updated.

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
