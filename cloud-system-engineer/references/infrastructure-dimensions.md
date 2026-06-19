# Infrastruktur-Layer — Entscheidungsraster (13 Layer)

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](infrastructure-dimensions.en.md)

Stack-, sprach- und plattformneutrales **Fragen- und Risiko-Raster** für die 13 Infrastruktur-Layer, die ein Prototyp zum
Produkt machen. Es schreibt **keine Technologie vor** — es macht sichtbar, *welche* Infrastruktur-Entscheidungen pro Layer
zu treffen sind, *welche* Risiken (Failure-Modes, Anti-Patterns) lauern und *wann* „minimal" nicht mehr reicht. Konkrete,
stack-spezifische Vorschläge (Produkte, Konfiguration) gehören **bewusst nicht** hierher — die generiert der Skill
`infrastructure-onboarding` (BOO-223) zur Laufzeit aus dem echten Stack. Für die konkrete VPS-Betriebs-/Härtungs-Ebene
siehe [`vps-ops-checklist.md`](vps-ops-checklist.md).

> **Zwei Achsen, keine Ersetzung.** Dieses Raster ist die **Infra-Achse** (Runtime/Deployment/Infrastruktur). Die
> **Qualitäts-Achse** (Reliability, Testability, Maintainability, Scalability …) lebt unverändert in den Architektur-
> Dimensionen (HANDBUCH §5). Überlappung (Security, Monitoring, Performance) wird **per Querverweis** behandelt, nicht
> dopplelt gepflegt — siehe die Layer×Qualitäts-Attribut-Matrix unten.

Pro Layer: **Zweck · Pflichtfragen · Failure-Modes · Anti-Patterns (die Guardrails) · Ansatz-Kategorien (Trade-offs) ·
Minimal vs. „mehr nötig" · Compliance-Trigger · §5-Überlappung.**

---

## Lauf 1 — Data & Delivery

### 1. Frontend
- **Zweck:** Liefert die Benutzeroberfläche und vermittelt zwischen menschlicher Interaktion und den Backend-Diensten.
- **Pflichtfragen:** Wo wird gerendert (CSR/SSR/SSG/ISR/Edge), und passt das zu den SEO-Anforderungen? Wie wird State verwaltet? Wie ist das Frontend per API-Vertrag vom Backend entkoppelt? Welche Performance-Budgets (Core Web Vitals) gelten und wie werden sie gemessen? Wie wird Accessibility (WCAG) sichergestellt?
- **Failure-Modes:** Falscher Rendering-Ansatz → schlechtes SEO. Zu viel State im Client → schwer reproduzierbare Bugs + größere Angriffsfläche. Ungepatchte JS-Dependencies → XSS/Supply-Chain. Fehlende Accessibility → rechtlich angreifbar.
- **Anti-Patterns:** SPA für content-lastige öffentliche Seiten · schweres Framework für statischen Content · **Business-Logik nur im Frontend** (nie autoritativ) · versionsloses API-Coupling · kein Performance-Budget.
- **Ansatz-Kategorien:** CSR (Interaktivität ↔ schwaches SEO) · SSR (schneller First Paint ↔ Serverkosten) · SSG (CDN-Speed ↔ nur selten ändernder Content) · ISR (SSG-Speed + Frische ↔ Build-Komplexität) · Edge (Latenz ↔ eingeschränkte Runtime) · Hybrid (flexibel ↔ Komplexität).
- **Minimal vs. mehr:** CSR/SSG reicht für interne Tools/Prototypen. Mehr nötig bei öffentlichem SEO-Traffic (SSR/SSG/ISR), globaler Latenz-SLA (Edge), Barrierefreiheits-Pflicht (Accessibility-Gate).
- **Compliance-Trigger:** EU Accessibility Act (ab 2025); GDPR Art. 25 bei PII im State; PCI-DSS bei Zahlungsabwicklung.
- **§5-Überlappung:** eher Qualitäts-Attribut (Performance/Accessibility/SEO sind Cross-Cutting); der Layer selbst ist Infra-Baustein.

