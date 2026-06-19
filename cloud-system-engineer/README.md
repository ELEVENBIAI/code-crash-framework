<a name="deutsch"></a>

# Cloud System Engineer — VPS, Docker, Firewall, DNS aus Claude Code

> Behandelt Cloud-Infrastruktur als Teammate: Health-Checks auf VPS und Containern, Firewall-Audit, DNS-Management, Infra-Kosten-Abschaetzung. Drei Modi — standalone Check, Architektur-Konsultation (als Teammate), oder Aenderungen ausfuehren mit Operator-Freigabe.

**Version:** 1.2.0 · **Befehl:** `/cloud-system-engineer`

> **Claude-Code-Modus:** Check/Konsultation (Modus A/B) sind read-only → **`plan`**; Aenderungen ausfuehren (Modus C: Firewall/DNS/Docker, remote-irreversibel) → **`default`** (Ask before edits), pro Aktion bewusst freigeben — **nie** `acceptEdits`/`dontAsk`/unbeaufsichtigt. Details: HANDBUCH §6 „Claude-Code-Modus".

---

## Was der Skill tut

Die meisten Dev-Teams ignorieren Infrastruktur bis etwas kaputt geht. Der Skill macht Infrastruktur zum Erst-Klasse-Citizen im Dev-Workflow: Er prueft das VPS, markiert Security-Fehlkonfigurationen und nimmt als Teammate an `/ideation` teil wenn eine Story Infra-Impact hat.

Nutzt den Hostinger MCP Server fuer API-Level-Operationen (VPS, DNS, Firewall, Billing) und lokale Shell-Commands fuer Server-Level-Operationen (Docker, Prozesse, Files).

---

## Drei Modi

### Modus A — Infrastructure Check (Default)

Schnelle Bestandsaufnahme der aktuellen Umgebung.

| Check | Was er deckt |
|-------|--------------|
| System-Ressourcen | CPU, RAM, Disk, Netzwerk, Uptime |
| Docker | Container-Health, Volumes, Netzwerke, Ports |
| Security | SSH-Config (Key-Only, Port, Root-Login), Firewall, Ports vs. erwartet, SSL |
| Report | Strukturierter Output — Format siehe unten |

### Modus B — Architecture Consultation (als Teammate)

Wird von `/ideation` oder `/implement` aufgerufen wenn Story Infrastruktur beruehrt.

| Aufgabe | Was bewertet wird |
|---------|-------------------|
| Story-Kontext lesen | Welche Infra-Aspekte betrifft die Aenderung? |
| Impact-Analyse | Neue Ports/Firewall? Server-Ressourcen ausreichend? Docker-Aenderungen? DNS? Externe APIs freizuschalten? |
| Infrastruktur-Dimensionen | Reliability, Security, Cost Efficiency, Scalability — siehe Referenz-Datei |
| Feedback | Empfehlungen an Lead/Architekt, keine Direkt-Ausfuehrung |

### Modus C — Aenderungen ausfuehren

Infrastruktur-Aenderungen anwenden — IMMER mit Operator-Bestaetigung.

1. Aenderung planen — was aendert sich, Rollback-Plan?
2. **Operator-Bestaetigung** — IMMER vor destruktiven Ops
3. Ausfuehren via Hostinger MCP oder Shell
4. Verifizieren — Service laeuft? Keine Seiteneffekte?
5. Dokumentieren — was, warum, wann

---

## Safety-Regeln (harte Constraints)

- Keine destruktive Operation ohne explizite Operator-Bestaetigung
- Keine Firewall-Aenderung ohne Dry-Run und Rollback-Plan
- Keine DNS-Aenderung ohne TTL-Beruecksichtigung und Propagation-Warnung
- API-Tokens nie loggen oder klartext ausgeben
- Immer erst lesen, dann aendern — kein blindes Konfigurieren

---

## Trigger-Phrasen

- `/cloud-system-engineer`
- "Umgebung pruefen"
- "Infrastruktur"
- "Server-Status"
- "Firewall"
- "VPS"
- "Hostinger"

---

## Schnittstellen zu anderen Skills

| Upstream | Warum wir gerufen werden | Downstream | Was wir liefern |
|----------|--------------------------|------------|------------------|
| `ideation` (Teammate-Mode) | Story beruehrt Infra | `grafana` | Infra-Metriken fuer Dashboards |
| `implement` | Deployment involviert VPS/Docker | `security-architect` (AUDIT) | Infra-Security-Befunde |
| Operator | Day-to-Day-Infra-Fragen | `architecture-review` | Infrastruktur-Dimensionen-Bewertung |

---

## Artefakte / Outputs

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

### Empfehlungen
- ...
```

### Architecture Consultation (als Teammate)
```
## Infrastructure Assessment fuer: [Story-Titel]
| Dimension | Impact | Mitigation |
### Infra-Aenderungen noetig:
- [ ] ...
### Risiken:
- ...
```

---

## Voraussetzungen

- Hostinger MCP Server (optional — Shell-Commands koennen ersetzen)
- SSH-Zugang zum VPS
- Hostinger API-Token in `.env` (nie im Code)

---

## Installation

```bash
cp -r cloud-system-engineer ~/.claude/skills/cloud-system-engineer
```

---

## Dateistruktur

```
cloud-system-engineer/
├── SKILL.md                                ← Skill-Definition
└── references/
    ├── infrastructure-dimensions.md        ← Stack-neutrales 13-Layer-Entscheidungsraster (Fragen/Risiken/Anti-Patterns)
    └── vps-ops-checklist.md                ← Konkrete VPS-Betriebs-/Härtungs-Checkliste (SSH, Docker, Firewall, Backup)
```
