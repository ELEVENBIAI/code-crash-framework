# Runbook: Headless VPS — start the sprint via `claude -p` as a cron or systemd job

**Purpose:** Start the whole run **unattended and scheduled** — `claude -p "/sprint-run --auto"` as a cron job or systemd service on a VPS, with a budget cap, sandbox and deny rules.

**Last updated:** 2026-06-21

> DE: [`headless-vps.md`](headless-vps.md)

---

## Three layers — don't confuse them

Headless is an **operating mode**, not a skill. Three things interlock:

| Layer | What it is | Example |
|---|---|---|
| **headless** (`claude -p`) | the **operating mode**: start Claude Code without an interactive terminal | `claude -p "…"` |
| **`/sprint-run`** | the **wrapper**: prepares the sprint (specs, worktrees, token budget, gate audit) | `/sprint-run --auto` |
| **`/goal`** | the **engine**: the Anthropic-native termination engine that runs turn after turn to a termination phrase | behind `/sprint-run` |

**Important:** headless is **not a prerequisite** for `--auto`. `/sprint-run --auto` runs just as well interactively (in [tmux](sprint-unattended-tmux.en.md)). Headless is only the way to automate the **start** — on a schedule, without a human typing `claude`. For "I start it myself and close the laptop", [tmux](sprint-unattended-tmux.en.md) is enough; for "it starts every night on its own" you need cron/systemd (this runbook).

---

## Prerequisites

