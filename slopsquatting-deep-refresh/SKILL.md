---
name: slopsquatting-deep-refresh
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Quartals-Layer fuer den Slopsquatting-Schutz (Code Crash Kap. 3-4) — ein duenner Orchestrator,
  der via /research die METHODIK der Slopsquatting-Wordlist ueberprueft: neue Advisory-Quellen,
  geaenderte Feeds, Forschungsstand, Threshold-Anpassungen. Liefert eine Update-Empfehlung
  (kein Auto-Write). Abgrenzung: der woechentliche Auto-Workflow refresht die DATEN, dieser Skill
  prueft das VERFAHREN. Verwenden wenn der Operator den Quartals-Review faellig hat, "/slopsquatting-deep-refresh"
  sagt oder die Wordlist-Methodik gegen den aktuellen Forschungsstand abgleichen will. Ausloeser sind
  Anfragen wie "Slopsquatting-Quartals-Review", "Wordlist-Methodik pruefen", "neue Slopsquatting-Quellen",
  "/slopsquatting-deep-refresh".
version: 1.0.0
metadata:
  hermes:
    category: governance
    tags: [slopsquatting, supply-chain, quarterly-review, methodology-audit, research-orchestrator]
    requires_toolsets: [terminal]
    related_skills: [research, quality-gate-audit, bootstrap]
---

# Slopsquatting Deep Refresh — der Quartals-Methodik-Review

> "19,7 % der KI-empfohlenen Pakete existieren nicht." — Matthias Schrader, *Code Crash* Kap. 3-4

Der Skill ist der **manuelle Quartals-Layer** des Slopsquatting-Schutzes. Er ist ein duenner Orchestrator, der `/research` mit einem festen Quartals-Prompt-Template fuehrt und damit nicht die Wordlist-*Daten*, sondern die Wordlist-*Methodik* gegen den aktuellen Forschungsstand abgleicht: Sind neue Advisory-Quellen entstanden? Haben sich bestehende Feeds geaendert oder abgekuendigt? Verschiebt sich der Stand der Slopsquatting-Forschung (neue Angriffsvektoren, neue Oekosysteme)? Muessen Schwellen (Age-Check, 90-Tage-Frische, Quellen-Filter) angepasst werden?

Output ist eine **Update-Empfehlung** plus optionaler Threshold-Anpassungs-Vorschlag — **kein Auto-Write**. Der Operator entscheidet, was in die Templates (`dependency-check.sh`, `wordlist.txt`-Refresh-Workflow, `quality-gate-audit`-Gate) zurueckfliesst.

## Abgrenzung: zwei Layer, zwei Aufgaben

Der Slopsquatting-Schutz hat zwei Pflege-Layer mit unterschiedlicher Kadenz und unterschiedlichem Ziel. Dieser Skill ist Layer 2.

| Layer | Was | Kadenz | Pflegt | Mechanismus |
|-------|-----|--------|--------|-------------|
| **1 — Daten-Refresh** | woechentlicher Auto-Refresh der Wordlist-*Eintraege* | woechentlich (Cron) | `.claude/hooks/slopsquatting/wordlist.txt` | GitHub-Actions-Workflow `.github/workflows/slopsquatting-refresh.yml` → PR |
| **2 — Methodik-Review** (dieser Skill) | quartalsweiser Review der *Methodik* hinter der Wordlist | quartalsweise (manuell) | Quellenliste, Filter, Thresholds, Verfahren | `/slopsquatting-deep-refresh` → `/research` → Empfehlung |

Layer 1 haelt die Liste aktuell. Layer 2 prueft, ob die Liste **richtig** aktuell gehalten wird — ob die Quellen noch die richtigen sind, ob die Filter noch greifen, ob das 90-Tage-Frische-Kriterium noch passt. Layer 1 schreibt (per PR). Layer 2 empfiehlt nur.

## Wann nutzen / Wann nicht nutzen

**Nutze `/slopsquatting-deep-refresh` wenn:**
- Der Quartals-Review faellig ist (alle ~90 Tage, an das Frische-Kriterium gekoppelt)
- Der woechentliche Refresh-Workflow auffaellig oft leer laeuft (Verdacht: eine Quelle ist tot oder hat ihr Format geaendert)
- Ein neuer Slopsquatting-Angriffsvektor oeffentlich bekannt wird und die Frage im Raum steht, ob die aktuelle Methodik ihn erfasst
- Das `quality-gate-audit`-Gate (BOO-183) wiederholt eine ueberalterte Wordlist meldet und unklar ist, warum der Auto-Refresh nicht greift

