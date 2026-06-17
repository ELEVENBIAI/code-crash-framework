# Sprint 5 — Claude-Code-first: Schalter A/B/C + Implement-Migration (v0.12.0)

> 🌐 **Sprache:** Deutsch + 🇬🇧 English (diese Datei, EN-Spiegel unten via `# 🇬🇧 English Version`)

> Sprint-Sammelnote (BOO-216-Konvention). Sprint 5 endete am 80%-Token-Boundary, getaggt auf **v0.12.0**. Umgesetzt in vier Slices: **5a** (Fundament) · **5b-1** (Implement-Cluster) · **5b-2** (Plan + Complement) · **5b-3** (Docs/Runbook).

## Highlights

- **Claude-Code-first-Pivot (ADR-2):** Drei Schalter aktivieren native Claude-Code-Pfade statt sie nachzubauen. Das Framework wird zum Governance-Skelett, Anthropic liefert den Motor.
- **Schalter A** — Bootstrap-Default `runtime_target=claude-code`; neuer **Native-Pfade-Block** in der CLAUDE.md mit vier Flags.
- **Schalter B** — `/implement` generiert echte **native Subagents** (eigenes 200k-Kontextfenster pro Agent); `/architecture-review` + `/ideation` schlagen **`/ultraplan`** vor; neuer Skill **`insights-review`** (`/insights`-Komplement zum Sprint-Review).
- **Schalter C** — Routinen kommen als **Runbook** mit kopierbereiten Prompts, nicht als Bootstrap-Frage.
- Dazu: ADR-3 (Automemory vs Learning-Loop), die **13-Komponenten-USP-Liste** (Build-vs-Buy sichtbar) und `/rewind`-Doku.

## Was sich ändert

- **BOO-199:** Schalter A — A.1c-Default `unklar` → `claude-code`; `native_paths`-Block (`prefer_native_subagents`, `prefer_goal_termination`, `prefer_ultraplan`, `complement_insights`) im CLAUDE.md-Template; `migrate_boo_199()`; `verify-setup.sh` §4b. bootstrap **3.41.0**.
- **BOO-200:** ADR-3 entschieden; HANDBUCH Anhang AM; Bootstrap-Block **D.4b** legt einen Automemory-Abgrenzungs-Header an (`migrate_boo_200()`, `verify-setup.sh` §4c). bootstrap **3.42.0**.
- **BOO-204:** `/implement` Schritt 0d (liest `prefer_native_subagents`) + Schritt 4b (Native-Subagent-Generierung, `## Subagents`-Spec-Konvention). implement **2.16.0**.
- **BOO-208:** `/implement`-Notiz „Rollback per `/rewind`" + HANDBUCH §11b „Checkpoints".
- **BOO-207:** `/architecture-review` (0b) + `/ideation` (3b) Ultraplan-Trigger; HANDBUCH Anhang AN; `## Plan`-Spec-Konvention. architecture-review **1.13.0**, ideation **2.9.0**.
- **BOO-206:** neuer Skill `insights-review` (1.0.0); `/sprint-review` Schritt 7d (`complement_insights`). sprint-review **2.8.0**.
- **BOO-211:** HANDBUCH Anhang AO „Sprint Review vs /insights".
- **BOO-213:** Schalter C — Runbook `docs/runbooks/routinen-vernetzen.md` (3 Aufstellungen, 7 Routinen); Bootstrap-Abschluss-Hinweis. bootstrap **3.43.0**.
- **BOO-209:** 13-Komponenten-USP-Liste — HANDBUCH Anhang AP (kanonisch), pitch **1.2.0**, README, Vault-MOC.

## Breaking Changes

Keine. Sprint 5 ist additiv. Der Default-Wechsel `runtime_target` betrifft **nur Neuanlagen**; Bestandsprojekte bleiben unverändert, bis sie die Migration ziehen. Eine explizite `codex`/`cross-tool`-Wahl wird nie überschrieben.

## Migrations-Anleitung

Bestandsprojekte (idempotent, nicht-destruktiv):

1. `intentron migrate` laufen lassen → führt `migrate_boo_199()` (setzt `runtime_target=claude-code` **nur** wenn `unknown`/fehlend; hängt den Native-Pfade-Block an die CLAUDE.md) und `migrate_boo_200()` (Automemory-Abgrenzungs-Header) aus.
2. `bash scripts/verify-setup.sh` → prüft `runtime_target`, Native-Pfade-Block (§4b) und Automemory-Header (§4c).
3. Wer `codex`/`cross-tool` fährt: nichts zu tun — Native-Pfade bleiben inaktiv (Schalter-A-Kopplung).

