# Sprint 6 — Status Line + Validierung + Restklärung (v0.13.0)

> 🌐 **Sprache:** Deutsch + 🇬🇧 English (diese Datei, EN-Spiegel unten via `# 🇬🇧 English Version`)

> Sprint-Sammelnote (BOO-216-Konvention). Sprint 6 endete am 80%-Token-Boundary, getaggt auf **v0.13.0**. Umgesetzt in vier Slices: **6a** (Status-Line + `/goal`-E2E) · **6b** (Backlog-Sprint-Sync + ADR-5 Hermes) · **6c** (Infra-Layer-Klärung) · **Gate** (finaler Doku-Smoke-Test + v1.0-Major-Doku).

## Highlights

- **Worker-Equivalent läuft live in der Status Line.** Modell, Token-Budget, Story-Budget und das Menschen-Äquivalent (h/h) stehen jetzt nativ in der Claude-Code-Status-Line — der ROI-Anker aus Sprint 4 wird sichtbar, statt nur im Report zu schlummern.
- **Der Backlog schreibt zum ersten Mal zurück.** Der `backlog`-Skill bekommt einen geführten, dry-run-default Sprint-Plan-Sync-Modus: Sprint-Zuordnungen aus `Sprints.md` landen append-only als Linear-Label `sprint-N`, jeder Lauf wird protokolliert.
- **ADR-5 (Hermes) festgezurrt + ein Wächter dazu.** Hermes bleibt vorerst differenzierend, solange Anthropics Agent Teams experimentell sind — `quality-gate-audit` beobachtet das monatlich und meldet, wenn der Re-Evaluations-Trigger zieht (kein Hard-Block).
- **Infra-Layer geklärt.** 13-Layer-Raster als eigene Achse neben den Architektur-Dimensionen verankert; Output sind die Folge-Stories BOO-220/221/223 (Sprint 7+).

## Was sich ändert

- **BOO-205:** Status-Line-Custom-Script `bootstrap/templates/statusline.sh` (liest nativen stdin: Modell/Kontext/$ und reichert um Worker-Equivalent h/h aus der Story-Spec an). `migrate_boo_205()` (Schalter-A-gated, idempotent: `statusline.sh` + `settings.json`-`statusLine`-Merge + `environment.json`-Referenz), `verify-setup.sh` §5c, HANDBUCH **Anhang AQ** (DE+EN). bootstrap **3.43.0 → 3.44.0**.
- **BOO-194:** `backlog`-Skill **Schritt 6 „Sprint-Plan-Sync"** — der erste schreibende Modus (Schritte 0–5 bleiben read-only). Append-only Label `sprint-N` via `save_issue`, AC-Abgleich gegen Specs, **Dry-Run-Default**, Audit-Log `docs/audits/backlog-sync-YYYY-MM-DD.md`, **nur** auf manuellen Trigger `/backlog sync`. backlog **1.7.0 → 1.8.0**.
- **BOO-202:** **ADR-5 entschieden** (Status quo halten — Hermes-Layer vs Agent Teams). `quality-gate-audit` bekommt eine **monatliche Native-Feature-Beobachtung** (Watch, kein Gate): erinnert an den Agent-Teams-Status auf [code.claude.com] und meldet, sobald Re-Eval-Trigger 1 (Agent Teams → *stable*) erfüllt ist. quality-gate-audit **1.0.0 → 1.1.0**.
- **BOO-217:** Infra-Layer-Verankerung **geklärt** (Ideation) — 13-Layer-Raster als separate Achse neben §5 (Querverweis, keine Dopplung), Katalog als Fragen-/Risiko-Raster, Projekt-Tabelle als Single Entry Point. Output: Folge-Stories **BOO-220/221/222/223** (Sprint 7+) + **BOO-224** (Supabase/RAG, geparkt). Klärungs-Notiz + Ist/Soll-Sketch im Vault.

## Breaking Changes

Keine. Sprint 6 ist additiv. Die Status-Line greift **nur** bei `runtime_target=claude-code` (Schalter-A-Kopplung); der Backlog-Sync ist opt-in und dry-run-default; die Native-Feature-Beobachtung ist eine Meldung, kein Block. Bestandsprojekte bleiben unverändert, bis sie die Migration ziehen.

