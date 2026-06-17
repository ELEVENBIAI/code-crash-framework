---
name: pitch
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
version: 1.2.0
description: |
  Schliesst Schraders 4P-Pipeline (Perceive/Prompt/Produce/Pitch).
  Sammelt Evidenz (Metriken, Architektur-Diff, Intent-Erfuellung) als
  Markdown-Briefing fuer Stakeholder-Termine. Erzeugt keine Slides —
  Mensch baut Story und macht Live-Demo. Verwenden wenn der Operator
  "Pitch vorbereiten", "/pitch" oder "Sprint X praesentieren" sagt.
tools: [Read, Write, Edit, Bash, Glob, Grep]
metadata:
  hermes:
    category: governance
    tags: [pitch, evidence-gathering, sprint-presentation, 4p-pipeline]
    requires_toolsets: [terminal, git, linear]
    related_skills: [sprint-review, architecture-review, intent]
---

# Pitch — Evidenz fuer Stakeholder-Termine sammeln

Schraders Pitch-Prinzip ist Evidenz, nicht Live-Coding. Dieser Skill ist die Hybrid-Variante (Option 3): er sammelt die Daten, der Mensch baut daraus die Story und macht die Live-Demo. Output ist ein einzelnes Markdown-Briefing unter `pitch/PITCH-XX.md` — committed, NICHT gitignored, weil Pitch-Briefings Teil der Projekt-Geschichte sind. Der Skill laeuft NACH `/sprint-review` und VOR dem Stakeholder-Termin. Er ist read-only gegenueber dem Learning-Loop und schreibt NIE in L3 — das ist die saubere Trennung zu `/sprint-review`.

Referenzen:
- `references/pitch-template.md` — Body-Schema fuer `PITCH-XX.md`
- `references/demo-path-heuristic.md` — Heuristik fuer Demo-Pfad-Vorschlag

## Workflow (6 Schritte)

### Schritt 0: Environment laden

1. Lese `.claude/environment.json` (BOO-34). Bei Bedarf folgende Pfade extrahieren:
   - `paths.pitches` — Default `pitch/`
   - `paths.reports_local` — Local-Implement-Reports
   - `paths.reports_ci` — CI-Reports
   - `paths.lessons_l3` — L3-Lessons-DB
   - `paths.specs` — Story-Specs
   - `paths.architecture_design` — `ARCHITECTURE_DESIGN.md`
   - `paths.intents` — Intent-Files
   - `paths.feature_flags` — `.claude/feature-flags.json` (BOO-17)
2. Bei `tools_available.linear == false` → Linear-Lookups skippen mit Hinweis im Output.
3. Fallback bei fehlender Datei: Defaults annehmen und im Output vermerken: "Hinweis: `.claude/environment.json` fehlt — Defaults aktiv. Empfehlung: `/bootstrap` re-rennen oder die Datei manuell anlegen."

### Schritt 1: Pitch-Scope abfragen

Skill fragt den Operator:

1. Welcher Sprint? (z.B. Sprint 12, Datum-Range oder Sprint-Datei `journal/sprint-{date}.md`)
2. Welche Intents sind im Pitch-Fokus? (IDs aus `intents/INTENT-XX.md`, mehrere moeglich)
3. Welche Stories sollen vorgestellt werden? (Linear-IDs, mehrere moeglich)
4. Stakeholder-Kontext optional (1 Satz, fliesst in Demo-Pfad-Heuristik)

PITCH-XX-Nummer: hoechste Nummer in `pitch/PITCH-*.md` + 1, sonst `PITCH-1`.

### Schritt 2: Daten aus 8 Quellen sammeln

Alle Quellen optional — graceful skip bei fehlender Quelle, jeweils Hinweis im Output.

| Quelle | Pfad | Was wird gelesen |
|---|---|---|
| L3 Lessons-DB | `journal/learnings.db` | Cross-Sprint-Trends, Iterations-Avg ueber Zeit |
| Local Reports | `journal/reports/local/{date}_{story}/` | Iterations-Counts, Final-Status pro Story (`meta.json`) |
| CI Reports | `journal/reports/ci/run-{id}/` | Coverage, Performance-Baselines (BOO-32-Konvention) |
| Sprint-Files (L2) | `journal/sprint-{date}.md` | Aggregat-Metriken pro Sprint |
| Architektur-Doku | `ARCHITECTURE_DESIGN.md` | Architektur-Stand fuer Diff (Schritt 3) |
| Intents | `intents/INTENT-XX.md` | Erfolgskriterien fuer Intent-Erfuellung |
| Feature-Flags | `.claude/feature-flags.json` (BOO-17) | aktive Flags + Rollout-Phase |
| Git-Log | `git log --since=<sprint-start>` | LOC-Delta (`--shortstat`), Commit-Counts |