### 2. APIs & Backend
- **Zweck:** Stellt Geschäftslogik und Daten-Schnittstellen bereit, über die alle Clients mit dem System interagieren.
- **Pflichtfragen:** Welches API-Paradigma (REST/GraphQL/gRPC/Event-driven)? Wie wird der API-Vertrag (Schema, Versioning, Backward-Compat) durchgesetzt? Wie werden AuthN/AuthZ am Eingang erzwungen? Wie erfolgt Input-Validierung gegen Injection? Wie wird horizontal skaliert (Statefulness-Annahmen)?
- **Failure-Modes:** Fehlende Input-Validierung → Injection (OWASP Top 10). Stateful Monolith ohne Skalierung → SPOF unter Last. Unversioned API → Breaking Changes brechen Clients. Hartcodierte Credentials → Exposure. Fehlende Timeouts → kaskadierende Ausfälle.
- **Anti-Patterns:** **Kein API-Vertrag/keine Versionierung** · Business-Logik in der Datenbank (Stored Procedures als Primär-Logik) · Monolith mit implizitem Coupling · **Config/Secrets im Code** · keine Idempotenz bei mutierenden Operationen.
- **Ansatz-Kategorien:** Monolith (einfach ↔ Big Ball of Mud) · Modularer Monolith (saubere Grenzen ↔ Disziplin nötig) · Microservices (unabhängiges Scaling ↔ Distributed-Komplexität) · Serverless (kein Ops ↔ Cold Starts/Lock-in) · Event-driven (Entkopplung ↔ Observability/Eventual Consistency).
- **Minimal vs. mehr:** (Modularer) Monolith reicht für Prototyp/kleines Team/klare Domäne. Mehr nötig bei unabhängigen Domain-Teams, Compliance-Trennung (PCI-Scope), divergierenden Lastprofilen.
- **Compliance-Trigger:** PCI-DSS (Zahlungs-API segmentiert); GDPR Art. 25 (Datenminimierung am Eingang); HIPAA (PHI verschlüsselt+auditiert); NIS2/DORA (Resilienz kritischer Dienste).
- **§5-Überlappung:** Infra-Baustein; Security und Performance sind hier zu erzwingende Qualitäts-Attribute.

### 3. Database & Storage
- **Zweck:** Persistiert den Systemzustand und garantiert Datenintegrität über den Lebenszyklus.
- **Pflichtfragen:** Welches Daten-Modell passt zur Domäne (relational/Document/KV/Graph/Time-Series)? Welche Konsistenzgarantien (ACID/Eventual)? Wie wird Hochverfügbarkeit (Replikation/Failover) und Skalierung (Sharding/Shard-Key) erreicht? Was ist die Backup-Strategie (RPO/RTO, Restore-Test)? Wie werden Schema-Migrationen versioniert?
- **Failure-Modes:** Fehlende Replikation → SPOF/Datenverlust. Falscher Shard-Key → Hotspots, Re-Sharding-Albtraum. Ungetestetes Backup → Paper-RTO ≠ reale Restore-Zeit. Shared-DB über Servicegrenzen → implizites Coupling. Keine Encryption at Rest bei regulierten Daten → Compliance-Verletzung.
- **Anti-Patterns:** One-Size-Fits-All (RDBMS für alles) · kein getrennter Read/Write-Pfad · **migrationsfreies Schema in Prod** · **Shared Database across Services** · **kein Restore-Test** (Restore ist Theorie).
- **Ansatz-Kategorien:** RDBMS (ACID ↔ horizontale Skalierung aufwändig) · Document (flexibel ↔ schwache Joins) · KV (max. Speed ↔ minimale Abfrage) · Wide-Column (massiv horizontal ↔ Umdenken) · Graph (Beziehungen ↔ Nische) · Replikation/Sharding (Skalierung ↔ Betriebskomplexität).
- **Minimal vs. mehr:** Single-Node-RDBMS reicht für Prototyp/<10k Nutzer/keine HA-SLA. Mehr nötig bei >99.9% SLA (Replikation+Failover), Datenwachstum >1 Node (Sharding), Regulatorik (Encryption at Rest + Audit Logs).
- **Compliance-Trigger:** GDPR (Löschbarkeit technisch realisierbar); HIPAA (Encryption at Rest+Transit für PHI); PCI-DSS (isolierter Card-Storage); SOC 2 (Backup-/Zugriffs-Audit); MiFID II/DORA (unveränderliche Transaktionslogs).
- **§5-Überlappung:** Infra-Baustein; Durability, Availability, Confidentiality werden durch DB-Design realisiert.

