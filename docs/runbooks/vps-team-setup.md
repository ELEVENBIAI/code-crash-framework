# Runbook: INTENTRON auf einer Developer-VPS für Teams

> **➜ Dieses Runbook ist jetzt HANDBUCH-Anhang Y „VPS/Cloud-Team-Runbook" (BOO-94).**
>
> Der vollständige, **zweisprachige** Inhalt (mit Übersichtsdiagramm) lebt kanonisch im HANDBUCH —
> diese Datei ist nur noch ein Pointer, damit es keine zwei auseinanderdriftenden Quellen gibt.
>
> - **Deutsch:** [HANDBUCH.md → Anhang Y](../../HANDBUCH.md#anhang-y-vpscloud-team-runbook-boo-94)
> - **English:** [HANDBUCH.en.md → Appendix Y](../../HANDBUCH.en.md#appendix-y-vpscloud-team-runbook-boo-94)
>
> Inhalt: Deployment-Szenario & Voraussetzungen · einmal pro VPS · pro Projekt (Git-Hooks pro Repo!) ·
> Projekt 2..N & Brownfield-Onboarding · Team (CODEOWNERS/Branch-Protection) · Entscheidungen
> (Docker vs. Direkt-Install, Git-lokal vs. GitHub, Souveränität) · Vier-Layer auf headless VPS ·
> Schnellreferenz einmal-pro-VPS vs. pro-Projekt.

---

## Siehe auch

**Mentales Modell:** Cheat-Sheet = Befehle · tmux = Basis · Headless + Remote = Betriebs-Varianten · Team/Multi-User = Skalierung · **Anhang Y = Hub.**

- **Befehle:** [`quickstart-entwickler.md`](../quickstart-entwickler.md) — Cheat-Sheet „Wann nehme ich was?"
- **Basis:** [`sprint-unattended-tmux.md`](sprint-unattended-tmux.md) — tmux: Prozess überlebt SSH-Abbruch
- **Betriebs-Varianten:** [`headless-vps.md`](headless-vps.md) — cron/systemd · [`vps-vom-handy.md`](vps-vom-handy.md) — vom Handy (Remote Control)
- **Skalierung:** vps-team-setup (dieses Runbook → kanonisch in Anhang Y) · [`multi-user-vps.md`](multi-user-vps.md) · [`hostinger-vps-setup.md`](hostinger-vps-setup.md)
- **Hub:** HANDBUCH [Anhang Y — VPS/Cloud-Team-Runbook](../../HANDBUCH.md#anhang-y-vpscloud-team-runbook-boo-94)
