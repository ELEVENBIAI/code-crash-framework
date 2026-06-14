---
name: bootstrap
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
version: 3.40.0
description: Setzt ein neues Projekt mit Governance-Framework auf — interaktiver Block-Interview-Flow in 4 Schritten, Doku-Architektur mit Hub-Auto-Verlinkung, optionaler Learning-Loop L1/L2/L3. Verwenden wenn der Operator ein neues Projekt aufsetzen will oder "/bootstrap" sagt.
tools: [Read, Write, Edit, Bash, Glob, Grep]
metadata:
  hermes:
    category: governance
    tags: [setup, project-init, governance-config]
    requires_toolsets: [terminal, git, github, obsidian]
    related_skills: []
---

# Bootstrap — Neues Projekt aufsetzen (v3.0)

Setzt ein neues Projekt mit Governance-Framework auf. Der Flow ist in **4 Bloecke (A-D)** strukturiert — jeder Block mit klarem Fokus, keine Fragen-Batches.

> **Hinweis zur Einordnung:** Das Setup richtet Governance fuer einen **sequenziellen, kontrollierten Entwicklungsflow** ein — kein autonom laufendes Agentensystem. Die gewaehlten KI-Tools (Claude, Codex) sind Adapter auf den Story-Vertrag, nicht die Governance selbst.

Referenzen:
- `references/info-gathering.md` — Kern-Fragen (Block A)
- `references/existing-infra-check.md` — Bestehende Infrastruktur (Block B)
- `references/project-documentation-ssot.md` — Projekt-Dokumentations-SSoT, Project Hub und Developer-Onboarding
- `references/doc-architecture-proposal.md` — Doku-Architektur (Block C)
- `references/optional-components.md` — Self-Healing / DocSync / Daemon / Learning-Loop (Block D)
- `references/learning-loop.md` — L1/L2/L3 Design
- `references/file-templates.md` — Dateischablonen
- `references/skills-setup.md` — Skills aus GitHub ziehen
- `references/global-registry-update.md` — SecondBrain-Integration
- `references/hooks-setup.md` — Governance-Hooks
- `references/provider-postflight.md` — externe Provider, Monitoring, Research, Visualize/Miro
- `references/framework-upgrade.md` — Upgrade-Modus fuer bestehende Projekte

---

## Phase 0: Briefing + Pre-Flight-Gate (vor allen Fragen)

### 0.1 Briefing

Den Operator zuerst informieren:

```
Bootstrap v3.0 — ich fuehre dich durch 4 Bloecke:

  Block A — Projekt-Kern           (10 Fragen, ~4 min)
  Block B — Bestehende Infra       (6 Fragen,  ~4 min)
  Block C — Doku-Architektur       (Vorschlag + Review)
  Block D — Optional-Komponenten   (gezielte Ja/Nein-Fragen am Ende)

Danach lege ich das Projekt an. Gesamt ~15 min.

Wichtig: Ich richte Governance + Configs ein (scaffold-only). Tools/CLIs
installiere ich NICHT — die stellst du vorab bereit (siehe Pre-Flight).
```

### 0.2 Pre-Flight-Gate (BOO-114) — Voraussetzungen pruefen, sonst Abbruch

**Vor** jedem Scaffold die Kern-Voraussetzungen abfragen:

```
Pre-Flight — sind diese Voraussetzungen erfuellt? [ja / nein / unklar]
  1. Vorab-Bogen `docs/onboarding/bootstrap-prep.md` durchgelaufen?
  2. Toolchain bereit? (Node 18+, Git, Claude-CLI; bei GitHub-Scope zusaetzlich `gh` +
     `gh auth status` ok; bei Container: Image gebaut) — der Bootstrap installiert nichts (scaffold-only).
  3. API-Keys / Zugaenge vorhanden? (ANTHROPIC_API_KEY; je nach Scope
     GitHub-Token oder SSH-Key, Backlog-Tool-Key, externe Provider)
  4. Ziel-Verzeichnis geklaert + (falls GitHub im Scope) leeres Repo/Remote bereit?
```

**Auswertung:**
- Alle Punkte `ja` → weiter zu `Bereit?` und Phase 1.
- Mind. ein `nein/unklar` → **kontrollierter Abbruch, kein Scaffold:**

```
⛔ Pre-Flight nicht bestanden — ich lege noch nichts an.

Offen: <die mit nein/unklar markierten Punkte>.

Naechste Schritte:
  → Vorab-Bogen durcharbeiten: docs/onboarding/bootstrap-prep.md (16 Fragen).
  → Voraussetzungs-Details: HANDBUCH §3 „Voraussetzungen und Vorbereitung"
    + Anhang A „Checkliste vor dem ersten Bootstrap".
  → Tools fehlen? Der Bootstrap installiert sie nicht (scaffold-only); Install-
    Anleitungen: HANDBUCH Anhang Y.2 (Direkt-Install) bzw. Container-Profil (BOO-81).
    Beim naechsten Lauf fuehre ich dich gezielt auf die passenden Deeplinks (BOO-115).

Starte `/bootstrap` erneut, sobald die Voraussetzungen stehen.
```

Erst nach bestandenem Pre-Flight:

```
Bereit? [ja / spaeter]
```

Warte auf `ja`.

---

## Phase 1: Block A — Projekt-Kern

Lies `references/info-gathering.md` fuer die vollstaendige Fragenliste. Stelle die Fragen **einzeln oder in kleinen Gruppen** (max 3 pro Rueckfrage), nicht als Batch.

### A.1 Stack-Frage (zuerst)

```
Was moechtest du entwickeln?
  a) Node.js / TypeScript Backend (API, CLI, Daemon)
  b) Frontend (React, Vue, Svelte, Vanilla)
  c) Full-Stack — inkl. Meta-Frameworks (Next.js, Nuxt, SvelteKit, Remix, Astro)
  d) Python (KI/ML, Scripts, FastAPI, Django)
  e) Anderes / Noch nicht klar  → Guided Discovery (A.1a)
```

Antwort als `STACK_CHOICE` merken. Die Optionen sind **framework-aware**: ein Meta-Framework-Projekt (Next.js o.ae.) gehoert nach `c)`, **nicht** nach `a)` — das war die haeufigste Fehlwahl (Stack-Mismatch).

**TypeScript ist first-class.** Bei `a/b/c` direkt nachfragen:

```
TypeScript oder JavaScript? [ts / js]   (Default: ts)
```

`LANG_VARIANT = ts | js` merken. Bei `ts`: zusaetzlich `tsconfig.json` + `typescript-eslint` + ein `tsc --noEmit`-CI-Gate anlegen (Phase 4.4), `metadata.stack = node-typescript`. Bei `js`: `node-javascript`. (Bei `d) Python` und `e)` entfaellt die Frage.)

| Wahl | LANG_VARIANT | Linter-Config | Formatter | Typecheck |
|------|--------------|--------------|-----------|-----------|
| a) Node.js/TS Backend | ts (default) / js | `eslint.config.mjs` (+ `typescript-eslint` bei ts) | — | `tsc --noEmit` (bei ts) |
| b) Frontend | ts (default) / js | `eslint.config.mjs` + `.prettierrc` (+ `typescript-eslint` bei ts) | Prettier | `tsc --noEmit` (bei ts) |
| c) Full-Stack / Meta-Framework | ts (default) / js | beide (+ `typescript-eslint` bei ts) | Prettier | `tsc --noEmit` (bei ts) |
| d) Python | — | `pyproject.toml` (Ruff + Black) | Black | — |
| e) Anderes | — | Freitext-Rueckfrage (s.u., BOO-116) bzw. Guided Discovery (A.1a) — **kein** stiller ESLint-Default | — | — |

**Bei `e) Anderes` zuerst nachfragen (BOO-116) — nicht still ESLint annehmen:**

```
Welche Technologie / Sprache? (z.B. Go, Rust, Java, PHP, Ruby — oder „noch unklar")
```

- **Bekannte Tech → passender Linter-Hinweis** (kein JS-Default):

  | erkannte Tech | Linter-/Format-Hinweis |
  |---------------|------------------------|
  | Go | `golangci-lint` (+ `gofmt`) |
  | Rust | `clippy` (+ `rustfmt`) |
  | Java / Kotlin | `Checkstyle` / `ktlint` + `SpotBugs` |
  | PHP | `PHPStan` / `Psalm` + `PHP-CS-Fixer` |
  | Ruby | `RuboCop` |
  | sonstige | Operator nennt den Linter |

  `STACK_CHOICE` bleibt `e`; das Linter-/Tooling-Setup folgt dem Hinweis (Operator richtet ein), **nicht** dem ESLint-Default. Entscheidung als ADR in `docs/domain/adrs/` festhalten. Für die konkrete Integration (die 5 Stellen + Verifikation + Kopiervorlagen) → HANDBUCH-Kapitel „Stack-Linter integrieren" (§8d-bis) + Runbook `docs/runbooks/stack-linter-integrieren.md`.
- **„noch unklar"** → explizit als offen markieren (kein JS-Default) **oder** Guided Discovery (A.1a) nutzen, um aus Quelle/Beschreibung einen Vorschlag abzuleiten.

### A.1a Guided Stack-Discovery (BOO-127 — bei `e)` oder Unsicherheit)

Waehlt der Operator `e)` oder ist unsicher: **nicht raten lassen**, sondern einen Stack-**Vorschlag** ableiten.

```
Unsicher bei der Wahl? Ich kann den Stack vorschlagen:
  (a) Quelle analysieren — bestehendes Repo / Intent-Datei / vorhandene Doku
      (nutzt den Bestands-Quellen-Import aus A.2b, BOO-117)
  (b) Vorhaben in 1-2 Saetzen beschreiben → ich leite Sprache, Framework und TS/JS ab
```

Aus Quelle oder Beschreibung einen Vorschlag bilden, z.B.: „Erkenne **Next.js + TypeScript + Tailwind** → Vorschlag: `STACK_CHOICE = c) Full-Stack`, `LANG_VARIANT = ts`. Uebernehmen / anpassen / selbst waehlen?"

- Operator **bestaetigt oder ueberschreibt** — der Vorschlag ist nie bindend.
- Die getroffene Stack-Entscheidung als **ADR** in `docs/domain/adrs/` festhalten (gleiche Mechanik wie die uebrigen Stack-Defaults, §4.4f). Bei `e)` **ohne** erkennbaren Stack: explizit als „noch offen" markieren, **nicht** still als JS annehmen.
- **Reihenfolge:** A.1 laeuft vor A.2 — eine hier (A.1a) analysierte Quelle liest A.2b **nicht erneut**, sondern verwendet das Ergebnis fuer `PROJECT_DESC` **wieder** (kein Doppel-Einlesen, keine Doppelfrage).

### A.1b Lighthouse-CI fuer Frontend-Performance (BOO-45, nur bei STACK_CHOICE = b oder c)

Wenn `STACK_CHOICE = b` (Frontend) oder `c` (Full-Stack mit Frontend-Anteil), Folge-Frage:

```
Lighthouse-CI fuer Web-Performance aktivieren?
  Pendant zu BOO-16 Performance-Gate fuer Backend-Services, aber gegen die Browser-URL.
  Misst LCP, FID, CLS + Bundle-Size + Accessibility und blockt Merge bei Budget-Verletzung.
  [ja / spaeter]
```

Bei `ja`:
- Render `lighthouserc.json` mit Performance-Budgets (LCP <2.5s, CLS <0.1, TBT <300ms, Mobile-Throttling 3G-slow) — Template in `references/file-templates.md` §`lighthouserc.json (BOO-45)`
- Render `.github/workflows/lighthouse.yml` (treosh/lighthouse-ci-action@v12, auf jeden Push + PR) — Template in `references/file-templates.md` §`.github/workflows/lighthouse.yml (BOO-45)`
- Beide Files schreiben Reports nach `journal/reports/ci/run-${{ github.run_id }}/lighthouse.json` (BOO-32-Konvention)
- HANDBUCH §Lighthouse-Integration (Anhang H) erklaert die manuellen Operator-Tasks: Frontend-URL pro Environment eintragen, Performance-Budgets justieren, Mobile-Throttling-Profil waehlen

Bei `spaeter`: kein Template angelegt. Operator kann via `migrate_boo_45()` nachholen.

`LIGHTHOUSE_CHOICE = yes | later` merken fuer Phase 4.

### A.1c Ziel-Runtime / Tool-Adapter (BOO-53/54)

```
Welche KI-Runtime soll das Projekt primaer nutzen?
  a) Claude Code — AGENTS.md als Codex-Einstieg optional, CLAUDE.md ist aktive Runtime-Datei
  b) Codex — AGENTS.md ist aktiver Einstieg, CLAUDE.md bleibt Kompatibilitaetsbruecke
  c) Cross-Tool — beide Einstiege aktiv, CONVENTIONS.md ist der harte Adapter-Vertrag
  d) unklar — Cross-Tool-Baseline anlegen, spaeter in CONVENTIONS.md schaerfen
  Default: unklar
```

**Merken:** `RUNTIME_TARGET = claude-code | codex | cross-tool | unknown`

Rollen:
- `AGENTS.md` = Codex-Einstieg mit Repo-Regeln, Sandbox-/Scope-Hinweisen und Verweis auf `CONVENTIONS.md`.
- `CLAUDE.md` = Claude-Code-Einstieg und Kompatibilitaetsbruecke fuer bestehende Claude-Workflows; darf nicht als alleinige Wahrheit fuer tool-neutrale Regeln gelten.
- `CONVENTIONS.md` = Adapter-Vertrag: Runtime, Backlog-Adapter, Governance-Modus, Execution-Isolation, aktive Gates und Postflight-Status.

Bei `codex`, `cross-tool` oder `unknown` immer `AGENTS.md` anlegen. Bei `claude-code` darf `AGENTS.md` trotzdem als portabler Codex-Einstieg angelegt werden; nicht anlegen nur auf expliziten Operator-Wunsch.

### A.2 Projekt-Identitaet (3 Fragen)

```
1. Projektname? (z.B. MyAnalytics)
2. Ein-Satz-Beschreibung: Was macht das System?
3. Start-Version? (default 0.1.0)
```

### A.2b Bestands-Quellen-Import (optional, BOO-117)

Bevor der Operator alles manuell eintippt: pruefen, ob bereits eine Quelle existiert, aus der sich Projektinfos ableiten lassen. Diese Quelle wird **inhaltlich eingelesen** und liefert **Vorschlaege** (nie stillschweigende Uebernahme).

```
Gibt es bereits eine Quelle, aus der ich Projektinfos ziehen kann?
  a) Intent-Datei (z.B. intents/*.md aus dem intent-Skill)
  b) Bestehendes Repo / Verzeichnis (README, package.json, pyproject.toml, Code)
  c) Andere Doku (Konzept, Pflichtenheft, Pitch, Notion-/Confluence-Export ...)
  d) Nein — ich beschreibe es selbst
  Default: d
```

Bei `a/b/c`: Quelle (Pfad/URL vom Operator) lesen und daraus **ableiten + vorschlagen**:
- `PROJECT_DESC` (Ein-Satz-Beschreibung) — Hauptzweck dieses Schritts
- optional `PROJECT_NAME`, ein `stack_hint` (Korrektur-Vorschlag fuer A.1 / Guided-Discovery BOO-127), erkennbare Add-ons

Vorschlag dem Operator zeigen, z.B.: „Aus `<Quelle>` abgeleitet: `PROJECT_DESC = '…'` (und Stack sieht nach `…` aus). Uebernehmen, anpassen oder verwerfen?" → Operator bestaetigt oder ueberschreibt.

**Merken:** `SOURCE_IMPORT = {type: intent|repo|doc|none, ref: <pfad/url>, derived: {project_desc, stack_hint, ...}}`.

Sauber optional — kein Zwang, kein Bruch:
- Bei `d`, fehlender, leerer oder unlesbarer Quelle: normal mit den A.2-Eingaben weiter, `SOURCE_IMPORT.type = none`.
- A.1 (Stack) wurde bereits gestellt; ein hier abgeleiteter `stack_hint` wird nur als Korrektur angeboten, nie erzwungen.
- Wurde dieselbe Quelle schon in A.1 (Guided-Discovery, BOO-127) analysiert: hier **wiederverwenden**, nicht erneut einlesen oder fragen.

### A.3 Backlog (2 Fragen)

```
4. Issue-Prefix? (default aus Projektname abgeleitet, z.B. "MA-" fuer MyAnalytics)
5. Primaere Sprache fuer Doku? (de / en, default: de)
```

### A.3b Backlog-Adapter (BOO-54)

```
Welches Backlog-System soll als primaerer Adapter genutzt werden?
  a) Linear
  b) GitHub Issues  (empfohlener Standard — schlank, nativ im Repo, kein OAuth-Tunnel)
  c) Jira
  d) Azure DevOps Boards
  e) Microsoft Planner
  f) none — Backlog-Record nur als Markdown/Datei, kein externes Tool
  Default: none  (Empfehlung bei GitHub-Repo: b)
```

**Merken:** `BACKLOG_ADAPTER = linear | github | jira | azure-devops | planner | none`

Der Bootstrap erzeugt einen neutralen **Backlog-Record** als Vertragsform. Externe Tools sind Adapter darauf, nicht die Quelle des Frameworks:
- Pflichtfelder: `id`, `title`, `status`, `priority`, `estimate`, `intent`, `acceptance_criteria`, `links`, `adapter`.
- `id` folgt dem Issue-Prefix (`{ISSUE_PREFIX}XXX`) auch dann, wenn das externe Tool eigene IDs vergibt.
- Linear ist ein unterstuetzter Adapter, aber keine Pflichtvoraussetzung.

### A.4 Architektur-Dimensionen + Add-ons (1 Frage)

