# `/research`-Prompt-Template — Slopsquatting-Quartals-Methodik-Review

Dieses Template fuehrt der Skill `slopsquatting-deep-refresh` in Schritt 2 aus. Der in Schritt 1 geladene Kontext (Quellenliste, aktuelle Filter/Thresholds, `last_refreshed`) wird in die `{{...}}`-Platzhalter eingesetzt, **bevor** das Prompt an `/research` geht. So recherchiert `/research` gegen den konkreten Ist-Stand statt generisch.

> DE: Primaere Arbeitssprache. EN-Spiegel weiter unten — beide Versionen inhaltlich aequivalent.

---

## Platzhalter (in Schritt 1 befuellen)

| Platzhalter | Quelle |
|-------------|--------|
| `{{LAST_REFRESHED}}` | Header-Feld `# last_refreshed:` in `wordlist.txt` |
| `{{WORDLIST_COUNT}}` | Anzahl Nicht-Kommentar-Zeilen in `wordlist.txt` |
| `{{CURRENT_SOURCES}}` | Quellenliste aus `slopsquatting-refresh.yml` (z.B. GHSA GraphQL `MALWARE`, OSV `MAL-`, OSSF Package-Analysis-Feed, npm Advisory-JSON) |
| `{{CURRENT_ECOSYSTEMS}}` | Oekosystem-Filter aus dem Workflow (z.B. `npm | pypi | cargo`) |
| `{{CURRENT_THRESHOLDS}}` | Age-Check (`<30 Tage`), Wordlist-Frische (`90 Tage`), Filter-Klassifikationen |
| `{{LAST_REVIEW_DATE}}` | Datum des letzten Quartals-Reviews (oder "kein vorheriger Review") |

---

## Prompt (DE)

```
Deep Research: Quartals-Methodik-Review fuer einen Slopsquatting-Supply-Chain-Schutz.

KONTEXT (Ist-Stand des zu pruefenden Schutzes):
- Eine projekt-lokale Wordlist bekannter malicious/typosquatted Pakete blockt im Pre-Commit-Hook
  neu hinzugefuegte Dependencies (Schema <ecosystem>:<package-name>).
- Letzter Daten-Refresh der Wordlist: {{LAST_REFRESHED}} ({{WORDLIST_COUNT}} Eintraege).
- Ein woechentlicher GitHub-Actions-Workflow refresht die Wordlist automatisch aus diesen Quellen:
  {{CURRENT_SOURCES}}.
- Abgedeckte Oekosysteme: {{CURRENT_ECOSYSTEMS}}.
- Aktuelle Schwellen: {{CURRENT_THRESHOLDS}}.
- Letzter Methodik-Review: {{LAST_REVIEW_DATE}}.

AUFGABE — pruefe die METHODIK (nicht die einzelnen Paketnamen) entlang von vier Dimensionen
und liefere zu jeder eine zitierte Einschaetzung:

1. NEUE DATENQUELLEN
   Gibt es seit {{LAST_REVIEW_DATE}} neue oeffentliche Advisory-/Malicious-Package-Feeds, die die
   Wordlist-Abdeckung sinnvoll erhoehen wuerden? (z.B. neue OSV-Exports, Registry-eigene Malware-Listen
   von npm/PyPI/crates.io, CISA/ENISA/Behoerden-Feeds, kommerzielle Open-Feeds). Pro Quelle: Name,
   Zugriffsweg (API/Token/oeffentlich), Format, Abdeckung.

2. GEAENDERTE / ABGEKUENDIGTE FEEDS
   Haben die aktuell genutzten Quellen ({{CURRENT_SOURCES}}) ihr Schema, ihren Endpunkt, ihre
   Auth-Anforderung oder ihre Verfuegbarkeit geaendert? Ist eine davon deprecated oder tot?
   Pro genutzter Quelle: Status (unveraendert / geaendert / deprecated / tot) + Beleg.

3. METHODIK-STAND DER FORSCHUNG
   Was ist der aktuelle Forschungs- und Bedrohungsstand zu Slopsquatting / Package-Hallucination /
   Typosquatting? Neue Angriffsvektoren, neu betroffene Oekosysteme (ueber {{CURRENT_ECOSYSTEMS}}
   hinaus), neue Erkennungs- oder Praeventionsverfahren? Hat sich die oft zitierte Halluzinations-Rate
   ("~19,7 % der KI-empfohlenen Pakete existieren nicht") seit der Erstmessung veraendert?

4. THRESHOLD-KANDIDATEN
   Sind die aktuellen Schwellen ({{CURRENT_THRESHOLDS}}) noch sinnvoll? Gibt es Evidenz fuer eine
   Anpassung des Age-Checks (<30 Tage), des 90-Tage-Frische-Kriteriums der Wordlist oder der
   Quellen-Filter (malicious-package-Klassifikation, MAL-IDs)? Pro Vorschlag: Schwelle, aktueller Wert,
   vorgeschlagener Wert, Begruendung mit Quelle.

AUSGABE-FORMAT:
- Pro Dimension eine kurze Synthese + die belegenden Quellen (mit Link/Datum).
- Abschluss: eine priorisierte Handlungs-Liste (hoch/mittel/niedrig) mit konkreten Aenderungs-Kandidaten.
- Wo keine Aenderung noetig ist: explizit "unveraendert, keine Aktion" mit Begruendung.

WICHTIG: Nichts erfinden. Jede Quellen-Empfehlung und jeden Threshold-Vorschlag mit einem echten,
ueberpruefbaren Beleg (URL + Datum) versehen. Wo keine belastbare Quelle existiert: als "unbestaetigt"
markieren statt zu raten.
```