- VPS set up once (→ [Hostinger VPS setup](hostinger-vps-setup.en.md) resp. HANDBUCH **Appendix Y**), Claude Code CLI installed.
- A **non-root user** for the job (e.g. `claude-runner` or your operator user). Claude Code deliberately blocks `bypassPermissions` as root on Linux.
- Project repo cloned into the user's home, git hooks installed (`bash scripts/install-hooks.sh`), `verify-setup.sh` → 0 FAIL.
- **Skills + `CLAUDE.md` must be discoverable** — `/sprint-run` is a skill. So do **not** use `--bare` (it skips skill/`CLAUDE.md`/hook discovery); the plain `claude -p` invocation loads them.
- TTY-less auth is set up (→ section [Auth](#auth-without-a-tty)).

---

## The headless invocation

The core is a single line. Slash commands work under `-p`: the skill expands before the run.

```bash
claude -p "/sprint-run --auto" \
  --permission-mode dontAsk \
  --allowedTools "Bash(git *),Bash(npm *),Bash(pytest *),Read,Edit,Write" \
  --output-format json \
  --max-turns 200
```

- **`-p "…"`** — non-interactive (headless) mode. Source: [docs.claude.com/.../headless](https://code.claude.com/docs/en/headless).
- **`--permission-mode dontAsk`** — auto-**denies** anything not in `--allowedTools`/`permissions.allow` (no human to confirm). The balanced choice for unattended: only the allowlist runs, the rest is blocked. (Values: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` — see the [permissions docs](https://code.claude.com/docs/en/permissions#permission-modes).)
- **`--allowedTools`** — the explicit allowlist. Keep it tight: only what the sprint actually needs.
- **`--output-format json`** — returns `total_cost_usd`, `session_id` etc. at the end → for cost logging (see [Budget](#budget-sandbox-deny--the-three-caps)).
- **`--max-turns`** — ceiling on agentic turns (runaway guard). **Not** a money/token limit.

> **Merge/deploy/secrets stay human.** `/sprint-run --auto` runs to a **ready-to-review PR** — it does **not** merge to `main`, rotate secrets, or deploy. That is the framework's deliberate boundary (→ README ["Our position"](../README.md#our-position-sequential-pipeline-human-gated-merges), BOO-227). Headless does not change that.

---

## Budget, sandbox, deny — the three caps

Claude Code has **no** native money/token cap (no `--max-budget`). Unattended, you protect yourself with three interlocking caps:

**1. Budget cap (wall-clock + turns + framework budget).**

```bash
timeout 6h claude -p "/sprint-run --auto" --max-turns 200 --output-format json
```

- `timeout` hard-stops the run by wall-clock time.
- `--max-turns` bounds the iterations.
- `/sprint-run` brings its **own** token budget (stops at the 80% token boundary and triggers `/sprint-review`) — that is the real functional cap.
- Read the cost from the JSON afterwards: `… --output-format json | jq '.total_cost_usd'` and log/alert.

**2. Sandbox (OS level, optional but recommended).** Native sandbox feature; on Linux a one-time `sudo apt-get install bubblewrap socat`. In `~/.claude/settings.json` or `.claude/settings.json`:

```json
{
  "sandbox": {
    "enabled": true,
    "filesystem": { "denyRead": ["~/.ssh", "~/.aws", "~/.claude/.credentials.json"] },
    "network": { "allowedDomains": ["github.com", "api.anthropic.com"] }
  }
}
```

Source: [docs.claude.com/.../sandboxing](https://code.claude.com/docs/en/sandboxing).

**3. Deny rules (defense in depth).** Via flag or in `settings.json` — deny beats allow:

```json
{
  "permissions": {
    "deny": ["Bash(rm -rf *)", "Bash(git push --force *)", "Read(.env)", "mcp__*"]
  }
}
```

Or on the invocation: `--disallowedTools "Bash(rm -rf *),Bash(git push --force *)"`. Source: [Permissions](https://code.claude.com/docs/en/permissions#manage-permissions).

---

## Variant A — cron job (non-root)

As the job user (e.g. `claude-runner`), never as root. `crontab -e`:

```cron
# Start an unattended sprint every night at 03:00, hard-stop after 6 h.
# Auth + PATH come from the service env file (no secret in the crontab!).
0 3 * * *  cd "$HOME/projects/projektX" && \
  . "$HOME/.config/claude-runner.env" && \
  timeout 6h claude -p "/sprint-run --auto" \
    --permission-mode dontAsk \
    --allowedTools "Bash(git *),Bash(npm *),Bash(pytest *),Read,Edit,Write" \
    --output-format json --max-turns 200 \
  >> "$HOME/logs/sprint-$(date +\%F).json" 2>&1
```

`~/.config/claude-runner.env` (mode **600**) exports the auth variable (see [Auth](#auth-without-a-tty)). cron has a minimal `PATH` — hence `cd` into the project and, if needed, set `PATH` in the env file.

---

## Variant B — systemd service + timer (non-root)

Cleaner than cron: logs in the journal, a restart policy, no secret in the crontab. **Two units** — a `oneshot` service (the work) and a timer (the schedule). Create them as root but run with `User=` non-root.

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
# Crash resilience; loop guard via StartLimit:
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

Enable and check:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now sprint-run.timer
systemctl list-timers sprint-run.timer        # next run
journalctl -u sprint-run.service -f            # live log
```

> **`EnvironmentFile`** keeps the auth variable out of the unit (mode 600, owned by the job user). **`User=` non-root** is mandatory: root + `bypassPermissions` is blocked on Linux.

---

## Auth without a TTY

A cron/systemd job has no terminal for `/login`. Auth therefore comes from an environment variable (in the `EnvironmentFile`, mode 600 — **never** in the crontab or the repo):

- **Subscription (Pro/Max/Team/Enterprise):** run `claude setup-token` once interactively, put the long-lived token in the env file: `CLAUDE_CODE_OAUTH_TOKEN=…`.
- **API key:** `ANTHROPIC_API_KEY=sk-ant-…` in the env file.

The interactive `/login` credentials under `~/.claude/.credentials.json` are **not** meant for headless — use the env variable. Source: [docs.claude.com/.../authentication](https://code.claude.com/docs/en/authentication).

---

## Limit (deliberate)

Headless only automates the **start**. The functional limits stay: `/sprint-run --auto` ends at a **ready-to-review PR**, pauses on non-self-healable gate blocks, and **merge/deploy/secrets stay human** (BOO-227). If you only want "start and close the laptop", [tmux](sprint-unattended-tmux.en.md) is the right tool and needs no daemon setup.

---

## See also

**Mental model:** cheat sheet = commands · tmux = base · headless + remote = operating variants · team/multi-user = scaling · **Appendix Y = hub.**

- **Commands:** [`quickstart-entwickler.en.md`](../quickstart-entwickler.en.md) — cheat sheet "when do I use what?"
- **Base:** [`sprint-unattended-tmux.en.md`](sprint-unattended-tmux.en.md) — tmux: the sprint survives an SSH drop
- **Operating variants:** **Headless VPS (this runbook)** · [`vps-vom-handy.en.md`](vps-vom-handy.en.md) — steer from your phone (Remote Control)
- **Scaling:** [`vps-team-setup.md`](vps-team-setup.md) · [`multi-user-vps.en.md`](multi-user-vps.en.md) · [`hostinger-vps-setup.en.md`](hostinger-vps-setup.en.md)
- **Hub:** HANDBUCH [Appendix Y — VPS/cloud team runbook](../../HANDBUCH.en.md#appendix-y-vpscloud-team-runbook-boo-94) · headless Linear MCP: [Appendix AB](../../HANDBUCH.en.md#appendix-ab-connecting-the-linear-mcp-on-a-headless-vps-boo-133)
