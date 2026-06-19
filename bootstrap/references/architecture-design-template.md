# Architecture Design Template

> **Verwendung:** Dieses Template wird in Phase 1 des `/bootstrap` Skills erzeugt.
> Alle `{{PLATZHALTER}}` werden mit Projekt-Infos aus Phase 0 befüllt.
> `ARCHITECTURE_DESIGN.md` ist laut CLAUDE.md das **Einstiegsdokument** — jede neue
> Komponente wird zuerst hier eingetragen, vor dem git commit.

---

# {{PROJECT_NAME}} — Architecture Design

**Version:** {{VERSION_START}} | **Stand:** {{TODAY}}
**Besitzer:** {{OWNER_NAME}}

> **Einstiegsdokument.** Jede neue Komponente und jedes neue File wird hier zuerst
> eingetragen — vor dem git commit.

---

## §1 Big Picture

[Systemkarte — Übersicht aller Komponenten und ihrer Verbindungen.
ASCII-Diagramm oder beschreibender Text wenn das System noch klein ist.]

```
[Komponente A] → [Komponente B] → [Output]
      ↑
[Externe API]
```

---

## §2 Design-Rationale ("Das Warum")

[Begründung der wesentlichen Architekturentscheidungen.
Warum dieser Stack? Warum diese Struktur?
Beantwortet "Warum haben wir X so gebaut?" für neue Entwickler und KI-Assistenten.]

| Entscheidung | Begründung | Alternative verworfen |
|-------------|------------|----------------------|
| [z.B. Node.js statt Python] | [Begründung] | [Was wurde verworfen und warum] |

### KI-Architektur-Prinzipien + Anti-Patterns (Schrader Kap. 4, Pflicht)

> Referenz: `intentron/references/ki-architektur-prinzipien.md` — proaktiv verankert durch `/bootstrap`, reaktiv geprüft durch `/architecture-review` (BOO-7).
> Schrader: "Die Prinzipien sind Voraussetzung, keine Option." (Kap. 4, Z. 1806)

**Die 4 Prinzipien (Was tun?):**

1. **Kleine, unabhängige Module** — max. 500 LOC, ein Zweck. (`cloc` / `wc -l`)
2. **Explizite Interfaces** — starke Typen, API-Doc, ADRs für jede Architekturentscheidung.
3. **Testbarkeit als Grundvoraussetzung** — Coverage ≥80% auf neuem Code (BOO-15).
4. **Observability von Tag 1** — JSON-Logging, Tracing, Metriken + Alerts (BOO-14).

**Die 4 Anti-Patterns (Was vermeiden?):**

| Anti-Pattern | Verletzt | Schwellwert |
|-------------|---------|------------|
| AP1: Gewachsener Monolith | Prinzip 1 | >500 LOC oder >1 Zweck → BLOCK |
| AP2: Implizites Wissen | Prinzip 2 + 4 | Fehlende ADR, `console.log` in Prod → BLOCK |
| AP3: Keine Modulgrenzen | Prinzip 2 | Zirkulärer Import, ungetypte Grenzen → BLOCK |
| AP4: Tests als Nachgedanke | Prinzip 3 | Coverage <60% auf neuem Code → BLOCK |

`/architecture-review` (BOO-7) prüft alle 8 Checks bei jeder Story.

---

## §3 ADR — Architecture Decision Records

> ADRs dokumentieren wichtige Architekturentscheidungen mit Kontext, Entscheidung und Konsequenzen.
> **Status:** Proposed → Active → Deprecated

| ADR | Titel | Status | Datum |
|-----|-------|--------|-------|
| ADR-01 | [Erste Architekturentscheidung] | Active | {{TODAY}} |

### ADR-01: [Titel]

**Status:** Active | **Datum:** {{TODAY}}

**Kontext:** [Welches Problem oder welche Situation hat diese Entscheidung erzwungen?]

**Entscheidung:** [Was wurde entschieden?]

**Konsequenzen:**
- ✅ [Positiver Effekt]
- ⚠️ [Einschränkung oder Trade-off]

---

## §4 Komponenten-Übersicht

> Jede neue Komponente MUSS hier eingetragen werden — vor dem git commit.