### 4. Caching & CDN
- **Zweck:** Reduziert Latenz und Last durch temporäres Vorhalten häufig angefragter Daten näher am Konsumenten.
- **Pflichtfragen:** Was wird gecacht (API-Antworten/Queries/Sessions/Assets/HTML)? Welche Invalidierungsstrategie (TTL/Event/Write-Through/-Behind/-Around)? Wo liegt der Cache (In-Process/Distributed/CDN-Edge/Browser)? Welche Staleness ist fachlich tolerierbar? Wie verhält sich das System bei Cold Start / Cache-Stampede?
- **Failure-Modes:** Thundering Herd/Cache-Stampede bei gleichzeitig ablaufenden TTLs. Stale Data als Autorität (besonders Preise/Permissions). Sensible Daten im Public CDN → Datenpanne. Fehlende Invalidierung beim Deployment → alte Assets. Cache als SPOF.
- **Anti-Patterns:** Cache-everything-by-default ohne Hot-Path-Messung · **kein TTL** (ewig veraltet) · **personalisierte Responses ohne Vary-Header** (CDN liefert sie fremden Nutzern) · Cache als Backup-Strategie · Invalidierungs-Ignoranz bei Mutationen.
- **Ansatz-Kategorien:** In-Process (kein Netz-Hop ↔ kein Sharing, Verlust bei Neustart) · Distributed (Shared State ↔ Netz-Hop) · CDN-Edge (Latenz ↔ limitierte Invalidierung) · Browser (kein Serveraufwand ↔ schwer invalidierbar) · Cache-Aside / Read-/Write-Through (Trade-off Kontrolle ↔ Code-Verantwortung).
- **Minimal vs. mehr:** Kein explizites Caching nötig für interne Tools/Prototyp/<1k RPS. Empfohlen wenn DB zum Bottleneck wird; CDN zwingend bei weltweiten Nutzern / >10k concurrent / großen Static Assets.
- **Compliance-Trigger:** GDPR (keine PII über CDN außerhalb EWR ohne Garantien); Finanz-/Healthcare-Daten nicht über öffentliche/Edge-Caches.
- **§5-Überlappung:** eher Qualitäts-Attribut (Performance/Availability als Ziel); der Cache ist Mechanismus zur Realisierung.

---

## Lauf 2 — Run & Scale

### 5. Hosting & Deployment
- **Zweck:** Stellt die Laufzeitumgebung bereit und definiert den Übergang von Code-Artefakt zu laufendem Service.
- **Pflichtfragen:** Welches Abstraktionsniveau (IaaS/Container/PaaS/Serverless)? Wie wird Dev/Prod-Parity gehalten? Wie wird IaC für Reproduzierbarkeit/Drift-Vermeidung umgesetzt? Wie erfolgt Zero-Downtime-Deployment (Blue/Green/Canary/Rolling)? Wie werden Secrets sicher injiziert? Wie sind Health-/Readiness-Checks definiert?
- **Failure-Modes:** Deployment-Downtime ohne Zero-Downtime-Strategie. Umgebungs-Drift Staging↔Prod. Keine IaC → nicht reproduzierbar/auditierbar. Fehlende Health-Checks → defekte Instanzen erhalten Traffic. Secrets im Build-Artefakt → Leakage über Registry.
- **Anti-Patterns:** **„SSH into Production"** (manuelle Änderungen ohne IaC) · Snowflake Servers · Single Deployment Slot (kein Canary/Blue-Green) · Config im Image gebaked · kein Ressourcen-Budget (keine CPU/Mem-Limits).
- **Ansatz-Kategorien:** IaaS (max. Kontrolle ↔ max. Ops) · Container+Orchestration (Portabilität ↔ Lernkurve) · PaaS (schnell ↔ limitierte Kontrolle/Preis) · Serverless (kein Ops ↔ Cold Starts/Lock-in) · Hybrid (nach Workload ↔ hohe Reife nötig).
- **Minimal vs. mehr:** PaaS/Serverless reicht für MVP/kleines Ops-Team. Mehr nötig bei >99.9% SLA mit Maintenance-Windows, Compliance-Audit (Infra-Kontrolle), Cost-Optimierung bei hohem Hosting-Budget → IaC+Container.
- **Compliance-Trigger:** ISO 27001 (Change-Management); SOC 2 (Deployment-Logs als Evidence, Separation of Duties); DORA (Deployment als ICT-Risiko dokumentiert).
- **§5-Überlappung:** Infra-Baustein; Availability, Maintainability, Reliability sind Qualitäts-Attribute dieses Layers.

### 6. Cloud & Compute
- **Zweck:** Stellt (virtualisierte) Rechenressourcen bereit und definiert die Sourcing-Strategie.
- **Pflichtfragen:** Welche Cloud-Strategie (Single/Multi/Hybrid/On-Prem)? Wie wird Vendor-Lock-in begrenzt? Wie läuft Capacity-Planning (reaktiv/Auto-Scaling/Reserved)? Wie werden Compute-Kosten gemessen/optimiert (FinOps)? Welche Datenresidenz-/Latenz-Zonen gelten? Wie wird mit Provider-Incidents umgegangen (AZ/Multi-Region)?
- **Failure-Modes:** Single-AZ → AZ-Outage = Totalausfall. Kein Auto-Scaling → Traffic-Spike überfordert fixe Kapazität. Cloud-Cost-Sprawl → Budget-Überschreitung. Datenlokalisierungs-Verletzung → GDPR-Bußgeld. Over-Reliance auf Proprietary → prohibitive Exit-Kosten.
- **Anti-Patterns:** Lift-and-Shift ohne Redesign · manuelles Capacity-Management (keine Elastizität) · **kein FinOps** (keine Kostensichtbarkeit) · alle Eier in eine AZ · max. Vendor-Lock-in ohne Exit-Strategie.
- **Ansatz-Kategorien:** Public Single-Provider (einfach ↔ Lock-in) · Multi-Cloud (Resilienz ↔ komplexes Networking/IAM) · Private/On-Prem (Datenkontrolle ↔ Capex, kein elastisches Scaling) · Hybrid (Kontrolle+Elastizität ↔ Integrationsaufwand) · Serverless Compute (Elastizität ↔ Cold Starts).
- **Minimal vs. mehr:** Single-Region reicht für Prototyp/Region-Nutzerbasis. Mehr nötig bei globaler Nutzerbasis (Multi-Region), Datensitz-Pflicht (Region-Pinning), >99.95% (Multi-AZ), KRITIS (Private/Hybrid).
- **Compliance-Trigger:** GDPR (Verarbeitung nur in Ländern mit angemessenem Schutz, SCCs); BSI C5 (Testat für regulierte Branchen); DORA (Cloud-Anbieter registriert, Exit-Plan verpflichtend).
- **§5-Überlappung:** Infra-Baustein; Reliability (Multi-AZ), Cost Efficiency (FinOps), Portability sind Qualitäts-Attribute.

