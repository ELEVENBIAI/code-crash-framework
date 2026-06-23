# Wave CI — Codex reviewer: independent code review as an opt-in layer (BOO-239)

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](wave-ci-codex-reviewer.md)

**Linear:** [BOO-239](https://linear.app/owlist/issue/BOO-239/) · Sprint 10 · As of: 2026-06-23

## Problem

So far only the author (Claude) reviews its own code (`/architecture-review`) — a conflict of interest. The deterministic gates (Semgrep/Sonar/coverage) catch rule violations but not design/craft/edge cases. An **independent** second review pass from a *different* vendor was missing.

## What changes

- **New runbook `docs/runbooks/codex-reviewer.md` + `.en.md`:** two-tier layer (comfort GitHub-native / sovereignty CLI + Azure-EU), reviewer contract, findings flow, AGENTS.md guidelines, boundary.
- **2 data-flow sketches** (DE+EN, render-loop-verified): comfort tier (code → OpenAI cloud US) + sovereignty tier (code → own runner → Azure-EU) — showing the data hop exactly.
- **AGENTS.md review-guidelines block** in `bootstrap/references/file-templates.md` (+ `.en.md`) + `migrate_boo_239`; **bootstrap 3.49.0 → 3.50.0** (README.md/.en.md pulled along).
- **§7.7 Codex pointer** wired to the runbook (marker "(with BOO-239)" removed, DE+EN).
- **HANDBUCH Appendix AU** (DE+EN); **INDEX runbook row** (DE+EN); `specs/BOO-239.md`.

## Verified

- `python3 .github/scripts/docs_drift_check.py` → 0 findings. `bash -n` ok.
- DE/EN parity (runbook pair, file-templates pair, HANDBUCH pair, INDEX pair, SKILL/README pairs).
- Sketches render-loop-verified (Read-tool visual check).
- Only verified facts (research 2026-06-22): native GitHub review not EU-residency-capable; Azure-EU regions (Sweden Central / West Europe / Germany West Central); **Switzerland North = GPT-4o only**; Vertex `gpt-oss` only; Bedrock US-only.

## Design decision

Build-vs-buy (ADR-1): **Codex = engine**, the framework provides contract + wiring. **No** MCP server, **no** Claude review skill (CoI), **no** standing agent. **Opt-in, no gate.** Report-only — the fix runs through the normal pipeline (`/implement` → gates → human merge).

## References

Spec: `specs/BOO-239.md`. Branch: `feat/boo-239-codex-reviewer`. Surfacing groundwork: Wave CH (BOO-248). Related: `daily-bug-scanner.en.md` (cron variant), BOO-150, BOO-227, BOO-241.
