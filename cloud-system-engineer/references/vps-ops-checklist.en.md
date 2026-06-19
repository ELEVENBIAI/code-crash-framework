# VPS ops checklist for the Cloud System Engineer

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](vps-ops-checklist.md)

Concrete, **stack-specific** operations and hardening checklist for Linux VPS environments (SSH, Docker, firewall,
backup). It is the Cloud System Engineer's **operational review lens** and complements the **stack-neutral 13-layer grid**
in [`infrastructure-dimensions.en.md`](infrastructure-dimensions.en.md): the grid asks *which* infrastructure decisions and
risks to check (universal, no tech prescription); this checklist says *how* a concrete VPS is hardened and operated (with
concrete tools).

## 1. Compute & resources
**Check when:** New agent, new daemon, new container, higher load expected.
- CPU headroom: Enough reserves for peak times?
- RAM: Node.js heap + Docker overhead + OS. Swap configured?
- Disk I/O: SQLite WAL mode under high write load? Log rotation active?
- Process limits: ulimit, max file descriptors, max processes

## 2. Containers & orchestration
**Check when:** New service, Docker change, volume change.
- Container health: Restart policy (always/unless-stopped)?
- Volume persistence: Critical data on named volumes, not in the container?
- Network: Container-to-container communication (Docker network)?
- Image updates: How are containers updated? Downtime?
- Resource limits: Docker memory/cpu limits set?

## 3. Network & connectivity
**Check when:** New external service, new port, new API connection.
- Firewall: Only required ports open (principle of least privilege)
- Egress: Which external APIs must be reachable?
- Ingress: Which ports are reachable from outside? Why?
- Latency: Is the hosting location optimal for the APIs?
- Bandwidth: Enough for WebSocket streams + API calls?

## 4. Security & hardening
**Check when:** Always. On every review.
- SSH: Key-only auth? Non-standard port? Fail2Ban active?
- Firewall: UFW/iptables correct? Default-deny policy?
- Updates: OS patches current? Node.js LTS?
- Secrets: .env protected on the VPS (chmod 600)? Not in Git?
- Docker: Containers run as non-root? Read-only filesystem where possible?
- TLS: Certificates for all exposed endpoints?

## 5. Backup & disaster recovery
**Check when:** New critical data, new database, new configuration.
- VPS backup: Auto-backup active? Interval?
- Data backup: Trades journal, database, .env — how secured?
- Recovery time: How fast can the system be restored?
- Rollback plan: On a failed update — how to roll back?

## 6. Monitoring & alerting
**Check when:** New critical path, new daemon, new external dependency.
- Uptime monitoring: Active?
- Disk-space alert: Warning before the disk is full?
- Container health: Auto-restart on crash?
- API health: Externally reachable endpoints monitored?

## 7. Cost & scaling
**Check when:** Resource increase needed, new service, upgrade planning.
- VPS plan: Is the current plan enough? Next tier needed?
- Bandwidth cost: Mind the plan's traffic limit
- Scaling path: Vertical (bigger VPS) vs. horizontal (multiple VPS)
- Alternative hosting options for specific workloads

## Reference

Stack-neutral infrastructure decision grid (13 layers, mandatory questions/anti-patterns):
[`infrastructure-dimensions.en.md`](infrastructure-dimensions.en.md).
</content>