### 7. CI/CD & Version Control
- **Zweck:** Automatisiert den Weg von Code-Änderung zu getestetem, ausgeliefertem Deployment — mit Rückverfolgbarkeit jeder Änderung.
- **Pflichtfragen:** Welche Branching-Strategie (Trunk-Based/Gitflow)? Wie sind Build/Release/Run getrennt? Welche Qualitätsgates (Tests/SAST/Dependency-Scan/Lint) sind vor Merge/Deploy verpflichtend? Wie werden Artefakte versioniert/signiert? Wie werden Secrets im CI/CD gehandhabt? Wie wird die Pipeline selbst getestet/versioniert (Pipeline as Code)?
- **Failure-Modes:** Secrets in Pipeline-Config/Repo → Exposure. Keine Artefakt-Signierung → Supply-Chain-Attack. Manuelle Deployments neben der Pipeline → Drift. Zu seltene große Releases → hohes Risiko. Keine Pipeline-Tests → bricht produktiv ohne Vorwarnung.
- **Anti-Patterns:** **Secrets im Repository** (auch in der Git-History) · kein Artifact Registry · **manuelles Deploy-to-Production ohne Audit-Trail** · monolithische Pipeline ohne Stages · kein Dev/Prod-Parity der Pipelines.
- **Ansatz-Kategorien:** Trunk-Based (weniger Merge-Konflikte ↔ Test-Disziplin/Feature-Flags) · Gitflow/Feature-Branches (strukturiert ↔ Merge-Komplexität) · Continuous Deployment (Velocity ↔ exzellente Coverage nötig) · Continuous Delivery (manueller Release-Trigger ↔ mehr Schritte) · Pipeline as Code (reproduzierbar ↔ DSL-Lernkurve).
- **Minimal vs. mehr:** Minimal = automatischer Build + Tests + manueller Deploy-Trigger, Secrets aus dem Code. Mehr nötig bei Reguliertheit (Separation of Duties), SBOM-Pflicht (EU CRA → Dependency-Scan-Gate), >10 Entwickler (Branching + Branch Protection).
- **Compliance-Trigger:** SOC 2 (Deployment-Logs als Evidence); ISO 27001 (Change-Management, autorisierte Änderungen); EU Cyber Resilience Act (SBOM ab 2027); DORA (ICT-Change-Management).
- **§5-Überlappung:** Infra-Baustein (Delivery-Prozess); Security (Supply Chain), Maintainability, Reliability sind Qualitäts-Attribute.

### 8. Rate Limiting
- **Zweck:** Schützt das System vor Überlastung, Missbrauch und DoS durch Begrenzung der Anfragehäufigkeit pro Zeiteinheit.
- **Pflichtfragen:** Auf welcher Ebene (Gateway/LB/Middleware/App)? Welche Dimension wird begrenzt (IP/User/API-Key/Endpoint/Tenant)? Welcher Algorithmus (Fixed/Sliding Window, Token/Leaky Bucket)? Wie konsistent in verteilten Deployments (kein Node-Hopping-Bypass)? Wie werden Limits an den Client kommuniziert (429, Retry-After)? Fail Open oder Fail Closed?
- **Failure-Modes:** Kein Rate Limiting → DDoS/ineffizienter Client überlastet, Kosten explodieren. Limiting nur auf einem Node → Bypass durch IP-Rotation. Zu restriktiv ohne Burst → legitime Spitzen geblockt. Fehlende Limit-Kommunikation → sofortige Retries erhöhen Last. Fail-Open im Ausfall → Schutz entfällt im Angriffsszenario.
- **Anti-Patterns:** Kein Limiting bei „vertrauenswürdigen Clients" (auch intern buggy/kompromittiert) · **nur IP-Ebene** (Bot-Netz umgeht es) · einheitliche Limits für alle Endpunkte · **keine Limit-Headers** in Responses · Rate Limiting als After-Thought.
- **Ansatz-Kategorien:** Fixed Window (einfach ↔ Burst am Fensterende) · Sliding Window (gleichmäßig ↔ Aufwand) · Token Bucket (kontrollierte Bursts) · Leaky Bucket (glättet ↔ keine Bursts) · zentral/Gateway (konsistent ↔ SPOF) · distributed (HA ↔ Sync-Overhead).
- **Minimal vs. mehr:** Minimal ab erstem öffentlichen Endpunkt: IP-basiert am Eingang, auch ohne Auth. Mehr nötig bei mehreren API-Tiers (User-/Key-Limits), >100 RPS (zentral/verteilt), Partner-APIs (Quota-Management).
- **Compliance-Trigger:** Kein universeller Standard; implizit für Verfügbarkeits-SLAs; Finanz: Burst-Missbrauch bei Transaktions-APIs (indirekte Pflicht).
- **§5-Überlappung:** eher Qualitäts-Attribut (Availability, Abuse-Prevention, Fairness); Rate Limiting ist Mechanismus, kein eigenständiger Infra-Block.

