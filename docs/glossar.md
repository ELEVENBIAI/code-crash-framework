# Glossar für Nicht-Entwickler (Klartext)

> Schulungs-Glossar (BOO-131): die wichtigsten Framework-Begriffe in 1–2 Sätzen, mit Alltagsanalogie — für Fachseite, Management und Kunden. Die technische Kurzfassung steht in **HANDBUCH Anhang C**. EN: [`glossar.en.md`](glossar.en.md).

## Grundbegriffe

- **Repository (Repo)** — der zentrale Ordner, in dem der gesamte Code + die Doku eines Projekts liegen, inkl. voller Änderungs-Historie. *Analogie:* der Aktenschrank des Projekts, in dem jede Version archiviert ist.
- **Commit** — ein gespeicherter Änderungs-Stand mit kurzer Beschreibung. *Analogie:* ein „Speichern + Notiz, was ich geändert habe".
- **Branch** — eine parallele Arbeitskopie, auf der man gefahrlos arbeitet, ohne den Hauptstand zu stören. *Analogie:* ein Entwurf neben dem Original.
- **`main`** — der Hauptstand, der immer funktionieren soll. *Analogie:* die freigegebene Reinschrift.
- **Pull Request (PR) / Merge** — der Antrag, eine Branch-Änderung in `main` zu übernehmen — erst nach Prüfung. *Analogie:* „Bitte um Freigabe", bevor der Entwurf in die Reinschrift einfließt.

## Qualität & Automatik

- **Gate** — eine automatische Prüfung, die durchlaufen sein muss, bevor es weitergeht. *Analogie:* die Schranke, die nur bei grün öffnet.
- **Hook** — ein kleines Skript, das bei einem bestimmten Ereignis (z. B. vor dem Speichern) automatisch losläuft. *Analogie:* ein Bewegungsmelder, der bei Auslösung etwas anstößt.
- **Linter** — ein Werkzeug, das den Code automatisch auf Stil- und Flüchtigkeitsfehler prüft. *Analogie:* die Rechtschreibprüfung für Code.
- **SAST** (Static Application Security Testing) — automatische Suche nach Sicherheitslücken im Code, ohne ihn auszuführen. *Analogie:* der TÜV liest die Baupläne, statt das Auto zu fahren.
- **Runner** — der Computer (oft in der Cloud), der die automatischen Prüfungen ausführt. *Analogie:* der Prüfstand, auf dem die Tests laufen.
- **CI** (Continuous Integration) — die Automatik, die bei jeder Änderung alle Prüfungen auf dem Runner startet. *Analogie:* die Endkontrolle am Fließband, die bei jedem Stück anspringt.
- **Branch-Protection** — die Regel, die direktes Ändern von `main` verbietet und PR + grüne Gates erzwingt. *Analogie:* „Nur über die Qualitätskontrolle, kein Schleichweg in die Reinschrift."
- **Auditor** — eine prüfende Person (Cyber-Security oder Code-Qualität), die nachträglich kontrolliert, ob das Framework auch wirklich eingehalten wurde — ohne selbst etwas zu ändern. *Analogie:* die Wirtschaftsprüferin, die die Bücher liest, aber nicht mitbucht. Eigenes Einstiegs-Runbook: [`audit-perspective.md`](runbooks/audit-perspective.md).
- **Audit-Trail** — die lückenlose Spur, die jede Änderung zurück auf ihre dokumentierte Absicht und den auslösenden Arbeitsschritt führt (Commit → Spec → Session). *Analogie:* der Belegfluss in der Buchhaltung: zu jeder Buchung gibt es einen Beleg.
- **Audit-Artefakt** — ein vom Framework erzeugter Nachweis, den ein Auditor einsehen kann (z. B. Prüf-Reports, Datenschutz-Audit, Sprint-Metriken). *Analogie:* die abgestempelten Prüfprotokolle im Ordner. Wichtig ist die Haltbarkeit: dauerhaft im Repo, 30 Tage in der CI, oder nur flüchtig auf dem Arbeitsrechner.
- **Slopsquatting** — wenn eine KI ein Paket empfiehlt, das gar nicht existiert, und ein Angreifer genau diesen erfundenen Namen mit Schadcode belegt. Das Framework hält dagegen eine Liste bekannter Fake-/Schad-Pakete (eine *Wordlist*), die regelmäßig aufgefrischt wird. *Analogie:* eine schwarze Liste gefälschter Lieferanten, die nur frisch gehalten etwas taugt.
- **Wiring-Canary** ("Verdrahtungs-Kanarienvogel") — eine kleine Test-Datei mit einem absichtlichen Fehler, die nur dann eine Meldung auslöst, wenn die Prüfung wirklich angeschlossen ist. Bleibt es still, ist die Prüfung blind. *Analogie:* der Kanarienvogel im Bergwerk — solange er singt, funktioniert die Warnung.

## Audit & Steuerung

