# Wave CG — Position block + Hermes rationale + README refresh (BOO-227, BOO-236)

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](wave-cg-position-readme-refresh.md)

**Linear:** [BOO-227](https://linear.app/owlist/issue/BOO-227/) · [BOO-236](https://linear.app/owlist/issue/BOO-236/) · Source: research 2026-06-19 (autonomous dev agent) + verify 2026-06-20

## Problem

Two doc gaps: (1) The positioning — why INTENTRON runs sequentially and keeps merges human-gated — and the rationale for why the Hermes layer only proposes were scattered across CONVENTIONS §0, the README "What INTENTRON is not", and Appendix-F notes, without explicit evidence. (2) The README lagged behind reality: "latest v0.9.0", wave list up to BB, `quality-gate-audit` still described as "upcoming" although long shipped.

## What changes

- **README (DE+EN): new section "Our position: sequential pipeline, human-gated merges"** between "Why INTENTRON?" and "How INTENTRON differs". Risk-asymmetry argument, sources linked: OWASP Top 10 for Agentic Applications 2026, Meta "Agents Rule of Two", lethal trifecta, documented incidents (Replit prod-DB deletion, GitHub-MCP injection).
- **HANDBUCH.md + .en.md, Appendix D: new subsection "Why Hermes only proposes (Human-in-the-Lead)"** with skill-drift evidence: model collapse (Nature 2024), catastrophic forgetting, skill drift; cross-reference to the approval gate (Appendix F) + ADR-5.
- **README refresh (BOO-236):** "What's new" to v0.13.0, sprints 3–6 added; `quality-gate-audit` from "upcoming" to done (hard hook in `/sprint-run`); `grafana` skill row gets a Cloud-vs-self-hosted note (Automation Plane BOO-234). Entry prompts A/B/C verified current — unchanged.
- **INDEX.md + .en.md:** README and HANDBUCH rows extended with the position/Hermes rationale.

## Verified

- `python3 .github/scripts/docs_drift_check.py` → 0 findings.
- DE/EN parity (README single-file both halves, HANDBUCH pair, INDEX pair).
- Sources taken verbatim from the approved vault research (anti-fabrication), nothing invented.

## Design decision

Position block goes into the README (CONVENTIONS §0 already carries the consensus — deliberately not duplicated, lightweight design principle). Hermes rationale goes into the HANDBUCH Hermes section (the bilingual pair). Position and Hermes ship together with the README refresh in one doc PR because they touch the same files.

## Consequence

- Extend the entry prompts later with the STANDARD_SCAN bootstrap question and new migrations once those features are built (BOO-236 note).
- `grafana` self-hosted reconciliation arrives with the Automation Plane (BOO-234).