## Migrations-Anleitung

Bestandsprojekte (idempotent, nicht-destruktiv):

1. `intentron migrate` laufen lassen → führt `migrate_boo_205()` aus: legt `statusline.sh` an, merged den `statusLine`-Block in `settings.json` und ergänzt die `environment.json`-Manifest-Referenz — **nur** wenn `runtime_target=claude-code` (Schalter-A-gated), sonst übersprungen.
2. `bash scripts/verify-setup.sh` → §5c prüft die Status-Line-Verdrahtung (Script vorhanden, `settings.json`-Eintrag, Manifest-Referenz).
3. Wer `codex`/`cross-tool` fährt: nichts zu tun — die Status-Line bleibt inaktiv.

Details: `references/framework-upgrade.md` (`inspect → apply-safe → apply-with-confirmation`).

## Schalter & Konfiguration

- **Status Line** — an `runtime_target=claude-code` gekoppelt (Schalter A). Claude Code rendert die Zeile aus `settings.json`; `environment.json` hält die Manifest-Referenz (dokumentiert in HANDBUCH Anhang AQ).
- **Backlog-Sprint-Sync** — kein Default; läuft nur auf `/backlog sync` und zeigt erst einen Dry-Run, bevor irgendetwas geschrieben wird.

## Doku-Updates

- **HANDBUCH Anhang AQ** (DE+EN) — Status Line / Worker-Equivalent live.
- **`quality-gate-audit`** SKILL+README (DE+EN, 1.1.0) — Abschnitt „Native-Feature-Beobachtung (ADR-5 Re-Eval-Trigger)".
- **`backlog`** SKILL+README (DE+EN, 1.8.0) — Schritt 6 Sprint-Plan-Sync.
- **Vault** — `Decisions/` ADR-5 (`offen` → `entschieden`), Infra-Layer-Klärungs-Notiz + Ist/Soll-Sketch in `assets/`, Skill-Dokus (`statusline`/`backlog`/`quality-gate-audit`) DE+EN nachgezogen.
- **Doku-Smoke-Test (BOO-215)** — `docs/reports/doku-smoke-test-sprint-3-6.md` (+ `.en.md`) prüft alle Sprint-3–6-Doku-Outputs gegen den Konsistenz-Standard.

## Vertraute Sprache / Glossar

- **Status Line** — die native Claude-Code-Statuszeile, hier um das Worker-Equivalent angereichert. Siehe `docs/glossar.md` + HANDBUCH Anhang C.
- **Native-Feature-Beobachtung** — ein monatlicher Watch (kein Gate), der prüft, ob ein nachgebautes Framework-Feature inzwischen nativ (stable) verfügbar ist und eine ADR-Re-Evaluation auslöst.

## Bekannte Limitierungen

- **BOO-218 (`/goal`-E2E-Lauf)** ist **operator-gebunden** und läuft asynchron beim Framework-Reinstall (native LLM-Subagents, nicht skriptbar). Schließt die zwei offenen BOO-203-Checkboxen (Gate-Recovery + Gate-Assertion) ab — blockiert den Sprint-6-Release nicht.
- **v1.0.0-Tag + GitHub-Release + 3-VPS-Rollout** = post-Sprint-6 / **BOO-9** (Major-Phase). Sprint 6 released v0.13.0; das v1.0-Dokument beschreibt v1.0, taggt es aber nicht.
- **Infra-Layer-Umsetzung** = Sprint 7+ (BOO-220 → 221 → 223; BOO-222 parallel; BOO-224 geparkt).

## Stories-Mapping