Details: `references/framework-upgrade.md` (`inspect → apply-safe → apply-with-confirmation`).

## Schalter & Konfiguration

Neuer **`native_paths`-Block** im CLAUDE.md-Template (Schalter B), nur aktiv bei `runtime_target: claude-code`:

- `prefer_native_subagents` (Default `true`) — `/implement` → echte `.claude/agents/<story>-<agent>.md`.
- `prefer_goal_termination` (Default `true`) — `/sprint-run` nutzt `/goal`.
- `prefer_ultraplan` (Default `auto`) — `/architecture-review` + `/ideation` schlagen `/ultraplan` vor (`auto|always|never`).
- `complement_insights` (Default `true`) — `/sprint-review` ruft `insights-review`/`/insights`.

Schalter A: `runtime_target`-Default jetzt `claude-code`. Schalter C: keine Bootstrap-Frage — Runbook.

## Doku-Updates

HANDBUCH-Anhänge **AL** (Schalter A/Native-Pfade), **AM** (Automemory vs Learning-Loop), **AN** (Cloud-Engine /ultraplan), **AO** (Sprint Review vs /insights), **AP** (USP 13 Komponenten) + **§11b** (Checkpoints/`/rewind`); TOC + Signpost (42 Anhänge). Neuer Skill `insights-review` (SKILL/README/Sketch DE+EN). Runbook `routinen-vernetzen.md` (+ `.en`). USP-Block in `pitch`, README, Vault-MOC `USP-Komponenten.md`. `## Subagents`- und `## Plan`-Spec-Konventionen. ADR-2 + ADR-3 → `entschieden`. Alles DE+EN.

## Vertraute Sprache / Glossar

- **Native-Pfade** — die vier `native_paths`-Flags, die native Claude-Code-Mechanismen vor Framework-Eigenbau bevorzugen.
- **Ultraplan** — Anthropics native Code-Level-Planungs-Engine (Schwester zu `/goal`).
- **complement_insights** — Operator-Reflexion (`/insights`) als abgegrenzte Begleitung zum Sprint-Review.

## Bekannte Limitierungen

- **BOO-215** (finaler Doku-Smoke-Test, zielgeführte E2E-Verifikation) folgt nach Sprint 6.
- **BOO-205** (Status-Line mit Worker-Equivalent live) bleibt Sprint 6.
- Native-Subagent-Generierung von `/implement` ist Instruktions-Logik (Skill), kein Bash-Generator.

## Stories-Mapping

