# VPS-Ops-Checkliste fuer Cloud System Engineer

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](vps-ops-checklist.en.md)

Konkrete, **stack-spezifische** Betriebs- und Haertungs-Checkliste fuer Linux-VPS-Umgebungen (SSH, Docker, Firewall,
Backup). Sie ist die **operative Review-Linse** des Cloud System Engineer und ergaenzt das **stack-neutrale
13-Layer-Raster** in [`infrastructure-dimensions.md`](infrastructure-dimensions.md): das Raster fragt *welche*
Infrastruktur-Entscheidungen und -Risiken zu pruefen sind (universell, ohne Tech-Vorschrift); diese Checkliste sagt
*wie* eine konkrete VPS gehaertet und betrieben wird (mit konkreten Werkzeugen).

## 1. Compute & Resources
**Pruefen wenn:** Neuer Agent, neuer Daemon, neuer Container, erhoehte Last erwartet.
- CPU-Headroom: Genuegend Reserven fuer Peak-Zeiten?
- RAM: Node.js Heap + Docker Overhead + OS. Swap konfiguriert?
- Disk I/O: SQLite WAL-Mode bei hoher Schreiblast? Log-Rotation aktiv?
- Prozess-Limits: ulimit, max file descriptors, max processes

## 2. Container & Orchestrierung
**Pruefen wenn:** Neuer Service, Docker-Aenderung, Volume-Aenderung.
- Container-Health: Restart-Policy (always/unless-stopped)?
- Volume-Persistenz: Kritische Daten auf Named Volumes, nicht in Container?
- Netzwerk: Container-zu-Container Kommunikation (Docker Network)?
- Image-Updates: Wie werden Container aktualisiert? Downtime?
- Ressource-Limits: Docker memory/cpu limits gesetzt?

## 3. Netzwerk & Konnektivitaet
**Pruefen wenn:** Neuer externer Service, neuer Port, neue API-Verbindung.
- Firewall: Nur benoetigte Ports offen (Principle of Least Privilege)
- Egress: Welche externen APIs muessen erreichbar sein?
- Ingress: Welche Ports sind von aussen erreichbar? Warum?
- Latenz: Ist der Hosting-Standort optimal fuer die APIs?
- Bandwidth: Genuegend fuer WebSocket-Streams + API-Calls?

## 4. Security & Hardening
**Pruefen wenn:** Immer. Bei jedem Review.
- SSH: Key-Only Auth? Non-Standard Port? Fail2Ban aktiv?
- Firewall: UFW/iptables korrekt? Default-Deny Policy?
- Updates: OS-Patches aktuell? Node.js LTS?
- Secrets: .env auf VPS geschuetzt (chmod 600)? Nicht in Git?
- Docker: Container laufen als non-root? Read-only Filesystem wo moeglich?
- TLS: Zertifikate fuer alle exponierten Endpoints?

## 5. Backup & Disaster Recovery
**Pruefen wenn:** Neue kritische Daten, neue Datenbank, neue Konfiguration.
- VPS-Backup: Auto-Backup aktiv? Intervall?
- Daten-Backup: Trades-Journal, Datenbank, .env — wie gesichert?
- Recovery-Zeit: Wie schnell laesst sich das System wiederherstellen?
- Rollback-Plan: Bei fehlgeschlagenem Update — wie zurueck?

## 6. Monitoring & Alerting
**Pruefen wenn:** Neuer kritischer Pfad, neuer Daemon, neue externe Abhaengigkeit.
- Uptime-Monitoring: Aktiv?
- Disk-Space-Alert: Warnung bevor Disk voll?
- Container-Health: Auto-Restart bei Crash?
- API-Health: Extern erreichbare Endpoints ueberwacht?

## 7. Kosten & Skalierung
**Pruefen wenn:** Ressourcen-Erhoehung noetig, neuer Service, Upgrade-Planung.
- VPS-Plan: Reicht der aktuelle Plan? Naechste Stufe noetig?
- Bandwidth-Kosten: Traffic-Limit des Plans beachten
- Skalierungs-Pfad: Vertikal (groesserer VPS) vs. Horizontal (mehrere VPS)
- Alternative Hosting-Optionen fuer spezifische Workloads

## Verweis

Stack-neutrales Infrastruktur-Entscheidungsraster (13 Layer, Pflichtfragen/Anti-Patterns):
[`infrastructure-dimensions.md`](infrastructure-dimensions.md).
</content>
