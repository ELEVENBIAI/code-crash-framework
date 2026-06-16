# Optional-Komponenten — Block D

Block D ist der **End-Block** des Bootstrap-Interviews. Alle hier abgefragten Komponenten sind **optional**. Der Operator kann sie bewusst jetzt installieren oder spaeter nachziehen.

Jede Frage wird einzeln gestellt, mit klarer Empfehlung und Default.

## D.1 — Self-Healing-Agent

**Frage:**
```
Self-Healing-Agent einrichten?

Was das macht: Cron-Job laeuft alle 15 Min und prueft:
  - Sind alle DOC_FILES auf der gleichen Version wie lib/config.js?
  - Existieren alle in COMPONENT_INVENTORY.md gelisteten Dateien?
  - Laufen konfigurierte Daemon-Prozesse?
Bei Drift/Ausfall: Auto-Korrektur oder Alert (via Telegram wenn Token gesetzt).

Empfohlen: ab mehreren Mitwirkenden, oder wenn Doku-Drift geschaeftskritisch waere.
Solo-Projekt mit <10 Stories: meist nicht noetig.

Jetzt installieren?
  [ja]  Skill legt agents/self-healing.js an, generiert Cron-Eintrag
  [nein] (default) — kann spaeter nachgezogen werden
```

**Wenn ja:**
- Template `references/self-healing-template.js` rendern mit `PROJECT_PATH`, `OBSIDIAN_VAULT`, Telegram-Token falls vorhanden
- In `agents/self-healing.js` schreiben
- Cron-Eintrag generieren und Operator zeigen:
  ```
  */15 * * * * cd {PROJECT_PATH} && node agents/self-healing.js >> /var/log/self-healing-{slug}.log 2>&1
  ```
- Operator bestaetigt Cron-Eintrag selbst (`crontab -e`)

## D.2 — DocSync zum Obsidian-Vault

**Frage:**
```
DocSync zum Obsidian-Vault aktivieren?

Was das macht: Bei jedem /implement T_last-Task werden Component-Docs
aus {PROJECT_PATH}/docs/components/ oder {PROJECT_PATH} in den Obsidian-Vault
gespiegelt. Kein Cron — laeuft als Manuelle-Aufforderung (implement-Skill T_last).

Empfohlen: wenn Obsidian-Vault gesetzt wurde (Block B.3 = ja).

Jetzt installieren?
  [ja]  (default wenn Vault gesetzt) — Skill legt lib/doc-sync.js an
  [nein] — bei jedem /implement musst du manuell updaten
```

**Wenn ja:**
- Template `references/doc-sync-template.js` rendern mit `PROJECT_PATH`, `OBSIDIAN_VAULT`, Projekt-Name
- Mapping Repo → Vault konfigurieren:
  ```javascript
  const MAPPINGS = [
    {
      src: '{PROJECT_PATH}/docs/components/',
      dst: '{OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Components/'
    },
    {
      src: '{PROJECT_PATH}/ARCHITECTURE_DESIGN.md',
      dst: '{OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/.architecture-hub.md'  // mirror
    }
  ];
  ```
- In `lib/doc-sync.js` schreiben
- `implement`-Skill T_last-Task verweist auf `node lib/doc-sync.js`

## D.3 — Automation-Daemon (Linear-Webhook-Listener)

**Frage:**
```
Automation-Daemon einrichten?

Was das macht: Nimmt Linear-Webhook-Events entgegen und triggert /implement
vollautomatisch bei Story-Status-Aenderung ("In Progress" → Skill laeuft).

Empfohlen: NUR fuer fortgeschrittene Setups mit Vertrauen in die Pipeline.
Sicherheits-Implikationen:
  - Jeder Webhook kann Code-Aenderungen ausloesen
  - --dangerously-skip-permissions noetig
  - HMAC-Verifikation Pflicht

Jetzt einrichten?
  [ja]  Skill legt agents/linear-automation-daemon.js an
  [nein] (default) — Operator-Freigabe-Modus bleibt aktiv
```

**Wenn ja:**
- Daemon-Template rendern (nicht Bestandteil dieses Repos — Operator bekommt Skelett und Anleitung)
- `.env` um `LINEAR_WEBHOOK_SECRET`, `DAEMON_PORT`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` erweitern
- Linear-Webhook-URL generieren + Operator muss im Linear-Dashboard konfigurieren
- `systemd`/`launchd`-Service-Template zeigen (je nach OS)

**Anmerkung:** Dieser Skill hat (Stand v3.0) noch kein fertiges Daemon-Template — Operator bekommt Skelett und dokumentierte Erweiterungsstrategie.

## D.4 — Learning-Loop-Level

**Frage:**
```
Learning-Loop aktivieren?

