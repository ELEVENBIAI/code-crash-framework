# Provider-Postflight

Ziel: Bootstrap unterscheidet **lokal installierte Artefakte** von **extern verifizierten Providern**. Ein Skill oder eine Konfigurationsdatei macht GitHub, Linear, Research, Miro, Grafana oder Obsidian-Sync noch nicht einsatzbereit.

## Statusmodell

| Status | Bedeutung |
|---|---|
| `OK` | Provider wurde aktiv gewaehlt und die Verbindung wurde verifiziert oder vom Operator bewusst als bereits aktiv bestaetigt. |
| `WARN` | Artefakt oder Auswahl existiert, aber Verifikation, Credential, Konto, MCP oder Live-Test fehlt. |
| `SKIP` | Provider wurde bewusst abgewaehlt oder ist fuer dieses Projekt nicht relevant. |
| `FAIL` | Provider sollte aktiv sein, die Verifikation ist aber fehlgeschlagen oder blockiert. |

Secrets werden nie angezeigt, nie in Repo-Dateien geschrieben und nie in Abschlussberichte kopiert. Geprueft wird nur Existenz oder Ergebnis eines Live-Tests.

## Pflichtmatrix im Abschlussbericht

| Provider | Lokales Artefakt | Credential vorhanden | Live-Test | Status | Naechste Aktion |
|---|---|---|---|---|---|
| GitHub | Remote / `.github/` | n/a | `git ls-remote` oder `gh repo view` | OK/WARN/SKIP/FAIL | Remote anlegen, Auth reparieren, oder bewusst ohne GitHub fortfahren |
| Backlog | Backlog Record / Adapter-Konfig | nur falls API/MCP genutzt | Linear/GitHub/Jira/Azure/Planner erreichbar | OK/WARN/SKIP/FAIL | Adapter aktivieren oder Markdown-only dokumentieren |
| Research | `research` Skill oder Companion-Quelle | `PERPLEXITY_API_KEY`, OpenRouter-Key oder MCP | optionaler Probe-Call ohne Secret-Ausgabe | OK/WARN/SKIP/FAIL | Provider einrichten oder Research als offline/Companion markieren |
| Visualize/Miro | `visualize` Skill / Diagramm-Fallback | Miro-Auth oder MCP-Konfig | Miro-MCP Tool erreichbar | OK/WARN/SKIP/FAIL | Miro anbinden oder Excalidraw/Mermaid als Fallback setzen |
| Monitoring | `docs/MONITORING.md`, Grafana/Sonar/Health-Konzept | Plattform-spezifisch | Dashboard/API/Healthcheck erreichbar | OK/WARN/SKIP/FAIL | zentrale Plattform nutzen, eigene vorbereiten, oder Architekturfrage dokumentieren |
| Obsidian | Vault-Pfad / DocSync | n/a | Pfad existiert und Schreibtest optional | OK/WARN/SKIP/FAIL | Vault-Pfad korrigieren oder Repo-only dokumentieren |

> **SonarCloud (externer Provider, BOO-58/119):** Bei aktiviertem SonarQube Cloud (D.5 = ja) ist der Provider-Postflight der Punkt, an dem die **SonarCloud-seitige** Einrichtung geprueft wird (Org/Projekt-Key/`SONAR_TOKEN`-Secret). Schritt-fuer-Schritt: **HANDBUCH Anhang AA** (zwei Szenarien: Account existiert / von 0). Ohne gueltiges Token failt `sonar.yml` rot und blockiert den ersten Merge (siehe BOO-122).

## Monitoring- und Logging-Frage

Bootstrap fragt:

```text
Gibt es bereits eine Monitoring-/Logging-Plattform?
  a) Ja, zentrale Plattform nutzen
  b) Nein, Projekt soll eigene Monitoring-Loesung vorbereiten
  c) Noch unklar, als Architekturfrage dokumentieren
```

Der Logging-Vertrag muss mindestens festhalten:

- Log-Format,
- Ablage oder Transport,
- Pflichtfelder: `timestamp`, `level`, `service`, `run_id`, `trace_id`, `message`,
- verbotene Inhalte: Secrets, Tokens, Cookies, personenbezogene Rohdaten,
- Metriken,
- Health-Endpunkte,
- verantwortliche Stelle.

Artefakt: `docs/MONITORING.md` oder eine klar markierte Sektion in `GOVERNANCE.md` / `observability.md`.

## Research-Entscheidung

Bootstrap fragt:

```text
Research-Skill-Quelle (seit BOO-219 vendored Bundle-Skill, im Minimum-Set):
  a) in INTENTRON enthalten (Default — wird in Phase 5 installiert)
  b) bereits global installiert
  c) nicht installieren

Provider:
  a) Perplexity MCP lokal
  b) Perplexity API direkt
  c) OpenRouter
  d) kein Provider
```

Regel: Research darf `OK` nur bekommen, wenn Skill-Quelle und Provider-Status getrennt bewertet wurden. Ohne Provider ist Research `WARN` oder `SKIP`, nicht `OK`.

## Visualize- und Miro-Entscheidung

Bootstrap fragt:

```text
Visualisierung:
  - Soll der visualize-Skill installiert werden?
  - Soll Miro als Diagramm-Ziel genutzt werden?
  - Ist ein Miro-Konto vorhanden?
  - Ist Miro-MCP eingerichtet?
  - Soll die Verbindung geprueft werden?
  - Fallback: Excalidraw / Mermaid / keiner?
```

Abschlussbericht:

```text
Visualize Skill: OK / WARN / SKIP / FAIL
Miro MCP: OK / WARN / SKIP / FAIL
Diagramm-Fallback: Excalidraw / Mermaid / keiner
```

## Schreibregel

Provider-Postflight schreibt in Projektartefakte nur:

- Status,
- Quelle oder Adapter,
- letzte Verifikation als Datum/kurze Notiz,
- naechste Aktion.

Nicht geschrieben werden:

- API-Keys,
- Tokens,
- Cookies,
- private URLs mit Credentials,
- rohe personenbezogene Daten,
- lokale Session-Dateien.
