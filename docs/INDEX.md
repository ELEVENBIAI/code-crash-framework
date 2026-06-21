# INTENTRON — Dokumenten-Index

[🇩🇪 Deutsch](./INDEX.md) · [🇬🇧 English](./INDEX.en.md)

Dieser Index listet **alle Dokumente** des Frameworks an einer Stelle — nicht die generierten Artefakte (`.excalidraw`/`.png`), nicht die `specs/` und nicht die Release-Notes (`docs/releases/`). Lies ihn als Landkarte: Die erste Tabelle erschließt die eigentliche Dokumentation (Handbuch, Runbooks, ADRs, Onboarding, Referenzen), die zweite die Skill-Dokumentation. Alle Pfade sind relativ zu `docs/`. Zurück zur Einstiegsseite: [README](../README.md).

Die Spalte **Sprachen** zeigt, ob ein Dokument zweisprachig vorliegt (`DE+EN`) oder nur auf Deutsch (`DE`). Der englische Zwilling liegt jeweils als `<name>.en.md` neben der deutschen Datei.

## Dokumentation

| Dokument | Beschreibung | Zielgruppe | Sprachen |
| --- | --- | --- | --- |
| [ADR: Branching-Standard](./domain/adrs/branching-standard.md) | Architektur-Entscheidung für Trunk-Based Development mit geschützter `main`-Branch. | Entwickler, Architekten | DE+EN |
| [ADR: Cross-Session-Drift](./domain/adrs/cross-session-drift.md) | Dokumentiert und akzeptiert den BOO-Nummern- und Wave-Buchstaben-Versatz aus parallelen Sessions. | Entwickler, Operator | DE+EN |
| [ADR: Design-Story-Handling](./domain/adrs/design-story-handling.md) | Architektur-Entscheidung, Design-Stories gegen eine Referenz zu implementieren statt über `change_type:design`. | Entwickler, Architekten | DE+EN |
| [ADR: Firmenkontext-Layer (Dev-VPS)](./domain/adrs/company-context-layer.md) | Spike-Entscheidung (Vorschlag): leaner Firmenkontext (Zweck/Ziele/Werte) als referenzierte Ebene der globalen CLAUDE.md statt parallelem SecondBrain. | Operator, Entwickler | DE+EN |
| [Anti-Pattern-Katalog](../references/anti-pattern-katalog.md) | Katalog typischer Anti-Patterns auf Sprint- und Programm-Ebene (Schrader Kap. 7) als Prüfreferenz. | Operator, Lead | DE+EN |
| [Artefakt- & Freigabe-Landkarte](./onboarding/artefakt-landkarte.md) | Überblick, welche Artefakte das Framework liefert und welche Rollen sie abnehmen. | Kunde, Operator | DE+EN |
| [Audit-Perspektive (Runbook)](./runbooks/audit-perspective.md) | Wie ein Auditor die Regel-Einhaltung anhand reproduzierbarer Belege verifiziert. | Auditor, CISO/CIO/CTO | DE+EN |
| [Bootstrap-Vorab-Fragebogen](./onboarding/bootstrap-prep.md) | Fragebogen, der vor dem Projekt-Aufsetzen die nötigen Eckdaten erhebt. | Kunde, Operator | DE+EN |
| [Business Case (Runbook)](./runbooks/ceo-business-case.md) | Warum ein Entscheider in INTENTRON investiert — der wirtschaftliche Nutzen. | CEO, Entscheider | DE+EN |
| [CISO-Sicht (Runbook)](./runbooks/ciso-security.md) | Was INTENTRON für die Cyber-Security bedeutet, von Threat Model bis Gate. | CISO | DE+EN |
| [Codequalität & Tech-Debt (Runbook)](./runbooks/cto-code-quality.md) | Wie ein CTO mit der Quality-Gate-Kette die Codequalität sichert. | CTO | DE+EN |
| [Compliance-Mechanik](./compliance/compliance-mechanik.md) | End-to-End-Mechanik aus Gates und Katalogen über den gesamten Lebenszyklus. | Operator, Compliance | DE+EN |
| [Conventions](../CONVENTIONS.md) | Verbindliche Konventionen für Arbeit, Code und Doku im Framework. | Entwickler, Operator | DE |
| [Daily-Bug-Scanner (Runbook)](./runbooks/daily-bug-scanner.md) | Wie der Codex-Reviewer-Job funktioniert und gebaut ist: Auslöser/Cron, Prompt-Vertrag, Sandbox, memory.md-Dedup, Findings, Setup, Grenzen. | Operator, Entwickler | DE+EN |
| [Demo-Vorbereitung (Runbook)](./runbooks/demo-vorbereitung.md) | Vorbereitungs-Drehbuch: VPS → /bootstrap → Beispiel-Story + kopierfertiger Prompt → Feature-Walkthrough → Reset, damit man mit fertiger Demo beim Kunden ankommt. | Vertrieb, Operator | DE+EN |
| [DPO-Sicht (Runbook)](./runbooks/dpo-privacy.md) | Wo Datenschutz im Framework fest verdrahtet ist — Planung, Code, Audit. | DPO | DE+EN |
| [Doku-Review 2026-06-03 (BOO-114–129)](./doc-review-2026-06-03-boo-114-129.md) | DE+EN-Review von Onboarding, Sketches und Handbuch auf Aktualität und Gaps. | Operator, Doku-Autor | DE |
| [Entwickler-Schnelleinstieg (Cheat-Sheet)](./quickstart-entwickler.md) | Kurzanleitung „Wann nehme ich was?" — `/implement` vs `/sprint-run` vs `--auto`, Gates, Schalter. ≤5 Seiten. | Entwickler | DE+EN |
| [Framework-Update (Runbook)](./runbooks/framework-update.md) | Wie ein Bestandsprojekt auf den aktuellen Framework-Stand gehoben wird. | Operator | DE+EN |
| [Glossar für Nicht-Entwickler](./glossar.md) | Klartext-Erklärungen zentraler Begriffe (Repo, Commit, …) für Nicht-Techniker. | Nicht-Entwickler, Stakeholder | DE+EN |
| [HANDBUCH](../HANDBUCH.md) | Das vollständige Framework-Handbuch — erklärt das System zusammenhängend (inkl. Hermes-Begründung Human-in-the-Lead, Anhang D). | Operator, Entwickler | DE+EN |
| [Headless-VPS (Runbook)](./runbooks/headless-vps.md) | Den Sprint unbeaufsichtigt per `claude -p "/sprint-run --auto"` als cron- oder systemd-Job starten — Budget-Schranke, Sandbox, Deny-Regeln, non-root. | Operator, DevOps | DE+EN |
| [Hostinger-VPS-Setup (Runbook)](./runbooks/hostinger-vps-setup.md) | Schrittweiser OS-Bootstrap und Härtung einer Hostinger-VPS. | Operator, DevOps | DE+EN |
| [Integration-Discovery-Fragebogen](./onboarding/integration-discovery.md) | Erfasst den kundenindividuellen Teil für CI/CD in die Live-Umgebung des Kunden. | Kunde, Kunden-IT | DE+EN |
| [KI-Architektur-Prinzipien](../references/ki-architektur-prinzipien.md) | Die vier KI-Architektur-Prinzipien als verbindliche Voraussetzung (Schrader Kap. 4). | Architekten, Operator | DE+EN |
| [Kollisionsschutz: drei Ebenen](./kollisionsschutz-drei-ebenen.md) | Trennt die drei Ebenen der Parallelität und ihre jeweiligen Schutzmechanismen. | Entwickler, Operator | DE+EN |
| [Kunden-Demo (Runbook)](./runbooks/customer-demo.md) | Drehbuch, um das Framework beim Kunden live in 1–2 h vorzuführen — Ablauf mit Timing, Rollen-Use-Cases, Gate-Block live, Reset. | Vertrieb, Operator | DE+EN |
| [LICENSE](../LICENSE.md) | Lizenztext (PolyForm Perimeter License 1.0.0) des Frameworks. | Alle | DE |
| [Logging & Monitoring (Runbook)](./runbooks/logging-monitoring.md) | Logging/Monitoring nach dem Bootstrap einrichten: `observability.md` füllen — Onboarding-Fragen + Beispiele. | Operator, DevOps | DE+EN |
| [Multi-User-VPS (Runbook)](./runbooks/multi-user-vps.md) | Ein neues Teammitglied auf einer geteilten VPS onboarden. | Operator, DevOps | DE+EN |
| [Pitch](./pitch/README.md) | Beschreibung der standalone 30-Minuten-Pitch-Präsentation im OWLIST-Layout. | Vertrieb, Operator | DE |
| [Q&A](./qa.md) | Sammlung operativer Praxisfragen ergänzend zum Handbuch. | Operator, Entwickler | DE |
| [README](../README.md) | Einstiegsseite des Frameworks mit Überblick, Navigation und der Positionierung (sequenzielle Pipeline, menschlich freigegebene Merges). | Alle | DE |
| [Routinen vernetzen (Runbook)](./runbooks/routinen-vernetzen.md) | Drei Aufstellungs-Optionen für wiederkehrende Routinen mit kopierfertigen Prompt-Templates (Schalter C). | Operator | DE+EN |
| [SECURITY](../SECURITY.md) | Security-Policy des Frameworks (Vulnerability-Reporting, Scope). | Alle, Security | DE |
| [So dokumentiert dieses Framework](./how-we-document.md) | Erklärt das Doku-Modell: versionierter Markdown im Repo, per Hook erzwungen. | Operator, Doku-Autor | DE+EN |
| [SecondBrain-Setup nachziehen (Runbook)](./runbooks/secondbrain-nachziehen.md) | SecondBrain-Anbindung ohne Re-Bootstrap in einem Bestandsprojekt nachziehen. | Operator | DE+EN |
| [SonarCloud-Setup (Runbook)](./runbooks/sonarcloud-setup.md) | SonarCloud-Integration für neue GitHub-Repos via GitHub Actions. | Operator, DevOps | DE+EN |
| [Sprint-Run (Runbook)](./runbooks/sprint-run.md) | Einen ganzen Sprint mit `/sprint-run` vollautomatisch fahren. | Operator | DE+EN |
| [Sprint unbeaufsichtigt per tmux (Runbook)](./runbooks/sprint-unattended-tmux.md) | Einen Sprint unbeaufsichtigt auf der VPS per tmux fahren. | Operator, DevOps | DE+EN |
| [Stack-Linter integrieren (Runbook)](./runbooks/stack-linter-integrieren.md) | Einen nicht-abgedeckten Stack/Linter (z.B. PHP/TYPO3, Go) Schritt für Schritt integrieren — die 5 Stellen + Verifikation. | Operator, DevOps | DE+EN |
| [Unit-Tests (Runbook)](./runbooks/unit-tests.md) | Unit-Test-Ablauf im Detail: Test-Gate 6a-quart, Diff-Coverage, JUnit-XML, Anti-Platzhalter-Check. | Operator | DE+EN |
| [Vercel-CI/CD-Setup (Runbook)](./runbooks/vercel-cicd-setup.md) | Vercel-CI/CD-Integration via GitHub Actions, Deploy nach grünen Checks. | Operator, DevOps | DE |
| [VPS-Team-Setup (Runbook)](./runbooks/vps-team-setup.md) | INTENTRON auf einer Developer-VPS für Teams einrichten. | Operator, DevOps | DE |
| [VPS-vom-Handy (Runbook)](./runbooks/vps-vom-handy.md) | Eine laufende Claude-Code-Session auf der VPS vom Handy beobachten/steuern — Remote Control + tmux, menschlich-gated bei irreversiblen Aktionen. | Operator, Entwickler | DE+EN |