```
7. Standard-Dimensionen (immer aktiv): Reliability, Data Integrity, Security,
   Performance, Observability, Maintainability, Testability, Scalability, KI-Tauglichkeit.

   Zusaetzliche Add-ons aktivieren (Multi-Select)?
   [ ] Privacy / DSGVO — fuer Voice-Assistants, personenbezogene Daten, Tier-Modelle
   [ ] Cost Efficiency — bei LLM-lastigen / SaaS-Subscription-Projekten
   [ ] Signal Quality — bei ML / Analytics / Signal-Systemen
   [ ] Compliance — fuer regulierte Branchen (Gesundheit, Finanz, Legal)
   [ ] EU AI Act — fuer Solutions mit KI-Anteil, die (Kunden-)Daten verarbeiten (KI-VO-Doku-Pflichten)
```

Jedes aktivierte Add-on ergaenzt die Architektur-Dimensionen in `ARCHITECTURE_DESIGN.md` + entsprechende Sektion in `SECURITY.md` / `GOVERNANCE.md`.

> **Privacy-Add-on (BOO-69/74):** Bei `[x] Privacy / DSGVO` installiert Bootstrap zusaetzlich den `dpo`-Skill **aus dem Framework-Bundle** (`$SKILL_SRC/dpo/`, analog `security-architect`), rendert `PRIVACY.md` aus `references/privacy-template.md`, legt `personal-data-paths.json`-Template an und setzt Backlog-Label `privacy`. Die operative Setup-Phase ist 4.4n (Privacy-Setup, analog 4.4i Sensitive-Paths). DPO laeuft mit drei Modi (ASSESS in `/ideation` Schritt 0e, REVIEW in `/implement` Schritt 5.5b, AUDIT in `/sprint-review` Schritt 7c). Details: HANDBUCH Anhang O.

> **EU-AI-Act-Add-on (BOO-101/105):** Bei `[x] EU AI Act` kopiert Bootstrap den Katalog `dpo/controls/optional/eu-ai-act.yml` ins Projekt-Overlay `.claude/dpo/controls/` und rendert `AI_SYSTEM.md` aus `dpo/references/ai-system-template.md`. Operative Phase: **4.4n-bis**. Setzt das Privacy-Add-on voraus. **Strikt opt-in** — der Katalog liegt unter `controls/optional/` und wird vom dpo-Runner NUR geladen, wenn er ins Projekt kopiert wurde (kein Rauschen in Nicht-KI-Projekten). KEINE Rechtsberatung; Urteils-Punkte = REVIEW-NEEDED.

**Merken:** `ADDONS = [...aktivierte]`

### A.5 Governance-Intensitaet (BOO-51)

```
8. Governance-Intensitaet fuer dieses Projekt?
   a) Lite/Light — kleine Experimente/Skripte: Kernkontext, CONVENTIONS.md, Spec-Gate, Basis-Linting; ohne schwere CI/Audit/Performance-Gates
   b) Standard — serioese Solo-/Kundenprojekte: Security-Gates, CI-Lint/SAST, Sensitive-Paths, Learning-Loop L1
   c) Heavy — regulierte/umsatzkritische Systeme: Coverage, Performance, SonarQube, Branch-Protection, Audit-Trail, Mandatory Review
   Default: Standard
```

**Merken:** `GOVERNANCE_MODE = lite | standard | heavy`

### A.6 Execution-Isolation / Worktrees (BOO-52)

```
9. Parallele Agentenarbeit isolieren?
   a) none — nur lineare Arbeit, keine parallelen Agenten
   b) write-scope — parallele Subagents nur mit klar getrennten Datei-/Modul-Scopes
   c) git-worktree — jeder parallele Agent bekommt eigenen Git-Worktree/Branch
   Default: write-scope
```

**Merken:** `EXECUTION_ISOLATION = none | write-scope | git-worktree`

Regeln:
- Wenn `GOVERNANCE_MODE = lite`, Default `EXECUTION_ISOLATION = none`.
- Wenn `GOVERNANCE_MODE = standard`, Default `EXECUTION_ISOLATION = write-scope`.
- Wenn `GOVERNANCE_MODE = heavy`, Default `EXECUTION_ISOLATION = git-worktree`.
- `agentic`-Execution ist nur erlaubt, wenn `EXECUTION_ISOLATION = git-worktree`.
- `none` ist kein Governance-Modus, sondern nur eine Execution-Isolation ohne Parallel-Agenten-Schutz.

### A.7 Deployment-Szenario (BOO-70)

```
10. Deployment-Szenario?
    a) Solo-Mac (Default — ~80% der Operatoren)
    b) anders → siehe HANDBUCH Anhang P (Solo-VPS / Multi-User-VPS-Coding-Factory / Team-mit-Coding-Server)
```

**Merken:** `DEPLOYMENT_SCENARIO = solo-mac | other`

**Install-Default ableiten (BOO-115):** `INSTALL_DEFAULT = system` bei `solo-mac`; `INSTALL_DEFAULT = docker` (Golden Image / Container-Profil) bei `other` (Solo-VPS / Multi-User-VPS-Coding-Factory / Team-Server). Der Operator kann den Default jederzeit ueberschreiben. Verwendet in der Tool-Install-Fuehrung (Phase 7.3b).

- Bei `a)` laeuft der bestehende Bootstrap-Pfad unveraendert weiter — Solo-Mac ist Default, keine zusaetzliche Setup-Logik. (Solo-Hinweis: arbeitest du parallel an **zwei Sessions auf demselben Klon**, nutze `git worktree` statt zweimal denselben Working Tree — Kollisionsschutz Ebene 2, `docs/kollisionsschutz-drei-ebenen.md`.)
- Bei `b)` gibt der Bootstrap nur einen Hinweis-Block aus und keinen Interview-Fork:

  ```
  Du hast "anders" gewaehlt. INTENTRON bringt selbst keine szenarien-
  spezifische Setup-Automatik mit — lies HANDBUCH Anhang P, waehle dein
  Szenario (Solo-VPS / Multi-User-VPS / Team-Server) und arbeite die
  dort beschriebenen Schritte einmalig ab. Danach kannst du Bootstrap
  unveraendert weiterlaufen lassen.
  ```

- **Bei Multi-User-VPS** (mehrere Menschen, ein Projekt): zusaetzlich das Runbook `docs/runbooks/multi-user-vps.md` (Teammitglied-Checkliste — einmal VPS / einmal GitHub / einmal Claude / pro Repo) + Anhang P §3. Jeder User bekommt einen **eigenen Klon** (kein geteilter Working Tree), `journal/daily/` wird pro User lokal (`.gitignore`). Konzept: `docs/kollisionsschutz-drei-ebenen.md` (Ebene 1).
- Konsequenz fuer Phase 4 / 5: `DEPLOYMENT_SCENARIO` wird in `metadata.deployment_scenario` der `.claude/environment.json` festgehalten und steuert ab BOO-115 den **Install-Default** (System vs. Docker) in der Tool-Install-Fuehrung (Phase 7.3b). Sonst kein Interview-Fork.

> **Issue-Referenz:** BOO-70. Quelle: HANDBUCH Anhang P (Deployment-Szenarien). Migration fuer Bestands-Projekte: `references/migration-checklist-v1-to-v2.md` §BOO-70.

### A.7b CI/CD-Modus

```
Wie wird Code deployed und integriert?
  a) GitHub Actions CI/CD — Push → GitHub Actions → automatisches Deploy/Test
     (SonarQube, CI-Lint/SAST, Performance-Gate sinnvoll)
  b) Direkt auf VPS — GitHub = Code-Storage, kein CI/CD-Pipeline
     (SonarQube und CI-Workflows entfallen — lokale Hooks ersetzen CI-Gates)
  c) Hybrid — manche Workflows via CI, Deployment direkt
  Default: b) (bei solo-mac/VPS-Setup ohne konfiguriertes CI)
```

**Merken:** `CI_MODE = github-actions | direct-deploy | hybrid`

Bei `direct-deploy` (b) gelten folgende Konsequenzen fuer den Rest des Bootstraps:
- **D.5 SonarQube:** automatisch `SKIP` — SonarCloud benoetigt GitHub Actions, nicht nur ein GitHub-Repo
- **Phase 4.4c (Semgrep CI-Action):** `SKIP`
- **Phase 4.4g (Performance-Gate CI):** `SKIP`
- **Phase 4.4k (Branch-Protection):** optional, aber kein SonarCloud Required Check

Beim Skip-Output immer erklaeren warum:

```
CI_MODE = direct-deploy erkannt.

SonarCloud, Semgrep-CI-Action und Performance-Gate werden uebersprungen
— diese Tools benoetigen eine GitHub-Actions-Pipeline als Ausloesemechanismus.

Lokale Hooks ersetzen die CI-Layer fuer dieses Setup:
  Layer 0: pre-edit-bodyguard (schreibt keine unsicheren Muster)
  Layer 2: pre-commit (spec-gate, semgrep lokal wenn installiert)

SonarCloud kann nachgezogen werden wenn GitHub Actions spaeter
eingerichtet wird — Runbook: docs/runbooks/sonarcloud-setup.md
```

`CI_MODE` wird in `.claude/environment.json` unter `metadata.ci_mode` gespeichert.

> **Visueller Ueberblick:** `docs/runbooks/sonarcloud-setup.excalidraw` zeigt den Unterschied zwischen CI/CD-Pipeline und Direct-Deploy fuer SonarCloud.

### A.8 Maschinen-Kontext (BOO-145)

Zum Abschluss von Block A — die Stack-Antwort aus A.1 liegt vor — den **Maschinen-Kontext** automatisch in die globale `~/.claude/CLAUDE.md` schreiben. **Idempotent + ohne separaten Operator-Schritt:** zuerst `~/.claude/CLAUDE.md` lesen; steht dort bereits ein `## Maschinen-Kontext`-Abschnitt, **nichts tun** (nicht ueberschreiben). Fehlt die Datei, anlegen.

Werte ermitteln:

- **Typ:** `uname -s` → `Darwin` = `macOS`, `Linux` = `Linux` (Fallback `$OSTYPE`).
- **Framework-Version:** neuester Release-Tag des intentron-Repos via `git -C <intentron-repo> describe --tags --abbrev=0` (z.B. `v0.8.1`); Fallback: `bootstrap`-Skill-Version aus dem SKILL.md-Frontmatter.
- **Stack-Praeferenz:** aus `STACK_CHOICE` + `LANG_VARIANT` (A.1), in Klartext (z.B. „Node.js / Next.js / TypeScript").
- **Verfuegbare Skills:** `ls ~/.claude/skills/` (kommasepariert in einer Zeile).

Abschnitt anhaengen (nur wenn `## Maschinen-Kontext` fehlt):

```markdown
## Maschinen-Kontext
- Typ: <macOS | Linux>
- Framework: intentron <VERSION> — Skills unter ~/.claude/skills/ + pro Projekt
- Stack-Praeferenz: <Stack aus A.1>
- Verfuegbare Skills: <ls ~/.claude/skills/>
```

Kein Secret schreiben. Schreib-/Lese-Format + Idempotenz-Regel: `references/global-registry-update.md §Maschinen-Kontext`. Verwandt: `PROJECTS_ROOT` (BOO-138, Block B) — beide bilden den Maschinen-Ebene-Kontext der globalen `~/.claude/CLAUDE.md`.

Phase-1-Checkpoint: Kurze Bestaetigung der Antworten ausgeben.

---

## Phase 2: Block B — Bestehende Infrastruktur

Lies `references/existing-infra-check.md` fuer den vollstaendigen Dialog-Flow.

Der Skill respektiert bereits vorhandene Infrastruktur — nicht alles neu anlegen.

**Standard-Projektpfad (`PROJECTS_ROOT`, BOO-138):** Bevor Frage 1 gestellt wird, prueft der Skill, ob in der globalen Operator-`~/.claude/CLAUDE.md` ein `PROJECTS_ROOT` hinterlegt ist:

- **Hinterlegt** (Maschine bereits eingerichtet): Frage 1 wird mit dem Default `<PROJECTS_ROOT>/<projektname>` vorbelegt — Operator bestaetigt mit Enter oder gibt einen eigenen Pfad an (Override bleibt jederzeit moeglich).
- **Nicht hinterlegt** (erstes Projekt auf dieser Maschine): Der Skill fragt **einmalig** nach dem Standard-Projektpfad (`Wo sollen Projekte auf dieser Maschine standardmaessig liegen? [Default: ~/projects]`) und traegt ihn — nach Operator-Bestaetigung — in `~/.claude/CLAUDE.md` ein. So landet jedes weitere Projekt reibungsarm am selben Ort, ohne Pfad-Tipparbeit.

Schreib-/Lese-Format + Operator-Bestaetigung: `references/global-registry-update.md` §Standard-Projektpfad. Kein Cockpit/Dashboard — der Tagesstand entsteht beim Oeffnen des jeweiligen Projekts (PMO-Hub + letzte `journal/daily/`-Notiz, BOO-139).

```
Hast du bereits folgendes eingerichtet? (jede Frage einzeln beantworten)

1. Projekt-Verzeichnis?
   [a] Ja + absoluter Pfad
   [b] Nein, neu anlegen — wo? (absoluter Pfad)
       Default (wenn PROJECTS_ROOT gesetzt): <PROJECTS_ROOT>/<projektname>
       → Enter bestaetigt den Default, eigener Pfad ueberschreibt

2. GitHub-Repo?
   [a] Ja + URL
   [b] Nein, spaeter anlegen (keine Remote jetzt)
   [c] Kein GitHub gewuenscht

3. Projekt-Dokumentations-SSoT?
   [a] Obsidian Vault + absoluter Vault-Pfad
   [b] Repo docs — Projekt-Doku unter docs/project/
   [c] Externes DMS — Notion / Confluence / SharePoint / anderes + URL/Pfad
   [d] Noch unklar — Repo-Fallback docs/project/ + TODO
   [e] Repo docs + persoenlicher Vault-Harvest (Team mit Obsidian-Nutzern) — BOO-75

   > Achtung — Obsidian ist ein Solo-Werkzeug, kein Enterprise-Werkzeug:
   > - Solo / 1 Person → [a] Obsidian Vault als SSoT ist ideal.
   > - Team / mehrere Personen → [b] Repo docs (oder [c] externes DMS). Ein
   >   Obsidian-Vault ist persoenlich; es gibt keinen geteilten Vault fuer das Team.
   > - Team MIT Obsidian-Nutzern, die Cross-Project-Insights im eigenen Vault
   >   wollen → [e] Repo docs + persoenlicher Vault-Harvest (Stefans Git-Szenario:
   >   Doku lebt im Repo, ein git-post-merge-Hook spiegelt ausgewaehlte docs/
   >   einseitig in den persoenlichen Vault jedes Mitarbeiters). Details: HANDBUCH
   >   Anhang R Layer 3 (Vault-Harvest-Pattern).

4. Backlog-System / Adapter?
   [a] Linear + Team-Slug
   [b] GitHub Issues + Repo
   [c] Jira + Projekt-Key
   [d] Azure DevOps Boards + Projekt
   [e] Microsoft Planner + Plan
   [f] Keines / Markdown-only

5. API-Keys fuer das Projekt?
   [a] Existieren bereits in .env
   [b] .env.example reicht, Keys spaeter

6. Developer-Uebergabe?
   [a] Standard: Developer Onboarding erzeugen und fortlaufend pflegen
   [b] Nur verlinken, existiert bereits in der Doku-SSoT
```

**Merge-Modus:** Wenn ein Ordner/Repo/Vault existiert und Dateien enthaelt, **vor dem Ueberschreiben** fragen:

```
Warnung: {PROJECT_PATH} enthaelt bereits Dateien.
  [a] Backup anlegen + Bootstrap fortsetzen
  [b] Nur fehlende Governance-Dateien ergaenzen (merge)
  [c] Abbruch
```

**Merken:** `EXISTING_INFRA = {...}`, `DOCUMENTATION_SSOT = {type, path_or_url, project_path, fallback, status}` und `PROJECTS_ROOT = {path, source}` (`source = claude-md` wenn aus `~/.claude/CLAUDE.md` gelesen, `newly-set` wenn in diesem Lauf erstmals erfragt+geschrieben) fuer weitere Phasen. Bei Wahl `[e]` ist `type = repo-docs-plus-vault-harvest`.

> **Wahl [e] Repo-Docs + persoenlicher Vault-Harvest (BOO-75/77):**
> Bootstrap richtet das Vault-Harvest mit der **framework-nativen Engine** (BOO-77) vollstaendig ein:
> 1. legt die Doku-SSoT auf `docs/project/` (wie `[b]`),
> 2. kopiert die Engine-Files aus `references/vault-sync/` ins Projekt:
>    - `scripts/vault-sync.py` (einseitige Sync-Engine Repo→Vault, Python-Stdlib),
>    - `.claude/hooks/post-merge.sh` (Hook-Wrapper, feuert nach `git pull`),
>    - `scripts/install-vault-sync.sh` (interaktives Init pro Mitarbeiter),
>    - `.vault-sync/tracked-paths.json` (versionierter Team-Vertrag, 4 Defaults),
> 3. traegt `.vault-sync/local.json` in `.gitignore` ein (persoenliche Konfig, nie committen),
> 4. setzt **Block D DocSync = nein** (Vault-Harvest und DocSync wuerden sich sonst ueberschneiden — DocSync ist solo/bidirektional, Harvest ist team/einseitig),
> 5. ergaenzt in `DEVELOPER_ONBOARDING.md` einen Setup-Schritt: "Vault-Harvest pro Mitarbeiter optional aktivieren: `bash scripts/install-vault-sync.sh` (legt `.vault-sync/local.json` an + symlinkt den Hook). Default-Modus `dry-run` — erst pruefen, dann auf `auto` stellen."
>
> **Sicherheit:** die Engine schreibt einseitig NUR in den Vault (nie ins Repo), prueft Pfad-Containment (kein Schreiben ausserhalb `vault_path`) und beendet sich still mit `exit 0`, wenn ein Mitarbeiter keine `local.json` hat (null Reibung). Details: HANDBUCH Anhang R Layer 3 + `references/vault-sync-pattern.md`.

Phase-2-Checkpoint: Zusammenfassung ausgeben.

### B.6 Provider- und Plattform-Postflight vormerken (BOO-58)

Lies `references/provider-postflight.md`. Der Bootstrap muss lokale Skill-Installation und externe Provider-Verifikation trennen.

Zusaetzliche Fragen nach Block B:

```
Gibt es bereits eine Monitoring-/Logging-Plattform?
  a) Ja, zentrale Plattform nutzen
  b) Nein, Projekt soll eigene Monitoring-Loesung vorbereiten
  c) Noch unklar, als Architekturfrage dokumentieren
```

```
Soll der Research-Skill installiert oder angebunden werden?
  Quelle: Framework / Companion / global installiert / nicht installieren
  Provider: Perplexity MCP / Perplexity API / OpenRouter / kein Provider
```

```
Visualisierung:
  - visualize-Skill installieren?
  - Miro als Diagramm-Ziel nutzen?
  - Miro-MCP vorhanden und pruefen?
  - Fallback: Excalidraw / Mermaid / keiner?
```

**Merken:** `PROVIDER_POSTFLIGHT = {...}` fuer Abschlussbericht und optional `docs/MONITORING.md`.

---

## Phase 3: Block C — Doku-Architektur-Vorschlag

Lies `references/doc-architecture-proposal.md` fuer die vollstaendige Begruendung.
Lies zusaetzlich `references/project-documentation-ssot.md`. Block C muss zuerst die in Block B gewaehlte Projekt-Dokumentations-SSoT operationalisieren:

- `obsidian`: Projektordner im Vault anlegen oder bestaetigen; Obsidian ist Best-Practice, aber keine Framework-Voraussetzung.
- `repo-docs`: `docs/project/` als verbindliche Projekt-Dokumentations-SSoT anlegen.
- `external-dms`: lokale Verweisdatei in `docs/project/` anlegen und Runtime-Artefakte auf URL/Pfad verweisen lassen.
- `undecided`: `docs/project/` als Fallback anlegen, TODO "finale Dokumentations-SSoT entscheiden" erzeugen und Postflight als `WARN` markieren.

Unabhaengig vom Zielort muessen Project Hub, Developer Onboarding, Projekt-Governance, Zielarchitektur, Backlog, Decisions, Meetings, Research, Assets und Archive existieren oder eindeutig verlinkt sein.

Basierend auf Stack-Wahl (A.1) und Infra-Status (Block B) einen konkreten Doku-Struktur-Vorschlag praesentieren:

```
Vorschlag: 3-Schichten-Doku mit ARCHITECTURE_DESIGN.md als zentralem Hub

  Schicht 1 — Story-Specs (Repo)
    Pfad:     {PROJECT_PATH}/specs/<PREFIX>XXX.md
    Zweck:    Pro Story ein Spec, git-versioniert
    Trigger:  Pflicht vor jeder Code-Aenderung (spec-gate.sh)

  Schicht 2 — Component-Docs (Obsidian)
    Pfad:     {OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Components/*.md
    Zweck:    Lebende Doku pro Komponente (Stack, Status, offene Fragen)
    Trigger:  Update bei jedem /implement (T_last-Pflicht)
    Komponenten-Vorschlag (basierend auf Stack): {STACK_SUGGESTION}

  Schicht 3 — Architektur-Vorgaben (Obsidian)
    Pfad:     {OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Architektur-Vorgaben.md
    Zweck:    Konsolidierte Leitprinzipien, Stack-Entscheidungen, verworfene Alternativen
    Trigger:  Update bei ADR-Aenderungen

  Hub (Repo)
    Pfad:     {PROJECT_PATH}/ARCHITECTURE_DESIGN.md
    Zweck:    Einstiegspunkt fuer /ideation, /architecture-review, /implement
    §9 Referenzen verlinkt automatisch auf alle obigen Dateien

Passt das? [ja / anpassen / skip Obsidian-Schicht]
```

**Komponenten-Vorschlag (STACK_SUGGESTION) je nach A.1:**
- Node.js Backend → `api.md`, `db.md`, `background-jobs.md`, `auth.md`
- Frontend → `ui.md`, `state.md`, `routing.md`, `api-client.md`
- Full-Stack → `frontend.md`, `backend.md`, `api.md`, `db.md`
- Python → `cli.md`, `core.md`, `integrations.md`, `data.md`
- Anderes → fragt den Operator nach Komponenten-Namen

Operator kann Komponenten anpassen oder eigene eingeben.

**Bei `ja`:**
- Components-Skelette werden in Phase 4 angelegt
- `ARCHITECTURE_DESIGN.md §9 Referenzen` wird initial befuellt
- Optional `orphan-check.sh` Hook wird in Phase 4 installiert (fragt explizit: "Hook, der prueft ob jede neue `*.md` im Hub registriert ist? [ja, empfohlen / nein]")

**Bei `anpassen`:** Dialog fragt welche Schichten + Pfade gewuenscht sind.

**Bei `skip Obsidian-Schicht`:** Alle Docs im Repo (`docs/components/`), kein SecondBrain-Anteil.

Phase-3-Checkpoint: Doku-Struktur bestaetigen.

---

## Phase 4: Grundstruktur anlegen

### 4.1 Verzeichnisstruktur

```bash
mkdir -p {PROJECT_PATH}/{lib,agents,.claude/skills,.claude/hooks,.codex,specs,docs,journal,intents,pitch}
```

### 4.2 Git-Repo initialisieren (falls noch nicht vorhanden)

```bash
cd {PROJECT_PATH}
git init
# Remote nur setzen wenn B.2 == Ja + URL
git remote add origin {GITHUB_REPO}
```

`.gitignore` aus `references/file-templates.md` anlegen — enthaelt seit BOO-36 den Block `journal/reports/local/` (Iteration-Outputs aus `/implement` Schritt 6, lebend nur lokal — werden NICHT committed, weil sie pro Run einmalig und re-erzeugbar sind. `/sprint-review` aggregiert sie in `journal/sprint-{date}.md`, das wird committed). Pendant: `journal/reports/ci/` bleibt fuer CI-Runs aus GitHub Actions (separater Pfad, getrennt entscheidbar).

### 4.3 Kern-Dateien aus Templates rendern

Aus `references/file-templates.md` mit Block-A-Angaben befuellen:

| Datei | Template-Sektion |
|-------|-----------------|
| `lib/config.js` | config.js |
| `AGENTS.md` | AGENTS.md (Codex-Einstieg; bei Runtime `codex`/`cross-tool`/`unknown` Pflicht) |
| `CLAUDE.md` | CLAUDE.md (Claude-Code-Einstieg + Kompatibilitaetsbruecke, mit Hub-Regel) |
| `CONVENTIONS.md` | CONVENTIONS.md (Adapter-Vertrag: Runtime, Backlog-Adapter, Governance-Modus, Execution-Isolation, aktive Gates) |
| `SYSTEM_ARCHITECTURE.md` | SYSTEM_ARCHITECTURE.md |
| `ARCHITECTURE_DESIGN.md` | ARCHITECTURE_DESIGN.md (Hub mit §9 Referenzen) |
| `INDEX.md` | INDEX.md |
| `COMPONENT_INVENTORY.md` | COMPONENT_INVENTORY.md |
| `.env.example` | .env.example |
| `CHANGELOG.md` | CHANGELOG.md |
| `specs/TEMPLATE.md` | specs/TEMPLATE.md |

> **KI-Architektur-Block (BOO-24):** Das `ARCHITECTURE_DESIGN.md`-Template enthaelt bereits den Pflicht-Block "KI-Architektur-Prinzipien + Anti-Patterns" in §2 (Design-Rationale). Referenz: `intentron/references/ki-architektur-prinzipien.md`. Der Block wird automatisch beim Template-Rendering befuellt — kein manueller Schritt noetig. `/architecture-review` (BOO-7) prueft alle 8 Checks reaktiv bei jeder Story.

> **CONVENTIONS.md (BOO-51/52/53/54):** Dieses Dokument ist der projektlokale Adapter-Vertrag zwischen allen Skills und Runtimes. `/ideation` liest daraus `runtime_target`, `backlog_adapter`, `governance_mode` und `execution_isolation`; `/implement` nutzt es als Pre-Flight fuer Worktree-/Write-Scope-Pflicht und aktive Gates; `/sprint-review` prueft spaeter Drift gegen die gewaehlte Governance-Intensitaet.

> **Baseline-Regel fuer Governance-Modi (BOO-61):** Lite/Standard/Heavy duerfen keine Skill- oder Artefakt-Baseline zerstoeren. Immer angelegt werden mindestens `AGENTS.md`/`CLAUDE.md` gemaess Runtime, `CONVENTIONS.md`, `ARCHITECTURE_DESIGN.md`, `GOVERNANCE.md`, `SECURITY.md`, `specs/TEMPLATE.md`, `journal/`, Backlog-Record-Template und die gewaehlte Skill-Baseline. Die Modi steuern nur Gate-Strenge, Defaults und erforderliche Nachweise.

Aus `references/governance-template.md`:
- `GOVERNANCE.md` mit Projektname + Prefix + aktivierten Add-ons

Aus `references/issue-writing-guidelines-template.md` (Version 3.1, BOO-30):
- `.claude/ISSUE_WRITING_GUIDELINES.md` mit ISSUE_PREFIX
- Enthaelt seit v3.1 die Pflicht-Sektion `## Definition of Done (Pflicht)` als 5er-Checkliste (lokale Gates, PR-Merge, Required Status Checks, kein "QA Failed", Spec-File-Update) — 1:1 aus BOO-30
- Operator-Hinweis: Workflow-States (`Backlog`, `In Progress`, `In Review`, `QA Failed`, `Done`, `Cancelled`) werden im neutralen Backlog-Record beschrieben. Externe Adapter mappen sie auf Linear/GitHub/Jira/Azure DevOps/Planner — siehe Phase 4.4l.

Zusaetzlich Skelette:
- `DEVELOPMENT_PROCESS.md` — Verweis auf GOVERNANCE.md
- `SECURITY.md` — Minimales Skelett (Add-on-Sektionen: Privacy/Compliance falls aktiviert)

> **KERN-REGEL im Runtime-Einstieg (`AGENTS.md`/`CLAUDE.md`):** Jede neue Datei MUSS sofort in `ARCHITECTURE_DESIGN.md §9 Referenzen` UND `INDEX.md` eingetragen werden — vor dem git commit.

### 4.3a PROJEKT-TYP-Marker setzen (BOO-148)

Beim Befuellen der `CLAUDE.md` (Template `references/file-templates.md` §`CLAUDE.md (Minimum)`) den Platzhalter `{{PROJECT_TYPE_MARKER}}` setzen — der Marker steht als erste Zeile nach dem H1-Titel und steuert, ob Deployment-/CI-Gates fuer dieses Repo greifen. Entscheidungsregel:

- **Aktiv-Projekt** (Code + Deployment hier) → AKTIV-Marker:

  ```markdown
  > **PROJEKT-TYP: AKTIV** — Code + Deployment in diesem Repo
  ```

- **Reine Docs/Specs / Governance-Referenz** (kein Coding) → GOVERNANCE-REFERENZ-Marker:

  ```markdown
  > **PROJEKT-TYP: GOVERNANCE-REFERENZ** — nur Docs/Specs, kein Coding
  ```

**Default = AKTIV** — im Zweifel nicht nachfragen, AKTIV setzen (~80% der Faelle). Nur auf eindeutige Docs/Specs-Repos (z.B. Governance-Buch, reine Referenz-Sammlung) GOVERNANCE-REFERENZ setzen.

> **Issue-Referenz:** BOO-148. Migration fuer Bestands-Projekte: `references/migration-checklist-v1-to-v2.md` §BOO-148 (`migrate_boo_148`).

### 4.3b CONTEXT.md seeden — Ubiquitous Language (BOO-91)

`CONTEXT.md` im Projekt-Root aus `references/context-base.md` (DE) bzw. `references/context-base.en.md` (EN, je nach `documentation`-Sprache aus A.3) seeden: vorgefuelltes **kanonisches Vokabular** + **Verbotsliste** (Compliance + Governance, jeder Begriff mit Quelle) plus eine leere Sektion `## Projekt-Domaene (vom Operator fuellen)` fuer projektspezifische Begriffe. Die KI liest `CONTEXT.md` beim Schreiben und nutzt konsequent die kanonischen Begriffe — **Default Guidance, kein Hard-Gate** (kein Block, nur Fuehrung).

- Nur seeden wenn `CONTEXT.md` fehlt — ein vorhandenes Operator-Overlay nie ueberschreiben (idempotent, analog `migrate_boo_91()`).
- Die generierte `CLAUDE.md` (und `AGENTS.md`) **verweist auf `CONTEXT.md`** als verbindliches Vokabular fuer alle Schreib-Aktionen.
- `CONTEXT.md` in `ARCHITECTURE_DESIGN.md §9 Referenzen` + `INDEX.md` eintragen.

> **Issue-Referenz:** BOO-91. Enforcement (dpo-Control „Vokabular folgt CONTEXT.md", Layer-0-Bodyguard-`warn` auf verbotene Begriffe) ist bewusst eine **spaetere, opt-in Ausbaustufe** — diese Stufe liefert nur die Guidance-Schicht. Details: CONVENTIONS.md §Ubiquitous Language.

### 4.3c Artefakt-Landkarte seeden (BOO-108)

Projekt-lokale Instanz der **Artefakt- & Freigabe-Landkarte** aus der Master-Vorlage `docs/onboarding/artefakt-landkarte.md` (DE) bzw. `artefakt-landkarte.en.md` (EN, je nach `documentation`-Sprache aus A.3) erzeugen — als `solution-artefakte.md` im Doku-SSoT. Die Landkarte ist der **Planungs- und Abnahme-Layer**: sie verknuepft jedes Framework-Artefakt mit der Kundenseiten-Rolle, die es abgleicht, und der Regel-Senke, in der die resultierende Regel landet — die Voraussetzung dafuer, dass ein autonomes Team regelkonform selbst entwickeln kann.

**Frage an den Operator (einmal, Ja/Nein):**
> „Soll ich die Artefakt-Landkarte fuer dieses Projekt erzeugen? Sie listet — gefiltert auf diese Solution — welche Artefakte mit welcher Kundenrolle abzugleichen sind und wo die Regeln hinterlegt werden. Empfohlen, wenn das Framework bei einem Kunden/Konzern ausgerollt wird."

Bei **ja**: Instanz rendern und nach den Block-A-Antworten **vorfiltern** (Leichtgewicht-Prinzip — nur getriggerte Zeilen):
- `STACK_CHOICE = b/c` (Frontend) → Zeile *Design-/CI-Vorgaben* aktiv, inkl. `DESIGN.md`-Verweis aus `ARCHITECTURE_DESIGN.md §5`
- Governance-Intensitaet (A.5) = `streng` → *Threat Model*, *Compliance-Nachweismechanik*, Vier-Augen aktiv
- PII/DSGVO bzw. KI-Komponente markiert → Abschnitt C (dpo-Artefakte) aktiv
- Monitoring gewuenscht / Observability-Skelett (4.4f) → *Monitoring-/Logging-Setup* aktiv

Bei **nein**: ueberspringen, Hinweis im Output („spaeter via Master-Vorlage `docs/onboarding/artefakt-landkarte.md` nachholbar").

- Nur seeden wenn `solution-artefakte.md` fehlt — vorhandene Operator-Instanz nie ueberschreiben (idempotent, analog `migrate_boo_91()`).
- `solution-artefakte.md` in `ARCHITECTURE_DESIGN.md §9 Referenzen` + Doku-Hub eintragen.

> **Issue-Referenz:** BOO-108. Die Auto-Generierung direkt aus `.claude/environment.json`-Flags ist eine spaetere, opt-in Ausbaustufe — diese Stufe rendert die gefilterte Master-Vorlage. Hintergrund: HANDBUCH Anhang Z + `docs/onboarding/artefakt-landkarte.md`.

### 4.4 Linting-Konfiguration

Basierend auf `STACK_CHOICE` — siehe `references/file-templates.md`:
- Node.js / Full-Stack / Anderes → `eslint.config.mjs` (ESLint v9 Flat Config)
- Frontend / Full-Stack → zusaetzlich `.prettierrc`
- Python → `pyproject.toml` (Ruff + Black)
- **TypeScript** (`LANG_VARIANT = ts` bei a/b/c, BOO-127) → zusaetzlich `tsconfig.json` (Template `references/file-templates.md` §`tsconfig.json (BOO-127)`); `eslint.config.mjs` bindet `typescript-eslint` ein; plus `tsc --noEmit`-Typecheck-Gate (siehe CI-Tabelle unten).
- **React / Frontend mit JSX** (Stack b/c, BOO-141) → `eslint.config.mjs` bekommt zusaetzlich einen Frontend-Block mit `...globals.browser` **und** `React: 'readonly'` (Paket `globals` als devDep). Pflicht, sonst wirft `no-undef` bei jeder `.tsx`-Datei `'React' is not defined`. Template: `references/file-templates.md` §`eslint.config.mjs` → „Mit React / Frontend (TSX)".
- **Next.js / Meta-Framework `package.json`-`lint`-Script** (Stack b/c, BOO-140) → falls `create-next-app` o.ae. bereits ein `"lint": "next lint"` in `package.json` angelegt hat, das Script idempotent auf `"lint": "eslint ."` umbiegen (Operator-Bestaetigung als ADR). Grund: `next lint` versteht die ESLint-v9-Flat-Config (`eslint.config.mjs`) nicht und bricht mit `Invalid project directory ... /lint` ab; die CI nutzt ohnehin `npx eslint .` (BOO-28). Fuer Bestands-Projekte: `migrate_boo_140()`.

Zusaetzlich Stack-abhaengig **CI-Lint-Workflow (BOO-28)** — wird nur angelegt wenn `B.2 == ja` (GitHub-Repo angelegt). Pendant zur Semgrep-CI-Action (Phase 4.4c) — gleicher Layer-3-Mechanismus, andere Tool-Klasse (Lint statt SAST):

| STACK_CHOICE | CI-Workflow-Datei | Quelle |
|--------------|-------------------|--------|
| a) Node.js Backend | `.github/workflows/eslint.yml` | `references/file-templates.md` §`.github/workflows/eslint.yml (BOO-28 — ESLint CI Gate)` |
| b) Frontend | `.github/workflows/eslint.yml` | siehe oben |
| c) Full-Stack | `.github/workflows/eslint.yml` | siehe oben |
| d) Python | `.github/workflows/ruff.yml` | `references/file-templates.md` §`.github/workflows/ruff.yml (BOO-28 — Ruff CI Gate)` |
| e) Anderes | keiner — Operator entscheidet manuell | — |