---

## Lauf 3 — Trust & Operate

### 9. IAM / RBAC / Permissions
- **Zweck:** Kontrolliert, wer (Identity) was (Permission) auf welche Ressource in welchem Kontext darf — die zentrale Vertrauensgrundlage.
- **Pflichtfragen:** Wie werden Identitäten (Nutzer/Services) authentifiziert (Passwort/MFA/Cert/OIDC/SAML)? Wie ist das Rollenmodell strukturiert (flach/hierarchisch/ABAC)? Wie wird Least Privilege je Rolle/Service-Account durchgesetzt? Wie werden privilegierte Zugänge zeitlich limitiert (JIT)? Wie laufen On-/Offboarding? Wie sind Service-to-Service-Zugänge gesichert (Workload Identity/mTLS)?
- **Failure-Modes:** Zu breite Rollen → maximaler Blast Radius. Kein Offboarding → Ex-Mitarbeiter/-Systeme behalten Zugang. Shared Credentials → eine Kompromittierung trifft alle. Keine MFA für privilegierte Accounts → Phishing direkt wirksam. Privilege Creep über Zeit.
- **Anti-Patterns:** **„God Mode" Service Accounts** · statische, nie rotierte Credentials · keine IAM-as-Code · **keine Separation of Duties** (eine Person schreibt+reviewt+deployt+DB-Zugriff) · Implicit Trust im internen Netz.
- **Ansatz-Kategorien:** RBAC (einfach ↔ granulare Ausnahmen schwer) · ABAC (feingranular ↔ Policy-Komplexität) · ReBAC (Objekthierarchien ↔ anspruchsvoll) · Centralized IdP (Single Source ↔ SPOF) · Federated (SSO ↔ Provider-Abhängigkeit) · Zero Trust/Workload Identity (kein Netz-Vertrauen ↔ hohe Reife).
- **Minimal vs. mehr:** Minimal = MFA für privilegierte Accounts, Least Privilege, keine Shared Credentials, Offboarding-Prozess. Mehr nötig bei >10 Nutzern (formales RBAC), Reguliertheit (Access Reviews), Microservices (Workload Identity/mTLS), SOC 2/ISO 27001 (IAM als Audit-Target).
- **Compliance-Trigger:** GDPR (Zugang beschränkt+dokumentiert); ISO 27001 A.9; SOC 2 CC6; PCI-DSS Req 7/8; NIS2 (privilegierter Zugang reguliert).
- **§5-Überlappung:** eher Qualitäts-Attribut (Security); IAM ist zugleich Infra-Baustein (Auth-System) und Security-Control.

