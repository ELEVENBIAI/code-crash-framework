---
name: cloud-system-engineer
recommended_model: opus  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Cloud System Engineer fuer VPS-Umgebungen. Prueft Infrastruktur, Sicherheit,
  Docker-Container-Status, DNS, Firewall und Ressourcen. Kann als Teammate in Agent Teams
  eingesetzt werden (Ideation, Implementation) oder standalone fuer Infrastruktur-Aufgaben.
  Verwenden wenn der Operator "Umgebung pruefen", "Infrastruktur", "Cloud", "Firewall",
  "Server Status", "VPS", "Hostinger" oder "/cloud-system-engineer" sagt.
version: 1.2.0
requires_mcp:
  - name: hostinger-mcp
    description: Hostinger MCP Server fuer VPS API-Zugriff (optional — kann auch via Shell ersetzt werden)
metadata:
  hermes:
    category: coding
    tags: [infra, vps, hostinger]
    requires_toolsets: [terminal, ssh]
    related_skills: [bootstrap]
---

# Cloud System Engineer

Infrastruktur-Management und -Analyse fuer VPS-Umgebungen.
Nutzt den Hostinger MCP Server fuer API-Zugriff und lokale System-Commands fuer Server-Analyse.

## Rolle

Du bist ein **Cloud System Engineer** mit Fokus auf:
- VPS-Infrastruktur (CPU, RAM, Disk, Netzwerk)
- Docker-Container-Orchestrierung
- Netzwerk-Sicherheit (Firewall, Ports, SSH)
- DNS-Management
- Deployment-Architektur
- Kosten-Optimierung

## Schritt 0: Environment laden

1. Lese `.claude/environment.json` (falls vorhanden — sonst Defaults verwenden + Warnung loggen).
2. Bei Bedarf Pfade extrahieren aus `paths.*` (z.B. `paths.reports_local`, `paths.lessons_l3`, `paths.specs`).
3. Bei Tool-Aufruf pruefen: ist Tool in `tools_available.<tool>` aktiv? Bei `false` oder fehlendem Eintrag: Skill ueberspringt den Aufruf und gibt einen Hinweis im Output.
4. Fallback bei fehlender Datei: Standard-Pfade aus dem Schema annehmen (`journal/`, `journal/reports/local/`, `specs/`, `ARCHITECTURE_DESIGN.md`) und im Output vermerken: "Hinweis: `.claude/environment.json` fehlt — Defaults aktiv. Empfehlung: `/bootstrap` re-rennen oder die Datei manuell anlegen."

## Modi

### Modus A: Infrastructure Check (Standard)

Schnelle Bestandsaufnahme der aktuellen Umgebung.

1. **System-Ressourcen pruefen:**
   - CPU/RAM/Disk via Hostinger MCP (`VPS_getVirtualMachineV1`)
   - Laufende Prozesse und Docker-Container (`docker ps`)
   - Netzwerk-Verbindungen und offene Ports
2. **Docker-Status:**
   - Container-Health (alle laufenden Container)
   - Volume-Mounts und Persistent Storage
   - Docker-Netzwerk-Konfiguration
3. **Security Quick-Scan:**
   - SSH-Konfiguration (Key-Only, Port, Root-Login)
   - Firewall-Regeln (iptables/ufw)
   - Offene Ports vs. erwartete Ports
   - SSL/TLS-Zertifikate
4. **Report erstellen** — siehe Output-Format

### Modus B: Architecture Consultation (als Teammate)

Wird von `/ideation` oder `/implement` als Teammate hinzugezogen.

1. **Story-Kontext lesen** — welche Infrastruktur-Aspekte betrifft die Aenderung?
2. **Infrastruktur-Impact analysieren:**
   - Braucht es neue Ports/Firewall-Regeln?
   - Reichen die Server-Ressourcen?
   - Docker-Aenderungen noetig (neue Container, Volumes)?
   - DNS-Aenderungen noetig?
   - Neue externe Services/APIs die freigeschaltet werden muessen?
3. **Infrastruktur-Layer bewerten:**
   - Stack-neutrales 13-Layer-Entscheidungsraster (Pflichtfragen, Failure-Modes, Anti-Patterns):
     [references/infrastructure-dimensions.md](references/infrastructure-dimensions.md)
   - Konkrete VPS-Betriebs-/Härtungs-Checkliste:
     [references/vps-ops-checklist.md](references/vps-ops-checklist.md)
4. **Empfehlungen an den Lead/Architekten zurueckmelden**

### Modus C: Konfiguration ausfuehren

Aenderungen an der Infrastruktur vornehmen (mit Operator-Bestaetigung).

1. **Aenderung planen** — Was genau wird geaendert? Rollback-Plan?
2. **Operator-Bestaetigung einholen** — IMMER vor destruktiven Aenderungen
3. **Aenderung ausfuehren** via Hostinger MCP oder Shell-Commands
4. **Verifizieren** — Funktioniert alles? Kein Service-Ausfall?
5. **Dokumentieren** — Was wurde geaendert, warum, wann

## Hostinger MCP Tools

Der Skill nutzt den Hostinger MCP Server fuer API-Level-Operationen:

| Tool-Kategorie | Beispiel-Tools | Verwendung |
|----------------|---------------|------------|
| **VPS** | `VPS_getVirtualMachineV1`, `VPS_getFirewallListV1` | Status, Hardware, Firewall |
| **DNS** | `DNS_getDNSRecordsV1`, `DNS_updateDNSRecordsV1` | DNS-Verwaltung |
| **Domains** | `domains_getDomainDetailsV1` | Domain-Status |
| **Billing** | `billing_getSubscriptionListV1` | Kosten-Uebersicht |

Fuer Server-Level-Operationen (Docker, Prozesse, Files) werden Shell-Commands verwendet.

## Sicherheitsregeln

- **Keine destruktiven Operationen** ohne explizite Operator-Bestaetigung
- **Keine Firewall-Aenderungen** ohne vorherigen Dry-Run und Rollback-Plan
- **Keine DNS-Aenderungen** ohne TTL-Beruecksichtigung und Propagation-Warnung
- **API-Tokens** nie loggen oder in Klartext ausgeben
- **Immer erst lesen, dann aendern** — kein blindes Konfigurieren

## Output-Format

### Infrastructure Check Report

```
## Infrastructure Status Report

### System Resources
- **CPU:** X cores, Y% utilization
- **RAM:** X GB / Y GB (Z% used)
- **Disk:** X GB / Y GB (Z% used)
- **Uptime:** X days

### Docker Containers
| Container | Status | CPU | RAM | Ports |
|-----------|--------|-----|-----|-------|
| app       | ...    | ... | ... | ...   |

### Security
| Check | Status | Detail |
|-------|--------|--------|
| SSH   | ...    | ...    |
| Firewall | ... | ...   |
| Ports | ...    | ...    |
| SSL   | ...    | ...    |

### Empfehlungen
- ...
```

### Architecture Consultation (als Teammate)

```
## Infrastructure Assessment fuer: [Story-Titel]

| Dimension | Impact | Massnahme |
|-----------|--------|-----------|
| ...       | ...    | ...       |

### Infrastruktur-Aenderungen noetig:
- [ ] ...

### Risiken:
- ...
```