Was das macht: Systematische Erfassung von Lessons-Learned — was funktioniert,
was nicht, naechste Experimente. Speist sich aus /sprint-review, wird gelesen
von /ideation (Anti-Pattern-Warnung vor neuen Stories).

Drei Levels:
  L1 — Einfach       (eine learnings.md, Bullet-Points)          empfohlen fuer Solo-Projekte
  L2 — Strukturiert  (Sprint-Journal mit Frontmatter)            empfohlen ab 10+ Sprints
  L3 — SQLite        (quantitative Metriken ueber Zeit)          empfohlen ab 50+ Sprints
  nein               (keine Lessons-Learned-Dokumentation)

Default: L1. Welches Level?
```

**Wenn L1/L2/L3:**
- `{PROJECT_PATH}/.learning-loop` File mit Level-String (`L1`, `L2`, `L3`) — wird von `sprint-review`/`ideation` gelesen
- Journal-Struktur entsprechend anlegen:
  - L1: `journal/learnings.md` mit Skelett-Inhalt
  - L2: `journal/` Ordner + `journal/sprint-template.md` (Template-Copy)
  - L3: `journal/learnings.db` (SQLite initialisiert mit Schema) + `journal/write_sprint.py` (Helper)
- Wenn Obsidian aktiv: Mirror in `04 Ressourcen/{PROJECT_NAME}/` anlegen + Wikilink vom PMO-Hub
- `CLAUDE.md` um Regel erweitern: "Nach jedem Sprint-Review ist der Learning-Loop-Eintrag Pflicht"

**Wenn nein:**
- Kein `.learning-loop` File
- `sprint-review`-Skill laeuft ohne Schritt 7
- `ideation`-Skill liest keine Learnings

**Details:** Siehe `learning-loop.md` fuer die vollstaendige Spezifikation.

## D.5 — SonarQube Cloud (Code-Qualitaets-Dashboard)

**Frage:**
```
SonarQube Cloud aktivieren?

Was das macht: Kontinuierliches Code-Qualitaets-Monitoring ueber sonarcloud.io.
Jeder Push triggert einen Scan — Bugs, Code Smells, Security Hotspots, Coverage-Trends.
Komplementaer zu ESLint (Syntax/Style) + Semgrep (Security-Patterns).

Kosten: Public Repos gratis. Private Repos ab ~10 EUR/Monat (LOC-basiert).

[Mac] Lokal: SonarLint VS-Code-Extension (Connected Mode zeigt Cloud-Ergebnisse direkt in der IDE).
[VPS] SonarLint-Plugin nicht relevant — nur CI-Gate.

Jetzt einrichten?
  [ja]  Skill generiert sonar-project.properties + GitHub Action sonar.yml
  [nein] (default) — kann spaeter nachgezogen werden
```

**Wenn ja — Schritt 1: Dateien generieren**

Aus `references/file-templates.md`:
- `sonar-project.properties` (Projekt-Root) — Inhalt aus §`sonar-project.properties (BOO-5)`
- `.github/workflows/sonar.yml` — Inhalt aus §`.github/workflows/sonar.yml (BOO-5)`

**Wenn ja — Schritt 2: environment.json aktualisieren**

`tools_available.sonarqube_cloud = true`

Nur wenn Umgebung `mac`:
```
Hast du die SonarLint VS-Code-Extension bereits installiert?
(Extension-ID: SonarSource.sonarlint-vscode)
[ja] → sonarqube_ide_plugin = true
[nein / spaeter] → sonarqube_ide_plugin = false
```
Auf VPS: `sonarqube_ide_plugin = false` (kein Dialog, automatisch).

**Wenn ja — Schritt 3: Operator-Instruktionen**

```
SonarQube Cloud Setup — Manuelle Schritte:

Voraussetzung: GitHub-Repo muss existieren (SonarCloud verbindet sich via GitHub OAuth).

── CI-Setup (jedes Repo) ──────────────────────────────────────────────────────

a) https://sonarcloud.io → "Log in with GitHub"
   → SonarCloud importiert deine GitHub-Organisation automatisch —
     kein manuelles Anlegen von Org oder Projekt noetig.
b) Repo zur Analyse hinzufuegen: "Analyze new project" → GitHub-Repo auswaehlen
   → Projekt-Key wird automatisch gesetzt: <github-org>_<repo-name>
c) CI-Token generieren (pro Repo):
   My Account → Security → Generate Token
   Typ: "Project Analysis Token"
   Ablauf: "No expiration" oder 1 Jahr (Erinnerung setzen!)
e) Token als GitHub-Secret eintragen:
   gh secret set SONAR_TOKEN
f) Push machen → erster CI-Scan laeuft automatisch via sonar.yml

