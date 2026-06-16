<a name="deutsch"></a>

# Backlog — Abhaengigkeits-bewusstes Sprint Planning

> Laedt das gesamte Backlog, mappt Abhaengigkeiten, respektiert DB-Schema-Ketten und schlaegt konkrete Reihenfolge vor. Schluss mit "welche Story als naechstes?" per Bauchgefuehl.

**Version:** 1.6.0 · **Befehl:** `/backlog`

> 🔗 Sprint-Automation: **`/sprint-run`** faehrt einen ganzen Sprint und orchestriert die Kette `backlog → implement → sprint-review`. Siehe [`sprint-run/`](../sprint-run/README.md) · HANDBUCH Anhang AD.

> **Claude-Code-Modus:** `/backlog` liest und priorisiert nur (schreibt nichts) → **`plan`** (Plan Mode). Im `/sprint-run`-Daemon laeuft es read-only mit. Details: HANDBUCH §6 „Claude-Code-Modus".

---

## Was der Skill tut

Die meisten Backlogs sind flache Listen nach Prioritaet sortiert. Echte Backlogs haben versteckte Struktur: Abhaengigkeiten, Schema-Versionsketten, Stories die Linear noch als "Todo" zeigt obwohl sie letzte Woche released wurden.

Der Skill laedt das ganze Bild — Systemkontext aus `CLAUDE.md` + `ARCHITECTURE_DESIGN.md`, abgeschlossene Issues der letzten 30 Tage, alle offenen Issues — und baut einen Abhaengigkeitsgraph. Findet was ein Mensch uebersieht:

- Stories die blockiert aussehen, aber nicht sind (Blocker ist schon Done)
- Zwei Stories beide auf `schemaVersion 18` (Konflikt — eine muss neu)
- Zirkulaere Abhaengigkeiten
- Verwaiste Referenzen (`CLAW-14` in Issue X erwaehnt aber existiert nicht)

---

## Wie er funktioniert

```
Environment laden  (.claude/environment.json — Pfade + tools_available, Fallback auf Defaults)
        │
        ▼
Systemkontext laden  (CLAUDE.md + ARCHITECTURE_DESIGN.md + SYSTEM_ARCHITECTURE.md)
        │
        ▼
Completed Issues laden (letzte 30 Tage)
        │
        ▼
Offenes Backlog laden (alle Stati)
        │
        ▼
Abhaengigkeits-Graph · Schema-Chain-Check · Cycle Detection
        │
        ▼
Sortieren:  In Progress > Blocker > Intent-Label > Prio > Dep-Tiefe > Alter
        │
        ▼
Output:  Geordnete Liste · Konflikte · Backlog-Hygiene-Vorschlaege
```

Die `.claude/environment.json` liefert Pfade (`paths.specs`, `paths.architecture_design`, `paths.reports_local`, ...) und ein `tools_available`-Gating: ist ein Tool nicht aktiv, ueberspringt der Skill den Aufruf mit Hinweis im Output. Fehlt die Datei, faellt der Skill auf Standard-Pfade zurueck und vermerkt das.

---

## Der Schema-Chain-Check (Pflicht)

Laeuft bei jedem Backlog-Durchgang. Stoppt Schema-Konflikte bevor zwei Entwickler die gleiche Migration anfangen:

1. Offene Issues auf `## DB Schema Impact` Sektion pruefen
2. Chain aufbauen: `currentSchemaVersion → targetSchemaVersion` pro Story
3. Regel: **Stories mit niedriger `targetSchemaVersion` IMMER zuerst**
4. Konflikt-Flag: Zwei Stories mit gleicher Ziel-Version → als **kritischer Blocker** gemeldet

Beispiel-Output:
```
Schema-Chain: STORY-A (v17 → v18) muss vor STORY-B (v18 → v19) kommen.
Konflikt:     STORY-C und STORY-D zielen beide auf v18 — eine muss neu.
```

---

## Intent-Label-Priorisierung

Beim Sortieren respektiert der Skill das Intent-Label aus der `## Intent-Check`-Sektion im Story-Body (gesetzt von `/ideation`):

- `on-intent` kommt **vor** `neutral` bei gleichem Status und gleicher Priority
- `off-intent`-Stories landen am Ende — mit Warnung: "Story X ist off-intent — gehoert ins Backlog, nicht in den Sprint"
- Fehlt das Label, wird die Story als `neutral` behandelt

Bei der Ausgabe wird der Grund erklaert: "Story X priorisiert vor Y weil on-intent bei gleichen Points."

---

## Trigger-Phrasen

- `/backlog`
- "was steht an?"
- "Sprint Planning"
- "Prioritaeten"
- "was nehm ich als naechstes?"

---

## Schnittstellen zu anderen Skills

| Upstream | Was geliefert wird | Downstream | Was wir liefern |
|----------|--------------------|------------|------------------|
| `ideation` | Neue Stories + Abhaengigkeiten + Schema-Impact | `implement` | Top-Story + Begruendung der Reihenfolge |
| Linear | Offene / abgeschlossene Issues | `architecture-review` | Stories die einen Pre-Check brauchen |
| `architecture-review` (System-Mode) | Empfohlene Issues | `sprint-review` | Aktueller Backlog-Snapshot fuer Quartals-Audit |

---

## Artefakte / Outputs

- **Priorisierte Story-Liste** mit explizitem Grund pro Story
- **Abhaengigkeits-Konflikte** — Orphans, Cycles, kaputte Referenzen
- **Schema-Chain-Report** — wer vor wem, und warum
- **Hygiene-Vorschlaege** — Issues zum Schliessen, neu priorisieren, splitten

---

## Installation

```bash
cp -r backlog ~/.claude/skills/backlog
```

---

## Dateistruktur

```
backlog/
└── SKILL.md     ← Skill-Definition (wird von Claude Code gelesen)
```

Keine Referenz-Dateien — Workflow ist self-contained in `SKILL.md`.