| BOO | Titel | Label | Slice / PR |
|-----|-------|-------|------------|
| BOO-199 | Schalter A + Native-Pfade-Block (ADR-2) | governance, skill-change | 5a · [PR #88](https://github.com/vibercoder79/intentron/pull/88) |
| BOO-200 | ADR-3 Automemory vs Learning-Loop + MEMORY.md-Header | governance | 5a · [PR #88](https://github.com/vibercoder79/intentron/pull/88) / [#89](https://github.com/vibercoder79/intentron/pull/89) |
| BOO-204 | /implement → native Subagents | skill-change, Feature | 5b-1 · [PR #91](https://github.com/vibercoder79/intentron/pull/91) |
| BOO-208 | /rewind-Doku in /implement | docs | 5b-1 · [PR #91](https://github.com/vibercoder79/intentron/pull/91) |
| BOO-207 | /architecture-review + /ideation Ultraplan-Trigger | skill-change, Feature | 5b-2 · [PR #92](https://github.com/vibercoder79/intentron/pull/92) |
| BOO-206 | insights-review-Skill (complement_insights) | skill-change, Feature | 5b-2 · [PR #92](https://github.com/vibercoder79/intentron/pull/92) |
| BOO-211 | HANDBUCH „Sprint Review vs /insights" | docs | 5b-2 · [PR #92](https://github.com/vibercoder79/intentron/pull/92) |
| BOO-213 | Runbook „Routinen vernetzen" + Bootstrap-Hinweis (Schalter C) | docs, skill-change | 5b-3 · [PR #93](https://github.com/vibercoder79/intentron/pull/93) |
| BOO-209 | USP-Liste 13 Komponenten ohne Anthropic-Pendant | docs, skill-change | 5b-3 · [PR #93](https://github.com/vibercoder79/intentron/pull/93) |

## ADR-Verweise

- **ADR-2 — Claude-Code-first Pivot, Schalter A B C** (HANDBUCH Anhang AL/AN/AO, BOO-199).
- **ADR-3 — Automemory vs Learning-Loop** (HANDBUCH Anhang AM, BOO-200).
- **ADR-1 — Build-vs-Buy-Doktrin** (HANDBUCH Anhang AG/AP, BOO-198/209).

## Verifikation

`docs-drift-check` grün (0 Befunde, 20 Skills) · DE/EN-Parität · SKILL↔README-Version-Gleichstand (bootstrap 3.43.0, implement 2.16.0, architecture-review 1.13.0, ideation 2.9.0, sprint-review 2.8.0, pitch 1.2.0, insights-review 1.0.0) · CI grün (PRs #88, #89, #91, #92, #93).

---

# 🇬🇧 English Version

# Sprint 5 — Claude-Code-first: switches A/B/C + implement migration (v0.12.0)

> Sprint roll-up note (BOO-216 convention). Sprint 5 ended at the 80% token boundary, tagged **v0.12.0**. Delivered in four slices: **5a** (foundation) · **5b-1** (implement cluster) · **5b-2** (plan + complement) · **5b-3** (docs/runbook).

## Highlights

- **Claude-Code-first pivot (ADR-2):** three switches activate native Claude Code paths instead of rebuilding them. The framework becomes the governance skeleton, Anthropic provides the engine.
- **Switch A** — bootstrap default `runtime_target=claude-code`; new **native-paths block** in CLAUDE.md with four flags.
- **Switch B** — `/implement` generates real **native subagents** (own 200k context window per agent); `/architecture-review` + `/ideation` suggest **`/ultraplan`**; new skill **`insights-review`** (`/insights` companion to the sprint review).
- **Switch C** — routines come as a **runbook** with copy-ready prompts, not a bootstrap question.
- Plus: ADR-3 (Automemory vs Learning-Loop), the **13-component USP list** (build-vs-buy made visible) and `/rewind` docs.

## What changes

- **BOO-199:** switch A — A.1c default `unclear` → `claude-code`; `native_paths` block (`prefer_native_subagents`, `prefer_goal_termination`, `prefer_ultraplan`, `complement_insights`) in the CLAUDE.md template; `migrate_boo_199()`; `verify-setup.sh` §4b. bootstrap **3.41.0**.
- **BOO-200:** ADR-3 decided; HANDBUCH Appendix AM; bootstrap block **D.4b** prepends an automemory boundary header (`migrate_boo_200()`, `verify-setup.sh` §4c). bootstrap **3.42.0**.
- **BOO-204:** `/implement` step 0d (reads `prefer_native_subagents`) + step 4b (native subagent generation, `## Subagents` spec convention). implement **2.16.0**.
- **BOO-208:** `/implement` note "rollback via `/rewind`" + HANDBUCH §11b "checkpoints".
- **BOO-207:** `/architecture-review` (0b) + `/ideation` (3b) ultraplan trigger; HANDBUCH Appendix AN; `## Plan` spec convention. architecture-review **1.13.0**, ideation **2.9.0**.
- **BOO-206:** new skill `insights-review` (1.0.0); `/sprint-review` step 7d (`complement_insights`). sprint-review **2.8.0**.
- **BOO-211:** HANDBUCH Appendix AO "Sprint Review vs /insights".
- **BOO-213:** switch C — runbook `docs/runbooks/routinen-vernetzen.en.md` (3 setups, 7 routines); bootstrap closing hint. bootstrap **3.43.0**.
- **BOO-209:** 13-component USP list — HANDBUCH Appendix AP (canonical), pitch **1.2.0**, README, vault MOC.

## Breaking changes

None. Sprint 5 is additive. The `runtime_target` default change affects **new projects only**; existing projects stay unchanged until they pull the migration. An explicit `codex`/`cross-tool` choice is never overwritten.

## Migration guide

Existing projects (idempotent, non-destructive):

1. Run `intentron migrate` → runs `migrate_boo_199()` (sets `runtime_target=claude-code` **only** if `unknown`/missing; appends the native-paths block to CLAUDE.md) and `migrate_boo_200()` (automemory boundary header).
2. Run `bash scripts/verify-setup.sh` → checks `runtime_target`, native-paths block (§4b) and automemory header (§4c).
3. On `codex`/`cross-tool`: nothing to do — native paths stay inactive (switch-A coupling).

Details: `references/framework-upgrade.md` (`inspect → apply-safe → apply-with-confirmation`).

## Switches & configuration

New **`native_paths` block** in the CLAUDE.md template (switch B), active only when `runtime_target: claude-code`:

- `prefer_native_subagents` (default `true`) — `/implement` → real `.claude/agents/<story>-<agent>.md`.
- `prefer_goal_termination` (default `true`) — `/sprint-run` uses `/goal`.
- `prefer_ultraplan` (default `auto`) — `/architecture-review` + `/ideation` suggest `/ultraplan` (`auto|always|never`).
- `complement_insights` (default `true`) — `/sprint-review` calls `insights-review`/`/insights`.

Switch A: `runtime_target` default is now `claude-code`. Switch C: no bootstrap question — runbook.

## Documentation updates

HANDBUCH appendices **AL** (switch A/native paths), **AM** (Automemory vs Learning-Loop), **AN** (cloud-engine /ultraplan), **AO** (Sprint Review vs /insights), **AP** (USP 13 components) + **§11b** (checkpoints/`/rewind`); TOC + signpost (42 appendices). New skill `insights-review` (SKILL/README/sketch DE+EN). Runbook `routinen-vernetzen` (+ `.en`). USP block in `pitch`, README, vault MOC `USP-Komponenten.md`. `## Subagents` and `## Plan` spec conventions. ADR-2 + ADR-3 → `decided`. All DE+EN.

## Familiar language / glossary

- **Native paths** — the four `native_paths` flags that prefer native Claude Code mechanisms over framework-built equivalents.
- **Ultraplan** — Anthropic's native code-level planning engine (sibling to `/goal`).
- **complement_insights** — operator reflection (`/insights`) as a separated companion to the sprint review.

## Known limitations

- **BOO-215** (final docs smoke test, goal-driven E2E verification) follows after Sprint 6.
- **BOO-205** (status line with worker-equivalent live) stays in Sprint 6.
- `/implement`'s native subagent generation is instruction logic (skill), not a bash generator.

## Stories mapping

| BOO | Title | Label | Slice / PR |
|-----|-------|-------|------------|
| BOO-199 | Switch A + native-paths block (ADR-2) | governance, skill-change | 5a · [PR #88](https://github.com/vibercoder79/intentron/pull/88) |
| BOO-200 | ADR-3 Automemory vs Learning-Loop + MEMORY.md header | governance | 5a · [PR #88](https://github.com/vibercoder79/intentron/pull/88) / [#89](https://github.com/vibercoder79/intentron/pull/89) |
| BOO-204 | /implement → native subagents | skill-change, Feature | 5b-1 · [PR #91](https://github.com/vibercoder79/intentron/pull/91) |
| BOO-208 | /rewind docs in /implement | docs | 5b-1 · [PR #91](https://github.com/vibercoder79/intentron/pull/91) |
| BOO-207 | /architecture-review + /ideation ultraplan trigger | skill-change, Feature | 5b-2 · [PR #92](https://github.com/vibercoder79/intentron/pull/92) |
| BOO-206 | insights-review skill (complement_insights) | skill-change, Feature | 5b-2 · [PR #92](https://github.com/vibercoder79/intentron/pull/92) |
| BOO-211 | HANDBUCH "Sprint Review vs /insights" | docs | 5b-2 · [PR #92](https://github.com/vibercoder79/intentron/pull/92) |
| BOO-213 | Runbook "wire routines" + bootstrap hint (switch C) | docs, skill-change | 5b-3 · [PR #93](https://github.com/vibercoder79/intentron/pull/93) |
| BOO-209 | USP list 13 components without an Anthropic equivalent | docs, skill-change | 5b-3 · [PR #93](https://github.com/vibercoder79/intentron/pull/93) |

## ADR references

- **ADR-2 — Claude-Code-first pivot, switches A B C** (HANDBUCH Appendix AL/AN/AO, BOO-199).
- **ADR-3 — Automemory vs Learning-Loop** (HANDBUCH Appendix AM, BOO-200).
- **ADR-1 — build-vs-buy doctrine** (HANDBUCH Appendix AG/AP, BOO-198/209).

## Verification

`docs-drift-check` green (0 findings, 20 skills) · DE/EN parity · SKILL↔README version lockstep (bootstrap 3.43.0, implement 2.16.0, architecture-review 1.13.0, ideation 2.9.0, sprint-review 2.8.0, pitch 1.2.0, insights-review 1.0.0) · CI green (PRs #88, #89, #91, #92, #93).