Ablauf-Handling: Wenn Token ablaeuft → SonarCloud → altes Token loeschen →
neues generieren → gh secret set SONAR_TOKEN (und SonarLint-Verbindung erneuern).

── [Mac] IDE-Setup (einmalig, alle Projekte) ──────────────────────────────────

g) Extension installieren (falls noch nicht):
   VS Code → Extensions → "SonarLint" von SonarSource
   → https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarlint-vscode

h) User Token fuer SonarLint generieren (einmal, gilt fuer alle Projekte):
   sonarcloud.io → My Account → Security → Generate Token
   Typ: "User Token" (nicht "Project Analysis Token")
   Ablauf: "No expiration" empfohlen (SonarLint verliert sonst die Verbindung still)

i) Connected Mode einrichten:
   VS Code → SonarLint Extension → Settings → Connected Mode
   → Add Connection → SonarCloud
   → Organization Key: <dein-github-org-name>
   → Token: <user-token aus Schritt h>
   → Workspace binden: aktuellen Ordner mit SonarCloud-Projekt verknuepfen

Wenn du fertig bist, sag "fertig" oder "done" — ich verifiziere dann die Einrichtung.
```

**Wenn ja — Schritt 4: Verify-Schritt (nach "fertig")**

Environment-aware Pruefung — liest `environment` aus `.claude/environment.json`:

```markdown
### Verify SonarQube Setup

Lese `.claude/environment.json` → `environment` (mac/vps/ci) und `tools_available.sonarqube_cloud`.

**V.1** `sonar-project.properties` vorhanden?
  → `test -f sonar-project.properties && echo "OK" || echo "FEHLT"`

**V.2** `.github/workflows/sonar.yml` vorhanden?
  → `test -f .github/workflows/sonar.yml && echo "OK" || echo "FEHLT"`

**V.3** SONAR_TOKEN in GitHub Secrets eingetragen?
  → `gh secret list 2>/dev/null | grep -q SONAR_TOKEN && echo "OK" || echo "FEHLT"`
  Falls `gh` nicht konfiguriert: manuell bestaetigen.

**V.4** SonarCloud-Projekt erreichbar? (nur wenn SONAR_TOKEN als Env-Var verfuegbar)
  → `PROJ_KEY=$(grep sonar.projectKey sonar-project.properties | cut -d= -f2)`
  → `curl -sf -u "$SONAR_TOKEN:" "https://sonarcloud.io/api/projects/search?projectKeys=$PROJ_KEY" | grep -q '"components":\[{' && echo "OK" || echo "NICHT ERREICHBAR (Token pruefen oder Projekt noch nicht angelegt)"`
  Falls `$SONAR_TOKEN` nicht gesetzt: `[SKIP] Token nicht lokal gesetzt — manuell pruefen`

**V.5** Letzter sonar.yml GitHub-Actions-Run?
  → `gh run list --workflow sonar.yml --limit 1 2>/dev/null || echo "Noch kein Run"`
  Falls noch kein Run: `"→ Trigger: git add . && git commit -m 'chore: init sonarqube' && git push"`

**V.6 [Mac]** SonarLint Connected Mode:
  → `"Hast du Connected Mode in VS-Code eingerichtet? [ja/nein]"`
  Bei `ja`: `sonarqube_ide_plugin = true` in `.claude/environment.json` schreiben.

**V.6 [VPS/CI]** SonarLint:
  → `[N/A — VPS-Umgebung, kein IDE-Plugin noetig]`