Beide Workflows schreiben SARIF nach `.ci-reports/` (Pflicht — wird in BOO-32 fuer Hermes-Konsumtion und in BOO-29 als Required Status Check `eslint` / `ruff` gelesen) und uploaden via `github/codeql-action/upload-sarif@v4` in den GitHub-Security-Tab.

Bei `B.2 == nein/c` (kein GitHub gewuenscht): BOO-28-Schritt skippen, nur Layer 2 (Pre-Commit-Hook, Phase 4.6) deckt Linting lokal ab.

> **TypeScript-Typecheck-Gate (BOO-127):** Bei `LANG_VARIANT = ts` (a/b/c) ergaenzt der Bootstrap einen `tsc --noEmit`-Schritt in `eslint.yml` (oder eine eigene `.github/workflows/typecheck.yml`) — Template `references/file-templates.md` §`tsc --noEmit Typecheck (BOO-127)`. Das Gate ist in BOO-29 als Required Status Check `typecheck` referenzierbar. Lokal deckt der Pre-Commit-Hook (Phase 4.6) `tsc --noEmit` zusaetzlich ab.

### 4.4b SAST-Konfiguration (Semgrep — alle Stacks)

Aus `references/file-templates.md` §.semgrep.yml + §.semgrepignore:

- `.semgrep.yml` — Drei-Layer-Default-Ruleset:
  - **Layer 1 (Pflicht, alle Stacks):** `p/security-audit`, `p/secrets`
  - **Layer 2 (sprach-spezifisch, auto-erkannt):** `p/javascript` wenn `package.json` vorhanden, `p/python` wenn `pyproject.toml` vorhanden
  - **Layer 3 (optional, auskommentiert):** `p/owasp-top-ten` — Operator entscheidet pro Web-Projekt
- `.semgrepignore` — Default-Excludes (`node_modules/`, `dist/`, `build/`, `journal/reports/`, `.venv/`, `__pycache__/`)

Die Sprach-Erkennung passiert beim Bestandsprojekt-Migrationspfad in `migrate_boo_3()` — fuer ein neues Projekt (Bootstrap-Flow) wird die jeweilige Layer-2-Zeile basierend auf `STACK_CHOICE` direkt aktiv eingefuegt:

| STACK_CHOICE | Layer-2-Aktivierung |
|--------------|--------------------|
| a) Node.js Backend | `p/javascript` aktiv |
| b) Frontend | `p/javascript` aktiv |
| c) Full-Stack | `p/javascript` aktiv |
| d) Python | `p/python` aktiv |
| e) Anderes | beide auskommentiert (Operator entscheidet manuell) |

Bei Frontend-/Full-Stack-Projekten zusaetzlich beim Anlegen Hinweis ausgeben:

```
Empfehlung: bei Web-App auch Layer 3 (p/owasp-top-ten) in .semgrep.yml aktivieren.
Einkommentieren ueber: sed -i '' 's/^  # - p\/owasp/  - p\/owasp/' .semgrep.yml
```

Konsumiert vom Pre-Commit-Hook (Layer 2, siehe Phase 4.6) und der GitHub Action (Layer 3, siehe Phase 4.4c).

**Custom-Rule-Verzeichnis + Wiring-Canary (BOO-185):** Zusätzlich rollt der Bootstrap das Verzeichnis `.semgrep/` aus — projekt-eigene Regeln, die CI (Layer 3) und Pre-Commit (Layer 2) via `--config .semgrep/` **zusätzlich** zu den Registry-Packs laden, sobald das Verzeichnis existiert. Darin liegt `.semgrep/custom-rules.yml` mit der Regel `qgaudit-wiring-canary` und die Fixture `.semgrep/test-fixtures/wiring-canary.py` (Tripwire-Literal `QGAUDIT-CANARY-TRIPWIRE`). `.semgrep/test-fixtures/` ist im `.semgrepignore` ausgeschlossen, damit die CI nicht dauerrot wird — der Canary wird nur vom gezielten Audit-Scan erfasst. **Verifikations-Praxis:** Ein konfiguriertes Custom-Rule-Verzeichnis ist erst dann nachweisbar aktiv, wenn `semgrep --config .semgrep/ .semgrep/test-fixtures/wiring-canary.py` die Canary-Regel meldet — bleibt der Scan stumm, ist das Gate blind (Anker für den `quality-gate-audit`-Skill, BOO-183). Inhalte aus `references/file-templates.md` §`.semgrep/custom-rules.yml`, §`.semgrep/test-fixtures/wiring-canary.py` und §`.semgrepignore`.

### 4.4c CI-Layer (Semgrep, BOO-4)

Wenn `B.2 == ja` (GitHub-Repo angelegt), wird zusaetzlich `.github/workflows/semgrep.yml` aus `references/file-templates.md` §`.github/workflows/semgrep.yml (BOO-4 — Quality-Gate Layer 3)` angelegt.

Die Action liest dasselbe `.semgrep.yml`-Manifest wie der Pre-Commit-Hook (Layer 2, Phase 4.6) — identische Manifest-Reader-Logik, identische Pack-Auswahl. Blockiert Merge in `main` via Required Status Check `Semgrep` (Branch-Protection wird in BOO-29 aktiviert).

| Layer | Wo | Wann | Was |
|-------|-----|------|-----|
| Layer 2 | `.git/hooks/pre-commit` | bei `git commit` | lokal blockierend, ESLint + Semgrep |
| Layer 3 | `.github/workflows/semgrep.yml` | bei `push`/`pull_request` auf `main` | CI-blockierend, Semgrep mit SARIF-Output nach `.ci-reports/` |

**Wichtig:** Beide Layer lesen `.semgrep.yml`. Wer den Hook lokal via `--no-verify` umgeht, wird in Layer 3 gefangen — Belt-and-Suspenders.

Bei `B.2 == nein/c` (kein GitHub gewuenscht): Phase 4.4c skippen, nur Layer 2 (Hook) wird in Phase 4.6 installiert.

### 4.4d Test-Setup (BOO-15)

Voraussetzung fuer das Coverage-Gate (BOO-15) im `/implement`-Skill (Schritt 6a-quart). Ohne JSON-Coverage-Output wird das Gate uebersprungen mit Hinweis. Stack-abhaengig:

- **Node (a/b/c):** `c8` als devDependency installieren — `npm install --save-dev c8` — und in `package.json` ein Coverage-Test-Skript ergaenzen:
  ```json
  "scripts": {
    "test:coverage": "c8 --reporter=json --reporter=text-summary npm test"
  }
  ```
  Coverage-Output landet in `coverage/coverage-final.json`.

- **Python (d):** `pytest-cov` in `pyproject.toml` als Test-Dependency aufnehmen, Test-Lauf mit `pytest --cov --cov-report=json --cov-report=term-missing`. Coverage-Output landet in `coverage.json`.

- **Anderes (e):** Operator entscheidet manuell, Stack-passendes Coverage-Tool mit JSON-Export aktivieren.

Test-Verzeichnis-Konvention: `tests/` (Python), `__tests__/` oder `test/` (Node) — die Filter-Logik im Hook erkennt diese Pfade automatisch und schliesst Test-Dateien selbst aus der Diff-Coverage-Berechnung aus.

Coverage-Output-Pfade (Hook erwartet):
| Stack | Pfad |
|-------|------|
| Node (c8) | `coverage/coverage-final.json` |
| Python (pytest-cov) | `coverage.json` |

Hinweis: das Coverage-Gate selbst wird in Phase 4.6 installiert (`coverage-check.sh`), aber NICHT im Pre-Commit-Hook aufgerufen.

### 4.4e Environment-Awareness (BOO-34)

Voraussetzung dafuer, dass alle nachgelagerten Skills (implement, sprint-review, breakfix, ...) ihre Mac-/VPS-/CI-Awareness aus einer **Single Source of Truth** lesen, statt selbst Detection zu fahren. Single Source of Truth ist `.claude/environment.json` (Manifest), erzeugt vom mitgelieferten Bash-Generator.

Aus `references/file-templates.md` §`.claude/environment.json (BOO-34 — Skill-Umgebungs-Awareness)` und §`.claude/generate-environment-json.sh (BOO-34)`:

- `.claude/generate-environment-json.sh` — Bash-Generator (~120 Zeilen, BSD- und Linux-kompatibel, idempotent: schreibt nur wenn File fehlt oder `--force`-Flag). Keine Dependencies ausser `bash`, `uname`, `command`, `cat`, `grep`, `sed`, `date`.
- Direkter erster Lauf nach dem Anlegen: `bash .claude/generate-environment-json.sh`
- Ergebnis: `.claude/environment.json` mit `environment` (mac/vps/ci, CI-Check zuerst), `tools_available` (eslint, semgrep, Test-Framework, SonarQube), `paths` (journal/reports/lessons/specs), `metadata` (created_at, bootstrap_version=3.3.0, stack).

> **Wichtig zur Detection-Reihenfolge:** CI-Check (env-var `$CI`) VOR Mac/VPS — ein CI-Runner kann Linux ODER Mac sein. Sonst wird ein Mac-CI-Job faelschlich als `mac` markiert.

`metadata.stack` wird analog zur BOO-3-Stack-Erkennung gesetzt:

| Indikator | stack-Wert |
|-----------|-----------|
| `package.json` + (`tsconfig.json` ODER `"typescript"` in deps) | `node-typescript` |
| `package.json` ohne TypeScript | `node-javascript` |
| `pyproject.toml` | `python` |
| Beide (`package.json` + `pyproject.toml`) | `mixed` |
| Keiner | `unknown` |

Konsumiert von **allen** Sub-Skills via Schritt-0-Read (Rollout in BOO-34 Sub-Agent #2). Beispiel-Pattern:

```bash
ENV_FILE=".claude/environment.json"
if [[ -f "$ENV_FILE" ]]; then
    HAS_SEMGREP=$(grep '"semgrep"' "$ENV_FILE" | grep -oE 'true|false')
fi
```

Bei Tooling-Aenderung (z.B. Semgrep nachinstalliert) Datei mit `bash .claude/generate-environment-json.sh --force` neu generieren. Die Datei wird committed — `metadata.created_at` ist Audit-Spur.

### 4.4f Observability-Skelett (BOO-14)

Voraussetzung dafuer, dass jedes Projekt ab Tag 0 eine **strukturierte Logging-, Metrics- und Alert-Konvention** hat — nicht erst spaeter retrofittet wird. Schrader Code Crash Kap. 3 §Production Readiness §Observability + Kap. 4 §Run the System (Saeule 3 Observability): "Wer ohne Observability deployed, fliegt blind."

Aus `references/file-templates.md` §`observability.md (BOO-14 — Observability-Skelett)`, §`observability/alerts/<service>.yml (BOO-14)` und §`observability/.env.observability (BOO-14)`:

- `observability.md` (Projekt-Root) — zentrales Skelett mit drei Pflicht-Sektionen:
  - **Logging-Schema** — strukturierte JSON-Logs mit Pflicht-Feldern (`timestamp`, `level`, `service`, `trace_id`, `message`, `context`)
  - **Metrics-Endpoint** — `/metrics` im Prometheus-Format pro Service, Port-Konvention `9090+N` (auth=9091, api=9092, ...)
  - **Alert-Rules** — drei Pflicht-Alerts pro Service: `{service}_down` (`up == 0` fuer >2 min, severity critical), `{service}_error_rate_high` (errors/requests >5% fuer 5 min, severity warning), `{service}_p95_slow` (p95(request_duration_seconds) >1s fuer 5 min, severity warning)
- `observability/alerts/<service>.yml` — Pro Service aus Block C eine Prometheus-Alert-Rules-Datei.
- `observability/.env.observability` — Routing-Konfiguration (Telegram/Slack/Email-Webhooks). **Wird ge-gitignored**, nur `.env.observability.example` committed.
- `.gitignore`-Eintrag: `observability/.env.observability`.

**Block-C-Kopplung:** Pro Service aus Block C (`STACK_SUGGESTION` — z.B. `api.md`, `db.md`, `auth.md` bei Node.js) wird in `observability.md` eine Sektion `### Service: <name>` angelegt + eine Datei `observability/alerts/<name>.yml` mit den drei Pflicht-Alerts.

**Stack-Defaults** (Vorschlag, Operator kann ueberschreiben — als ADR dokumentieren):

| Stack | Logger-Lib | Metrics-Lib |
|-------|-----------|-------------|
| Node.js (a/b/c) | `pino` | `prom-client` |
| Python (d) | `structlog` | `prometheus_client` |
| Frontend (b) | Hinweis: Browser-Logs gehen an Backend-Service, nicht direkt an Prometheus |
| Anderes (e) | Operator entscheidet — als ADR in `docs/domain/adrs/` dokumentieren |

**Validierung (optional, falls `promtool` lokal installiert):**

```bash
promtool check rules observability/alerts/*.yml
```

Wenn `promtool` nicht installiert: Skip mit Hinweis. Empfehlung: `brew install prometheus` (Mac) bzw. `apt install prometheus` (VPS) beim ersten Service mit echten Alert-Rules.

> **Issue-Referenz:** BOO-14, Schrader Code Crash Kap. 3 §Production Readiness §Observability sowie Kap. 4 §Run the System (Saeule 3 Observability).

### 4.4g Performance-Baseline (BOO-16)

Voraussetzung dafuer, dass Performance-Regressionen **vor** dem Merge auffallen — nicht erst in Production. BOO-14 hat bereits den Production-Alarm `{service}_p95_slow` etabliert; BOO-16 ergaenzt den Pre-Production-Gate: CI-Bench gegen lebende Baseline, blockiert Merge bei p95 > Baseline +20 %. Schrader Code Crash Kap. 3 §Production Readiness (Gate 3: Performance Baseline) — ohne Baseline keine sichtbare Regression.

Aus `references/file-templates.md` §`Performance-Baseline-Gate (BOO-16 — P95 + 20%-Rueckfall-Alarm)` mit den vier Sub-Sektionen:

- `journal/perf-baseline.json` (Projekt-Root, committed) — lebende Baseline mit `p50_ms`, `p95_ms`, `p99_ms`, `req_per_sec`, `recorded_at`, `commit_sha`, `bench_tool` pro Service. Beim Bootstrap initial mit `services: []` angelegt; Operator befuellt nach erstem gruenen CI-Lauf.
- `bench/<service>.bench.js` (Node-Stack) ODER `bench/<service>_bench.py` (Python-Stack) — Service-Benchmark mit autocannon (Node, 30s Lauf, 10 Connections, Warmup 5s) bzw. pytest-benchmark + httpx (Python, Approximation `p95 ≈ mean + 1.645*stddev`).
- `.github/workflows/perf.yml` — CI-Gate (`pull_request` gegen `main` + `workflow_dispatch`), Schwellen `<=1.05` PASS / `1.05-1.20` WARNING (PR-Comment) / `>1.20` FAIL. Override via PR-Label `perf-override` ODER Commit-Trailer `Perf-Override: <begruendung>`, append-only nach `journal/reports/perf/overrides.log`.
- `journal/reports/perf/overrides.log` — entsteht beim ersten Override; append-only Audit-Spur.

**Block-C-Kopplung:** Pro Service aus Block C (`STACK_SUGGESTION`) wird ein Bench-File angelegt + ein Eintrag in der Workflow-Matrix `service: [...]`. Service-Namen identisch zu `observability.md` (Kebab-Case).

**Stack-Defaults** (Operator kann ueberschreiben — als ADR dokumentieren):

| Stack | Bench-Tool | Bench-File | bench_tool-Wert in Baseline |
|-------|-----------|-----------|----------------------------|
| Node.js (a/c) | autocannon (devDep) | `bench/<service>.bench.js` | `autocannon` |
| Python (d) | pytest-benchmark + httpx (test-Dep) | `bench/<service>_bench.py` | `pytest-benchmark` |
| Frontend (b) | Lighthouse CI (separater Issue) | — | aus BOO-16-Scope ausgeschlossen |
| Anderes (e) | Operator-Choice mit JSON-Output (p50/p95/p99) | — | `other` |

> [!important] autocannon hat kein natives p95
> autocannon's `result.latency` exponiert `p2_5, p50, p75, p90, p97_5, p99, ...` — kein `p95`. Wir nutzen `p97_5` als konservative Approximation (worst-case Bias nach oben — eine echte Regression wird erkannt, harmlose Schwankungen ggf. groesser dargestellt). Das ist explizit dokumentiert in der Baseline ueber `bench_tool: "autocannon"`. Details siehe Template-Sektion.

> [!important] GitHub-Hosted-Runner-Varianz
> Standard-Runner sind shared Hardware mit +/- 30 % Varianz zwischen identischen Laeufen. Der 20%-FAIL-Threshold ist absichtlich generoes — er faengt echte Regressionen, nicht Noise. Folge-Issue (nach BOO-16): Self-Hosted-Runner mit reservierter CPU/Memory, dort kann der Threshold auf 10 % geschaerft werden.

> [!note] Erstbefuellung der Baseline
> Frischer Repo-State: `services: []`. Erster CI-Lauf failt mit "Baseline fehlt". Operator laed das Bench-Artefakt herunter, kopiert die Werte manuell in `perf-baseline.json` und committed mit Begruendung — danach laeuft das Gate. Auto-Befuellung waere ein Anti-Pattern, weil dann jede Regression automatisch zur neuen Baseline wird.

> **Issue-Referenz:** BOO-16, Schrader Code Crash Kap. 3 §Production Readiness (Gate 3: Performance Baseline). Pendant zum Production-Alarm `{service}_p95_slow` aus BOO-14.

### 4.4h Reliability-Skelett (BOO-25)

Sechste Saeule des Schrader-Modells: Reliability als Architektur-Eigenschaft. Wer nur deployed und hofft, baut einen Demo. BOO-25 setzt fuenf Invarianten als konkrete Skelett-Dateien an: Idempotenz, Retry+Backoff, Circuit Breaker, Graceful Degradation und SLO+Error-Budget. Schrader Code Crash Kap. 4 §Run the System (Saeule 6 Reliability) — die Differenz zwischen "es lief beim Start" und "es laeuft Monat zwei".

Aus `references/file-templates.md` §`Reliability-Skelett (BOO-25 — 5 Invarianten Idempotenz/Retry/Circuit-Breaker/Graceful-Degradation/SLO)` mit den vier Sub-Sektionen:

- `docs/SLO.md` (Projekt-Root, committed) — Service Level Objective Manifest mit drei SLIs (Availability / Latency P95 / Error Rate), PromQL-Mess-Methode (liest aus dem `/metrics`-Endpoint von BOO-14), Error-Budget-Tabelle pro Quartal mit Verbrauch-Tracker, Review-Cadence in `/sprint-review` (monatlich).
- `lib/idempotency.{js,py}` — Idempotency-Key-Middleware (Express-Middleware bzw. FastAPI-Dependency). Liest Header `Idempotency-Key` (UUID v4), persistiert Request-Hash + Response in Redis fuer 24h TTL. Bei Wiederholung mit gleichem Key: cached Response. Bei gleichem Key + abweichendem Body: HTTP 422.
- `lib/retry.{js,py}` — Retry-Wrapper mit exponential Backoff + Jitter. Default: 3 Versuche, Faktor 2, Jitter aktiv. **Hard Constraint:** nur transiente Fehler (5xx, Timeout, Connection-Reset) werden retried — KEIN Retry bei 4xx oder 422.
- `lib/circuit-breaker.{js,py}` — Circuit-Breaker-Wrapper, **eine Instanz pro externe Abhaengigkeit** (DB, externe API, Message Bus). Drei States (Closed/Open/Half-Open), Logging via Pino/structlog (BOO-14), Fallback als Operator-Choice (Cache / Default / 503 + `Retry-After`).

**Phase 4.4h ist OPTIONAL** — nicht jeder Service braucht alle vier Skelette ab Tag 0. Operator-Frage am Anfang der Phase:

```
Reliability-Skelett aus BOO-25 anlegen? (Schrader Saeule 6)
  a) ja, alle vier (SLO + Idempotency + Retry + Circuit Breaker)  — empfohlen fuer Backend mit externer Abhaengigkeit
  b) nur Idempotency + SLO  — minimaler schreibender Service ohne externe Abhaengigkeiten
  c) nur SLO  — reine Lese-Services, Reliability-Mess-Manifest reicht
  d) nein  — uebersrpingen (Default fuer reines Frontend / Skript / experimentelles Setup)
```

**Default-Empfehlung pro Stack:**

| Stack | Default-Antwort | Begruendung |
|-------|-----------------|-------------|
| Node.js (a/c) | a) alle vier | Backend mit Side-Effects, externe Calls erwartet |
| Python (d) | a) alle vier | dito |
| Frontend (b) | d) nein | kein Server-Endpoint, Backend macht das |
| Anderes (e) | c) nur SLO | Tool-unabhaengig, Mess-Manifest immer sinnvoll |