| Komponente | Datei/Pfad | Verantwortlichkeit | Abhängigkeiten |
|-----------|-----------|-------------------|----------------|
| Config (SSoT) | `lib/config.js` | VERSION, DOC_FILES, Projekt-Config | — |
| [Neue Komponente] | `[Pfad]` | [Was macht sie?] | [Welche anderen Komponenten braucht sie?] |

---

## §5 Qualitäts-Dimensionen

> Bei jeder Story gegen diese Dimensionen prüfen (Architecture Review):

| # | Dimension | Fragen für dieses Projekt |
|---|-----------|--------------------------|
| 1 | **Reliability** | Graceful Degradation? Kill-Switch vorhanden? |
| 2 | **Data Integrity** | SSoT eingehalten? Kein Dual-Write? |
| 3 | **Security** | API-Keys in .env? Inputs validiert? |
| 4 | **Performance** | Latenz akzeptabel? Rate Limits? Memory stabil? |
| 5 | **Observability** | Logging? Alerts konfiguriert? |
| 6 | **Maintainability** | Keine Code-Duplikation? Config SSoT? Doku aktuell? |
| 7 | **Testability** | Coverage auf neuem Code (Change Value)? Test-Pyramide (Unit/Contract/Integration)? Pass-Rate stabil? |
| 8 | **Scalability** | Verhalten unter Last und über mehrere Instanzen — Statelessness, Horizontal Scaling, Async-Entkopplung. Detail: `architecture-review/references/dimensions-detail.md §8`. |
| 9 | **KI-Tauglichkeit** | 4 Prinzipien eingehalten (Module <500 LOC, explizite Interfaces, Testbarkeit, Observability)? 4 Anti-Patterns abwesend? |
| 10 | **Cost Efficiency** | API-Kosten kalkuliert? Günstigere Alternative? |
| 11 | **Domain Quality** | Verbessert Kern-Qualität des Projekts? |

### Kontextvalidierung fuer dieses Projekt

> Diese Fragen muessen beim Bootstrap und bei groesseren Architektur-Aenderungen beantwortet werden.
> Ein Blueprint ist erst gueltig, wenn er zur tatsaechlichen Projektlage passt.

| Frage | Antwort / Projektentscheidung |
|-------|-------------------------------|
| Welche Dimensionen sind fuer dieses Projekt wirklich kritisch? | [ausfuellen] |
| Welche Dimensionen sind bewusst nur leichtgewichtig aktiv? | [ausfuellen] |
| Welche externen Provider, Datenquellen oder Plattformen praegen die Architektur? | [ausfuellen] |
| Welche Security-/Privacy-Grenzen duerfen nie automatisch ueberschrieben werden? | [ausfuellen] |
| Welche Annahmen muessen nach dem ersten echten Implementierungsdurchlauf ueberprueft werden? | [ausfuellen] |

---

## §5b Infra-Layer (13-Layer-Entscheidungsraster)

> **Zweite Achse neben §5.** §5 ist die **Qualitäts-Achse** (was das System können muss), diese Tabelle ist die
> **Infra-Achse** (welche Infrastruktur-Entscheidung pro Layer getroffen ist). **Single Entry Point** für den Infra-Stand
> dieses Projekts — eine Zeile je Layer. Pflichtfragen, Failure-Modes und Anti-Patterns je Layer stehen im stack-neutralen
> Katalog `cloud-system-engineer/references/infrastructure-dimensions.md` (die Spalte „Verweis" zeigt dorthin). Keine
> Dopplung zu §5: wo ein Layer primär eine Qualitäts-Eigenschaft realisiert (Security, Monitoring, Performance), verweist
> die Zeile per Querverweis auf die passende §5-Dimension statt sie erneut auszuformulieren.
>
> **Status:** `ok` (entschieden + umgesetzt) · `n.ok` (offen / nachzuarbeiten) · `n/a (bewusst)` (für dieses Projekt
> bewusst irrelevant, mit Ein-Satz-Begründung). **Lazy-Fill erlaubt:** leere Zeilen sind ok, `/architecture-review` findet
> sie und stößt zur Nacharbeit an. Tiefe **on-demand**: „Verweis" darf auf ein Projekt-Sub-MD zeigen (z.B. `DB_SCHEMA.md`,
> `IAM_POLICY.md`, `RECOVERY_PLAN.md`) — nur wenn nötig, kein Vorbau.