Ausgabe-Format:
```
SonarQube Cloud — Verify:
  [✓] sonar-project.properties vorhanden
  [✓] .github/workflows/sonar.yml vorhanden
  [✓] SONAR_TOKEN in GitHub Secrets
  [?] SonarCloud API: Token nicht lokal gesetzt — bitte manuell pruefen
  [–] Letzter CI-Run: noch kein Run → push triggert den ersten Scan
  [N/A] SonarLint Connected Mode: VPS-Umgebung
```
```

**Wenn nein:**
- Keine Dateien generieren
- `tools_available.sonarqube_cloud = false` in `environment.json`
- Hinweis: "SonarQube Cloud kann spaeter aktiviert werden — `references/optional-components.md` §D.5"

## D.6 — Research-Skill: Quelle + Provider

Research ist seit BOO-219 ein **vendored Bundle-Skill** (im Minimum-Set). Der Skill selbst ist damit immer im Framework enthalten; getrennt zu bewerten bleibt nur der **Provider**:

- Skill-Quelle: im Framework enthalten (Default), bereits global installiert, oder bewusst nicht genutzt. **Kein** `claudecodeskills`-Companion-Clone mehr.
- Provider: Perplexity MCP, Perplexity API, OpenRouter oder kein Provider.
- Status: Nur `OK`, wenn Skill-Quelle und Provider-Verifikation getrennt positiv bewertet wurden.

Siehe `provider-postflight.md`.

## D.7 — Visualize und Miro

Visualisierung ist optional. Bootstrap fragt nach:

- `visualize` Skill,
- Miro als Ziel,
- Miro-Konto,
- Miro-MCP,
- Verbindungstest,
- Fallback: Excalidraw, Mermaid oder keiner.

Ohne Miro-Verifikation ist Miro `WARN`, nicht `OK`. Ein bewusster Excalidraw- oder Mermaid-Fallback ist `SKIP` fuer Miro und `OK` fuer den Fallback.

## D.8 — Monitoring-/Logging-Plattform

Monitoring ist eine Architekturentscheidung, kein reines Skill-Installationsdetail. Bootstrap unterscheidet:

- zentrale Plattform nutzen,
- projektspezifische Monitoring-Loesung vorbereiten,
- als offene Architekturfrage dokumentieren.

Der Logging-Vertrag gehoert in `docs/MONITORING.md` oder eine klar markierte Governance-/Observability-Sektion.

## D.9 — Financials / ROI-Tracking (BOO-190)

> **Hinweis zum Ort:** Financials wird **nicht in Block D** abgefragt, sondern als operator-aktivierte Ja/Nein-Frage **am Ende von Block A (A.9)** — analog zum Privacy-Add-on (A.4). Hier nur der Vollstaendigkeit halber als optionale Komponente gelistet.

**Was das macht:** Optionales ROI-/Budget-Tracking. Bei Aktivierung generiert Bootstrap zwei Templates unter `docs/financials/`:

- `budget.md` — schlankes Projekt-Budget-Template (Geo, Waehrung, aktiver Verrechnungssatz, optionale Token-Kosten-Annahmen); verweist auf `worker-equivalent-baseline.md` (aktiver Satz) und `sprint-costs.md` (Ist-Kosten, BOO-189).
- `worker-equivalent-baseline.md` — Verrechnungssatz-Baseline: aktiver Projekt-Satz (Abschnitt 1) + Market-Research-Defaults pro Geo als Fallback (Abschnitt 2). Native Waehrung, keine FX-Cross-Umrechnung.

**Flow:** A.9 stellt (a) Ja/Nein-Aktivierung; bei Ja (b) Folge-Frage interner Verrechnungssatz mit den vier Geo-Defaults (CH CHF 137 / DE EUR 95 / AT EUR 85 / US USD 120, externer P50) als sichtbare Auswahl. Eingabe → `source: intern`; uebersprungen → `source: market-research-2026`. **Intern-Vorrang** bei Konflikt. Operative Setup-Phase: **4.4o (Financials-Setup)**. Details: HANDBUCH Anhang AK.

**Konsumenten:** Worker-Equivalent-Report (`/sprint-review`, BOO-191), Sprint-Forecast (`/backlog`, BOO-192), Datenquelle Story-Doppelspalte (BOO-193).


## Finalisierung nach Block D

Skill fasst Optional-Komponenten-Status zusammen:

```
Block D Ergebnis:
  ✅ / ⏭  Self-Healing-Agent      — cron installiert / spaeter
  ✅ / ⏭  DocSync zu Obsidian     — lib/doc-sync.js / spaeter
  ✅ / ⏭  Automation-Daemon       — agents/...daemon.js / spaeter
  Learning-Loop: L1 / L2 / L3 / nein
  ✅ / ⏭  SonarQube Cloud         — sonar-project.properties + sonar.yml generiert / spaeter
```

## Nachtraegliche Aktivierung

Jede Optional-Komponente kann spaeter aktiviert werden, ohne das ganze Bootstrap erneut zu laufen:

- **Self-Healing:** `bootstrap/references/self-healing-template.js` kopieren und anpassen
- **DocSync:** `bootstrap/references/doc-sync-template.js` kopieren und anpassen
- **Automation-Daemon:** manuell + Linear-Webhook-Setup
- **Learning-Loop:** `.learning-loop` File anlegen, Skill-Pfad siehe `learning-loop.md`
- **SonarQube Cloud:** `bootstrap/references/optional-components.md §D.5` erneut durchgehen, oder manuell `sonar-project.properties` + `.github/workflows/sonar.yml` aus `file-templates.md §sonar-project.properties (BOO-5)` kopieren.

## Anti-Patterns

- ❌ Block D am Anfang des Interviews stellen — Operator hat noch keinen Kontext
- ❌ Alle Optional-Komponenten standardmaessig aktivieren — fuehrt zu Overhead fuer kleine Projekte
- ❌ Self-Healing ohne Obsidian/Telegram-Alert-Ziel — korrigiert still, Operator merkt nichts
- ❌ Learning-Loop aktivieren aber `/sprint-review` nie aufrufen — toter Loop
