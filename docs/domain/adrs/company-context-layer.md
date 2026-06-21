# ADR: Firmenkontext-Layer auf der Developer-VPS (BOO-242)

- **Status:** vorgeschlagen (Spike-Ergebnis 2026-06-21) — Festschreibung durch Operator ausstehend
- **Kontext-Quelle:** Brainstorm 2026-06-20 (Operator) + Spike BOO-242

## Kontext

Developer-VPS syncen heute **Projektwissen** via GitHub (VPS-Operator-Layer BOO-138/139: `PROJECTS_ROOT`, `journal/`, Daily-Note-Routine). Die globale `~/.claude/CLAUDE.md` ist bereits die **zentrale Landkarte** (Machine context + `PROJECTS_ROOT` + Projekt-Registry + Journaling-Konvention). Was fehlt: der **firmenweite Kontext** (Zweck, Ziele, Werte), damit Claude/Codex projektübergreifend weiss, in welchem Unternehmen es arbeitet. Risiko, das vermieden werden soll: **zwei lose Mechanismen** (SecondBrain vs. Projektverzeichnisse).

## Entscheidung

Ein **leaner Firmenkontext-Layer als referenzierte Ebene der bestehenden globalen `~/.claude/CLAUDE.md`** (für Codex analog `AGENTS.md`) — **kein paralleler Mechanismus, kein voller Vault-Klon**.

- **Scope (Whitelist):** Firma/Zweck, Ziele/strategische Ziele, Werte (optional Tonalität).
- **Ausgeschlossen:** Branding/Farbcodes → Projektebene (`ARCHITECTURE.md`/`DESIGN.md`); Sensibles (Financials, Kunden-Interna) → bleibt im Master-Vault (Privacy/Souveränität, HANDBUCH Anhang Q).
- **Form:** ein kleines `company-context.md`. **Eine VPS** → inline in die globale `CLAUDE.md` (Machine-context-Sektion). **Mehrere VPS** → die paar Dateien in ein kleines GitHub-Repo (oder ins Operator-Layer-Repo), per `git pull` verteilt.
- **Anbindung:** die globale `CLAUDE.md`/`AGENTS.md` nennt die Ebene explizit; Skills lesen sie wie heute `00 Kontext/`.
- **Sync:** `git pull` (manuell oder pull-on-session-start). `cron-sync` war für *Skills* Anti-Pattern → für read-only-Kontext separat zu bewerten.
- **Surfacing:** opt-in über die Post-Install-Checkliste (kein Bootstrap-Bloat) — BOO-239-Muster.

## Begründung

- **Leichtgewicht** (kein Voll-Vault) und nutzt die bestehende Landkarte → **keine zwei Mechanismen**.
- Pattern erprobt (SecondBrain-Klon auf der OpenCLAW-VPS mit GitHub-Sync).
- Schliesst die Kontext-Lücke an der VPS-Grenze, ohne Sensibles zu exponieren.

## Alternativen (verworfen)

- **Voller `secondbrain-setup`-Vault-Klon** auf die Dev-VPS — Overkill für eine reine Dev-VPS.
- **Eigener, von der `CLAUDE.md` getrennter Mechanismus** — schafft genau die zwei losen Systeme, die vermieden werden sollen.

## Konsequenzen

- Umsetzung ist eine **Folge-Story** (Inline-/Repo-Scaffold + `CLAUDE.md`/`AGENTS.md`-Anbindung + Doku DE+EN), erst nach Operator-Festschreibung.
- Verwandt: VPS-Operator-Layer (BOO-138/139), Cloud-Referenzarchitektur (BOO-243), Souveränität (HANDBUCH Anhang Q).
