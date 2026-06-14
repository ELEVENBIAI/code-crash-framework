# Wave CD — Semgrep custom-rule wiring + verification canary (BOO-185 / BOO-188)

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](wave-cd-semgrep-custom-rule-wiring.md)

**What is now in place:** Bootstrap no longer rolls out project-owned Semgrep rules merely nominally — it **wires** them in provably. New in the setup template: the custom-rule directory `.semgrep/`, which CI (Layer 3) and the pre-commit hook (Layer 2) load via `--config .semgrep/` **in addition** to the registry packs from `.semgrep.yml` — as soon as the directory exists. Plus a **wiring canary**: a custom rule and a fixture file with a deliberate violation that proves the gate actually fires. The lesson behind it is the real wave: **a gate that is only nominally configured is a blind gate.**

## The lesson — nominal vs. wired

A custom-rule directory can exist, be filled correctly, and still **never run** — namely when it is never handed to the Semgrep CLI via `--config`. The gate is then **effectively blind**: it looks like a control, but it checks nothing. This is exactly the finding behind the ADR "Semgrep custom-rule wiring — verification pattern for quality gates" (2026-06-11).

The countermeasure is a **verification pattern**, not a comment and not a doc line: a test file with a deliberate violation (canary) that produces a finding precisely when the gate truly bites. A hit proves the live wiring; silence proves the gate is blind. The pattern is **transferable to other gates** — slopsquatting check, coverage threshold, Layer-0 bodyguard: wherever "configured" and "actually active" can drift apart, a canary makes the difference provable instead of assumed.

## Changes

- **Custom-rule template `.semgrep/custom-rules.yml` (BOO-185):** project-owned Semgrep rules loaded via `--config .semgrep/` in addition to the registry packs. Contains the rule `qgaudit-wiring-canary`, which matches only the literal tripwire `QGAUDIT-CANARY-TRIPWIRE` — a literal the registry packs (`p/security-audit`, `p/secrets`, …) would **not** report. If the rule fires on the targeted audit scan, `--config .semgrep/` is provably active. (`bootstrap/references/file-templates.md` + `.en`.)
- **Canary fixture `.semgrep/test-fixtures/wiring-canary.py` (BOO-185):** carries the tripwire literal and the marker `# QGAUDIT-CANARY-DO-NOT-REMOVE`. As long as the targeted scan (`semgrep --config .semgrep/ .semgrep/test-fixtures/wiring-canary.py`) reports the canary, the custom-rule layer counts as **wired**; if it reports nothing, the layer is **blind**.
- **`.semgrepignore` excludes `.semgrep/test-fixtures/`:** the canary is an `ERROR`-severity rule. If it ran in the repo-wide scan, the CI of new projects would be **permanently red**. The canary is therefore picked up **only** by the targeted audit scan, never by the normal CI/pre-commit scan.
- **CI workflow + pre-commit hook wire `--config .semgrep/`:** both `.github/workflows/semgrep.yml` (Layer 3) and the local pre-commit hook (Layer 2) load both sources — the registry packs from `.semgrep.yml` **and** the custom rules from `.semgrep/`, as soon as the directory exists. Two sources, one action.
- **Anchor for the automation:** the upcoming `quality-gate-audit` skill (BOO-183) uses this canary as wiring proof and raises an alarm when the targeted scan stays silent.

## Migration — retrofitting existing projects

Existing projects retrofit the custom-rule layer in three steps (idempotent, non-destructive):

1. **Create `.semgrep/custom-rules.yml`** with the rule `qgaudit-wiring-canary` (template: `bootstrap/references/file-templates.en.md` §`.semgrep/custom-rules.yml`).
2. **Create `.semgrep/test-fixtures/wiring-canary.py`** with the tripwire literal and the `# QGAUDIT-CANARY-DO-NOT-REMOVE` marker, and **add `.semgrep/test-fixtures/` to `.semgrepignore`** — otherwise the CI goes permanently red.
3. **Add `--config .semgrep/` to the CI workflow and the pre-commit hook** (the "as soon as `.semgrep/` exists" pattern from the `semgrep.yml` and `pre-commit` templates).

Verify: `semgrep --config .semgrep/ .semgrep/test-fixtures/wiring-canary.py` must report `qgaudit-wiring-canary`. If it does not, the wiring is still blind.

## Scope

- **Stack-agnostic** for all stacks — custom-rule directory and canary are tool-, not stack-specific.
- **Deterministic** — an executable rule against a fixed tripwire literal, not a prompt.
- The setup-template technique (BOO-185) is already implemented in `bootstrap/references/file-templates.md` + `.en`; **this wave** (BOO-188) anchors the lesson in release note, README, and bootstrap docs.
- The audit automation (targeted scan + alarm) stays the `quality-gate-audit` skill **BOO-183** (referenced only).
- Wave letter **cd** (cc = linter wiring E2E BOO-182).

## References

ADR: "Semgrep custom-rule wiring — verification pattern for quality gates" (2026-06-11). Related: BOO-185 (custom-rule wiring in the setup template), BOO-183 (`quality-gate-audit` skill), BOO-182 (linter wiring E2E), BOO-176 (quality-gate integrity), BOO-4/BOO-3 (Semgrep Layer 2/3).