Aus den gesammelten Daten den Frontmatter-Snapshot bauen (Schema in `references/pitch-template.md`):

- `loc_delta` aus `git log --shortstat --since=...` (Summe lines added/removed)
- `coverage_trend` aus Sprint-File oder neuestem CI-Report
- `p95_change` aus Performance-Baseline (BOO-16)
- `iterations_avg` aus Local-Reports `meta.json` (Mittel ueber alle Stories im Scope)
- `feature_flags_active` aus `.claude/feature-flags.json`
- `intent_fulfillment_score` aus Schritt 4 (siehe unten — separater Schritt, hier nur Notiz)

L3-DB Lookup-Beispiel (sqlite, read-only — KEIN INSERT/UPDATE):

```bash
sqlite3 "${L3_DB:-journal/learnings.db}" \
  "SELECT story_id, iterations FROM lessons WHERE sprint = '<sprint-id>'"
```

### Schritt 3: Architektur-Diff berechnen

```bash
# Letztes Pitch-File finden (hoechste PITCH-Nummer < aktueller)
LAST_PITCH=$(ls pitch/PITCH-*.md 2>/dev/null | sort -V | tail -1)
# Commit-Hash aus Frontmatter `created_at` zurueckuebersetzen oder Git-Log nutzen
LAST_PITCH_DATE=$(grep '^created_at:' "$LAST_PITCH" | head -1 | sed 's/created_at: *//')
git diff $(git rev-list -1 --before="$LAST_PITCH_DATE" HEAD)..HEAD -- ARCHITECTURE_DESIGN.md
```

Bei erstem Pitch (kein vorheriges File): kompletten Stand von `ARCHITECTURE_DESIGN.md` zusammenfassen (3–5 Bullets pro §-Sektion).

Output: kurze Bullet-Liste was sich geaendert hat — §-Nummer aus `ARCHITECTURE_DESIGN.md`, Was geaendert, Warum laut Commits.

### Schritt 4: Demo-Pfad-Heuristik anwenden

Logik in `references/demo-path-heuristic.md`. Grundprinzip (zwei Faktoren):

1. **Hoechste Aenderung seit letztem Pitch** — welche Komponenten/Endpunkte haben die meisten Commits/LOC-Delta im Scope?
2. **Hoechste Intent-Relevanz** — welche Komponenten sind in den Erfolgskriterien der `related_intents` genannt?

Skill berechnet Score pro Komponente, schlaegt User-Journey als Pfad vor (z.B. "Onboarding → Search → Checkout"). Operator kann den Vorschlag uebersteuern beim Review in Schritt 5.

Pro Intent: Score 0–1 fuer Erfuellung. Skill schaut in das Erfolgskriterium des Intent (`intents/INTENT-XX.md`) und matched es gegen Sprint-Reports + Feature-Flag-Stand. Bei nicht eindeutig zu messendem Kriterium: Score `null` mit Hinweis "manueller Operator-Score noetig".

### Schritt 5: `pitch/PITCH-XX.md` schreiben

Body-Schema (siehe `references/pitch-template.md`):

1. **Architektur-Diff seit letztem Pitch** (aus Schritt 3)
2. **Quality-Gate-Status** — offene Findings, geschlossene Hotspots, Coverage-Bewegung (aus Sprint-File + SonarQube wenn `tools_available.sonarqube_cloud == true`)
3. **Intent-Erfuellung** — pro `related_intent`: Erfolgskriterium + aktueller Stand + Score 0–1 (aus Schritt 4)
4. **Demo-Pfad-Vorschlag** (aus Schritt 4)
5. **Open Questions** — was weiss der Skill noch nicht, was Stakeholder fragen koennten

Frontmatter aus dem Issue-Schema 1:1 schreiben: `pitch_id`, `sprint`, `created_at` (ISO-8601 UTC), `related_intents`, `related_stories`, `metrics_snapshot.*`, `demo_path`, `status: prepared`.

Operator zur Review auffordern:

> PITCH-XX.md erstellt unter `pitch/PITCH-XX.md`. Bitte vor dem Stakeholder-Termin durchgehen — der Skill ist Spickzettel, nicht Skript.

### Schritt 6 (optional, post-pitch): Status auf `delivered` + Outcome-Notiz

Erst NACH dem Stakeholder-Termin vom Operator aufgerufen ("/pitch post" oder "Pitch X war"). Skill:

1. Laedt das aktuellste `PITCH-XX.md`
2. Setzt `status: delivered`
3. Fragt Operator nach freier Outcome-Notiz (1–3 Saetze): Wer war da, welche Fragen kamen, welche Entscheidung wurde getroffen
4. Outcome-Notiz wird im `PITCH-XX.md` als Sektion `## Outcome (post-pitch)` angehaengt — KEINE Auto-Generierung, NUR Freitext-Operator-Input
5. Bei Bedarf Status `post-mortem` setzen (wenn Pitch schief lief — Operator entscheidet)

## Anti-Scope (was der Skill NICHT tut)

- **Keine Slide-Generierung** — kein PowerPoint, kein Reveal.js, kein Marp
- **Kein Outcome-Text** — User-Reaktion entsteht NUR in der Demo, Freitext-Input vom Operator (Schritt 6)
- **Kein Voice-Over / kein Demo-Video**
- **Kein Schreiben in L3** — read-only Position, schuetzt Trennung zu `/sprint-review`
- **Keine Stakeholder-Mail** — Kommunikation ist menschliche Arbeit

Wenn diese Features gewuenscht sind: separates Issue, nicht im BOO-37-Scope.

## Differenzierende Komponenten — 13 ohne Anthropic-Pendant (BOO-209)

Das Framework substituiert, wo Native-Features reichen (ADR-1 Build-vs-Buy), und baut nur, was Anthropic nicht nativ liefert. Diese 13 sind der USP fuer Stakeholder-Termine — kanonische Liste mit Quell-Links: [HANDBUCH Anhang AP](../HANDBUCH.md).

1. **`/intent`** — methodisches „Warum vor Spec" erzwingt Claude Code nicht.
2. **`/pitch`** — Stakeholder-Evidenz entlang eines Demo-Pfads sammelt kein natives Tool.
3. **Drei-Schicht-Quality-Gate** — gestuftes Semgrep/Coverage/Slopsquatting-Geruest gibt es nativ nicht.
4. **Layer-0 PreToolUse-Bodyguard** — deterministischer Edit-Gate vor dem Schreiben fehlt nativ.
5. **Spec-Gate als Git-Hook** — „kein Commit ohne Spec" wird nativ nicht erzwungen.
6. **dpo-Kontrollkatalog (YAML)** — Privacy-Compliance als deterministischer Katalog ist kein Native-Feature.
7. **CONVENTIONS.md** — tool-neutraler Adapter-Vertrag ueber Claude/Codex fehlt nativ.
8. **AGENTS.md-Generator** — portablen Codex-Einstieg generiert Claude Code nicht.
9. **Knowledge-Onboarding** — deterministisches Doku-Routing gibt es nativ nicht.
10. **DevContainer-Template** — governance-fertiger DevContainer ist kein Native-Asset.
11. **Quality-Gate-Self-Audit** — „sind die Gates wirklich verdrahtet?" prueft kein natives Tool.
12. **`change_type: prototype`** — bewusste Gate-Lockerung ohne Compliance-Bruch ist Framework-Logik.
13. **Vendored Querschnitts-Skills** — security-architect, dpo, cloud-system-engineer mitgeliefert.

## Zeitliche Verortung

```
/intent → /ideation → /backlog → /implement → /architecture-review → /sprint-review → /pitch
```

Die 4P-Pipeline-Phasen (Schrader Kap. 5):

- **Perceive** → `/intent`
- **Prompt + Produce** → `/ideation` + `/backlog` + `/implement`
- **Pitch** → `/pitch` (dieser Skill)

## Hinweise fuer den Operator

- `pitch/`-Dir wird committed (NICHT gitignored) — Pitch-Briefings sind Teil der Projekt-Geschichte
- `PITCH-XX.md` ist Spickzettel, nicht Drehbuch — die Buehne bleibt menschlich
- Optional: VS-Code-Markdown-Preview macht aus dem Briefing einen lesbaren Screen waehrend der Demo