### 10. Security & RLS (Row-Level Security)
- **Zweck:** Erzwingt granulare Zugriffsrechte auf einzelne Datensätze — Nutzer sieht nur seine Daten, unabhängig von API-Layer-Kontrollen.
- **Pflichtfragen:** Welche Daten-Ebenen-Isolation (Object-/Row-/Column-Level)? Wo wird RLS durchgesetzt (DB-Engine/ORM/Service)? Wie wird IDOR verhindert? Wie wird die Security-Policy als Code verwaltet+getestet? Wie wird Multi-Tenancy isoliert (Shared-Schema+RLS / separate Schema / separate DB)? Wie werden Datenzugriffe auf Datensatz-Ebene geloggt?
- **Failure-Modes:** IDOR → Nutzer A liest Daten von B per ID-Manipulation. RLS-Policy-Fehler → alle statt gefilterte Zeilen (Silent Full Access). Bypass durch Admin-Direkt-Queries ohne RLS. Fehlende Column-Encryption → Breach exponiert Klartext. Logging-Lücken → Forensik unmöglich.
- **Anti-Patterns:** **RLS ausschließlich im Application Layer** (ein Bug öffnet alles) · keine Tests der RLS-Policies · Shared DB-User für alle Services · **Tenant-Isolation nur per WHERE-Clause** · Feld-Verschlüsselung als Nachgedanke.
- **Ansatz-Kategorien:** DB-native RLS (unabhängig vom App-Layer ↔ DB-spezifisch) · ORM-Level (portabel ↔ umgehbar bei Direkt-DB) · Service-Layer (flexibel ↔ ein Bug exponiert alles) · separate Schemas/DBs per Tenant (stärkste Isolation ↔ Ops-Aufwand) · Policy-as-Code (zentral/versioniert ↔ Runtime-Call).
- **Minimal vs. mehr:** Minimal ab Multi-User-System: IDOR-Schutz (Ownership-Check bei jedem Zugriff). DB-native RLS bei Shared-Schema-Multi-Tenancy/regulierten Daten. Column-Encryption bei Legal-Hold-Feldern (PAN/SSN/Gesundheit); Row-Level Audit Logging bei Forensik-Pflicht.
- **Compliance-Trigger:** GDPR Art. 5/25 (Datenminimierung auf Datensatz-Ebene); HIPAA (Minimum Necessary); PCI-DSS Req 3; SOC 2 CC6.1.
- **§5-Überlappung:** eher Qualitäts-Attribut (Confidentiality/Integrity); RLS ist Mechanismus zur Realisierung auf Datenebene.

### 11. Monitoring / Logs / Alerts
- **Zweck:** Schafft kontinuierliche Sichtbarkeit über den Systemzustand und erkennt Abweichungen von Service-Level-Zielen rechtzeitig.
- **Pflichtfragen:** Welche drei Signale (Metrics/Logs/Traces) werden gesammelt und korreliert? Wie sind SLIs definiert und auf welchen SLOs basieren Alerts? Wie wird Alert-Fatigue vermieden (actionable vs. informational)? Wie sind Logs strukturiert und zentralisiert? Wie werden Logs gegen Manipulation gesichert (Immutability)? Welche Retention gilt (Compliance)?
- **Failure-Modes:** Kein Monitoring → Silent Failures. Alert-Fatigue → echte Incidents übersehen. Unstrukturierte Logs → Suche dauert Stunden. Keine Distributed Traces → Diagnose ist Rätselraten. Log-Lücken im Audit. Monitoring des falschen Signals → grüne Metriken, degradierte UX (False Comfort).
- **Anti-Patterns:** **Threshold-Alerts ohne SLO-Bezug** (CPU>80% ohne User-Impact) · log-alles-filtere-nichts · Monitoring als After-Thought · kein End-to-End-Tracing · **Mutable Logs** (für Compliance wertlos).
- **Ansatz-Kategorien:** Metrics (effizient ↔ kein Kontext) · Log-Aggregation (Kontext ↔ Kosten/Suche) · Distributed Tracing (End-to-End ↔ Sampling) · SLO-/Burn-Rate-Alerting (user-impact-korreliert ↔ Einarbeitung) · korreliertes Observability (vollständig ↔ Komplexität).
- **Minimal vs. mehr:** Minimal ab erstem Deployment: Health-Check + Uptime-Alert + Error-Rate + strukturierte Logs. Mehr nötig bei >2 Services (Tracing), Kunden-SLA (SLO-Alerting), Reguliertheit (Immutable Logs + Retention), hohem RPS (Sampled Tracing).
- **Compliance-Trigger:** SOC 2 CC7; ISO 27001 A.12.4; GDPR Art. 33 (Breach-Detection); DORA (kontinuierliches Monitoring); MiFID II (Transaktions-Logs, 5–7 J. Retention).
- **§5-Überlappung:** eher Qualitäts-Attribut (Reliability/Maintainability/Security-Detection); Monitoring ist Cross-Cutting über alle Layer.

