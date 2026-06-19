# Documentation smoke test — Sprint 3–6 (BOO-215)

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](doku-smoke-test-sprint-3-6.md)

> Goal-directed, final documentation smoke test across all Sprint-3-to-6 outputs. Evaluation standard: [`../standards/doku-consistency-checklist.en.md`](../standards/doku-consistency-checklist.en.md) (BOO-214, 11 points). Run on 2026-06-19 before the v0.13.0 release and before the v1.0 major doc.

## Overall verdict

**PASSED — green, with two gaps fixed directly.** Machine gate `docs-drift-check` rc=0 (20 skills, 0 findings). Four persona journeys walked end-to-end, all four navigable. Per-story consistency checked across Sprint 3–6; two real gaps found (plain-language glossary, doc index) and **fixed within this story** — no follow-up fix story needed.

## Method (anti-fabrication discipline)

Checked in two layers: (1) read-only sub-agents per story cluster (Sprint 3+4, Sprint 5, Sprint 6) against the 11-point checklist; (2) **lead cross-check of every reported finding against the real file** before it counts as a gap. This was necessary: several findings reported as "CRITICAL" were **fabricated** and rejected with evidence (see "Rejected findings"). Every pass/fail row below is backed by a real path.

## Story inventory (smoke-test scope)

| Sprint | Release | Stories |
|--------|---------|---------|
| 3 | v0.11.0 | BOO-198, 201, 203, 210, 212, 214, 216 |
| 4 | Wave CE | BOO-190, 191, 192, 193 |
| 5 | v0.12.0 | BOO-199, 200, 204, 206, 207, 208, 209, 211, 213 |
| 6 | v0.13.0 | BOO-205, 194, 202, 217 (+ BOO-218 operator-async, open) |

## Per-story consistency (condensed)

Only points with a finding or deliberate n/a. Full evidence tables are captured in the cluster checks; here the consolidated view.

| Point (standard) | Sprint 3+4 | Sprint 5 | Sprint 6 |
|------------------|-----------|----------|----------|
| 1 DE+EN parity | ✅ | ✅ | ✅ |
| 2 Skill↔README version | ✅ financials 1.0.0 · sprint-run 2.0.0 · sprint-review 2.8.0 | ✅ implement 2.16.0 · architecture-review 1.13.0 · ideation 2.9.0 · insights-review 1.0.0 · pitch 1.2.0 | ✅ bootstrap 3.44.0 · backlog 1.8.0 · quality-gate-audit 1.1.0 |
| 3 HANDBUCH section | ✅ Appendix AG/AH/AI/AJ/AK | ✅ Appendix AL/AM/AN/AO/AP · §11b | ✅ Appendix AQ |
| 4 CONVENTIONS.md | ➖ n/a | ➖ n/a (execution isolation covers subagents) | ➖ n/a |
| 5 Doc index | ✅ | ⚠️→✅ **routinen-vernetzen was missing → added** | ✅ |
| 6 Sketches | ✅ (sprint-run 6 pairs DE+EN) | ➖ optional (text sufficient) | ➖ optional |
| 7+8 Vault doc/wikilinks | ➖ external (checked separately, below) | ➖ external | ➖ external |
| 9 Cross-links | ✅ goal↔sprint-run bidirectional | ✅ appendix net AL–AP | ✅ sprint-6↔qga |
| 10 Glossary | ⚠️→✅ **plain-language glossary lacked terms → added** | ⚠️→✅ (same fix) | ⚠️→✅ (same fix) |
| 11 docs-drift green | ✅ rc=0 | ✅ rc=0 | ✅ rc=0 |

## Four persona journeys (end-to-end)

**P1 — New operator (onboarding):** ✅ `README.md` (bilingual, `#deutsch`/`#english`) → `## Quickstart` (l. 128, three install paths) → `/bootstrap` (repo root, one `git clone`) → onboarding checklist [`bootstrap-prep.md`](../onboarding/bootstrap-prep.md) → `## The Skills` (l. 227) → skill docs. Full step path linked via HANDBUCH §4. **Navigable, no dead hop.**

**P2 — Existing operator (build-vs-buy update):** ✅ release index [`../releases/_index.md`](../releases/_index.md) / [`sprint-6.md`](../releases/sprint-6.md) → HANDBUCH Appendix AL (switch A / native paths, l. 5451) + AN (`/ultraplan`, l. 5523) → migration runbook [`framework-update.md`](../runbooks/framework-update.md) → clarity on `/goal`, native subagents, ultraplan trigger. **Migration path continuous.**