---

## Prompt (EN)

```
Deep Research: quarterly methodology review for a slopsquatting supply-chain guard.

CONTEXT (current state of the guard under review):
- A project-local wordlist of known malicious/typosquatted packages blocks newly added dependencies
  in the pre-commit hook (schema <ecosystem>:<package-name>).
- Last data refresh of the wordlist: {{LAST_REFRESHED}} ({{WORDLIST_COUNT}} entries).
- A weekly GitHub Actions workflow auto-refreshes the wordlist from these sources:
  {{CURRENT_SOURCES}}.
- Covered ecosystems: {{CURRENT_ECOSYSTEMS}}.
- Current thresholds: {{CURRENT_THRESHOLDS}}.
- Last methodology review: {{LAST_REVIEW_DATE}}.

TASK — review the METHODOLOGY (not the individual package names) along four dimensions and return a
cited assessment for each:

1. NEW DATA SOURCES
   Since {{LAST_REVIEW_DATE}}, are there new public advisory / malicious-package feeds that would
   meaningfully increase wordlist coverage? (e.g. new OSV exports, registry-native malware lists from
   npm/PyPI/crates.io, CISA/ENISA/government feeds, commercial open feeds). Per source: name, access
   path (API/token/public), format, coverage.

2. CHANGED / DEPRECATED FEEDS
   Have the currently used sources ({{CURRENT_SOURCES}}) changed their schema, endpoint, auth
   requirement, or availability? Is any of them deprecated or dead? Per used source: status
   (unchanged / changed / deprecated / dead) + evidence.

3. RESEARCH STATE OF THE METHODOLOGY
   What is the current research and threat state on slopsquatting / package hallucination /
   typosquatting? New attack vectors, newly affected ecosystems (beyond {{CURRENT_ECOSYSTEMS}}), new
   detection or prevention methods? Has the frequently cited hallucination rate ("~19.7% of
   AI-recommended packages do not exist") changed since first measurement?

4. THRESHOLD CANDIDATES
   Are the current thresholds ({{CURRENT_THRESHOLDS}}) still sensible? Is there evidence to adjust the
   age check (<30 days), the 90-day wordlist freshness criterion, or the source filters
   (malicious-package classification, MAL- IDs)? Per proposal: threshold, current value, proposed
   value, rationale with source.

OUTPUT FORMAT:
- Per dimension a short synthesis + supporting sources (with link/date).
- Closing: a prioritized action list (high/medium/low) with concrete change candidates.
- Where no change is needed: explicitly "unchanged, no action" with rationale.

IMPORTANT: Do not invent anything. Back every source recommendation and threshold proposal with a real,
verifiable reference (URL + date). Where no solid source exists: mark as "unconfirmed" instead of
guessing.
```