**Stack-Defaults pro Skelett** (Operator kann ueberschreiben — als ADR dokumentieren):

| Stack | Idempotency | Retry | Circuit Breaker | SLO |
|-------|-------------|-------|-----------------|-----|
| Node.js (a/c) | `lib/idempotency.js` + `redis@5.x` | `lib/retry.js` + `p-retry@8.x` | `lib/circuit-breaker.js` + `opossum@9.x` | `docs/SLO.md` |
| Python (d) | `lib/idempotency.py` + `redis>=5.0` | `lib/retry.py` + `tenacity>=9.0` | `lib/circuit-breaker.py` + `pybreaker>=1.0` | `docs/SLO.md` |
| Frontend (b) | nicht aktiv (Backend macht das) | nicht aktiv | nicht aktiv | nicht aktiv |
| Anderes (e) | Operator-Choice | Operator-Choice | Operator-Choice | `docs/SLO.md` |

> [!important] SLO ist Architektur-Artefakt, kein Marketing-Versprechen
> Wer 99,99 % schreibt ohne Multi-Region oder Active-Passive-Failover, ist unehrlich. Default-Empfehlung: 99,9 % fuer Single-Region (43,8 min Downtime/Monat), 99,95 % mit Failover, 99,99 % nur mit Multi-Region + Chaos-Tests. Hoeher ist eine Luege bis zum Beweis des Gegenteils.

> [!important] Idempotency NUR fuer schreibende Endpunkte
> Anwenden auf POST / PUT / PATCH / DELETE — nicht auf GET (per HTTP-Spec idempotent, der Layer ist Overhead). Auch nicht global fuer alle Routes — nur dort, wo Side-Effects passieren (DB-Writes, externe API-Calls, Geld-Bewegung).

> [!important] Circuit Breaker pro externe Abhaengigkeit, nicht global
> Pattern: `dbBreaker`, `paymentApiBreaker`, `s3Breaker` — separate Instanzen mit eigenen Schwellen. Wenn die DB langsam ist, soll Auth nicht mit-failen. Schwellen pro Abhaengigkeit anpassen, dokumentiert im Code.

> [!note] Kopplung zu Reliability-Dimension in `architecture-review`
> Die Reliability-Dimension in `architecture-review/references/dimensions-detail.md` §1 listet diese fuenf Invarianten als Pflicht-Checks. Die hier erstellten Skelette sind die operationalisierte Form derselben Invarianten — bei `/architecture-review` werden die `lib/`-Dateien und `docs/SLO.md` gegen die Pflicht-Checks gehalten.

> **Issue-Referenz:** BOO-25, Schrader Code Crash Kap. 4 §Run the System (Saeule 6 Reliability). Pendant zur Reliability-Dimension in `architecture-review/references/dimensions-detail.md` §1.

### 4.4i Sensitive-Paths-Konfiguration (BOO-18)

Stellt sicher, dass Code-Aenderungen an sensiblen Pfaden (Auth, Payment, PII) einen **Mandatory Human Review** ausloesen — Schritt 5.5 im `/implement`-Skill blockiert den Commit bis der Operator explizit freigegeben hat. Schrader Code Crash Kap. 3 §Enterprise Governance.

Operator-Frage:

```
Sensitive Pfade fuer Mandatory Human Review konfigurieren? (BOO-18)
  a) ja — `.claude/sensitive-paths.json` mit Default-Patterns anlegen (empfohlen fuer jedes Projekt mit Auth/Payment/PII)
  b) nein — überspringen (Default fuer rein experimentelle Projekte ohne sensible Daten)
```

Bei `a) ja`:
- `.claude/sensitive-paths.json` aus `references/file-templates.md` §`.claude/sensitive-paths.json (BOO-18)` rendern
- `{{OPERATOR_NAME}}` mit dem Projektnamen oder GitHub-Handle des Operators befuellen
- Operator darauf hinweisen: Pattern-Liste ergaenzen fuer projektspezifische sensible Pfade (z.B. `src/api/**`, `stripe/**`)
- Datei committen: `git commit -m "chore: .claude/sensitive-paths.json — Mandatory Human Review Patterns (BOO-18)"`

Bei `b) nein`: Skip mit Log-Eintrag "BOO-18 Human Review: deaktiviert".

> **Wichtig:** `.claude/sensitive-paths.json` wird NICHT in `.gitignore` eingetragen — Audit-Trail-Pflicht. Wer sensible Pfade definiert, muss das committen.

> **Issue-Referenz:** BOO-18, Schrader Code Crash Kap. 3 §Enterprise Governance — "Mandatory Human Review fuer sensible Bereiche (Authentication, Payment, PII)".

### 4.5 Component-Skelette (wenn Block C = ja)

Fuer jede Komponente aus dem Doku-Architektur-Vorschlag:
- **Wenn Obsidian-Schicht:** `{OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Components/{component}.md`
- **Wenn Obsidian geskipped:** `{PROJECT_PATH}/docs/components/{component}.md`

Skelett-Struktur siehe `references/doc-architecture-proposal.md` (Frontmatter + Zweck + Stack + Architektur + Konfiguration + Phase-Status + Verbundene Stories + Offene Fragen + Referenzen).

Alle Component-Docs werden in `ARCHITECTURE_DESIGN.md §9 Referenzen` eingetragen.

### 4.6 Governance-Hooks installieren

Siehe `references/hooks-setup.md` fuer Details.

Hooks:
- `spec-gate.sh` — blockiert `git commit` mit `<PREFIX>XXX` wenn Spec-File fehlt
- `doc-version-sync.sh` — blockiert wenn `lib/config.js` VERSION erhoeht aber DOC_FILES nicht synchron
- Optional (bei Block C = ja, orphan-check = ja): `orphan-check.sh` — blockiert wenn neue `*.md` nicht im Hub §9 registriert
- `pre-edit-bodyguard.sh` (BOO-86) — **Layer-0** PreToolUse-Hook auf `Edit|Write`: faengt Secrets/Unsafe-Patterns ab, BEVOR die KI sie schreibt (Default Warnung, `BODYGUARD_STRICT=1` = Hard-Block). Scaffold inkl. `bodyguard/patterns/*.yml` + `SOURCES.md`. Inhalt aus `references/file-templates.md` §`hooks/pre-edit-bodyguard.sh (BOO-86 — Layer-0 Edit-Bodyguard)`. Registriert in `settings.json` unter `matcher: Edit|Write|MultiEdit` (separater Matcher-Block, nicht im `Bash`-Block).
- `pre-commit` (BOO-4) — Quality-Gate Layer 2: ESLint + Semgrep mit Manifest-Reader. Liest `.semgrep.yml` (BOO-3), extrahiert aktive Packs via `grep` + `sed`, baut `--config p/...`-Flags und ruft Semgrep CLI auf. Inhalt aus `references/file-templates.md` §`.git/hooks/pre-commit (BOO-4 — Quality-Gate Layer 2)`. Pendant-CI-Layer 3 (`semgrep.yml`-Workflow) wird in Phase 4.4c angelegt — beide Layer lesen dasselbe Manifest.
- `dependency-check.sh` (BOO-12) — Slopsquatting-Schutz: drittes Gate im Pre-Commit-Hook nach ESLint und Semgrep. Eigenstaendiges Bash-Skript unter `.claude/hooks/dependency-check.sh`, das nur lauft wenn `package.json`/`requirements.txt`/`pyproject.toml`/`Cargo.toml` im Diff der gestagten Files ist. Drei Stufen: Existenz-Check (404 -> BLOCK, Halluzination?), Age-Check (Paket <30 Tage alt -> Warnung, Typosquatter-Risiko), CVE-Check (`npm audit` / `pip-audit`, High/Critical -> BLOCK). Mit BOO-12 bekommt der `.git/hooks/pre-commit`-Hook aus BOO-4 einen vierten Aufruf am Ende: `bash .claude/hooks/dependency-check.sh`. Inhalt aus `references/file-templates.md` §`hooks/dependency-check.sh (BOO-12 — Slopsquatting-Schutz)`. Schrader Code Crash Kap. 3-4: 19,7 % der KI-empfohlenen Pakete existieren nicht. **Seit BOO-197** rollt der Bootstrap zusaetzlich eine projekt-lokale Slopsquatting-Wordlist (`.claude/hooks/slopsquatting/wordlist.txt`) als offline-faehige erste Schicht aus — der Hook prueft jede neue Dependency per `grep` gegen die Liste, bevor er die Live-Registry-Query (zweite Schicht) anstoesst; fehlt die Wordlist, greift nur die Registry-Query. Ein woechentlicher Workflow `.github/workflows/slopsquatting-refresh.yml` haelt die Liste aus oeffentlichen Advisory-Quellen (GHSA/OSV/OSSF) aktuell und oeffnet bei Aenderung einen PR. Templates: `references/file-templates.md` §`.claude/hooks/slopsquatting/wordlist.txt (BOO-197 — Slopsquatting-Wordlist)` + §`.github/workflows/slopsquatting-refresh.yml (BOO-197 — woechentlicher Wordlist-Refresh)`.
- `coverage-check.sh` (BOO-15) — Diff-Coverage-Gate: misst Coverage nur auf NEU hinzugefuegten Zeilen (`git diff --cached -U0`) gegen `coverage/coverage-final.json` (c8) bzw. `coverage.json` (pytest-cov). Drei Schwellwerte: `>=80%` Pass, `60-80%` Warnung mit Operator-Freigabe, `<60%` BLOCK. Eigenstaendiges Bash-Skript unter `.claude/hooks/coverage-check.sh`. Wird **NICHT** im Pre-Commit-Hook aufgerufen — Tests dauern zu lange und wuerden das 10s-Budget des Hooks sprengen. Stattdessen ruft der `/implement`-Skill den Hook in Schritt 6a-quart auf, nachdem die Test-Suite mit Coverage-Output gelaufen ist. Inhalt aus `references/file-templates.md` §`hooks/coverage-check.sh (BOO-15 — Coverage-Gate >=80% fuer neuen Code)`. Schrader Code Crash Kap. 3 §Production Readiness — Gate 2: Testabdeckung >=80 % auf neuem Code, nicht Gesamt-Coverage.

Registrierung:
```json
// {PROJECT_PATH}/.claude/settings.json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/spec-gate.sh\"" },
          { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/doc-version-sync.sh\"" }
        ]
      },
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/pre-edit-bodyguard.sh\"" }
        ]
      }
    ]
  }
}
```

> **Hinweis:** Der Claude-Code-Harness kann `.claude/settings.json` bei Permission-Grants auto-regenerieren und Hook-Sektionen stripppen. Als robusten Fallback: Hooks zusaetzlich in `.claude/settings.local.json` (gitignored) registrieren.

> **Klon-Portabilitaet (BOO-152):** Hook-Pfade verwenden `$CLAUDE_PROJECT_DIR` (vom Claude-Code-Harness auf das Projekt-Root gesetzt) statt eines absoluten Pfads. So funktioniert die committete `settings.json` in **jedem** Klon/Home unveraendert — Voraussetzung fuer Multi-User-VPS (Anhang P §3, `docs/runbooks/multi-user-vps.md`).

**Nativer Pre-Commit-Hook + `.githooks/` (BOO-152):** Den Quality-Gate-Layer-2-`pre-commit` (BOO-4) **zusaetzlich versioniert** unter `.githooks/pre-commit` ablegen (gleicher Inhalt), `scripts/install-hooks.sh` aus `references/file-templates.md` kopieren und einmal ausfuehren: `bash scripts/install-hooks.sh` (setzt `core.hooksPath=.githooks`). So bekommt jedes frische `git clone` das Pre-Commit-Gate mit **einem** Befehl — `.git/hooks/` wird nicht geklont. Die Claude-Code-Runtime-Hooks (`spec-gate`, `doc-version-sync`, `pre-edit-bodyguard`) kommen bereits committet mit `.claude/` + `settings.json`.

Hook-Test (probeweise):
```bash
cd {PROJECT_PATH}
echo "test" > test.txt && git add test.txt
git commit -m "test: {ISSUE_PREFIX}1 — should be blocked"
# Erwartet: Governance-Sperre
git restore --staged test.txt && rm test.txt
```

### 4.7 .env anlegen

Wenn `B.5 == Ja (existiert)`: Operator setzt `.env` selbst — Skill referenziert nur.

Wenn `B.5 == Nein`:
```
Ich habe .env.example angelegt. Bitte trage deine Keys in {PROJECT_PATH}/.env ein.
Variablen-Namen stehen in .env.example.
NIEMALS echte Keys im Chat nennen.
```

Warte auf Bestaetigung `done` bevor weiter.

### 4.8 Backlog-Adapter einrichten

Der Skill richtet zuerst den neutralen Backlog-Record ein (`docs/backlog/record-template.md` oder `specs/backlog-record-template.md`, je nach Projektlayout). Danach folgt optional der externe Adapter.

Wenn `BACKLOG_ADAPTER == linear`: Skill bietet an, Standard-Labels via Linear-MCP anzulegen:
- `architecture`, `bug`, `feature`, `refactor`, `docs`, `infra`
- Plus Add-on-Labels: `privacy` (wenn Privacy aktiviert), `compliance` (wenn Compliance aktiviert)

Wenn `BACKLOG_ADAPTER == github | jira | azure-devops | planner`: Operator bekommt Label-/Feldliste und Mapping-Tabelle zum manuellen oder adaptergestuetzten Anlegen.

Wenn `BACKLOG_ADAPTER == none`: Externe Tool-Einrichtung `SKIP`; neutrale Backlog-Records bleiben aktiv.

### 4.9 Erster Git-Commit

```bash
cd {PROJECT_PATH}
git add -A
git commit -m "v{VERSION_START} — Initial Governance Setup"
# Push nur wenn B.2 == Ja
git push -u origin main
```

### 4.4j Audit-Trail-Konfiguration (BOO-19)

Session-Logging ist in Claude Code per Default aktiv (`~/.claude/settings.json`). Dieser Schritt stellt sicher dass der Audit-Trail-Mechanismus im Projekt verankert ist.

**Schritte:**

