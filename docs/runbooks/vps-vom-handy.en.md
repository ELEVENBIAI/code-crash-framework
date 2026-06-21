# Runbook: Steer the developer VPS from your phone — Claude Remote Control + tmux

**Purpose:** **Observe and steer** a Claude Code session running on the VPS **from your phone** — Claude's Remote Control feature combined with the existing [tmux best practice](sprint-unattended-tmux.en.md).

**Last updated:** 2026-06-21

> DE: [`vps-vom-handy.md`](vps-vom-handy.md)

---

## What "Remote Control" actually is (verified)

Verified against the official Claude Code docs ([code.claude.com/docs/en/remote-control](https://code.claude.com/docs/en/remote-control), research preview):

| Question | Answer |
|---|---|
| **What is it?** | An official feature called **"Remote Control"** — it connects `claude.ai/code` or the **Claude app (iOS/Android)** to a Claude Code session running **on your machine**. |
| **Where does the work run?** | **On your VPS.** The session keeps running locally; nothing moves to the cloud. Unlike "Claude Code on the web" (which runs on Anthropic infra). |
| **Prerequisites** | A subscription plan — **Pro / Max / Team / Enterprise** — **not** an API key. A current Claude Code version (update if `/remote-control` is missing). On Team/Enterprise an admin must enable Remote Control. |
| **Auth / network** | `/login` with a claude.ai account (no API key). Your VPS makes **outbound HTTPS only** through the Anthropic API — **no inbound ports**, all over TLS. |
| **Reach** | View the conversation + tool activity, **send messages/prompts** (steer), reach the local filesystem via `@` autocomplete; MCP servers, tools and project config stay available; multiple surfaces at once; auto-reconnect across network blips. |

---

## Remote Control vs. tmux — who does what

The two solve **different** problems and complement each other:

- **tmux** keeps the `claude` **process alive on the VPS**, independent of your SSH connection. Without tmux the session dies when your SSH shell drops (SIGHUP) — and with it the Remote Control server you started in that shell.
- **Remote Control** is the **window from your phone** onto exactly that session — via the Anthropic API, no SSH and no open ports.

**Combination:** start Claude **inside tmux** (process survives an SSH drop and a closed laptop) **and** enable Remote Control (observe/steer from your phone). You are no longer tied to your SSH terminal, and the run survives every disconnect anyway.

---

## Step by step

1. **SSH onto the VPS** and **start a tmux session** (as in the [tmux runbook](sprint-unattended-tmux.en.md)):
   ```bash
   ssh your-vps
   tmux new -A -s sprint
   ```

2. **Start Claude and enable Remote Control** — inside the tmux session:
   ```bash
   claude
   # in the session:
   /remote-control
   ```
   Or directly at launch: `claude --remote-control "VPS sprint"`. (Do `/login` with your claude.ai account once beforehand; no API key.)

3. **Connect from your phone:** open the Claude app (iOS/Android) or `claude.ai/code` — the running VPS session shows up there. View the conversation and tool activity, send prompts, ride along on tool calls.

4. **Detach without killing the run:** in tmux press **`Ctrl`+`B`**, then `D` — the display in the SSH terminal goes away, the process (and Remote Control) keeps running on the VPS. You can now close SSH/the laptop safely; from your phone you stay attached.

5. **Re-attach** (from the laptop): `ssh your-vps && tmux attach -t sprint`. From your phone: just reopen the session in the app / `claude.ai/code` (auto-reconnect after network blips).

---

## Security

- **No open ports for Remote Control.** The VPS only talks outbound to the Anthropic API; you do **not** need to open SSH/a port to the internet just to reach it from your phone. SSH is only needed to start/manage the tmux session — with key auth and hardening (→ [Hostinger VPS setup](hostinger-vps-setup.en.md)).
- **Don't paste tokens.** Remote Control uses your claude.ai `/login` session (short-lived, purpose-scoped credentials). Don't put API keys/tokens into prompts or the repo.
- **Mobile = observe + steer + branch/PR.** From your phone you drive the work up to a ready-to-review PR. **Merge to `main`, deploy and secret rotation stay human-gated** — deliberately, not from a technical limit (→ README ["Our position"](../README.md#our-position-sequential-pipeline-human-gated-merges), BOO-227). A fat-finger is quick on a small screen; the irreversible action belongs at the keyboard, not on a thumb.

---

## Limits (research preview)

- The **local process must keep running** — if the VPS session dies (no tmux, a VPS reboot), Remote Control is gone too. That is exactly what tmux is for; against reboots → [Headless VPS](headless-vps.en.md) (systemd).
- **Longer network outages** (on the order of ~10 min) can let the session time out — reconnect afterwards.
- Some **interactive pickers** (e.g. `/resume`, plugin selection) are local-only.
- The feature is a **research preview** and may change — when in doubt, check the [official docs](https://code.claude.com/docs/en/remote-control).

---

## See also

**Mental model:** cheat sheet = commands · tmux = base · headless + remote = operating variants · team/multi-user = scaling · **Appendix Y = hub.**

- **Commands:** [`quickstart-entwickler.en.md`](../quickstart-entwickler.en.md) — cheat sheet "when do I use what?"
- **Base:** [`sprint-unattended-tmux.en.md`](sprint-unattended-tmux.en.md) — tmux: the process survives an SSH drop
- **Operating variants:** [`headless-vps.en.md`](headless-vps.en.md) — scheduled via cron/systemd · **VPS from your phone (this runbook)**
- **Scaling:** [`vps-team-setup.md`](vps-team-setup.md) · [`multi-user-vps.en.md`](multi-user-vps.en.md) · [`hostinger-vps-setup.en.md`](hostinger-vps-setup.en.md)
- **Hub:** HANDBUCH [Appendix Y — VPS/cloud team runbook](../../HANDBUCH.en.md#appendix-y-vpscloud-team-runbook-boo-94)
