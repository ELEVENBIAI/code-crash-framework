# Wave CH — Post-Install: Optionale Add-ons / Next-Steps-Sektion (BOO-248)

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](wave-ch-postinstall-addons.en.md)

**Linear:** [BOO-248](https://linear.app/owlist/issue/BOO-248/) · Sprint 10 · Stand: 2026-06-23

## Problem

Opt-in-Features (Codex-Reviewer, Daily-Bug-Scanner, Headless-VPS, Developer-VPS vom Handy) wurden teils schon ausgeliefert (Sprint 9: Headless/Remote), aber es gab keine gemeinsame Stelle, an der der Operator sie nach dem Setup *sieht*. Jede als Interview-Frage waere Bloat (Leichtgewicht-Designprinzip).

## Was sich aendert

- **bootstrap/SKILL.md + .en.md: neue §7.7 „Optionale Add-ons / Naechste Schritte"** — Tabelle (Add-on / Was es bringt / Runbook-Pointer). Erst-Liste: Codex-Reviewer (mit BOO-239), Daily-Bug-Scanner, Headless-VPS, Developer-VPS vom Handy. Erweiterungs-Regel: neue Opt-in-Features tragen sich hier ein, statt als Interview-Frage. **Version 3.48.0 → 3.49.0** (README.md/.en.md mitgezogen).
- **bootstrap/references/developer-onboarding-template.md + .en.md:** gleichnamige Sektion, damit generierte Projekte sie tragen.
- **bootstrap/scripts/migrate-to-v2.sh: `migrate_boo_248()`** — haengt die Sektion additiv an ein bestehendes `DEVELOPER_ONBOARDING.md` (idempotent, nicht-destruktiv) + Dispatch nach `migrate_boo_229`.
- **HANDBUCH.md + .en.md: Anhang AT** — Problem, Loesung (Surfacing statt Setup), Erst-Liste, Erweiterungs-Regel, Abgrenzung.

## Verifiziert

- `python3 .github/scripts/docs_drift_check.py` → 0 Befunde.
- DE/EN paritaetisch (SKILL/README-Paare, HANDBUCH-Paar, Template-Paar).
- Kein neuer Interview-Schritt, kein Gate — reines Surfacing. Nur belegte Runbooks referenziert (codex-reviewer-Pointer als „mit BOO-239" markiert).

## Designentscheid

Surfacing statt Interview-Frage (kein Bloat). Eine erweiterbare Liste an genau zwei Orten (bootstrap §7.7 + Developer-Onboarding), Hintergrund im HANDBUCH (Anhang AT). Vorbau-Story fuer BOO-239 (Codex-Reviewer-Surfacing).

## Folge

BOO-239 traegt den Codex-Reviewer-Runbook-Pointer final ein (loest die „mit BOO-239"-Markierung auf).

## Verweise

Spec: `specs/BOO-248.md`. Branch: `feat/boo-248-postinstall-addons`. Vorherige Wave: `wave-cg-position-readme-refresh.md`.