| BOO | Titel | Label | Slice / Note |
|-----|-------|-------|--------------|
| BOO-205 | Status-Line-Custom-Script mit Worker-Equivalent live | feat | 6a · PR [#95](https://github.com/vibercoder79/intentron/pull/95) |
| BOO-218 | echter `/goal`-E2E-Lauf (Operator) — schließt BOO-203 ab | qa | 6a · operator-async (offen) |
| BOO-194 | Backlog-Skill: Schritt 6 Sprint-Plan-Sync | feat | 6b · PR [#96](https://github.com/vibercoder79/intentron/pull/96) |
| BOO-202 | ADR-5: Hermes-Layer vs Agent Teams + Native-Feature-Watch | feat | 6b · PR [#97](https://github.com/vibercoder79/intentron/pull/97) |
| BOO-217 | Infrastruktur-Layer verankern — Klärung + Ideation | — | 6c · Ideation (Done) → BOO-220/221/222/223 |
| BOO-215 | Finaler Doku-Smoke-Test Sprint 3–6 + v1.0-Major-Doku | qa, docs | Gate · diese Release-Welle |

## ADR-Verweise

- **ADR-5 — Hermes-Layer vs Agent Teams (Re-Evaluations-Trigger)** (BOO-202, Vault `Decisions/`, gespiegelt in `quality-gate-audit`-Skill). Status quo halten, solange Agent Teams experimentell sind.

## Verifikation

`docs-drift-check` grün (0 Befunde) · DE/EN-Parität · SKILL↔README-Version gleichstand · CI grün (PRs #95, #96, #97).

---

# 🇬🇧 English Version

# Sprint 6 — Status line + validation + remaining clarifications (v0.13.0)

> Sprint roll-up note (BOO-216 convention). Sprint 6 ended at the 80% token boundary, tagged on **v0.13.0**. Delivered in four slices: **6a** (status line + `/goal` E2E) · **6b** (backlog sprint sync + ADR-5 Hermes) · **6c** (infra-layer clarification) · **Gate** (final doc smoke test + v1.0 major doc).

## Highlights

- **Worker-equivalent runs live in the status line.** Model, token budget, story budget and the human equivalent (h/h) now sit natively in the Claude Code status line — the ROI anchor from Sprint 4 becomes visible instead of dozing in a report.
- **The backlog writes back for the first time.** The `backlog` skill gains a guided, dry-run-default sprint-plan sync mode: sprint assignments from `Sprints.md` land append-only as the Linear label `sprint-N`, every run is logged.
- **ADR-5 (Hermes) locked + a watcher added.** Hermes stays differentiating for now, as long as Anthropic's Agent Teams are experimental — `quality-gate-audit` watches this monthly and reports when the re-evaluation trigger fires (no hard block).
- **Infra-layer clarified.** A 13-layer grid is anchored as its own axis next to the architecture dimensions; the output is the follow-up stories BOO-220/221/223 (Sprint 7+).

## What changes

- **BOO-205:** Status-line custom script `bootstrap/templates/statusline.sh` (reads native stdin: model/context/$ and enriches with worker-equivalent h/h from the story spec). `migrate_boo_205()` (switch-A-gated, idempotent: `statusline.sh` + `settings.json` `statusLine` merge + `environment.json` reference), `verify-setup.sh` §5c, HANDBUCH **Appendix AQ** (DE+EN). bootstrap **3.43.0 → 3.44.0**.
- **BOO-194:** `backlog` skill **step 6 "sprint-plan sync"** — the first writing mode (steps 0–5 stay read-only). Append-only label `sprint-N` via `save_issue`, AC reconciliation against specs, **dry-run default**, audit log `docs/audits/backlog-sync-YYYY-MM-DD.md`, **only** on the manual trigger `/backlog sync`. backlog **1.7.0 → 1.8.0**.
- **BOO-202:** **ADR-5 decided** (hold the status quo — Hermes layer vs Agent Teams). `quality-gate-audit` gains a **monthly native-feature watch** (watch, not a gate): reminds of the Agent Teams status on [code.claude.com] and reports once re-eval trigger 1 (Agent Teams → *stable*) is met. quality-gate-audit **1.0.0 → 1.1.0**.
- **BOO-217:** Infra-layer anchoring **clarified** (ideation) — a 13-layer grid as a separate axis next to §5 (cross-reference, no duplication), the catalog as a question/risk grid, the project table as the single entry point. Output: follow-up stories **BOO-220/221/222/223** (Sprint 7+) + **BOO-224** (Supabase/RAG, parked). Clarification note + as-is/to-be sketch in the vault.

## Breaking changes

None. Sprint 6 is additive. The status line only fires under `runtime_target=claude-code` (switch-A coupling); the backlog sync is opt-in and dry-run-default; the native-feature watch is a report, not a block. Existing projects stay unchanged until they pull the migration.

## Migration guide

Existing projects (idempotent, non-destructive):

1. Run `intentron migrate` → executes `migrate_boo_205()`: creates `statusline.sh`, merges the `statusLine` block into `settings.json` and adds the `environment.json` manifest reference — **only** when `runtime_target=claude-code` (switch-A-gated), otherwise skipped.
2. `bash scripts/verify-setup.sh` → §5c checks the status-line wiring (script present, `settings.json` entry, manifest reference).
3. If you run `codex`/`cross-tool`: nothing to do — the status line stays inactive.

Details: `references/framework-upgrade.md` (`inspect → apply-safe → apply-with-confirmation`).

## Switches & configuration

- **Status line** — coupled to `runtime_target=claude-code` (switch A). Claude Code renders the line from `settings.json`; `environment.json` holds the manifest reference (documented in HANDBUCH Appendix AQ).
- **Backlog sprint sync** — no default; runs only on `/backlog sync` and shows a dry-run first before writing anything.

## Documentation updates

- **HANDBUCH Appendix AQ** (DE+EN) — status line / worker-equivalent live.
- **`quality-gate-audit`** SKILL+README (DE+EN, 1.1.0) — "native-feature watch (ADR-5 re-eval trigger)" section.
- **`backlog`** SKILL+README (DE+EN, 1.8.0) — step 6 sprint-plan sync.
- **Vault** — `Decisions/` ADR-5 (`open` → `decided`), infra-layer clarification note + as-is/to-be sketch in `assets/`, skill docs (`statusline`/`backlog`/`quality-gate-audit`) carried in DE+EN.
- **Doc smoke test (BOO-215)** — `docs/reports/doku-smoke-test-sprint-3-6.md` (+ `.en.md`) checks all Sprint 3–6 doc outputs against the consistency standard.

## Familiar language / glossary

- **Status line** — the native Claude Code status line, here enriched with the worker-equivalent. See `docs/glossar.en.md` + HANDBUCH Appendix C.
- **Native-feature watch** — a monthly watch (not a gate) that checks whether a rebuilt framework feature is now natively (stable) available and triggers an ADR re-evaluation.

## Known limitations

- **BOO-218 (`/goal` E2E run)** is **operator-bound** and runs asynchronously at framework reinstall (native LLM subagents, not scriptable). It closes the two open BOO-203 checkboxes (gate recovery + gate assertion) — it does not block the Sprint 6 release.
- **v1.0.0 tag + GitHub release + 3-VPS rollout** = post-Sprint-6 / **BOO-9** (major phase). Sprint 6 releases v0.13.0; the v1.0 document describes v1.0 but does not tag it.
- **Infra-layer implementation** = Sprint 7+ (BOO-220 → 221 → 223; BOO-222 in parallel; BOO-224 parked).

## Stories mapping

| BOO | Title | Label | Slice / note |
|-----|-------|-------|--------------|
| BOO-205 | Status-line custom script with worker-equivalent live | feat | 6a · PR [#95](https://github.com/vibercoder79/intentron/pull/95) |
| BOO-218 | real `/goal` E2E run (operator) — closes BOO-203 | qa | 6a · operator-async (open) |
| BOO-194 | Backlog skill: step 6 sprint-plan sync | feat | 6b · PR [#96](https://github.com/vibercoder79/intentron/pull/96) |
| BOO-202 | ADR-5: Hermes layer vs Agent Teams + native-feature watch | feat | 6b · PR [#97](https://github.com/vibercoder79/intentron/pull/97) |
| BOO-217 | Anchor infrastructure layer — clarification + ideation | — | 6c · ideation (done) → BOO-220/221/222/223 |
| BOO-215 | Final doc smoke test Sprint 3–6 + v1.0 major doc | qa, docs | Gate · this release wave |

## ADR references

- **ADR-5 — Hermes layer vs Agent Teams (re-evaluation trigger)** (BOO-202, vault `Decisions/`, mirrored in the `quality-gate-audit` skill). Hold the status quo as long as Agent Teams are experimental.

## Verification

`docs-drift-check` green (0 findings) · DE/EN parity · SKILL↔README version in lockstep · CI green (PRs #95, #96, #97).
</content>
</invoke>
