# Runbook: Headless-VPS — den Sprint per `claude -p` als cron- oder systemd-Job starten

**Zweck:** Den ganzen Lauf **unbeaufsichtigt und zeitgesteuert** starten — `claude -p "/sprint-run --auto"` als cron-Job oder systemd-Service auf einer VPS, mit Budget-Schranke, Sandbox und Deny-Regeln.

**Zuletzt aktualisiert:** 2026-06-21

> EN: [`headless-vps.en.md`](headless-vps.en.md)

---

## Drei Ebenen — nicht verwechseln

Headless ist eine **Betriebsart**, kein Skill. Drei Dinge greifen ineinander:

| Ebene | Was es ist | Beispiel |
|---|---|---|
| **headless** (`claude -p`) | die **Betriebsart**: Claude Code ohne interaktives Terminal starten | `claude -p "…"` |
| **`/sprint-run`** | der **Wrapper**: bereitet den Sprint vor (Specs, Worktrees, Token-Budget, Gate-Audit) | `/sprint-run --auto` |
| **`/goal`** | der **Motor**: die Anthropic-native Termination-Engine, die Turn für Turn bis zur Termination-Phrase läuft | hinter `/sprint-run` |

**Wichtig:** Headless ist **nicht Voraussetzung** für `--auto`. `/sprint-run --auto` läuft genauso interaktiv (in [tmux](sprint-unattended-tmux.md)). Headless ist nur der Weg, das **Starten zu automatisieren** — per Zeitplan, ohne dass ein Mensch `claude` tippt. Für „ich starte selbst und klappe den Laptop zu" reicht [tmux](sprint-unattended-tmux.md); für „startet jede Nacht von allein" braucht es cron/systemd (dieses Runbook).

---

## Voraussetzungen