## Skill-Dokumentation

Die 15 Top-Level-Skills des Frameworks. Jeder verlinkt auf seine `README.md`; der englische Zwilling liegt jeweils als `README.en.md` daneben.

| Skill | Zweck | Sprachen |
| --- | --- | --- |
| [architecture-review](../architecture-review/README.md) | Architektur-Review für einzelne Stories oder das Gesamtsystem entlang der aktiven Architektur-Dimensionen. | DE+EN |
| [backlog](../backlog/README.md) | Sprint-Planning und Backlog-Übersicht: lädt Issues, analysiert Abhängigkeiten, schlägt Priorisierung vor. | DE+EN |
| [bootstrap](../bootstrap/README.md) | Setzt ein neues Projekt mit Governance-Framework auf — interaktiver Block-Interview-Flow und Doku-Architektur. | DE+EN |
| [cloud-system-engineer](../cloud-system-engineer/README.md) | Prüft VPS-Infrastruktur, Sicherheit, Container-Status, DNS und Firewall — standalone oder als Teammate. | DE+EN |
| [dpo](../dpo/README.md) | Data Protection Officer: Datenschutz by Design in drei Modi (ASSESS, REVIEW, AUDIT). | DE+EN |
| [grafana](../grafana/README.md) | Grafana-Dashboard-Entwicklung und Metric-Queries über den offiziellen Grafana MCP Server. | DE+EN |
| [ideation](../ideation/README.md) | Deep Research, Architektur-Prüfung und User-Story-Erstellung mit Learning-Loop- und Anti-Pattern-Warnung. | DE+EN |
| [implement](../implement/README.md) | Implementierungs-Protokoll für User Stories — 8-Schritte-Workflow inkl. Post-Implement-Validation. | DE+EN |
| [intent](../intent/README.md) | Operationalisiert „Intent before Implementation": destilliert ein messbares Intent-Statement als Input für /ideation. | DE+EN |
| [knowledge-onboarding](../knowledge-onboarding/README.md) | Routet Bestands-Doku deterministisch in Governance-Artefakte über drei Adapter und ein Manifest. | DE+EN |
| [pitch](../pitch/README.md) | Schließt die 4P-Pipeline: sammelt Evidenz als Markdown-Briefing für Stakeholder-Termine. | DE+EN |
| [security-architect](../security-architect/README.md) | Security by Design in vier Modi (DESIGN, REVIEW, AUDIT, SKILL-SCAN) über den Entwicklungsprozess. | DE+EN |
| [sprint-review](../sprint-review/README.md) | Periodisches Audit für Architektur-Gesundheit, Tech Debt und Backlog-Hygiene plus Learning-Loop-Eintrag. | DE+EN |
| [sprint-run](../sprint-run/README.md) | Sprint-Orchestrator: fährt einen ganzen Sprint vollautomatisch über Worktrees, CI und Merge. | DE+EN |
| [visualize](../visualize/README.md) | Generiert Architektur-Diagramme in Miro aus den Architektur-Docs des Projekts. | DE+EN |

> [!info] Anthropic-native, kein Skill
> [`goal/`](../goal/README.md) (`README.md` + `README.en.md`, DE+EN) dokumentiert die **Anthropic-native** Termination-Engine [`/goal`](../goal/README.md) — Sprint-Engine hinter `/sprint-run`, Story-Engine für lange `/implement`-Läufe. Kein Framework-Skill (kein `SKILL.md`), daher nicht in der Skill-Tabelle oben gezählt (Build-vs-Buy, ADR-1).
