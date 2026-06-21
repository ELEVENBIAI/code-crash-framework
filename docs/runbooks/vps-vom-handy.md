# Runbook: Developer-VPS vom Handy steuern — Claude Remote Control + tmux

**Zweck:** Eine auf der VPS laufende Claude-Code-Session **vom Handy beobachten und steuern** — Claudes Remote-Control-Feature kombiniert mit der bestehenden [tmux-Best-Practice](sprint-unattended-tmux.md).

**Zuletzt aktualisiert:** 2026-06-21

> EN: [`vps-vom-handy.en.md`](vps-vom-handy.en.md)

---

## Was „Remote Control" real ist (verifiziert)

Gegen die offizielle Claude-Code-Doku geprüft ([code.claude.com/docs/en/remote-control](https://code.claude.com/docs/en/remote-control), Research Preview):

| Frage | Antwort |
|---|---|
| **Was ist es?** | Eine offizielle Funktion **„Remote Control"** — verbindet `claude.ai/code` bzw. die **Claude-App (iOS/Android)** mit einer Claude-Code-Session, die **auf deiner Maschine** läuft. |
| **Wo läuft die Arbeit?** | **Auf deiner VPS.** Die Session läuft lokal weiter; nichts wandert in die Cloud. Anders als „Claude Code on the web" (das auf Anthropic-Infra läuft). |
| **Voraussetzungen** | Abo-Plan **Pro / Max / Team / Enterprise** — **kein** API-Key. Aktuelle Claude-Code-Version (Update, falls `/remote-control` fehlt). Bei Team/Enterprise muss der Admin Remote Control freischalten. |
| **Auth / Netz** | `/login` mit claude.ai-Account (kein API-Key). Deine VPS macht **nur ausgehende HTTPS**-Requests über die Anthropic-API — **keine offenen Inbound-Ports**, alles über TLS. |
| **Reichweite** | Verlauf + Tool-Aktivität ansehen, **Nachrichten/Prompts senden** (steuern), aufs lokale Dateisystem via `@`-Autocomplete zugreifen; MCP-Server, Tools und Projekt-Config bleiben verfügbar; mehrere Oberflächen parallel; Auto-Reconnect bei Netz-Aussetzern. |

---

## Remote Control vs. tmux — wer macht was

Die beiden lösen **verschiedene** Probleme und ergänzen sich:

- **tmux** hält den `claude`-**Prozess auf der VPS am Leben**, unabhängig von deiner SSH-Verbindung. Ohne tmux stirbt die Session, wenn deine SSH-Shell wegbricht (SIGHUP) — und damit auch der Remote-Control-Server, den du in dieser Shell gestartet hast.
- **Remote Control** ist das **Fenster vom Handy** auf genau diese Session — über die Anthropic-API, ohne SSH und ohne offene Ports.

**Kombination:** Claude **in tmux** starten (Prozess überlebt SSH-Abbruch und Laptop-Zuklappen) **und** Remote Control aktivieren (vom Handy beobachten/steuern). So bist du nicht mehr an dein SSH-Terminal gebunden, und der Lauf überlebt trotzdem jede Trennung.

---

## Schritt für Schritt

1. **Per SSH auf die VPS** und **tmux-Session starten** (wie im [tmux-Runbook](sprint-unattended-tmux.md)):
   ```bash
   ssh deine-vps
   tmux new -A -s sprint
   ```

2. **Claude starten und Remote Control aktivieren** — in der tmux-Session:
   ```bash
   claude
   # in der Session:
   /remote-control
   ```
   Alternativ direkt beim Start: `claude --remote-control "VPS-Sprint"`. (Einmalig vorab `/login` mit deinem claude.ai-Account; kein API-Key.)

3. **Vom Handy verbinden:** Claude-App (iOS/Android) oder `claude.ai/code` öffnen — die laufende VPS-Session erscheint dort. Verlauf und Tool-Aktivität ansehen, Prompts senden, Tool-Aufrufe begleiten.

4. **Abkoppeln, ohne den Lauf zu killen:** in tmux **`Strg`+`B`**, dann `D` — die Anzeige im SSH-Terminal löst sich, der Prozess (und Remote Control) läuft auf der VPS weiter. SSH/Laptop kannst du jetzt gefahrlos zumachen; vom Handy bleibst du dran.

5. **Wieder andocken** (vom Laptop): `ssh deine-vps && tmux attach -t sprint`. Vom Handy: einfach die Session in der App/`claude.ai/code` wieder öffnen (Auto-Reconnect nach Netz-Aussetzern).

---

## Sicherheit

- **Keine offenen Ports für Remote Control.** Die VPS spricht nur ausgehend mit der Anthropic-API; du musst **kein** SSH/keinen Port nach aussen öffnen, nur um vom Handy ranzukommen. SSH brauchst du nur zum Starten/Verwalten der tmux-Session — mit Key-Auth und Härtung (→ [Hostinger-VPS-Setup](hostinger-vps-setup.md)).
- **Keine Token pasten.** Remote Control nutzt deine claude.ai-`/login`-Session (kurzlebige, zweckgebundene Credentials). Trag keine API-Keys/Tokens in Prompts oder Repo ein.
- **Mobil = beobachten + steuern + Branch/PR.** Vom Handy lenkst du die Arbeit bis zum prüfbaren PR. **Merge nach `main`, Deploy und Secret-Rotation bleiben menschlich-gated** — bewusst, nicht aus technischer Not (→ README [„Unsere Position"](../README.md#unsere-position-sequenzielle-pipeline-menschlich-freigegebene-merges), BOO-227). Auf dem kleinen Screen ist ein Fehlgriff schnell passiert; die irreversible Aktion gehört an den Rechner, nicht auf den Daumen.

---

## Grenzen (Research Preview)

- Der **lokale Prozess muss laufen** — stirbt die VPS-Session (kein tmux, VPS-Reboot), ist auch Remote Control weg. Genau dagegen ist tmux da; gegen Reboots → [Headless-VPS](headless-vps.md) (systemd).
- **Längere Netz-Aussetzer** (Grössenordnung ~10 Min) können die Session auslaufen lassen — danach neu verbinden.
- Manche **interaktiven Picker** (z.B. `/resume`, Plugin-Auswahl) sind nur lokal bedienbar.
- Funktion ist eine **Research Preview** und kann sich ändern — im Zweifel die [offizielle Doku](https://code.claude.com/docs/en/remote-control) prüfen.

---

## Siehe auch

**Mentales Modell:** Cheat-Sheet = Befehle · tmux = Basis · Headless + Remote = Betriebs-Varianten · Team/Multi-User = Skalierung · **Anhang Y = Hub.**

- **Befehle:** [`quickstart-entwickler.md`](../quickstart-entwickler.md) — Cheat-Sheet „Wann nehme ich was?"
- **Basis:** [`sprint-unattended-tmux.md`](sprint-unattended-tmux.md) — tmux: Prozess überlebt SSH-Abbruch
- **Betriebs-Varianten:** [`headless-vps.md`](headless-vps.md) — zeitgesteuert per cron/systemd · **VPS-vom-Handy (dieses Runbook)**
- **Skalierung:** [`vps-team-setup.md`](vps-team-setup.md) · [`multi-user-vps.md`](multi-user-vps.md) · [`hostinger-vps-setup.md`](hostinger-vps-setup.md)
- **Hub:** HANDBUCH [Anhang Y — VPS/Cloud-Team-Runbook](../../HANDBUCH.md#anhang-y-vpscloud-team-runbook-boo-94)
