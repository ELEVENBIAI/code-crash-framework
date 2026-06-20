# Wave CG — Positions-Block + Hermes-Begruendung + README-Auffrischung (BOO-227, BOO-236)

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](wave-cg-position-readme-refresh.en.md)

**Linear:** [BOO-227](https://linear.app/owlist/issue/BOO-227/) · [BOO-236](https://linear.app/owlist/issue/BOO-236/) · Quelle: Recherche 2026-06-19 (Autonomer Dev-Agent) + Verify 2026-06-20

## Problem

Zwei Doku-Luecken: (1) Die Positionierung — warum INTENTRON sequenziell laeuft und Merges menschlich freigegeben bleiben — und die Begruendung, warum der Hermes-Layer nur Vorschlaege macht, waren ueber CONVENTIONS §0, README „Was INTENTRON nicht ist" und Anhang-F-Notizen verstreut, ohne expliziten Beleg. (2) Die README hing dem Stand hinterher: „latest v0.9.0", Wave-Liste bis BB, `quality-gate-audit` noch als „upcoming", obwohl laengst gebaut.

## Was sich aendert

- **README (DE+EN): neuer Abschnitt „Unsere Position: sequenzielle Pipeline, menschlich freigegebene Merges"** zwischen „Warum INTENTRON?" und „Wie sich INTENTRON unterscheidet". Risiko-Asymmetrie-Argument, Quellen verlinkt: OWASP Top 10 for Agentic Applications 2026, Meta „Agents Rule of Two", Lethal Trifecta, dokumentierte Vorfaelle (Replit Prod-DB-Loeschung, GitHub-MCP-Injection).
- **HANDBUCH.md + .en.md, Anhang D: neuer Unterabschnitt „Warum Hermes nur Vorschlaege macht (Human-in-the-Lead)"** mit Skill-Drift-Evidenz: Model Collapse (Nature 2024), Catastrophic Forgetting, Skill-Drift; Querverweis auf Approval-Gate (Anhang F) + ADR-5.
- **README-Auffrischung (BOO-236):** „What's new" auf v0.13.0, Sprints 3–6 ergaenzt; `quality-gate-audit` von „upcoming" auf done (Hard-Hook in `/sprint-run`); `grafana`-Skill-Zeile um Cloud-vs-self-hosted-Hinweis (Automation Plane BOO-234). Einstiegs-Prompts A/B/C verifiziert aktuell — unveraendert.
- **INDEX.md + .en.md:** README- und HANDBUCH-Zeile um Position/Hermes-Rationale ergaenzt.

## Verifiziert

- `python3 .github/scripts/docs_drift_check.py` → 0 Befunde.
- DE/EN paritaetisch (README-Single-File beide Haelften, HANDBUCH-Paar, INDEX-Paar).
- Quellen verbatim aus der abgenommenen Vault-Recherche (Anti-Fabrikation), nichts erfunden.

## Designentscheid

Position-Block in die README (CONVENTIONS §0 traegt den Konsens bereits — bewusst nicht dupliziert, Leichtgewicht-Designprinzip). Hermes-Begruendung in den HANDBUCH-Hermes-Abschnitt (das zweisprachige Paar). Position und Hermes gemeinsam mit der README-Auffrischung in einem Doku-PR, weil sie dieselben Dateien beruehren.

## Folge

- Einstiegs-Prompts spaeter um die STANDARD_SCAN-Bootstrap-Frage und neue Migrationen ergaenzen, sobald diese Features gebaut sind (BOO-236-Notiz).
- `grafana` self-hosted-Reconciliation kommt mit der Automation Plane (BOO-234).
