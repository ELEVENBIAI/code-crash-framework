# Wave CH — Post-install: optional add-ons / next-steps section (BOO-248)

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](wave-ch-postinstall-addons.md)

**Linear:** [BOO-248](https://linear.app/owlist/issue/BOO-248/) · Sprint 10 · As of: 2026-06-23

## Problem

Opt-in features (Codex reviewer, daily bug scanner, headless VPS, developer VPS from your phone) had partly already shipped (Sprint 9: headless/remote), but there was no shared place where the operator *sees* them after setup. Making each one an interview question would be bloat (lightweight design principle).

## What changes

- **bootstrap/SKILL.md + .en.md: new §7.7 "Optional add-ons / next steps"** — a table (add-on / what it gives you / runbook pointer). Initial list: Codex reviewer (with BOO-239), daily bug scanner, headless VPS, developer VPS from your phone. Extension rule: new opt-in features add themselves here instead of as an interview question. **Version 3.48.0 → 3.49.0** (README.md/.en.md pulled along).
- **bootstrap/references/developer-onboarding-template.md + .en.md:** the same-named section so generated projects carry it.
- **bootstrap/scripts/migrate-to-v2.sh: `migrate_boo_248()`** — appends the section additively to an existing `DEVELOPER_ONBOARDING.md` (idempotent, non-destructive) + dispatch after `migrate_boo_229`.
- **HANDBUCH.md + .en.md: Appendix AT** — problem, solution (surfacing not setup), initial list, extension rule, boundary.

## Verified

- `python3 .github/scripts/docs_drift_check.py` → 0 findings.
- DE/EN parity (SKILL/README pairs, HANDBUCH pair, template pair).
- No new interview step, no gate — pure surfacing. Only existing runbooks referenced (codex-reviewer pointer marked "with BOO-239").

## Design decision

Surfacing instead of an interview question (no bloat). One extensible list in exactly two places (bootstrap §7.7 + developer onboarding), background in the HANDBUCH (Appendix AT). Groundwork story for BOO-239 (Codex reviewer surfacing).

## Consequence

BOO-239 enters the Codex reviewer runbook pointer for good (resolves the "with BOO-239" marker).

## References

Spec: `specs/BOO-248.md`. Branch: `feat/boo-248-postinstall-addons`. Previous wave: `wave-cg-position-readme-refresh.en.md`.