**Nutze `/slopsquatting-deep-refresh` NICHT wenn:**
- Nur ein einzelnes malicious Paket nachgetragen werden soll → das macht Layer 1 (woechentlicher Workflow) oder ein manueller Eintrag in `slopsquatting-override.yaml`
- Die Wordlist nur "alt" ist, aber der Workflow laeuft → kein Methodik-Problem, sondern ein Daten-Problem; Layer 1 greifen lassen
- Ein False-Positive geblockt wird → `never_add`-Eintrag in `slopsquatting-override.yaml`, kein Methodik-Review noetig

## Workflow (3 Schritte)

### Schritt 1: Kontext laden

Skill liest beim Start (alle nur lesend):

1. `.claude/hooks/slopsquatting/wordlist.txt` — aktuelle Wordlist. Header-Feld `# last_refreshed: YYYY-MM-DD` lesen → **letzter Refresh-Zeitpunkt** und **Anzahl Eintraege** bestimmen.
2. `.claude/hooks/slopsquatting/slopsquatting-override.yaml` (falls vorhanden) — manuelle `never_add` / `never_remove`-Eintraege.
3. `.github/workflows/slopsquatting-refresh.yml` — der woechentliche Refresh-Workflow. Daraus die **aktuelle Quellenliste** extrahieren (GHSA, OSV, OSSF Package-Analysis-Feed, npm Advisory-JSON) und die **Filter** (`malicious-package`, `MAL-`-IDs, Oekosystem-Liste `npm | pypi | cargo`).
4. Optional: letzter Quartals-Review-Report (falls aus einer fruehen Session vorhanden), um Diff zum Vorquartal zu bilden.

Falls eine Datei fehlt: Skill vermerkt das im Output (z.B. "kein Refresh-Workflow gefunden — Methodik kann nur gegen die Wordlist selbst geprueft werden") und faehrt mit dem fort, was da ist. Kein Hard-Fail.

Skill fasst den geladenen Stand zusammen:

> Aktueller Stand: Wordlist `last_refreshed: <Datum>`, <N> Eintraege, <M> Override-Regeln. Quellen im Refresh-Workflow: GHSA, OSV, OSSF, npm-Advisory. Letzter Methodik-Review: <Datum oder "keiner gefunden">.

### Schritt 2: `/research`-Prompt-Template ausfuehren

Skill ruft `/research` (Deep-Research-Modus) mit dem festen Quartals-Prompt aus [references/quarterly-review-prompt.md](references/quarterly-review-prompt.md) auf. Der geladene Kontext aus Schritt 1 (Quellenliste, aktuelle Filter, `last_refreshed`) wird in das Template eingesetzt, sodass `/research` gegen den **konkreten Ist-Stand** recherchiert statt generisch.

Das Template laesst `/research` vier Dimensionen pruefen:

1. **Neue Datenquellen** — Gibt es seit dem letzten Review neue oeffentliche Advisory-/Malicious-Package-Feeds (z.B. neue OSV-Exports, Registry-eigene Malware-Listen, CISA/ENISA-Feeds), die die Wordlist-Abdeckung erhoehen wuerden?
2. **Geaenderte/abgekuendigte Feeds** — Haben die aktuell genutzten Quellen (GHSA GraphQL `MALWARE`, OSV `MAL-`, OSSF Package-Analysis, npm Advisory-JSON) ihr Schema, ihren Endpunkt oder ihre Verfuegbarkeit geaendert? Ist eine Quelle tot?
3. **Methodik-Stand der Forschung** — Was ist der aktuelle Stand zu Slopsquatting / Package-Hallucination / Typosquatting? Neue Angriffsvektoren, neue betroffene Oekosysteme (ueber `npm | pypi | cargo` hinaus), neue Erkennungsverfahren?
4. **Threshold-Kandidaten** — Sind die aktuellen Schwellen noch sinnvoll: Age-Check (`<30 Tage` → Warnung), 90-Tage-Frische der Wordlist, Filter-Klassifikationen? Gibt es Evidenz fuer eine Anpassung?

`/research` validiert (2-Tier: Perplexity Deep Research + WebSearch-Gegencheck) und liefert eine zitierte Synthese zurueck.

### Schritt 3: Output — Update-Empfehlung (kein Auto-Write)

Skill verdichtet das `/research`-Ergebnis zu einer strukturierten Empfehlung. **Der Skill schreibt nichts in die Templates oder die Wordlist** — er empfiehlt, der Operator entscheidet und setzt um (bzw. legt eine Story dafuer an).

Output-Struktur:

1. **Zusammenfassung** — 2-3 Saetze: Hat sich die Methodik bewegt? Handlungsbedarf ja/nein?
2. **Quellen-Empfehlungen** — Tabelle `Quelle | Status (neu / unveraendert / geaendert / tot) | Empfehlung (aufnehmen / anpassen / entfernen) | Begruendung + Zitat`.
3. **Threshold-Anpassungs-Vorschlag** (optional) — nur wenn Evidenz vorliegt: `Schwelle | aktueller Wert | Vorschlag | Begruendung`. Beispiel: Age-Check von 30 auf 14 Tage, oder Frische-Kriterium von 90 auf 60 Tage.
4. **Forschungs-Notizen** — relevante neue Erkenntnisse zu Slopsquatting, mit Quellen-Links.
5. **Naechste Schritte** — konkrete Umsetzungs-Hinweise: welche Template-Datei (`bootstrap/references/file-templates.md` §`slopsquatting-refresh.yml` bzw. §`dependency-check.sh`) angefasst werden muesste, ob eine Story (BOO-XX) noetig ist. **Keine** automatische Aenderung.

Der Skill schlaegt vor, den Report unter `journal/reports/slopsquatting/quarterly-<YYYY-Qn>.md` abzulegen (Pfad aus `.claude/environment.json` `paths.reports_local` ableiten falls vorhanden) — aber nur auf Operator-Bestaetigung.

## Sparringspartner-Prinzip

Der Skill **entscheidet nicht** und **schreibt nicht** in die Schutz-Mechanik. Er recherchiert, vergleicht gegen den Ist-Stand und legt eine begruendete Empfehlung vor. Die Anpassung der Wordlist-Methodik — neue Quelle in den Refresh-Workflow, neue Schwelle im Hook — ist eine bewusste Operator-Entscheidung, idealerweise als eigene Story durch die Pipeline (`/intent` → ... → `/implement`). Begruendung (INTENTRON-Leitsatz "leichtgewichtig + pragmatisch, ohne Security-Kompromisse"): Eine Methodik-Aenderung am Supply-Chain-Gate ist security-relevant und gehoert dokumentiert und reviewt, nicht auto-committet.

Was der Skill darf:
- Kontext laden (Wordlist, Override, Refresh-Workflow)
- `/research` mit dem festen Quartals-Prompt fahren
- Eine zitierte Update-Empfehlung + Threshold-Vorschlag produzieren
- Den Report-Ablageort vorschlagen

Was der Skill NICHT tut:
- Die Wordlist oder den Refresh-Workflow aendern
- Schwellen automatisch anpassen
- Eine Quelle ohne Operator-Freigabe in den Workflow aufnehmen

## Bezug zu Schrader

Der Skill operationalisiert das Supply-Chain-Argument aus *Code Crash* Kap. 3-4 (Matthias Schrader, 2025): Wenn 19,7 % der KI-empfohlenen Pakete nicht existieren, ist Slopsquatting ein eigener, KI-spezifischer Angriffsvektor. Der woechentliche Auto-Refresh (Layer 1) haelt die bekannten Faelle aktuell — aber ein Schutz, dessen *Quellen* veralten, wird unbemerkt blind. Der Quartals-Review erzwingt die bewusste Pause: nicht nur "ist die Liste frisch?", sondern "fragen wir noch die richtigen Quellen, mit den richtigen Filtern, gegen den aktuellen Forschungsstand?". Das ist dieselbe Logik wie die Wiring-Canary beim Quality-Gate-Audit (BOO-183): ein konfiguriertes Gate kann trotzdem blind sein.

Vollstaendige Hintergrund-Erklaerung: siehe README.md.

## Referenzen

- [references/quarterly-review-prompt.md](references/quarterly-review-prompt.md) — das ausformulierte `/research`-Prompt-Template fuer den Quartals-Review

Verwandte Artefakte (vom parallelen Setup-Layer, nicht von diesem Skill erzeugt):
- `.claude/hooks/slopsquatting/wordlist.txt` — die Wordlist (Daten-Layer)
- `.claude/hooks/slopsquatting/slopsquatting-override.yaml` — manuelle `never_add` / `never_remove`-Regeln
- `.github/workflows/slopsquatting-refresh.yml` — woechentlicher Refresh-Workflow (Layer 1)
- `.claude/hooks/dependency-check.sh` — der Pre-Commit-Hook, der die Wordlist nutzt (BOO-12 / BOO-197)
- HANDBUCH **Anhang AE** — Slopsquatting-Wordlist-Pflege (Gesamtbild beider Layer + `quality-gate-audit`-Frische-Gate)

EN-Spiegel: [SKILL.en.md](SKILL.en.md).

BOO-Quellen: BOO-197 (Slopsquatting-Wordlist + Quartals-Layer), BOO-183 (`quality-gate-audit` — Frische-Gate), BOO-12 (`dependency-check.sh`).