| # | Layer | Entscheidung (1 Satz) | Status | Verweis |
|---|-------|-----------------------|--------|---------|
| 1 | Frontend | [ausfüllen / n/a (bewusst)] | n.ok | [Katalog §1](cloud-system-engineer/references/infrastructure-dimensions.md) |
| 2 | APIs & Backend | [ausfüllen] | n.ok | [Katalog §2](cloud-system-engineer/references/infrastructure-dimensions.md) |
| 3 | Database & Storage | [ausfüllen] | n.ok | [Katalog §3](cloud-system-engineer/references/infrastructure-dimensions.md) |
| 4 | Caching & CDN | [ausfüllen] | n.ok | [Katalog §4](cloud-system-engineer/references/infrastructure-dimensions.md) |
| 5 | Hosting & Deployment | [ausfüllen] | n.ok | [Katalog §5](cloud-system-engineer/references/infrastructure-dimensions.md) |
| 6 | Cloud & Compute | [ausfüllen] | n.ok | [Katalog §6](cloud-system-engineer/references/infrastructure-dimensions.md) |
| 7 | CI/CD & Version Control | [ausfüllen] | n.ok | [Katalog §7](cloud-system-engineer/references/infrastructure-dimensions.md) |
| 8 | Rate Limiting | [ausfüllen] | n.ok | [Katalog §8](cloud-system-engineer/references/infrastructure-dimensions.md) |
| 9 | IAM / RBAC / Permissions | [ausfüllen] | n.ok | [Katalog §9](cloud-system-engineer/references/infrastructure-dimensions.md) · Q: §5 Security |
| 10 | Security & RLS | [ausfüllen] | n.ok | [Katalog §10](cloud-system-engineer/references/infrastructure-dimensions.md) · Q: §5 Security |
| 11 | Monitoring / Logs / Alerts | [ausfüllen] | n.ok | [Katalog §11](cloud-system-engineer/references/infrastructure-dimensions.md) · Q: §5 Observability |
| 12 | Rollback & Recovery | [ausfüllen] | n.ok | [Katalog §12](cloud-system-engineer/references/infrastructure-dimensions.md) · Q: §5 Reliability |
| 13 | Audit / Compliance & SLAs | [ausfüllen] | n.ok | [Katalog §13](cloud-system-engineer/references/infrastructure-dimensions.md) |

---

## §6 Referenzen

> Links zu allen verknüpften Architecture-Dokumenten — SSoT für Querverweise.

| Dokument | Pfad | Inhalt |
|----------|------|--------|
| System-Architektur | `SYSTEM_ARCHITECTURE.md` | Komponenten, Datenfluss |
| Komponenten-Inventar | `COMPONENT_INVENTORY.md` | Detaillierte Komponentenliste |
| Governance | `GOVERNANCE.md` | Framework-Regeln, ADRs |
| Security-Vertrag | `SECURITY.md` | Security-Grundsatz, Change-Type-Matrix, Security Validation, sensitive Pfade |
| API-Inventar | `API_INVENTORY.md` | Externe APIs (Update-Pflicht!) |
| Prozess-Katalog | `PROCESS_CATALOG.md` | Wie das System arbeitet |

### Security-Referenzmodell

`ARCHITECTURE_DESIGN.md` ist das Lead-Dokument: Es nennt Security als Qualitaetsdimension, dokumentiert Security-/Privacy-Grenzen und verlinkt auf `SECURITY.md`. `SECURITY.md` ist der operative Security-Vertrag und verweist auf Unterartefakte wie `API_INVENTORY.md`, `.semgrep.yml`, `.codex/hooks.json`, `.claude/sensitive-paths.json`, `.codex/sensitive-paths.json`, Threat Models sowie Privacy-/Compliance-Unterlagen.

---

*Aktualisiert bei jeder Architekturentscheidung durch Claude Code.*