- VPS einmal aufgesetzt (→ [Hostinger-VPS-Setup](hostinger-vps-setup.md) bzw. HANDBUCH **Anhang Y**), Claude Code CLI installiert.
- **Non-root-User** für den Job (z.B. `claude-runner` oder dein Operator-User). Claude Code blockt `bypassPermissions` als root auf Linux bewusst.
- Projekt-Repo als Klon im Home des Users, Git-Hooks installiert (`bash scripts/install-hooks.sh`), `verify-setup.sh` → 0 FAIL.
- **Skills + `CLAUDE.md` müssen auffindbar sein** — `/sprint-run` ist ein Skill. Nutze deshalb **nicht** `--bare` (das überspringt Skill-/`CLAUDE.md`-/Hook-Discovery); der normale `claude -p`-Aufruf lädt sie.
- Auth ohne TTY ist eingerichtet (→ Abschnitt [Auth](#auth-ohne-tty)).

---

## Der headless-Aufruf

Der Kern ist eine einzige Zeile. Slash-Commands funktionieren in `-p`: der Skill expandiert vor dem Lauf.

```bash
claude -p "/sprint-run --auto" \
  --permission-mode dontAsk \
  --allowedTools "Bash(git *),Bash(npm *),Bash(pytest *),Read,Edit,Write" \
  --output-format json \
  --max-turns 200
```

- **`-p "…"`** — non-interaktiver (headless) Modus. Quelle: [docs.claude.com/.../headless](https://code.claude.com/docs/en/headless).
- **`--permission-mode dontAsk`** — auto-**verweigert**, was nicht in `--allowedTools`/`permissions.allow` steht (kein Mensch zum Bestätigen da). Die balancierte Wahl für unbeaufsichtigt: nur die Allowlist läuft, der Rest wird geblockt. (Werte: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` — siehe [Permissions-Doku](https://code.claude.com/docs/en/permissions#permission-modes).)
- **`--allowedTools`** — die explizite Allowlist. Eng halten: nur was der Sprint wirklich braucht.
- **`--output-format json`** — liefert am Ende `total_cost_usd`, `session_id` u.a. → fürs Kosten-Logging (siehe [Budget](#budget-sandbox-deny--die-drei-schranken)).
- **`--max-turns`** — Obergrenze für agentische Turns (Runaway-Schutz). **Kein** Geld-/Token-Limit.

> **Merge/Deploy/Secrets bleiben menschlich.** `/sprint-run --auto` fährt bis zum **prüfbaren PR** — es merged **nicht** nach `main`, rotiert keine Secrets, deployt nicht. Das ist die bewusste Grenze des Frameworks (→ README [„Unsere Position"](../README.md#unsere-position-sequenzielle-pipeline-menschlich-freigegebene-merges), BOO-227). Headless ändert daran nichts.

---

## Budget, Sandbox, Deny — die drei Schranken

Claude Code hat **keinen** nativen Geld-/Token-Cap (kein `--max-budget`). Unbeaufsichtigt schützt du dich über drei zusammenwirkende Schranken:

**1. Budget-Schranke (Wall-Clock + Turns + Framework-Budget).**

```bash
timeout 6h claude -p "/sprint-run --auto" --max-turns 200 --output-format json
```

- `timeout` kappt den Lauf hart nach Wand-Uhr-Zeit.
- `--max-turns` begrenzt die Iterationen.
- `/sprint-run` bringt sein **eigenes** Token-Budget mit (stoppt am 80%-Token-Boundary und triggert `/sprint-review`) — das ist die eigentliche fachliche Schranke.
- Kosten danach aus dem JSON lesen: `… --output-format json | jq '.total_cost_usd'` und loggen/alarmieren.

**2. Sandbox (OS-Level, optional aber empfohlen).** Native Sandbox-Funktion; auf Linux einmalig `sudo apt-get install bubblewrap socat`. In `~/.claude/settings.json` oder `.claude/settings.json`:

```json
{
  "sandbox": {
    "enabled": true,
    "filesystem": { "denyRead": ["~/.ssh", "~/.aws", "~/.claude/.credentials.json"] },
    "network": { "allowedDomains": ["github.com", "api.anthropic.com"] }
  }
}
```

Quelle: [docs.claude.com/.../sandboxing](https://code.claude.com/docs/en/sandboxing).

**3. Deny-Regeln (Defense-in-Depth).** Per Flag oder in `settings.json` — Deny schlägt Allow:

```json
{
  "permissions": {
    "deny": ["Bash(rm -rf *)", "Bash(git push --force *)", "Read(.env)", "mcp__*"]
  }
}
```

Oder am Aufruf: `--disallowedTools "Bash(rm -rf *),Bash(git push --force *)"`. Quelle: [Permissions](https://code.claude.com/docs/en/permissions#manage-permissions).

---

## Variante A — cron-Job (non-root)

Als Job-User (z.B. `claude-runner`), nie als root. `crontab -e`:

```cron
# Jede Nacht um 03:00 einen unbeaufsichtigten Sprint starten, hart nach 6 h kappen.
# Auth + PATH kommen aus der Service-Env-Datei (kein Secret in der crontab!).
0 3 * * *  cd "$HOME/projects/projektX" && \
  . "$HOME/.config/claude-runner.env" && \
  timeout 6h claude -p "/sprint-run --auto" \
    --permission-mode dontAsk \
    --allowedTools "Bash(git *),Bash(npm *),Bash(pytest *),Read,Edit,Write" \
    --output-format json --max-turns 200 \
  >> "$HOME/logs/sprint-$(date +\%F).json" 2>&1
```

`~/.config/claude-runner.env` (Mode **600**) exportiert die Auth-Variable (siehe [Auth](#auth-ohne-tty)). cron hat ein minimales `PATH` — deshalb `cd` ins Projekt und ggf. `PATH` in der Env-Datei setzen.

---

## Variante B — systemd-Service + Timer (non-root)

Sauberer als cron: Logs im Journal, Restart-Policy, kein Secret in der crontab. **Zwei Units** — ein `oneshot`-Service (die Arbeit) und ein Timer (der Zeitplan). Als root anlegen, aber mit `User=` non-root laufen lassen.

`/etc/systemd/system/sprint-run.service`:

```ini
[Unit]
Description=INTENTRON unattended sprint run (headless)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=claude-runner
Group=claude-runner
WorkingDirectory=/home/claude-runner/projects/projektX
Environment=HOME=/home/claude-runner
Environment=PATH=/usr/local/bin:/usr/bin:/bin
EnvironmentFile=/home/claude-runner/.config/claude-runner.env
ExecStart=/usr/bin/timeout 6h /usr/local/bin/claude -p "/sprint-run --auto" \
  --permission-mode dontAsk \
  --allowedTools "Bash(git *),Bash(npm *),Bash(pytest *),Read,Edit,Write" \
  --output-format json --max-turns 200
# Crash-Resilienz; Schleifen-Schutz über StartLimit:
Restart=on-failure
RestartSec=300
StartLimitIntervalSec=3600
StartLimitBurst=3
TimeoutStartSec=7h
PrivateTmp=yes
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

`/etc/systemd/system/sprint-run.timer`:

```ini
[Unit]
Description=Run the unattended INTENTRON sprint nightly

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

Aktivieren und prüfen:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now sprint-run.timer
systemctl list-timers sprint-run.timer        # naechster Lauf
journalctl -u sprint-run.service -f            # Live-Log
```

> **`EnvironmentFile`** hält die Auth-Variable aus dem Unit heraus (Mode 600, dem Job-User gehörend). **`User=` non-root** ist Pflicht: root + `bypassPermissions` ist auf Linux gesperrt.

---

## Auth ohne TTY

Ein cron/systemd-Job hat kein Terminal für `/login`. Auth kommt deshalb aus einer Umgebungsvariablen (in der `EnvironmentFile`, Mode 600 — **nie** in die crontab oder ins Repo):

- **Abo (Pro/Max/Team/Enterprise):** einmal interaktiv `claude setup-token` ausführen, den langlebigen Token in die Env-Datei legen: `CLAUDE_CODE_OAUTH_TOKEN=…`.
- **API-Key:** `ANTHROPIC_API_KEY=sk-ant-…` in die Env-Datei.

Die interaktiven `/login`-Credentials unter `~/.claude/.credentials.json` sind **nicht** für headless gedacht — nutze die Env-Variable. Quelle: [docs.claude.com/.../authentication](https://code.claude.com/docs/en/authentication).

---

## Grenze (bewusst)

Headless automatisiert nur das **Starten**. Die fachlichen Grenzen bleiben: `/sprint-run --auto` endet am **prüfbaren PR**, pausiert bei nicht-selbstheilbaren Gate-Blocks, und **Merge/Deploy/Secrets bleiben menschlich** (BOO-227). Wer nur „starten und Laptop zuklappen" will, ist mit [tmux](sprint-unattended-tmux.md) richtig und braucht kein Daemon-Setup.

---

## Siehe auch

**Mentales Modell:** Cheat-Sheet = Befehle · tmux = Basis · Headless + Remote = Betriebs-Varianten · Team/Multi-User = Skalierung · **Anhang Y = Hub.**

- **Befehle:** [`quickstart-entwickler.md`](../quickstart-entwickler.md) — Cheat-Sheet „Wann nehme ich was?"
- **Basis:** [`sprint-unattended-tmux.md`](sprint-unattended-tmux.md) — tmux: Sprint überlebt SSH-Abbruch
- **Betriebs-Varianten:** **Headless-VPS (dieses Runbook)** · [`vps-vom-handy.md`](vps-vom-handy.md) — vom Handy steuern (Remote Control)
- **Skalierung:** [`vps-team-setup.md`](vps-team-setup.md) · [`multi-user-vps.md`](multi-user-vps.md) · [`hostinger-vps-setup.md`](hostinger-vps-setup.md)
- **Hub:** HANDBUCH [Anhang Y — VPS/Cloud-Team-Runbook](../../HANDBUCH.md#anhang-y-vpscloud-team-runbook-boo-94) · headless Linear-MCP: [Anhang AB](../../HANDBUCH.md#anhang-ab-linear-mcp-auf-einer-headless-vps-verbinden-boo-133)