**P3 — Pitch recipient (enterprise decision-maker):** ✅ USP-13 list HANDBUCH Appendix AP (l. 5582, canonical, "13 components without an Anthropic equivalent") → appendix guide (l. 29) + table (l. 2422) → [`pitch/README.md`](../pitch/README.md) → validation links to skill docs. **Pitch chain coherent.**

**P4 — Maintaining operator (routines):** ✅ [`routinen-vernetzen.md`](../runbooks/routinen-vernetzen.md) → `## Drei Aufstellungs-Optionen` (l. 14) → `## Sieben Routinen` (l. 28: backlog triage, sprint review, quality-gate audit, dependency drift, doc drift, cost drift, Hermes health) → `## Einrichtung pro Aufstellung` (l. 135) with copy-ready prompts. **Three options + seven routines complete.**

## Gaps found — fixed directly

| # | Gap | File(s) | Fix |
|---|-----|---------|-----|
| G1 | The plain-language glossary (for business/management/customers) contained **none** of the Sprint-3–6 strategic terms (build-vs-buy, `/goal`, native subagent, ultraplan, `/insights`, worker-equivalent, status line, native-feature watch). HANDBUCH/Appendix C cover them, the non-developer glossary did not. | `docs/glossar.md` + `glossar.en.md` | New section "Strategy & native paths (from Sprint 3)" — 9 plain-language entries with analogies, DE+EN. |
| G2 | The `routinen-vernetzen` runbook (BOO-213, Sprint 5) was missing from the doc index, even though the table lists virtually every other runbook. | `docs/INDEX.md` + `INDEX.en.md` | One table row DE+EN added (alphabetically after README). |

## Noted / operator decision (not changed unilaterally)

- **`insights-review` not in the INDEX skill table.** That table is a **curated subset** ("the 15 top-level skills") and deliberately omits `financials`, `quality-gate-audit`, `statusline`, `research` too. The machine-enforced README skills table (point 5, docs-drift) does contain `insights-review` correctly. Whether the INDEX curation is expanded to 16 is a deliberate curation call outside BOO-215's scope — **deliberately not changed silently**.
- **Optional sketches** for status-line flow / sprint-plan sync / ADR-5 trigger: not mandatory ("where a concept needs a visual"); the features are sufficiently documented in text. Candidates for a later sketch wave, not a consistency error.
- **Vault docs (points 7+8)** live outside the repo (SecondBrain). Carried in separately as part of this story (Sprints.md, Index, PMO hub, skill docs) — see BOO-215 result.

## Rejected findings (sub-agent fabrications, disproven with evidence)

| Claim (sub-agent) | Severity claimed | Reality (evidence) |
|-------------------|------------------|--------------------|
| "`README.en.md` missing entirely — DE/EN parity violated" | CRITICAL | **False.** Root `README.md` is a bilingual single file: `[🇬🇧 English](#english) · [🇩🇪 Deutsch](#deutsch)` (l. 1). No separate `.en.md` needed. |
| "ADR-5 missing as a file, referenced 9×" | CRITICAL | **False.** Repo ADRs are topic-named (`docs/domain/adrs/{branching-standard,cross-session-drift,design-story-handling}.md`). ADR-1…5 are **vault ADRs by design** (`Decisions/`), referenced in the repo only as cross-links — convention-conform. |
| "bootstrap version drift: 3.44.0 instead of 3.41/3.42/3.43" | MEDIUM | **False.** bootstrap legitimately advanced to 3.44.0 across Sprint 5→6 (BOO-205). SKILL==README in DE+EN, docs-drift green. |
| "CONVENTIONS.md lacks `## switch`/`## ultraplan` sections" | HIGH | **No finding.** The standard requires CONVENTIONS only for tool/adapter/branching/naming conventions, not per feature. native_paths/ultraplan correctly in HANDBUCH. |

## docs-drift check

```
docs-drift-check: 20 skills checked, 0 drift finding(s).
OK — no doc drift.   (rc=0)
```

## Conclusion

The Sprint-3–6 documentation is consistent, bilingual and navigable. The two real gaps are fixed, the `docs-drift` gate is green, all four persona paths hold. **The smoke test is therefore green — the precondition for the v1.0 major doc (`v1.0-native-pivot.md`) is met.**
</content>