### 12. Rollback & Recovery
- **Zweck:** Führt das System nach Fehldeployments, Datenkorruption oder Ausfällen in einen definierten Zustand zurück — innerhalb vereinbarter RTO/RPO.
- **Pflichtfragen:** Welche RTO/RPO pro Systemklasse? Wie wird Rollback ausgelöst (automatisch bei Health-Fail / manuell)? Wie werden DB-Migrationen rückwärtskompatibel gestaltet? Wie wird Restore-Fähigkeit verifiziert (regelmäßige Tests)? Wie wird Backup-Immutabilität gegen Ransomware gesichert (3-2-1, Air Gap)? Wie wird Recovery-Reihenfolge koordiniert?
- **Failure-Modes:** Ungetestete Backups → reale Restore-Zeit ≫ Paper-RTO. Irreversible Migration deployed → Code-Rollback unmöglich ohne Datenverlust. Keine Backup-Immutabilität → Ransomware verschlüsselt Backups mit. Undokumentierter manueller Rollback → Zeitverlust im Incident. Recovery-Reihenfolge undefiniert.
- **Anti-Patterns:** **„Wir haben Backups" ohne Restore-Test** · **Destructive Migrations** (DROP COLUMN ohne vorigen Code-Rollback) · kein Rollback-Plan im Deployment · Hot-Standby für alles (unnötige Kosten) · kein Post-Mortem-Prozess.
- **Ansatz-Kategorien:** Hot Standby (min. RTO/RPO ↔ Kosten/Sync) · Warm Standby (Balance ↔ Start-/Sync-Zeit) · Cold Recovery (günstig ↔ RTO in Tagen) · Blue/Green (Code-Rollback in Sekunden ↔ kein Schutz gegen Migrations-Fehler) · Feature Flags (Feature-Rollback ↔ Code-Komplexität) · Immutable Infrastructure (vorheriges Image ↔ Stateful separat).
- **Minimal vs. mehr:** Minimal = tägliches Backup + dokumentierter manueller Restore + Deployment-Rollback. Mehr nötig bei >99.9% SLA (Auto-Failover), RPO<1h (kontinuierliche Replikation), Ransomware-Risiko (Immutable/Air-Gapped), Retention-Pflichten.
- **Compliance-Trigger:** ISO 22301 (BCP/DRP mit RTOs); DORA (Recovery-Tests, Incident-Fristen 24h/72h/1M); SOC 2 A1; GDPR Art. 32; KRITIS (BCP verbindlich).
- **§5-Überlappung:** eher Qualitäts-Attribut (Availability/Durability/Resilience); Rollback/Recovery ist Mechanismus zur Realisierung.

### 13. Audit / Compliance & SLAs
- **Zweck:** Schafft die technische und organisatorische Grundlage für Nachweisbarkeit, Rechenschaft und vertragliche Verbindlichkeit gegenüber Regulatoren/Kunden.
- **Pflichtfragen:** Welche Frameworks gelten (GDPR/ISO 27001/SOC 2/PCI-DSS/HIPAA/NIS2/DORA/BSI C5)? Wie sind Audit-Trails implementiert (unveränderliche Logs, wer-wann-was)? Wie sind SLAs definiert und wie werden sie technisch als SLOs (≤ SLA mit Buffer) gemessen? Wie wird Continuous Compliance betrieben? Wie werden Sub-Processors bewertet? Wie ist der Breach-Notification-Prozess definiert+geübt?
- **Failure-Modes:** SLAs ohne messbaren Unterbau → Verletzung unbemerkt, Vertragsstrafe überraschend. Audit-Trail-Lücken → Prüfung scheitert. Compliance als Einmal-Projekt → Compliance Debt zwischen Audits. Keine Sub-Processor-Kontrolle (GDPR Art. 28). Breach ohne Notification-Prozess (Art. 33, 72h).
- **Anti-Patterns:** **Compliance-Theater** (Policy auf Papier, Kontrollen fehlen) · **SLA = SLO** (kein Fehlerbudget-Buffer) · retrospektiver Audit-Aufwand · Compliance als Security-Ersatz (Zertifikat ≠ Sicherheit) · kein Drittanbieter-Register.
- **Ansatz-Kategorien:** Continuous Compliance (laufend ↔ Tooling-Invest) · periodischer Audit (klar terminiert ↔ Verfall dazwischen) · Policy-as-Code (versioniert/testbar ↔ zusätzliche Codebasis) · GRC-Plattform (zentral ↔ teuer, ab mittlerer Größe) · Error-Budget-SLAs (messbar ↔ Monitoring-Reife nötig).
- **Minimal vs. mehr:** Minimal (jedes Produkt) = Datenschutz-Policy + Breach-Notification-Prozess + Basis-Audit-Log (Logins, Datenzugriffe). Mehr nötig bei B2B-Compliance-Nachweis (SOC 2/ISO 27001), Zahlungen (PCI-DSS), Gesundheitsdaten (HIPAA), EU-Finanz (DORA), KRITIS (BSI C5/NIS2). SLA-Tiefe wenn kundenseitige SLA-Verträge existieren.
- **Compliance-Trigger:** *Dieser Layer ist der Compliance-Layer selbst* — er aggregiert die Evidenz aller anderen Layer. Trigger = anwendbare Frameworks × Branche × Datenkategorien × Kundenprofil.
- **§5-Überlappung:** eher Qualitäts-Attribut (Accountability/Auditability/Legal Compliance); Cross-Cutting-Concern, der Evidenz aus allen Layern aggregiert.

---

## Schematische Übersicht: Layer × Qualitäts-Attribut-Matrix

Diese Matrix macht die **§5-Abgrenzung** operativ: Wo ein Layer in der Spalte „→ eher Q-Attribut" ein `●` trägt, ist der
Schwerpunkt eine **Qualitäts-Eigenschaft** (gehört primär auf die §5-Achse) und der Layer liefert nur den Infra-Mechanismus.
Überlappungen (Security/Monitoring/Performance) werden **per Querverweis** zwischen dieser Tabelle und HANDBUCH §5 gepflegt —
nicht doppelt.

