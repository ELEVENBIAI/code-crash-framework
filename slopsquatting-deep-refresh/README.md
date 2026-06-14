# Slopsquatting Deep Refresh — der Quartals-Methodik-Review

> Quartalsweiser Deep-Research-Review der Slopsquatting-Wordlist-*Methodik*: Sind die Quellen noch die richtigen, die Filter noch wirksam, die Schwellen noch sinnvoll? Liefert eine zitierte Update-Empfehlung — kein Auto-Write. Der woechentliche Auto-Refresh haelt die Daten frisch; dieser Skill prueft, ob die Daten *richtig* frisch gehalten werden.

**Version:** 1.0.0 · **Befehl:** `/slopsquatting-deep-refresh`

> **Claude-Code-Modus:** reiner Research- + Empfehlungs-Skill, schreibt nichts in die Schutz-Mechanik → **`plan`** (Plan Mode): die Update-Empfehlung entsteht im Dialog, umgesetzt wird erst nach Operator-Freigabe (idealerweise als eigene Story). Details: HANDBUCH §6 „Claude-Code-Modus" und **Anhang AE**.

---

## Was der Skill tut

Der Skill ist der **manuelle Quartals-Layer** des Slopsquatting-Schutzes und ein duenner Orchestrator: Er fuehrt `/research` (Deep Research) mit einem festen Quartals-Prompt-Template und gleicht damit die Wordlist-*Methodik* gegen den aktuellen Forschungsstand ab. Vier Dimensionen:

1. **Neue Datenquellen** — neue oeffentliche Advisory-/Malicious-Package-Feeds, die die Abdeckung erhoehen wuerden
2. **Geaenderte/abgekuendigte Feeds** — haben die aktuell genutzten Quellen Schema, Endpunkt oder Verfuegbarkeit geaendert? Ist eine tot?
3. **Methodik-Stand der Forschung** — neue Angriffsvektoren, neue Oekosysteme, neue Erkennungsverfahren
4. **Threshold-Kandidaten** — Age-Check, 90-Tage-Frische, Quellen-Filter: noch sinnvoll?

Output ist eine **Update-Empfehlung** plus optionaler Threshold-Vorschlag — **kein Auto-Write**. Der Operator entscheidet, was in die Templates zurueckfliesst.

---

## Welches Problem er loest

Schrader benennt Slopsquatting als eigenen, KI-spezifischen Angriffsvektor: **19,7 % der KI-empfohlenen Pakete existieren nicht** (*Code Crash* Kap. 3-4). Angreifer registrieren genau diese halluzinierten oder typosquatted Namen mit Malware. Der woechentliche Auto-Refresh (Layer 1) haelt die *bekannten Faelle* aktuell — aber ein Schutz, dessen **Quellen** veralten, wird unbemerkt blind. Genau wie ein konfiguriertes Quality-Gate trotzdem blind sein kann (Wiring-Canary, BOO-183), kann ein automatisch refreshter Schutz aus den falschen Quellen schoepfen.

Der Quartals-Review erzwingt die bewusste Pause: nicht "ist die Liste frisch?" (das macht Layer 1), sondern "fragen wir noch die *richtigen* Quellen, mit den *richtigen* Filtern, gegen den *aktuellen* Forschungsstand?".

---

## Zwei Layer — Abgrenzung

| Layer | Was | Kadenz | Pflegt | Mechanismus |
|-------|-----|--------|--------|-------------|
| **1 — Daten-Refresh** | Wordlist-*Eintraege* aktuell halten | woechentlich (Cron) | `wordlist.txt` | `slopsquatting-refresh.yml` → PR |
| **2 — Methodik-Review** (dieser Skill) | *Verfahren* hinter der Wordlist pruefen | quartalsweise (manuell) | Quellen, Filter, Thresholds | `/slopsquatting-deep-refresh` → `/research` → Empfehlung |

Layer 1 **schreibt** (per PR). Layer 2 **empfiehlt** nur.

---

## Trigger

- `/slopsquatting-deep-refresh`
- "Slopsquatting-Quartals-Review"
- "Wordlist-Methodik pruefen"
- "neue Slopsquatting-Quellen"
- "Slopsquatting-Schutz gegen Forschungsstand abgleichen"

---

## Workflow im Ueberblick (3 Schritte)

| # | Schritt | Was passiert |
|---|---------|--------------|
| 1 | **Kontext laden** | `wordlist.txt` (inkl. `last_refreshed` + Eintragszahl), `slopsquatting-override.yaml`, `slopsquatting-refresh.yml` (→ Quellenliste, Filter) lesen. Fehlende Datei = vermerken, kein Hard-Fail. |
| 2 | **`/research` fahren** | Quartals-Prompt-Template aus [references/quarterly-review-prompt.md](references/quarterly-review-prompt.md) mit dem Ist-Stand befuellen und an `/research` (Deep Research) geben — 4 Dimensionen, zitiert. |
| 3 | **Empfehlung** | `/research`-Ergebnis zu Update-Empfehlung + optionalem Threshold-Vorschlag verdichten. Kein Auto-Write. Report-Ablage `journal/reports/slopsquatting/quarterly-<YYYY-Qn>.md` nur auf Bestaetigung. |

