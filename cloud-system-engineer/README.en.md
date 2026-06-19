<a name="english"></a>

# Cloud System Engineer — VPS, Docker, Firewall, DNS from Claude Code

> Treats cloud infrastructure as a teammate: runs health checks on VPS and containers, audits firewall rules, manages DNS, estimates infra cost. Three modes — standalone check, architecture consultation (as teammate), or executing changes with operator approval.

**Version:** 1.2.0 · **Command:** `/cloud-system-engineer`

> **Claude Code mode:** check / consultation (mode A/B) are read-only → **`plan`**; executing changes (mode C: firewall/DNS/Docker, remotely irreversible) → **`default`** (ask before edits), approve each action deliberately — **never** `acceptEdits`/`dontAsk`/unattended. Details: HANDBUCH §6 "Claude Code mode".

---

## What It Does

Most dev teams ignore infrastructure until something breaks. This skill makes it a first-class citizen of the development workflow: it checks the VPS, flags security misconfigurations, and participates in `/ideation` as a teammate when a new story has infra impact.

Uses the Hostinger MCP server for API-level ops (VPS, DNS, Firewall, Billing) and local shell commands for server-level ops (Docker, processes, files).

---

## Three Modes

### Mode A — Infrastructure Check (default)

Fast inventory of the current environment.

| Check | What it covers |
|-------|----------------|
| System resources | CPU, RAM, disk, network, uptime |
| Docker | Container health, volumes, networks, ports |
| Security | SSH config (key-only, port, root-login), firewall rules, open ports vs. expected, SSL certs |
| Report | Structured output — see format below |

### Mode B — Architecture Consultation (as Teammate)

Called by `/ideation` or `/implement` when a story touches infrastructure.

| Task | What gets assessed |
|------|--------------------|
| Read story context | Which infra aspects does the change touch? |
| Impact analysis | New ports/firewall rules needed? Server resources sufficient? Docker changes? DNS? External APIs to whitelist? |
| Infrastructure dimensions | Reliability, Security, Cost Efficiency, Scalability — per the reference file |
| Feedback | Recommendations go back to the lead/architect, not direct execution |

### Mode C — Execute Changes

Apply infrastructure changes — always with operator confirmation.

1. Plan the change — what changes, rollback plan?
2. **Operator confirmation** — always, before destructive ops
3. Execute via Hostinger MCP or shell commands
4. Verify — service up? No unexpected side effects?
5. Document — what, why, when

---

## Safety Rules (Hard Constraints)

- No destructive operation without explicit operator confirmation
- No firewall change without dry run and rollback plan
- No DNS change without TTL awareness and propagation warning
- API tokens never logged or shown in plaintext
- Always read first, then change — no blind config

---

## Trigger Phrases

- `/cloud-system-engineer`
- "check the environment"
- "infrastructure"
- "server status"
- "firewall"
- "VPS"
- "Hostinger"

---

## Interfaces with Other Skills

| Upstream | Why it's called | Downstream | What we deliver |
|----------|-----------------|------------|------------------|
| `ideation` (Teammate mode) | Story touches infra | `grafana` | Infra metrics for dashboards |
| `implement` | Deployment involves VPS/Docker | `security-architect` (AUDIT) | Infra security findings |
| Operator | Day-to-day infra questions | `architecture-review` | Infrastructure-dimension assessment |

---

## Artifacts / Outputs

### Infrastructure Check Report
```
## Infrastructure Status Report

### System Resources
- CPU: X cores, Y% utilization
- RAM: X GB / Y GB (Z% used)
- Disk: X GB / Y GB (Z% used)
- Uptime: X days

### Docker Containers
| Container | Status | CPU | RAM | Ports |

### Security
| Check | Status | Detail |
| SSH   | ...    | ...    |
| Firewall | ... | ...  |

### Recommendations
- ...
```

### Architecture Consultation (as Teammate)
```
## Infrastructure Assessment for: [Story Title]
| Dimension | Impact | Mitigation |
### Infra changes needed:
- [ ] ...
### Risks:
- ...
```

---

## Requirements

- Hostinger MCP server (optional — shell commands can replace it)
- SSH access to VPS
- Hostinger API token in `.env` (never in code)

---

## Installation

```bash
cp -r cloud-system-engineer ~/.claude/skills/cloud-system-engineer
```

---

## File Structure

```
cloud-system-engineer/
├── SKILL.md                                ← Skill definition
└── references/
    ├── infrastructure-dimensions.md        ← Stack-neutral 13-layer decision grid (questions/risks/anti-patterns)
    └── vps-ops-checklist.md                ← Concrete VPS operations/hardening checklist (SSH, Docker, firewall, backup)
```

---

---