- **Schwellwert (Threshold)** — die Grenze, ab der eine Prüfung als bestanden, gewarnt oder durchgefallen gilt (z. B. Test-Abdeckung: ab 80 % grün, ab 60 % gelb; Wordlist max. 90 Tage alt; Architektur-Doku max. 30 Tage hinter dem Code). *Analogie:* die Messlatte mit grüner, gelber und roter Markierung.
- **Audit-Status** `verdrahtet` / `nominell` / `blind` — wie eine Prüfung beim Verdrahtungs-Check abschneidet: *verdrahtet* = angeschlossen und feuert, *nominell* = zwar eingerichtet, läuft aber nie (trügerische Sicherheit), *blind* = behauptet zu prüfen, prüft nichts. *Analogie:* ein Rauchmelder, der piept (verdrahtet), einer ohne Batterie an der Decke (nominell) und einer, der nur aufgemalt ist (blind).
- **Sprint** vs. **Cycle** — ein *Sprint* ist hier eine Arbeitseinheit, die in ein Token-Fenster der KI passt (ca. 80 % davon), kein fester Kalender-Zeitraum. *Cycles* (das Linear-eigene Zeittakt-Konzept) sind bewusst nicht aktiviert; die Sprint-Zuordnung steht in `Sprints.md`. *Analogie:* wir messen die Etappe nicht in Tagen, sondern darin, wie viel die KI am Stück überblicken kann.

## Doku & Steuerung

- **Spec** (Specification) — die kurze Vorgabe, *was* eine Aufgabe genau leisten soll, bevor Code entsteht. *Analogie:* der Bauauftrag mit Abnahmekriterien.
- **ADR** (Architecture Decision Record) — ein kurzes Dokument, das eine wichtige Entscheidung samt Begründung festhält. *Analogie:* das Protokoll „Wir haben X entschieden, weil Y".
- **Bootstrap** — der einmalige Einrichtungs-Lauf, der ein Projekt mit allen Regeln, Vorlagen und Prüfungen aufsetzt. *Analogie:* die Werkseinrichtung, bevor produziert wird.
- **Skill** — ein wiederholbarer KI-Arbeitsablauf, den man mit `/name` aufruft (z. B. `/ideation`, `/implement`). *Analogie:* ein eingespieltes Standard-Verfahren auf Knopfdruck.
- **Scaffold** — das automatische Anlegen der Grundgerüst-Dateien (leere Vorlagen). *Analogie:* das Baugerüst + Rohbau, das später gefüllt wird.

## KI-Anbindung

- **MCP** (Model Context Protocol) — der genormte „Stecker", über den die KI sichere Verbindungen zu Tools/Daten bekommt (z. B. Linear, GitHub). *Analogie:* die USB-Norm für KI-Werkzeuge.
- **Agent / Sub-Agent** — eine KI-Instanz, die eine abgegrenzte Aufgabe eigenständig erledigt. *Analogie:* eine Fachkraft mit klarem Auftrag.

## Strategie & Native-Pfade (ab Sprint 3)

- **Build-vs-Buy-Doktrin** — die Leitregel, Fähigkeiten, die der KI-Anbieter (Anthropic) selbst nativ liefert, zu *nutzen* statt sie im Framework nachzubauen. *Analogie:* kein eigenes Kraftwerk bauen, wenn es einen zuverlässigen Stromanschluss gibt. (ADR-1)
- **Claude-Code-first / Native Pfade (Schalter A/B/C)** — drei Schalter, die das Framework auf die nativen Claude-Code-Funktionen umstellen, statt eigene Nachbauten zu fahren. *Analogie:* die Werkseinstellung auf „Hersteller-Originalteile" stellen.
- **`/goal` (Termination-Engine)** — die native Funktion, die einen automatischen Lauf so lange wiederholt, bis das Ziel (alle Prüfungen grün) erreicht ist, und dann sauber stoppt. *Analogie:* der Tempomat, der erst abschaltet, wenn das Ziel erreicht ist.
- **Native Subagent** — eine eigenständige KI-Instanz mit eigenem, frischem Arbeitsspeicher (Kontextfenster), die eine Teilaufgabe unabhängig erledigt. *Analogie:* eine Fachkraft mit eigenem, leerem Schreibtisch statt einer, die sich denselben überfüllten Tisch teilt.
- **Ultraplan** — ein besonders gründlicher Planungs-Lauf in der Cloud, der bei großen Stories (über 5 Story Points) automatisch vorgeschlagen wird. *Analogie:* vor dem großen Umbau erst den Architekten lange planen lassen, statt sofort loszuschlagen.
- **`/insights`** — eine native Auswertung am Sprint-Ende, die den eigenen Sprint-Review ergänzt. *Analogie:* die zweite Meinung nach dem eigenen Rückblick. (Skill `insights-review`)
- **Worker-Equivalent** — die Umrechnung des KI-Aufwands in „so viele Menschen-Arbeitsstunden hätte das gekostet", als ROI-Anker neben den reinen Token-Kosten. *Analogie:* der Wechselkurs zwischen KI-Zeit und Personentagen.
- **Status Line** — die native Statuszeile von Claude Code, hier angereichert um Modell, Budget und Worker-Equivalent — der Live-Tacho der Arbeit. *Analogie:* das Armaturenbrett, das Tempo und Tankstand auf einen Blick zeigt.
- **Native-Feature-Beobachtung** — eine monatliche Erinnerung, die meldet, sobald eine nachgebaute Funktion inzwischen nativ verfügbar ist und neu bewertet werden sollte. *Analogie:* die Notiz „prüfen, ob es das jetzt fertig zu kaufen gibt", bevor man weiter selbst bastelt.

## Verweise

Technische Kurz-Definitionen: HANDBUCH **Anhang C**. Wie das alles zusammen dokumentiert wird: [`how-we-document.md`](how-we-document.md).