---

## Output

Strukturierte Empfehlung (kein Schreibzugriff auf Wordlist/Workflow):

1. **Zusammenfassung** — hat sich die Methodik bewegt, Handlungsbedarf ja/nein
2. **Quellen-Empfehlungen** — `Quelle | Status | Empfehlung | Begruendung + Zitat`
3. **Threshold-Anpassungs-Vorschlag** (optional) — `Schwelle | aktuell | Vorschlag | Begruendung`
4. **Forschungs-Notizen** — neue Erkenntnisse mit Quellen-Links
5. **Naechste Schritte** — welche Template-Datei anzufassen waere, ob eine Story noetig ist

---

## Modi / Features

- **Quartals-Review (Standard)** — der volle 3-Schritte-Durchlauf gegen den aktuellen Forschungsstand.
- **Ad-hoc-Review** — derselbe Durchlauf ausserhalb des Quartals-Takts, ausgeloest durch einen konkreten Anlass (tote Quelle, neuer Angriffsvektor, wiederholt ueberalterte Wordlist im `quality-gate-audit`).
- **Diff-zum-Vorquartal** — falls ein frueherer Report unter `journal/reports/slopsquatting/` liegt, baut der Skill den Delta zum letzten Review.
- **Graceful Degradation** — fehlt eine der Kontext-Dateien, laeuft der Review mit dem, was da ist, und vermerkt die Luecke.

---

## Sparringspartner-Prinzip

Der Skill **schreibt nichts** in die Schutz-Mechanik. Eine Methodik-Aenderung am Supply-Chain-Gate ist security-relevant und gehoert dokumentiert und reviewt — idealerweise als eigene Story durch die Pipeline (`/intent` → ... → `/implement`), nicht auto-committet. Der Skill recherchiert, vergleicht gegen den Ist-Stand, empfiehlt begruendet. Der Operator entscheidet. (INTENTRON-Leitsatz: leichtgewichtig + pragmatisch, ohne Security-Kompromisse.)

---

## Hintergrund

Slopsquatting funktioniert nur, solange ein malicious Name unbemerkt durchrutscht. Eine projekt-lokale Wordlist bekannter Faelle ist die billigste Frueherkennung — ein `grep` statt eines Registry-Roundtrips, und sie greift auch ohne Netz. Damit diese Liste belastbar bleibt, braucht sie zwei Pflege-Layer: einen **Daten-Layer**, der die Eintraege woechentlich auto-refresht (Layer 1), und einen **Methodik-Layer**, der quartalsweise prueft, ob das Refresh-Verfahren selbst noch stimmt (dieser Skill).

Die Trennung ist bewusst: Daten aendern sich schnell und automatisierbar (neue malicious Pakete taeglich) — Methodik aendert sich langsam und braucht Urteil (neue Quelle aufnehmen, Schwelle verschieben, Quelle abkuendigen). Den langsamen Teil quartalsweise und manuell zu fahren ist leichtgewichtig; ihn zu automatisieren waere Over-Engineering und wuerde eine security-relevante Entscheidung dem Review entziehen.

---

## Quellen

- **Buch:** Matthias Schrader, *Code Crash* (2025), Kap. 3-4 — Slopsquatting als KI-spezifischer Supply-Chain-Angriffsvektor, „19,7 %"-Halluzinations-Rate
- **BOO-197** — Slopsquatting-Wordlist + Quartals-Layer (dieser Skill)
- **BOO-183** — `quality-gate-audit`: prueft Existenz **und** 90-Tage-Frische der Wordlist
- **BOO-12** — `dependency-check.sh`: der Pre-Commit-Hook, der die Wordlist nutzt
- **HANDBUCH Anhang AE** — Slopsquatting-Wordlist-Pflege (Gesamtbild beider Layer)

---

## Installation und Nutzung

Skill liegt unter `~/.claude/skills/slopsquatting-deep-refresh/` (lokal) bzw. `intentron/slopsquatting-deep-refresh/` im Repo. Setzt einen verfuegbaren `/research`-Skill voraus (Deep Research). Nach dem Setup-Script (`setup.sh`) aktiviert.

Verwendung im Chat:

```
/slopsquatting-deep-refresh
```

Oder via Trigger-Phrase:

```
Slopsquatting-Quartals-Review faellig — gleich die Wordlist-Methodik gegen den aktuellen Stand ab
```

Skill laedt den Kontext, fuehrt `/research` und legt die Update-Empfehlung vor.

---

## Dateistruktur

```
intentron/slopsquatting-deep-refresh/
├── SKILL.md                          ← Skill-Definition (DE — primaer)
├── SKILL.en.md                       ← Skill-Definition (EN)
├── README.md                         ← Diese Datei (DE)
├── README.en.md                      ← Englisches README
└── references/
    └── quarterly-review-prompt.md       ← /research-Prompt-Template fuer den Quartals-Review (DE + EN)
```

> Hinweis: Der Overview-Sketch (`slopsquatting-deep-refresh-overview.excalidraw`/`.png` + `.en`) wird in einem spaeteren zentralen Render-Pass ergaenzt und fehlt aktuell noch.