1. `scripts/audit-trace.sh` aus `intentron/bootstrap/scripts/audit-trace.sh` in das Projekt-Verzeichnis kopieren:
   ```bash
   mkdir -p {PROJECT_PATH}/.claude/scripts
   cp {BOOTSTRAPPING_PATH}/bootstrap/scripts/audit-trace.sh {PROJECT_PATH}/.claude/scripts/
   chmod +x {PROJECT_PATH}/.claude/scripts/audit-trace.sh
   ```
2. Ins Spec-Template (`specs/TEMPLATE.md`) ist der `## Session-Referenz`-Block bereits enthalten — kein manueller Schritt nötig.
3. **GOVERNANCE.md** um Sektion `## Audit-Trail` ergänzen:
   ```markdown
   ## Audit-Trail

   Alle `/implement`-Sessions schreiben automatisch eine Session-Referenz ins Spec-File (BOO-19).
   Rekonstruktion: `bash .claude/scripts/audit-trace.sh {SPEC_ID}`

   **Retention-Policy (ADR anlegen unter `docs/domain/adrs/`):**
   - Session-Logs 90 Tage aufbewahren
   - Lesezugriff: nur Operator (lokales `~/.claude/`)
   - Sensitive Prompts mit Produktionsdaten: Projekt-Scope meiden — nicht in `/implement` eingeben
   ```

> **Issue-Referenz:** BOO-19, Schrader "Code Crash" Kap. 3 §Enterprise Governance — "Audit Trails: Jeder Prompt und jede Änderung werden für eine spätere Rekonstruktion protokolliert."

### 4.4k Branch-Protection-Setup (BOO-29)

Voraussetzung dafuer, dass kein Merge in `main` ohne gruene CI-Checks moeglich ist. Wird **nur ausgefuehrt wenn `B.2 == ja`** (GitHub-Repo angelegt) **und** Phase 4.9 (Erster Git-Commit + `git push -u origin main`) bereits gelaufen ist — die Branch-Protection braucht den remote `main`-Branch.

**Schritte:**

1. `scripts/setup-branch-protection.sh` aus `intentron/bootstrap/scripts/setup-branch-protection.sh` in das Projekt-Verzeichnis kopieren:
   ```bash
   mkdir -p {PROJECT_PATH}/.claude/scripts
   cp {BOOTSTRAPPING_PATH}/bootstrap/scripts/setup-branch-protection.sh {PROJECT_PATH}/.claude/scripts/
   chmod +x {PROJECT_PATH}/.claude/scripts/setup-branch-protection.sh
   ```

2. Skript ausfuehren — liest dynamisch alle `.github/workflows/*.yml` und baut die `required_status_checks[contexts][]`-Liste aus dem ersten `name:`-Feld jedes Workflows:
   ```bash
   cd {PROJECT_PATH}
   bash .claude/scripts/setup-branch-protection.sh
   ```

   Erwartete Detection-Set abhaengig von aktivierten Workflows (Phase 4.4 + 4.4c + 4.4d + 4.4g + Phase 6 D.5):

   | Workflow-Datei (BOO) | Detected Context |
   |----------------------|------------------|
   | `eslint.yml` (BOO-28) | `ESLint` |
   | `ruff.yml` (BOO-28) | `Ruff` |
   | `semgrep.yml` (BOO-4) | `Semgrep` |
   | `tests.yml` / `coverage.yml` (BOO-15) | `Tests` / `Coverage` |
   | `perf.yml` (BOO-16) | `Perf` |
   | `sonar.yml` (BOO-5/D.5) | `SonarQube` (oder `SonarCloud` je Workflow) |

   Workflows, die nicht existieren, werden aus `contexts[]` ausgelassen — das Skript wird nicht hart fehlschlagen, sondern protokolliert in `[INFO]`-Zeilen die tatsaechlich gefundenen Workflows.

3. Skript ruft intern (1:1 aus BOO-29):
   ```bash
   gh api -X PUT "repos/${OWNER}/${REPO}/branches/main/protection" \
     -F required_status_checks[strict]=true \
     -F required_status_checks[contexts][]=<dynamisch> \
     -F enforce_admins=false \
     -F required_pull_request_reviews[dismiss_stale_reviews]=true \
     -F required_pull_request_reviews[required_approving_review_count]=0 \
     -F restrictions=null \
     -F allow_force_pushes=false
   ```

   Idempotent — der PUT-Call ist Replace, also re-run-safe. Mehrfaches Ausfuehren ueberschreibt die Protection identisch.

4. **Voraussetzungen, die das Skript selbst prueft (mit Operator-Meldung bei Fehler):**
   - `gh --version` (CLI installiert?)
   - `gh auth status` (eingeloggt mit `repo`-Scope?)
   - `git remote get-url origin` (Remote vorhanden?)
   - Remote `main`-Branch existiert (`gh api repos/<owner>/<repo>/branches/main`)

   Bei Fehlschlag wird klar geloggt, was als naechstes zu tun ist (z.B. `gh auth login`, `git push -u origin main`) — kein stiller Fail.

5. Verifikation in GitHub-UI: `https://github.com/<owner>/<repo>/settings/branches` — Protection-Rule sollte aktiv sein mit den detected Checks.

6. Test-PR ohne gruene Checks oeffnen — Merge muss blockiert sein.

**Fallback ohne `gh` (BOO-123):** Ist `gh` nicht installiert/authentifiziert, schlaegt die Automatisierung fehl — Branch-Protection dann **manuell** setzen (gilt **unabhaengig** von der Sonar-Wahl):
- **Empfohlen:** erst `gh` einrichten (GitHub-Connect-Runbook, HANDBUCH Anhang Y), dann `setup-branch-protection.sh` erneut.
- **Oder im Browser** unter `…/settings/branches` → „Add rule" fuer `main`: **Require a pull request before merging** (1 Approval), **Require status checks to pass** (die in der Detection-Tabelle gelisteten Checks aus den vorhandenen Workflows auswaehlen), **Restrict who can push**. Entspricht 1:1 dem, was das Skript via API setzt.

> **Branch-Protection ≠ SonarQube (BOO-123):** Branch-Protection ist **nicht** an SonarQube gekoppelt. `SonarCloud` ist nur **einer** von mehreren dynamisch aus den Workflows ermittelten Required Checks (siehe Detection-Tabelle). Ohne SonarQube laeuft Branch-Protection mit den uebrigen Checks (ESLint/Ruff/Semgrep/Tests/…) genauso. Der frueher beobachtete „manuelle Zwang" kam von **fehlendem `gh`**, nicht von Sonar.

Bei `B.2 == nein/c` (kein GitHub gewuenscht): Phase 4.4k komplett skippen — Branch-Protection ist GitHub-spezifisch, hat kein Pendant auf lokalen oder Self-Hosted-Setups ohne GitHub.

> **Issue-Referenz:** BOO-29. Quelle: `scripts/setup-branch-protection.sh` (v3.18.0, 2026-05-12). Migration fuer Bestands-Projekte: `references/migration-checklist-v1-to-v2.md` §BOO-29.

### 4.4l Backlog-Workflow-States + Repo-Integration (BOO-30/54, manueller Operator-Schritt)

**Nur fuer externe Backlog-Adapter ausfuehren.** Bei `BACKLOG_ADAPTER == none` ueberspringen und im Abschlussbericht `SKIP` dokumentieren.

**Klare Trennung:**
- **Automatisiert (durch /bootstrap):** Issue-Template wird in Phase 4.3 mit DoD-Pflichtsektion gerendert (siehe oben). DoD-Checkliste ist in `.claude/ISSUE_WRITING_GUIDELINES.md` v3.1 enthalten und im Issue-Template `.github/ISSUE_TEMPLATE/story.yml` ueber `migrate_boo_27()` verankert.
- **Manuell/Adapter pro Projekt:** Workflow-States und Repo-Integration im gewaehlten Tool anlegen. Der neutrale Backlog-Record bleibt die Framework-Sprache; das Tool ist nur Adapter.

**Operator-Anleitung:** Skill listet hier den Checkpoint und das Mapping. Tool-spezifische Details gehoeren in Adapter-Doku, nicht in den Framework-Vertrag.

**Workflow-States (1:1 aus BOO-30):**

| State | Bedeutung | Auto-Transition |
|---|---|---|
| Backlog | Triage | initial |
| In Progress | Skill arbeitet, lokale Gates iterativ | manuell |
| In Review | PR offen, CI laeuft | auto bei PR-Open |
| QA Failed | CI rot, Story re-opened | manuell oder Webhook |
| Done | PR gemerged, alle Checks gruen | auto bei PR-Merge |
| Cancelled | verworfen | manuell |

**Adapter-Mapping:**

| Adapter | Externe ID | State-Mapping | Repo-Integration |
|---|---|---|---|
| Linear | Linear-Key optional, Framework-ID bleibt `{ISSUE_PREFIX}XXX` | Workflow-States im Team | GitHub-Integration in Linear |
| GitHub Issues | Issue-Nummer optional | Labels/Projects oder Issue-Status | nativ im Repo |
| Jira | Projekt-Key optional | Jira-Workflow | Development-Integration |
| Azure DevOps | Work Item ID optional | Boards-State | Repos/Pipelines-Verknuepfung |
| Planner | Task-ID optional | Buckets/Labels | manuell |
| none | nur `{ISSUE_PREFIX}XXX` | Markdown-Status | keine |

**Repo-Integration (falls vom Adapter unterstuetzt):**
1. Adapter mit Projekt-Repo verbinden.
2. Auto-Recognition wirkt fuer:
   - Branch-Names mit `{ISSUE_PREFIX}-XX`-Prefix (z.B. `BOO-30-feature-foo`)
   - PR-Titel mit `{ISSUE_PREFIX}-XX`
   - Commit-Messages mit `{ISSUE_PREFIX}-XX`
   - PR-Body mit `Closes {ISSUE_PREFIX}-XX`
3. PR-Open setzt Issue → `In Review`, Merge setzt Issue → `Done`.

**Checkpoint Operator:**
- [ ] 6 Workflow-States im Backlog-Adapter angelegt oder als `SKIP` begruendet (Namen exakt: `Backlog`, `In Progress`, `In Review`, `QA Failed`, `Done`, `Cancelled`)
- [ ] Repo-Integration mit Projekt-Repo verbunden oder als `SKIP` begruendet
- [ ] Test-Story mit Branch `{ISSUE_PREFIX}-XX-test` erstellt — PR-Open transitioniert Issue auf `In Review`

> **Issue-Referenz:** BOO-30/54. Quelle: `references/issue-writing-guidelines-template.de.md` v3.1 + neutraler Backlog-Record. Migration fuer Bestands-Projekte: `references/migration-checklist-v1-to-v2.md` §BOO-30 (Issue-Template-Erweiterung wird automatisch nachgezogen, Tool-Adapter-Setup bleibt projektspezifisch).

### 4.4m Token-Effizienz-Setup (BOO-84)

**Zweck:** Aktiviert das Modell-Routing pro Skill + Prompt-Caching fuer das neue Projekt. Folgt dem Designentscheid Leichtgewichtigkeit: Empfehlung statt Hard-Lock, Operator-Override jederzeit moeglich.

**Schritte:**

1. **Model-Routing-Sektion in `CLAUDE.md` einfuegen.** Das Template aus `references/file-templates.md` §`CLAUDE.md (Minimum)` enthaelt die Sektionen "Model-Routing-Policy (BOO-84)" und "Prompt-Caching (BOO-84)" bereits — beim Rendern automatisch uebernommen.
2. **`model-tiers.json` referenzieren.** Das zentrale Mapping `bootstrap/references/model-tiers.json` ist Framework-Owned und wird nicht ins Projekt kopiert. Skills lesen es per Framework-Pfad. Operator findet es bei Fragen via `intentron/bootstrap/references/model-tiers.json`.
3. **`meta.json`-Schema erweitern.** Implement-Skill (Schritt 6f-bis) schreibt ab jetzt zusaetzliche Felder: `input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`, `model_used`, `skill_invoked`, `story_id`, `iteration_label`, plus `override_audit: []` Array fuer Override-Eintraege. Siehe `implement/SKILL.md` §6f-bis.
4. **Override-Praezedenz dokumentieren.** Operator wird im Briefing informiert: **CLI-Flag `--model <tier>` > CLAUDE.md `model_overrides:` > Skill-Default-Tier**. Jeder Override schreibt einen Audit-Trail-Eintrag.
5. **Pflicht-Bleibt-Opus dokumentieren.** Security-relevante Skills (`architecture-review`, `cloud-system-engineer`, `/implement` Schritt 6e) duerfen nicht automatisch downgrade-en. Operator-Override moeglich, aber im Audit-Trail festgehalten — Audit-Argument fuer FINMA/BaFin/MaRisk.

**Checkpoint Operator:**
- [ ] `CLAUDE.md` enthaelt Sektion "Model-Routing-Policy (BOO-84)"
- [ ] `CLAUDE.md` enthaelt Sektion "Prompt-Caching (BOO-84)"
- [ ] Operator weiss, dass `bootstrap/references/model-tiers.json` (Framework-Pfad) die Source of Truth fuer Tier-zu-Version + Pricing ist
- [ ] `meta.json` wird beim ersten `/implement`-Lauf um die neuen Felder erweitert (automatisch durch Skill)

> **Issue-Referenz:** BOO-84. Quelle: `references/file-templates.md` §`CLAUDE.md (Minimum)`, `references/model-tiers.json`. Migration fuer Bestands-Projekte: `references/migration-checklist-v1-to-v2.md` §BOO-84.

> **Designentscheid-Hinweis:** Diese Story folgt dem INTENTRON-Leitsatz "leichtgewichtig + pragmatisch, ohne Security-Kompromisse". Modell-Routing ist eine Empfehlung mit Override-Pfad — kein Hard-Lock. Security-Skills bleiben dokumentiert auf Opus (Audit-Pflicht).

### 4.4n Privacy-Setup (BOO-69, nur wenn Privacy-Add-on aktiv)

**Zweck:** Bei aktivem Privacy-Add-on (siehe A.4 `[x] Privacy / DSGVO`) richtet diese Phase die Datenschutz-Infrastruktur ein. Spiegelt 1:1 das Security-Pattern: `dpo`-Standalone-Skill installiert, `PRIVACY.md` aus Template gerendert, `personal-data-paths.json` als Pendant zu `sensitive-paths.json` angelegt. Bootstrap fuegt nichts hinzu, wenn das Add-on nicht aktiv ist.

**Vorbedingung:** `ADDONS` enthaelt `"Privacy / DSGVO"`. Sonst ueberspringen.

**Schritte:**

1. **DPO-Skill aus Framework-Bundle installieren** (BOO-74, analog `security-architect`):
   - Quelle: `$SKILL_SRC/dpo/` (Framework-Repo, in Phase 5 bereits gecloned). Ziel: `~/.claude/skills/dpo/` (global) bzw. `{TARGET_SKILLS_DIR}/dpo/` je nach `RUNTIME_TARGET`. Nicht-destruktiv: vorhandene Installation bleibt unveraendert.
   - Keine externe Repo-Wahl mehr — der Skill kommt aus demselben Framework-Repo wie bootstrap/ideation/implement. Master des Skills bleibt `claudecodeskills` (Mirror-Konvention, siehe `references/skills-setup.md`).
   - Hinweis: DPO bleibt **gleichzeitig** global verfuegbar fuer andere Projekte. INTENTRON macht keinen exklusiven Anspruch.
2. **security-architect aus Framework-Bundle installieren** (Voraussetzung fuer DPO ↔ security-architect-Zusammenspiel) — gleiche Quelle `$SKILL_SRC/security-architect/`.
3. **`PRIVACY.md` rendern** aus `references/privacy-template.md` (DE) oder `.en.md` (EN) je nach Projekt-Sprache. Platzhalter `{{PROJECT_NAME}}`, `{{VERSION_START}}`, `{{TODAY}}` ersetzen. Pflicht-Sektionen (Verarbeitungsverzeichnis, Loeschkonzept) erhalten Skelett — Operator fuellt nach.
4. **`.claude/personal-data-paths.json` und/oder `.codex/personal-data-paths.json`** aus `references/file-templates.md` §`personal-data-paths.json` rendern. Default-Patterns (`**/user*`, `**/customer*`, `**/profile*`, `**/*pii*`, `**/auth/profile/**`, `**/billing/**`). Operator-Hinweis: Pattern-Liste projektspezifisch ergaenzen.
5. **Backlog-Label `privacy`** im konfigurierten Backlog-Adapter (Linear / GitHub Issues / MS Planner / Markdown-Backlog) anlegen, falls noch nicht vorhanden.
6. **`ARCHITECTURE_DESIGN.md`** um Privacy-Sektion-Verweis ergaenzen: "Privacy-Anforderungen: siehe `PRIVACY.md` und DPO-Skill-Output unter `dpia/`."
7. **`environment.json`** um optionales Feld `privacy_audit_cadence: 4` (Standard: alle 4 Sprints DPO-Audit) erweitern.

**Checkpoint Operator:**

- [ ] DPO-Skill global verfuegbar (`~/.claude/skills/dpo/SKILL.md` existiert)
- [ ] security-architect-Skill global verfuegbar
- [ ] `PRIVACY.md` im Projekt-Root gerendert mit Projekt-Platzhaltern
- [ ] `.claude/personal-data-paths.json` und/oder `.codex/personal-data-paths.json` angelegt
- [ ] Backlog-Label `privacy` existiert
- [ ] `ARCHITECTURE_DESIGN.md` verweist auf `PRIVACY.md`
- [ ] `environment.json.privacy_audit_cadence` gesetzt (Default 4)

> **Wichtig:** `PRIVACY.md` wird NICHT in `.gitignore` eingetragen — Audit-Trail-Pflicht. Datenschutz-Dokumentation gehoert ins Git. **`dpia/*.md`** ist ggf. sensibler — Operator entscheidet, ob die DPIA-Dateien committed oder in einem separaten privaten Repo gehalten werden.

> **Issue-Referenz:** BOO-69. Quelle: `references/privacy-template.md` + `references/file-templates.md` §`personal-data-paths.json`. Migration fuer Bestands-Projekte: `references/migration-checklist-v1-to-v2.md` §BOO-69. HANDBUCH-Hintergrund: Anhang O Privacy by Design.