| Layer | Security | Performance | Availability | Compliance | → eher Q-Attribut |
|---|---|---|---|---|---|
| Frontend | ◑ | ● | ○ | ◑ | ◑ |
| APIs & Backend | ● | ● | ● | ● | ○ |
| Database & Storage | ● | ◑ | ● | ● | ○ |
| IAM / RBAC | ● | ○ | ◑ | ● | ● |
| Hosting & Deployment | ◑ | ◑ | ● | ◑ | ○ |
| Cloud & Compute | ◑ | ● | ● | ◑ | ○ |
| CI/CD & Version Control | ● | ○ | ◑ | ● | ○ |
| Security & RLS | ● | ○ | ○ | ● | ● |
| Rate Limiting | ● | ● | ● | ○ | ● |
| Caching & CDN | ○ | ● | ◑ | ◑ | ● |
| Monitoring / Logs / Alerts | ● | ○ | ● | ● | ● |
| Rollback & Recovery | ◑ | ○ | ● | ● | ● |
| Audit / Compliance & SLAs | ● | ○ | ◑ | ● | ● |

`●` = primär relevant · `◑` = sekundär relevant · `○` = geringer Bezug

## Zwei Achsen — Abgrenzung zu HANDBUCH §5

- **Infra-Achse (dieses Raster):** *Welche* Infrastruktur-Entscheidung pro Layer, *welche* Risiken, *wann* mehr nötig ist.
- **Qualitäts-Achse (HANDBUCH §5):** *Welche* Qualitäts-Eigenschaften (Reliability, Testability, Maintainability,
  Scalability, Security …) das System erfüllen muss.
- **Querverweis statt Dopplung:** Layer mit `●` in „→ eher Q-Attribut" (Monitoring, Security & RLS, IAM, Rate Limiting,
  Caching, Rollback/Recovery, Audit) sind Mechanismen, die ein §5-Qualitätsziel realisieren. Die Infra-Tabelle eines
  Projekts (BOO-221) verweist für diese Layer auf §5, statt die Qualitäts-Dimension erneut auszuformulieren. §5 bleibt
  unverändert die Single Source of Truth der Qualitäts-Achse.

## Vererbungs-Mechanik (Katalog vs. Projekt vs. Konzern)

Der Katalog ist **stack-neutral und framework-weit** — er wird **nicht pro Kunde editiert**. Zwei Override-Ebenen:

1. **Framework-/Konzern-Ebene (geforkter Katalog):** Eine konzernweite Vorgabe (z.B. „nur EU-Regionen", „SOC-2-Pflicht ab
   Layer 13") lebt in einer **geforkten Framework-Instanz** dieses Katalogs — **einmal** gepflegt, an alle Projekte des
   Konzerns **vererbt** (Kopie beim Klon, nicht pro Projekt umgeschrieben). Vgl. [`../../docs/runbooks/multi-user-vps.md`](../../docs/runbooks/multi-user-vps.md)
   für die Klon-/Mehr-Nutzer-Mechanik.
2. **Einzel-Projekt-Ebene (Projekt-Tabelle):** Projekt-spezifische Entscheidungen + Abweichungen stehen in der
   **ARCHITECTURE_DESIGN-Infra-Tabelle** des Projekts (13 Zeilen, Status inkl. `n/a (bewusst)`; BOO-221). Sie **verweist**
   auf diesen Katalog, statt ihn zu kopieren.

Faustregel: **Katalog = Referenz (geteilt, vererbt), Projekt-Tabelle = Entscheidung (lokal).** Der geteilte Katalog wird nur
auf Framework-/Konzern-Ebene fortgeschrieben.

## Quellen

12-Factor App · AWS Well-Architected Framework · OWASP Cheat Sheet Series / Top 10 · Google SRE Book (SLI/SLO/Error Budgets) ·
NIST CSF 2.0 · ISO 22301 (Business Continuity) · ISO 27001 · SOC 2 Trust Services Criteria · GDPR / DSGVO · PCI-DSS · HIPAA ·
NIS2 · DORA · BSI C5 · EU Accessibility Act · EU Cyber Resilience Act. (Vollständige Fußnoten-Belege: Deep Research
`Research/Infrastruktur-Layer Entscheidungsraster.md` im Projekt-Vault.)

> **Technologieneutralität:** Alle in den Quellen genannten Produkte (Redis, Kubernetes etc.) sind ausschließlich Beispiele,
> keine Empfehlungen. Dieser Katalog nennt bewusst **keine** Produkte — konkrete Vorschläge generiert der Skill
> `infrastructure-onboarding` (BOO-223) zur Laufzeit aus dem realen Stack.
</content>
