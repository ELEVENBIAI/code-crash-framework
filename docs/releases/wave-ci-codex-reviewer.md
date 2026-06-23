# Wave CI — Codex-Reviewer: unabhängiger Code-Review als Opt-in-Layer (BOO-239)

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](wave-ci-codex-reviewer.en.md)

**Linear:** [BOO-239](https://linear.app/owlist/issue/BOO-239/) · Sprint 10 · Stand: 2026-06-23

## Problem

Bisher reviewt nur der Autor (Claude) seinen eigenen Code (`/architecture-review`) — Interessenkonflikt. Die deterministischen Gates (Semgrep/Sonar/Coverage) fangen Regelverstöße, aber nicht Design/Handwerk/Edge-Cases. Es fehlte ein **unabhängiger** zweiter Review-Pass von einem *anderen* Anbieter.

## Was sich ändert

- **Neues Runbook `docs/runbooks/codex-reviewer.md` + `.en.md`:** Zwei-Tier-Layer (Komfort GitHub-nativ / Souveränität CLI + Azure-EU), Reviewer-Contract, Findings-Flow, AGENTS.md-Guidelines, Abgrenzung.
- **2 Daten-Flow-Sketches** (DE+EN, render-loop-geprüft): Komfort-Tier (Code → OpenAI-Cloud US) + Souveränitäts-Tier (Code → eigener Runner → Azure-EU) — zeigen den Datensprung exakt.
- **AGENTS.md-Review-Guidelines-Block** in `bootstrap/references/file-templates.md` (+ `.en.md`) + `migrate_boo_239`; **bootstrap 3.49.0 → 3.50.0** (README.md/.en.md mitgezogen).
- **§7.7-Codex-Pointer** auf das Runbook scharf geschaltet (Marker „(mit BOO-239)" entfernt, DE+EN).
- **HANDBUCH Anhang AU** (DE+EN); **INDEX-Runbook-Zeile** (DE+EN); `specs/BOO-239.md`.

## Verifiziert

- `python3 .github/scripts/docs_drift_check.py` → 0 Befunde. `bash -n` ok.
- DE/EN paritätisch (Runbook-Paar, file-templates-Paar, HANDBUCH-Paar, INDEX-Paar, SKILL/README-Paare).
- Sketches render-loop-geprüft (Read-Tool-Sichtprüfung).
- Nur verifizierte Fakten (Recherche 2026-06-22): native GitHub-Review nicht EU-residenzfähig; Azure-EU-Regionen (Sweden Central / West Europe / Germany West Central); **Switzerland North = nur GPT-4o**; Vertex nur `gpt-oss`; Bedrock US-only.

## Designentscheid

Build-vs-Buy (ADR-1): **Codex = Engine**, das Framework liefert Vertrag + Verdrahtung. **Kein** MCP-Server, **kein** Claude-Review-Skill (CoI), **kein** stehender Agent. **Opt-in, kein Gate.** Report-only — die Behebung läuft durch die normale Pipeline (`/implement` → Gates → menschlicher Merge).

## Verweise

Spec: `specs/BOO-239.md`. Branch: `feat/boo-239-codex-reviewer`. Surfacing-Vorbau: Wave CH (BOO-248). Verwandt: `daily-bug-scanner.md` (Cron-Variante), BOO-150, BOO-227, BOO-241.