### 4.4n-bis EU-AI-Act-Setup (BOO-101/105, nur wenn EU-AI-Act-Add-on aktiv)

**Zweck:** Bei aktivem EU-AI-Act-Add-on (A.4 `[x] EU AI Act`) wird der EU-AI-Act-Kontrollkatalog **konditional** aktiviert und der KI-System-Steckbrief gerendert. Strikt opt-in: ohne dieses Add-on passiert nichts, und der Katalog laeuft NICHT im dpo-Audit anderer Projekte.

**Vorbedingung:** `ADDONS` enthaelt `"EU AI Act"` **und** `"Privacy / DSGVO"` (KI mit Kundendaten = auch Datenschutz; Privacy-Phase 4.4n zuerst). Sonst ueberspringen.

**Schritte:**

1. **Katalog ins Projekt-Overlay kopieren:** `$SKILL_SRC/dpo/controls/optional/eu-ai-act.yml` → `.claude/dpo/controls/eu-ai-act.yml`. **Erst dadurch** laedt der `dpo-audit.py`-Runner den Katalog (Overlay-Glob ist rekursiv) — und zwar nur fuer dieses Projekt. (Im Framework liegt er bewusst unter `controls/optional/`, das der Runner NICHT automatisch laedt.)
2. **`AI_SYSTEM.md` rendern** aus `$SKILL_SRC/dpo/references/ai-system-template.md` ins Projekt-Root. Abschnitte: Zweck, Risikoklasse, betroffene Daten, Transparenz, Human Oversight, Logging, GPAI, offene Punkte. Operator fuellt nach — **KEINE Rechtsberatung**.
3. **`ARCHITECTURE_DESIGN.md`** um Verweis ergaenzen: "EU-AI-Act-Anforderungen: siehe `AI_SYSTEM.md`; Compliance-Status via dpo-AUDIT."
4. **Backlog-Label `ai-act`** anlegen (optional, fuer Folge-Stories aus REVIEW-NEEDED).

**Checkpoint Operator:**

- [ ] `.claude/dpo/controls/eu-ai-act.yml` im Projekt vorhanden (Overlay)
- [ ] `AI_SYSTEM.md` im Projekt-Root gerendert
- [ ] `ARCHITECTURE_DESIGN.md` verweist auf `AI_SYSTEM.md`
- [ ] (optional) Backlog-Label `ai-act`

> **Designentscheid (BOO-105):** Der Katalog liegt unter `dpo/controls/optional/` (nicht `dpo/controls/`), damit der Runner ihn NICHT framework-weit automatisch laedt. So laeuft die EU-AI-Act-Pruefung garantiert **nur** in Projekten, die das Add-on gewaehlt haben — kein Rauschen (AI_SYSTEM.md-GAP) in Nicht-KI-Projekten. Der dpo-AUDIT meldet Urteils-Punkte (verbotene Praktiken, Hochrisiko-Einstufung, GPAI) als REVIEW-NEEDED; die Entscheidung liegt bei Operator/Legal.

> **Issue-Referenz:** BOO-101 (Katalog + Template), BOO-105 (konditionales Opt-in + Phase 4.4n-bis). Quelle: `$SKILL_SRC/dpo/controls/optional/eu-ai-act.yml` + `$SKILL_SRC/dpo/references/ai-system-template.md`.

> **Designentscheid-Hinweis:** Privacy ist optional, aber wenn aktiv: voll operationalisiert. Spiegelt das Security-Pattern (security-architect + SECURITY.md + sensitive-paths). Operator muss kein DPO-Wissen mitbringen — der Skill stellt die richtigen Pruef-Fragen. Rechtsempfehlungen aussprechen ist nicht Skill-Aufgabe, Pruef-Fragen sind.

### Phase 4.10: Domain Deep Research (PFLICHT)

**Zweck:** Domainwissen persistieren bevor Stories geschrieben werden. KI-Operator-Teams haben kein verteiltes Fach-Team-Wissen — dieser Schritt kompensiert das systematisch (Schrader Kap. 2 §Differenzierungskrise).

**Schritte:**

1. Operator fragen: "Welche Branche / welcher fachliche Domain-Kontext gilt fuer dieses Projekt?"
2. `/research` mit dem Projektthema aufrufen — DEEP-Modus:
   - Fachbegriffe + Glossar
   - Regulatorik (DSGVO/BDSG/nDSG, PSD2, MiFID, HIPAA — je nach Branche)
   - User-Personas + Stakeholder
   - Branchenmetriken + KPIs
   - Wettbewerber + Marktstandards
3. Output nach `Research/Domain-Overview.md` schreiben (Frontmatter: `source: claude`, `type: domain-research`)
4. `docs/domain/` Ordner anlegen mit `README.md`-Skelett:

```markdown
# Domain Context

Kuratierte Schluessel-Begriffe fuer [Projektname]. Ein Begriff pro Datei unter `docs/domain/`.
Format: 1 Datei pro Schluessel-Begriff, <30 Zeilen, Beispiele + Gegenbeispiele.

## Bekannte Begriffe
<!-- Wird bei /ideation und /implement erweitert -->

| Begriff | Datei | Beschreibung |
|---------|-------|-------------|
```

5. Fuer jeden Schluessel-Begriff aus der Research eine eigene Datei anlegen: `docs/domain/{begriff}.md`
   Template pro Begriff-Datei:
   ```markdown
   # {Begriff}
   
   **Definition:** [1-2 Saetze]
   
   **Beispiel:** [konkretes Praxis-Beispiel]
   
   **Gegenbeispiel / Abgrenzung:** [was es NICHT ist]
   
   **Regulatorik:** [falls relevant — Norm/Gesetz + Kernpflicht]
   ```

**Nicht optional.** Auch wenn Operator sagt "ich kenn die Branche": Research-Schritt kostet 5–10 Min und spart spaeter Stunden an Story-Nacharbeit durch fehlendes Fachvokabular.

Phase-4-Checkpoint: Zusammenfassung der angelegten Dateien.

---

## Phase 5: Skills installieren

Lies `references/skills-setup.md` fuer Details.

Skills werden aus dem **Framework-Repo** via `git clone` in einen Temp-Ordner geholt und je nach `RUNTIME_TARGET` kopiert:
- `claude-code` → `{PROJECT_PATH}/.claude/skills/`
- `codex` → `{PROJECT_PATH}/.codex/skills/`
- `cross-tool` / `unknown` → beide Zielpfade, identischer Skill-Stand

```bash
# Temp-Ordner fuer Skill-Quelle — Framework-Repo (BOO-74: alle Bundle-Skills + dpo + security-architect liegen hier)
SKILL_SRC=$(mktemp -d)
git clone --depth 1 https://github.com/vibercoder79/intentron "$SKILL_SRC"
```

> **Operator-Hinweis (BOO-121):** Halte den lokalen `bootstrap`-Skill aktuell (`git pull` im intentron-Klon). Eine veraltete Version kann Bundle-Skills (insb. `intent`) noch nach der **Pre-BOO-74-Struktur** aus `claudecodeskills` sourcen — alle Bundle-Skills kommen heute **ausschliesslich aus intentron**. Regression-Schutz: `bootstrap/scripts/check-skill-sources.sh` (CI: `skill-sources.yml`).

### Repo-Struktur (BOO-74)

Das `intentron`-Repo enthaelt **alle** Bundle-Skills flach als Top-Level-Ordner — keine `intentron/`-Verschachtelung mehr (das war die alte `claudecodeskills`-Struktur):

- **`$SKILL_SRC/<skill>/`** — alle Framework-Skills: `architecture-review`, `backlog`, `bootstrap`, `cloud-system-engineer`, `grafana`, `ideation`, `implement`, `intent`, `knowledge-onboarding`, `pitch`, `sprint-review`, `visualize` **plus `dpo` und `security-architect`** (vendored, BOO-74). `knowledge-onboarding` ist Bestands-Doku-Onboarding (BOO-137) — nur Installation, kein Auto-Run.

**Nicht im Framework-Repo:** eigenstaendige Allzweck-Skills wie `research`, `design-md-generator`, `setup-checklist`, `skill-creator` bleiben im `claudecodeskills`-Repo. Sie werden nur auf Wunsch ergaenzend gecloned (siehe optionale Zusatzfrage unten).

> **Master vs. Mirror (BOO-74):** `dpo` und `security-architect` werden im `claudecodeskills`-Repo gepflegt (Master, via `publish_skill.py`) und ins Framework-Repo **gespiegelt** (Vendoring). Bei einem Skill-Update gilt: erst Master in `claudecodeskills` aktualisieren, dann den Framework-Mirror nachziehen. Details: `references/skills-setup.md` §Sync-Konvention.

### Skill-Auswahl

```
Welche Skills installieren?
  a) Minimum (ideation, implement, backlog, intent)
  b) Standard (+ architecture-review, sprint-review, security-architect, dpo, knowledge-onboarding)
  c) Voll (alle Framework-Skills: + grafana, cloud-system-engineer, visualize, pitch)
  d) Manuell auswaehlen
```

> **Hinweis (BOO-69/74):** `dpo` und `security-architect` sind ab "Standard" dabei, weil das Privacy-Add-on (A.4) und die Security-Dimension auf sie angewiesen sind. Bei aktivem Privacy-Add-on werden beide unabhaengig von der Skill-Auswahl installiert (siehe Phase 4.4n).

### Optionale Allzweck-Skills aus claudecodeskills

```
Zusaetzliche Allzweck-Skills aus claudecodeskills ergaenzen?
(research, design-md-generator, setup-checklist, skill-creator — nicht im Framework-Bundle)
[ja / nein (default)]
```

Bei `ja`: `claudecodeskills` ergaenzend in einen zweiten Temp-Ordner clonen und die gewaehlten Top-Level-Skills von dort kopieren.

### Kopieren

Alle Framework-Skills liegen flach als Top-Level-Ordner — keine Sub-Folder-Unterscheidung mehr noetig:

```bash
for skill in $SELECTED_SKILLS; do
  SRC_PATH="$SKILL_SRC/$skill"   # Framework-Repo: alles Top-Level
  # Zielpfade aus RUNTIME_TARGET ableiten:
  # claude-code => .claude/skills
  # codex => .codex/skills
  # cross-tool/unknown => beide
  cp -R "$SRC_PATH" "{PROJECT_PATH}/{TARGET_SKILLS_DIR}/$skill"
done

# Optionale Allzweck-Skills (nur bei "ja" oben):
if [[ "$ADD_GENERAL_SKILLS" == "yes" ]]; then
  GENERAL_SRC=$(mktemp -d)
  git clone --depth 1 https://github.com/vibercoder79/claudecodeskills "$GENERAL_SRC"
  for skill in $SELECTED_GENERAL_SKILLS; do
    cp -R "$GENERAL_SRC/$skill" "{PROJECT_PATH}/{TARGET_SKILLS_DIR}/$skill"
  done
  rm -rf "$GENERAL_SRC"
fi
```

Ergebnis: Alle Skills landen **flach** in `.claude/skills/<skill>/` und/oder `.codex/skills/<skill>/`.

### Projekt-spezifische Anpassung (generisch, nicht trading-spezifisch)

- `.claude/ISSUE_WRITING_GUIDELINES.md` wird aus `references/issue-writing-guidelines-template.md` gerendert (Issue-Prefix eingesetzt)
- `implement/references/change-checklist.md` enthaelt generische Change-Typen — keine projekt-spezifische Anpassung noetig. Projekt-spezifische Spezial-Checklisten koennen spaeter via `/skill-creator` ergaenzt werden.

### Aufraeumen

```bash
rm -rf "$SKILL_SRC"
```

Phase-5-Checkpoint: Installierte Skills auflisten.

---

## Phase 6: Block D — Optional-Komponenten

Lies `references/optional-components.md` fuer die Implementation-Details.

> **Operator-Hinweis (BOO-30/54):** Block D ist die richtige Stelle, um den manuellen Backlog-Adapter aus Phase 4.4l zu finalisieren — Workflow-States anlegen + Repo-Integration aktivieren — bevor die ersten Stories ueber `/ideation` produziert werden. Issue-Template-Rendering selbst ist bereits in Phase 4.3 automatisiert (DoD-Pflichtsektion). Bei `BACKLOG_ADAPTER=none` bleibt der neutrale Backlog-Record die fuehrende Form.

Jede Frage einzeln mit klarer Empfehlung und Default:

### D.1 Self-Healing-Agent

```
Self-Healing-Agent einrichten?
(Cron alle 15 min: prueft Dok-Versionen, Datei-Integritaet, sendet Alerts)

Empfohlen: ab mehreren Mitwirkenden oder wenn Doku-Drift kritisch ist.
[ja / nein (default)]
```

Wenn `ja`: `agents/self-healing.js` aus `references/self-healing-template.js` rendern + Cron-Eintrag generieren.

### D.2 DocSync zum Obsidian-Vault

```
DocSync zum Obsidian-Vault?
(Bei jedem /implement werden Component-Docs im Vault mit-aktualisiert)

Kein Cron — laeuft als Manuelle-Aufforderung via implement-Skill T_last.
Empfohlen wenn Obsidian-Vault angegeben.
[ja (default wenn Vault) / nein]
```

Wenn `ja`: `lib/doc-sync.js` aus `references/doc-sync-template.js` rendern + Mapping Repo → Vault.

### D.3 Automation-Daemon (Backlog-Webhook-Listener)

```
Automation-Daemon?
(Vollautomatische Story-Umsetzung ohne Operator-Freigabe — Backlog-Adapter-Webhook triggert /implement)

Nur fuer fortgeschrittene Setups mit externem Backlog-Adapter. Sicherheits-Implikationen beachten.
[ja / nein (default)]
```

Wenn `ja`: Setup-Schritte fuer passenden Adapter-Webhook + Daemon.

### D.4 Learning-Loop-Level

Lies `references/learning-loop.md` fuer das vollstaendige Design.

```
Learning-Loop aktivieren?
Der Loop erfasst systematisch: was funktioniert hat, was nicht, naechste Experimente.
Trigger: /sprint-review. Speicherort: journal/ + optional Obsidian.

  L1 — Einfach     (learnings.md, Bullet-Points — empfohlen fuer Solo-Projekte)
  L2 — Strukturiert (Sprint-Journal mit Frontmatter — empfohlen ab 10+ Sprints)
  L3 — SQLite      (quantitative Metriken — empfohlen ab 50+ Sprints)
  nein             (keine Lessons-Learned dokumentieren)

Default: L1. Welches Level?
```

Wenn `L1/L2/L3` gewaehlt:
- `journal/`-Struktur entsprechend anlegen
- `.learning-loop`-Config im Repo (Level speichern)
- Wenn Obsidian aktiv: `04 Ressourcen/{PROJECT_NAME}/learnings.md` als Cross-Link vom PMO-Hub

Learning-Loop wird von `sprint-review` gefuettert (Pflicht-Schritt am Ende des Reviews) und von `ideation` bei Story-Erstellung gelesen (Anti-Pattern-Warnung).

### D.5 SonarQube Cloud

```
SonarQube Cloud aktivieren?
(Code-Qualitaets-Dashboard: Bugs, Smells, Security-Hotspots, Coverage-Trends nach jedem Push)

Kosten: Public Repos gratis. Private Repos ab ~10 EUR/Monat.
[Mac] Lokal: SonarLint VS-Code Connected Mode.
[VPS] Nur CI-Gate — kein IDE-Plugin.

[ja] Skill generiert sonar-project.properties + .github/workflows/sonar.yml
[nein] (default) — kann spaeter nachgezogen werden
```

Wenn `ja`: Lies `references/optional-components.md §D.5` fuer Implementation-Details inkl. Verify-Schritt. **SonarCloud-seitig (Account/Org/Token) ist manuell** — Schritt-fuer-Schritt im **SonarCloud-Setup-Runbook (HANDBUCH Anhang AA, zwei Szenarien)**; erster `git push` triggert `sonar.yml`.

> ⚠️ **Warnung bei `ja` (BOO-122):** Mit `sonar.yml` wird **`SonarCloud` automatisch ein Required Status Check** (Branch-Protection, Phase 4.4k, baut die Checks dynamisch aus allen Workflows) — **ohne gruenen Sonar-Lauf kein Merge**. Fehlt Account/Token, failt der Job rot und **dein erster PR ist blockiert**. Daher:
> - **Jetzt einrichten:** das SonarCloud-Setup-Runbook (BOO-119, HANDBUCH **Anhang AA**, zwei Szenarien) durchlaufen (Account/Org/Token + `SONAR_TOKEN`-Secret), **dann** `ja`.
> - **Oder spaeter aktivieren:** vorerst `nein`, Sonar ist jederzeit nachziehbar.
> - **Sonar wieder entfernen** (falls schon scaffolded): `.github/workflows/sonar.yml` loeschen, `tools_available.sonarqube_cloud = false` setzen, Branch-Protection neu setzen (`setup-branch-protection.sh` — `SonarCloud` faellt dann aus den Required Checks).
>
> **Optional-Abfrage:** „Sonar-Setup jetzt durchfuehren — oder nur **scaffolden ohne** Required-Check (`sonar.yml` anlegen, aber erst nach gruenem Erst-Lauf in die Branch-Protection aufnehmen)?"

Wenn `nein`: `tools_available.sonarqube_cloud = false` in `.claude/environment.json`.

### D.6 Self-Hosted-Runner (BOO-46, nur wenn Performance-Gate aktiv)

Wenn `STACK_CHOICE` Backend-Anteil hat (`a`, `c`, `d`) UND Performance-Gate aus BOO-16 aktiv ist:

```
Self-Hosted-Runner fuer Performance-Tests aktivieren?
  (Folgeschnitt zu BOO-16. GitHub-Hosted-Runner haben +/-30%% Varianz, daher
   BOO-16-Default-Threshold 20%%. Self-Hosted-Runner mit reservierten Ressourcen
   reduzieren Varianz auf ~5%% — dann kann der Threshold auf 10%% geschaerft werden.)

  Kosten: ein Hostinger-VPS-Beifahrer oder dedizierter Mac-Mini.
  Aufwand: Runner-Software installieren (Step-by-Step in HANDBUCH Anhang I).

  [ja] HANDBUCH §Self-Hosted-Runner-Setup mit Step-by-Step + migrate_boo_46() schaerft perf.yml
  [nein] (default) — GitHub-Hosted bleibt aktiv, Threshold bleibt 20%%
```

Wenn `ja`: Reine HANDBUCH-Verweise (kein Auto-Setup, weil VPS-Installation Operator-Hoheit ist). `migrate_boo_46()` patcht spaeter `perf.yml` (`runs-on: ubuntu-latest` -> `self-hosted`, Threshold 1.20 -> 1.10) wenn Operator den Runner installiert hat.
Wenn `nein`: kein Eintrag in `environment.json`, kein perf.yml-Patch.

### D.7 Projekt-spezifische MCP-Server (BOO-125, nur bei STACK = Frontend/Full-Stack)

Wenn `STACK_CHOICE = b` (Frontend) oder `c` (Full-Stack):

```
Weitere projekt-spezifische MCP-Server einrichten?
  Vorschlag fuer Web/Frontend: Vercel, Apify — oder eigene Quelle angeben.
  [ja / nein (default)]
```

Bei `ja`:
- Gewaehlte MCP-Server gemaess `references/mcp-setup.md` registrieren (Endpoint / Auth / Scope).
- Hinweis: die **nutzende Story/Skill** deklariert den MCP in ihrem `requires_toolsets`-Block (HANDBUCH §requires_toolsets) — der Bootstrap richtet nur den Server ein, nicht die Nutzung.
- `tools_available` in `.claude/environment.json` entsprechend ergaenzen (vom `verify-setup.sh` gelesen).

**Klarstellung Vercel (haeufige Verwechslung):**
- **Deploy** laeuft ueber die **Vercel↔GitHub-Integration** (Git-Push → Auto-Deploy) — dafuer ist **kein** MCP noetig.
- Der **Vercel-MCP** dient nur der **Agent-Interaktion**: Deployment-Logs / Env / Config lesen + analysieren. Optional.

**Frontend-Combo:** „Node-Backend + Frontend" wird sauber ueber `c) Full-Stack` abgebildet (Backend + Frontend in einem Projekt) — kein eigener Kombi-Pfad noetig. `b) Frontend` ist das reine Frontend ohne eigenes Backend.

Bei `nein`: kein MCP-Eintrag; projekt-spezifische MCPs koennen jederzeit spaeter via `references/mcp-setup.md` ergaenzt werden.

Phase-6-Checkpoint: Optional-Komponenten-Status inkl. Provider-Postflight und bewusst abgewaehlter Optionen.

---

## Phase 7: Finalisierung

Lies `references/global-registry-update.md` fuer die genaue Pfad-Liste.
Lies `references/project-documentation-ssot.md` fuer die SSoT-Varianten. Phase 7 finalisiert nicht nur SecondBrain, sondern immer die gewaehlte Projekt-Dokumentations-SSoT.

### 7.1 Projekt-Dokumentations-SSoT finalisieren

- `obsidian`: `{OBSIDIAN_VAULT}/<Projektbereich>/{PROJECT_NAME}/` anlegen oder bestaetigen.
- `repo-docs`: `{PROJECT_PATH}/docs/project/` anlegen.
- `external-dms`: `{PROJECT_PATH}/docs/project/DOCUMENTATION_SSOT.md` mit URL/Pfad und Zugriffshinweisen anlegen.
- `undecided`: `{PROJECT_PATH}/docs/project/` als Fallback anlegen und TODO fuer finale SSoT aufnehmen.

Standard-Artefakte erzeugen oder verlinken:

- Project Hub / PMO Hub
- Developer Onboarding
- Projekt-Governance
- Zielarchitektur / Target Architecture
- Backlog-Uebersicht oder Backlog-Verweis
- `Decisions/`, `Meetings/`, `Research/`, `Assets/`, `Archive/`

### 7.2 SecondBrain-Integration (wenn Documentation-SSoT == Obsidian)

- `{OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/` anlegen
- `{PROJECT_NAME} - PMO HUB.md` mit Projekt-Frontmatter, Phase-Tabelle, Backlog-Link, Referenzen-Block
- `Developer Onboarding.md`, `Projekt-Governance.md`, `Zielarchitektur.md`, `Backlog.md` anlegen oder verlinken
- `Components/`, `Decisions/`, `Meetings/`, `Research/`, `Assets/`, `Archive/` Ordner anlegen
- `Architektur-Vorgaben.md` Skelett (wird bei /ideation mit Research-Konsolidierung gefuellt)
- Eintrag in `{OBSIDIAN_VAULT}/00 Kontext/Projekte.md` (Projekt-Index)

### 7.3 Globale Registry (~/.claude/)

Wenn der Operator in `~/.claude/CLAUDE.md` eine Projekt-Tabelle hat:
- Projekt-Zeile ergaenzen (Name, Pfad, GitHub, Obsidian-Pfad, Sprint-Review-Frequenz)
- Skill listet Operator die Zeile vor, der bestaetigt den Einfuegepunkt

### 7.3b Setup-Verifikation (BOO-79)

Vor dem finalen Commit den **Proof** liefern, dass das Geruest komplett + funktionsfaehig ist:

1. `references/verify-setup.sh` nach `{PROJECT_PATH}/scripts/verify-setup.sh` kopieren (falls in Phase 4 noch nicht geschehen).
2. Im Projekt-Root ausfuehren: `bash scripts/verify-setup.sh`.
3. Das Skript prueft read-only: environment.json, Toolchain-Erreichbarkeit, Git-Hooks (pro Repo!), Kern-Artefakte (CONVENTIONS.md, ARCHITECTURE_DESIGN.md, specs/, journal/), Privacy-Add-on (falls aktiv), Backlog-Adapter. Ausgabe PASS/WARN/FAIL + Exit-Code (1 bei FAIL).
4. **FAIL-Punkte vor dem Abschluss beheben.** WARN-Punkte dem Operator vorlegen (oft bewusst, z.B. kein Test-Framework in einem Doku-Projekt).

**Tool-Install-Fuehrung bei fehlenden Tools (BOO-115):** Meldet `verify-setup.sh` (oder das Pre-Flight-Gate, Phase 0.2) ein fehlendes Tool, gibt der Bootstrap **Tool-Name + Deeplink** aus — nicht nur WARN — und nutzt den `INSTALL_DEFAULT` aus A.7:

- **`INSTALL_DEFAULT = system`** (solo-mac): Direkt-Install → HANDBUCH **Anhang Y.2 „Toolchain installieren"** (DE/EN sprach-gematcht). Reihenfolge: erst `bash .claude/generate-environment-json.sh --force` (setzt das Tool-Flag false→true), **dann** `bash scripts/verify-setup.sh`.
- **`INSTALL_DEFAULT = docker`** (VPS/Factory/Team): Golden Image → HANDBUCH **§Container-Profil (BOO-81)**. **Docker-Preflight:** `docker --version` → vorhanden: Container-Profil kopieren/bauen; fehlt: HANDBUCH-Verweis „Docker installieren (Linux/Mac)". Reihenfolge: im Container nur `bash scripts/verify-setup.sh` noetig — der `postCreateCommand` ruft `generate-environment-json.sh --force` bereits automatisch.
- **Scaffold-only:** Der Bootstrap installiert die Tools NICHT selbst (Ausnahme: `c8` als Dev-Dep); er fuehrt nur auf die passende Anleitung. Der Operator entscheidet System vs. Docker (Default = `INSTALL_DEFAULT`, ueberschreibbar).

5. Ergebnis fliesst in die Abschluss-Tabelle (7.5).

Manuelle Variante / Hintergrund: HANDBUCH Anhang T "Post-Install-Verifikation" (Checkliste Punkt fuer Punkt).

### 7.3a Post-Install Quality-Gate-Audit (BOO-183)

Als letzter Verifikations-Schritt vor dem finalen Commit: `/quality-gate-audit --trigger post-install`
ausfuehren. Das erzeugt den **Baseline-Report** unter `docs/audits/YYYY-MM-DD-quality-gate-audit.md`
und prueft, ob die gerade ausgerollten Gates (Semgrep-Wiring inkl. `.semgrep/`-Canary, Coverage,
Slopsquatting-Wordlist, Layer-0-Bodyguard) tatsaechlich **verdrahtet** sind — nicht nur nominell
konfiguriert. `verify-setup.sh` prueft, dass Dateien da sind; der Quality-Gate-Audit prueft, dass sie
auch greifen (Signal-Test). Der Baseline-Report wird mit-committet (7.4); `docs/audits/` ist von der
Doku-Drift-Pruefung ausgenommen. Steht ein Gate auf `blind`, vor dem ersten `/sprint-run` reparieren
(der Pre-Sprint-Hard-Hook in `sprint-run` Schritt 1 wuerde sonst stoppen). Details: Skill
[quality-gate-audit](../quality-gate-audit/SKILL.md).

### 7.4 Finaler Commit

```bash
cd {PROJECT_PATH}
git add -A
git commit -m "v{VERSION_START} — Complete Governance Bootstrap"
git push  # nur wenn B.2 == Ja
```

### 7.5 Abschluss-Tabelle

Der Abschlussbericht nutzt ein einheitliches Postflight-Statusmodell:

| Status | Bedeutung |
|--------|-----------|
| `OK` | angelegt, geprueft oder bewusst als aktiv bestaetigt |
| `WARN` | angelegt, aber mit Folgearbeit/Risiko/fehlender externer Verifikation |
| `SKIP` | bewusst nicht relevant oder vom Operator abgewaehlt |
| `FAIL` | sollte eingerichtet werden, ist aber fehlgeschlagen oder blockiert |

| Phase | Was | Status | Notiz |
|-------|-----|--------|-------|
| Block A | Projekt-Kern + Stack + Runtime + Add-ons | OK/WARN/FAIL | `RUNTIME_TARGET`, `GOVERNANCE_MODE`, `EXECUTION_ISOLATION` nennen |
| Block B | Bestehende Infrastruktur | OK/WARN/FAIL | vorhandene Pfade/Remotes nur referenzieren, nicht ueberschreiben |
| Block C | Projekt-Dokumentations-SSoT + Doku-Architektur | OK/SKIP/WARN | Obsidian/Repo/DMS/Fallback separat ausweisen |
| Phase 4 | Grundstruktur (Dateien, Git, Linting, Hooks, Backlog-Record) | OK/WARN/FAIL | Baseline-Artefakte duerfen nicht fehlen |
| Phase 5 | Skills installiert ({skill_count}) | OK/WARN/FAIL | Zielpfad `.claude/skills` und/oder `.codex/skills` nennen |
| Block D | Optional-Komponenten | OK/SKIP/WARN/FAIL | jede ausgewaehlte oder bewusst abgewaehlte Option einzeln listen |
| Phase 7 | SecondBrain + Registry + Final-Commit | OK/SKIP/WARN/FAIL | externe Provider separat pruefen |

Pflicht-Checks im Abschluss:
- Keine Secrets in Repo-Dateien, Chat, `.env.example`, Logs oder Abschlussbericht schreiben.
- Projekt-Dokumentations-SSoT ist festgelegt oder als Fallback mit TODO dokumentiert.
- Project Hub, Developer Onboarding, Governance, Target Architecture und Backlog-Verweis existieren oder sind eindeutig verlinkt.
- Runtime-Anweisungen enthalten SSoT und Developer Onboarding als Pflichtlektüre.
- Story-Spec-Template enthaelt den Developer-Onboarding-Pre-Flight.
- Externe Provider separat pruefen und nicht als `OK` markieren, nur weil lokale Dateien existieren: GitHub, Linear, Jira, Azure DevOps, Planner, SonarQube, Grafana, Telegram, Obsidian-Sync.
- Provider-Postflight-Matrix aus `references/provider-postflight.md` ausgeben: GitHub, Backlog, Research, Visualize/Miro, Monitoring, Obsidian.
- Upgrade-Grundsatz dokumentieren: bestehende Skills/Artefakte bleiben erhalten; Migrationen ergaenzen fehlende Baseline und schaerfen Gates, sie loeschen keine projektspezifischen Anpassungen ohne explizite Operator-Freigabe.

### 7.5a Upgrade-Modus fuer bestehende Projekte (BOO-60)

Wenn Bootstrap in einem Projekt mit bestehender Framework-Installation laeuft, **nicht neu bootstrappen**. Lies `references/framework-upgrade.md` und frage:

```
Bestehende Framework-Installation erkannt. Welcher Upgrade-Modus?
  a) inspect — nur Unterschiede zeigen, keine Dateien schreiben
  b) apply-safe — nur neue Dateien/fehlende Sektionen additiv ergaenzen
  c) apply-with-confirmation — potenziell ueberschreibende Aenderungen einzeln bestaetigen
```

Regeln:
- `inspect` schreibt keine Projektdateien.
- `apply-safe` ueberschreibt keine bestehenden Inhalte.
- `apply-with-confirmation` braucht pro Risiko-Datei eine Operator-Freigabe.
- `.env`, Secrets, lokale Reports und Session-Dateien werden nie veraendert.
- Der Upgrade-Report wird als Abschlussausgabe erstellt und optional unter `journal/reports/framework-upgrade/YYYY-MM-DD.md` gespeichert.

### 7.5 VS Code Extensions (optional, basierend auf STACK_CHOICE)

**Fuer alle Stacks:**
- ESLint `dbaeumer.vscode-eslint`
- SonarLint `SonarSource.sonarlint-vscode`
- Error Lens `usernamehw.errorlens`
- Claude Code `anthropic.claude-code`

**Node.js:** REST Client `humao.rest-client`

**Frontend / Full-Stack:** Prettier `esbenp.prettier-vscode`, Auto Rename Tag `formulahendry.auto-rename-tag`, CSS Peek `pranaygp.vscode-css-peek`

**Python:** Python `ms-python.python`, Black Formatter `ms-python.black-formatter`, Ruff `charliermarsh.ruff`

### 7.6 Naechste Schritte

```
Bootstrap fertig. Weiter mit:

  1. VS Code Extensions installieren (Liste oben)
  2. Runtime starten: Claude Code (`cd {PROJECT_PATH} && claude`) oder Codex im Projektpfad
  3. /ideation bzw. passender Codex-Aufruf — erste Story erstellen
  4. Wenn Learning-Loop aktiv: nach 1-2 Sprints /sprint-review laufen lassen
  5. Setup jederzeit pruefen: `bash scripts/verify-setup.sh` (`--strict` fuer CI) — read-only, PASS/WARN/FAIL. Details + Sketch: HANDBUCH Anhang T.
  6. SECURITY.md befuellen: `security-architect` (DESIGN) laufen lassen — Threat-Model (STRIDE) + Mitigations (besonders bei Governance standard/heavy).
  7. Wenn Bestands-Doku/Vor-Material vorhanden (Block-B-Flag `bestands_doku_erkannt: true` oder Operator weiss es): `/knowledge-onboarding` ausfuehren — routet GAP-Analysen, Recherchen, Design-Files, Plan, README etc. deterministisch in die Governance-Artefakte (Rubrik + Manifest). Details: knowledge-onboarding/SKILL.md (BOO-137).
  8. Logging/Monitoring eine Anforderung? → Vorgaben in `observability.md` eintragen, damit `ARCHITECTURE_DESIGN.md` sie beruecksichtigt (Runbook: docs/runbooks/logging-monitoring.md, Konzept: HANDBUCH §8d-ter).
```

> **SECURITY.md befuellen (BOO-136):** Der Bootstrap legt `SECURITY.md` nur als **Skelett** an. `security-architect` (DESIGN-Modus) fuellt es auf Basis der **STRIDE/OWASP-Pruef-Fragen** — der Operator braucht kein Security-Wissen, der Skill stellt die Fragen.

> **Setup-Self-Check jederzeit (BOO-128):** `verify-setup.sh` ist read-only und unabhaengig vom `/implement`-Probelauf — der Operator prueft sein Setup jederzeit selbst. Fertiger Prompt: „führ `verify-setup.sh` aus und erklär mir die WARN/FAIL-Punkte". Hintergrund + Sketch: HANDBUCH Anhang T „Post-Install-Verifikation".

> **GitHub-Connect proaktiv pruefen, wenn GitHub im Scope (BOO-123):** vor dem Loslegen `gh auth status` (CLI/API) **und** `git remote -v` (push-Pfad: HTTPS-via-`gh` oder SSH) checken — Branch-Protection braucht beide Auth-Ebenen (`gh auth` ≠ `git auth`). Runbook: HANDBUCH Anhang Y „GitHub-Connect pro VPS".

---

## Fehlerbehandlung

| Problem | Loesung |
|---------|---------|
| git push schlaegt fehl | SSH Key pruefen: `ssh -T git@github.com` |
| Backlog-Adapter-Fehler | Adapter-Credentials/Projekt-Key pruefen; bei `none` nur Backlog-Record lokal nutzen |
| Obsidian-Pfad nicht erreichbar | Pfad mit `ls` verifizieren, ggf. iCloud-Sync aktiv |
| Hook blockiert Commit | Spec-File anlegen aus `specs/TEMPLATE.md`, Agent-Pattern ausfuellen |
| doc-version-sync blockiert | Alle DOC_FILES auf neue VERSION setzen, dann `git add` |
| Harness strippt Hooks aus settings.json | Hook-Registrierung in `.claude/settings.local.json` (gitignored) als Fallback |
| Component-Doc fehlt nach /implement | T_last-Task im specs/TEMPLATE.md pruefen — muss Component-Update enthalten |
| Learning-Loop-Eintrag vergessen | /sprint-review erneut aufrufen, Schritt 7 ausfuehren |
