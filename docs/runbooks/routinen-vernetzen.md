# Runbook: Routinen intelligent vernetzen

> Quelle: ADR-2 Schalter C. Bootstrap **fragt nicht** nach Routines-Defaults — Aufstellungen sind
> operator- und umgebungsspezifisch. Dieses Runbook beschreibt drei Aufstellungs-Optionen und sieben
> Routinen-Vorschläge mit kopierbereiten Prompt-Blöcken. Du entscheidest, was du einrichtest.

Eine „Routine" ist ein wiederkehrender, terminierter Lauf eines Framework-Skills (z.B. täglich
`/backlog`-Triage). Der Wert entsteht durch **Vernetzung**: die Routinen füttern sich gegenseitig
(Backlog-Triage → Sprint-Review → Quality-Gate-Audit) und halten das Projekt zwischen aktiven Sessions
gesund.

---

## Drei Aufstellungs-Optionen

| Option | Mechanik | Vorteile | Nachteile |
|--------|----------|----------|-----------|
| **1. Developer-VPS** | Anthropic-Routines / Scheduled Agents in der Cloud | immer an; keine lokale Maschine nötig; zentral fürs Team | VPS-Kosten; Secrets/Repo-Zugang auf dem VPS einrichten |
| **2. Lokales MacBook** | `cron` + Claude-CLI lokal | nichts zu hosten; nutzt bestehende Auth | läuft nur wenn der Mac an ist; persönlich, nicht geteilt |
| **3. Lokaler Server / NAS / Raspberry Pi** | `cron` + Claude-CLI im Always-on | immer an, lokal, kostengünstig | Einrichtung/Wartung der Maschine; Repo-Klon + Auth nötig |

**Faustregel:** Solo + unregelmäßig → Option 2. Solo + verlässlich → Option 3. Team / mehrere Projekte →
Option 1. Die Prompt-Blöcke unten sind aufstellungs-neutral — nur der Auslöser (Anthropic-Routine vs.
`cron`-Eintrag) unterscheidet sich.

---

## Sieben Routinen

Pro Routine: **Ziel · Trigger-Phrase · Skill · Output-Ort · Aufstellungs-Eignung · Prompt-Block** (zum
Kopieren). Routinen 1–3 sind das **Pflicht-Set**, 4–7 optional.

### 1. Backlog-Triage (täglich) — Pflicht-Set

- **Ziel:** offene Issues priorisieren, Sprint-Fit prüfen, Drift früh fangen.
- **Trigger-Phrase:** „Triage den Backlog."
- **Skill:** `/backlog`
- **Output-Ort:** Backlog-Tool (Linear/GitHub) + ggf. `journal/`
- **Eignung:** alle drei Aufstellungen.

```text
Lauf /backlog im Triage-Modus für dieses Projekt: priorisiere offene Issues, prüfe Sprint-Fit
(80%-Token-Window), markiere Stories ohne vollständige Spec als nicht sprint-ready und melde die
Top-5-Kandidaten für den nächsten Sprint. Keine Code-Änderung. Fasse das Ergebnis in 5 Zeilen zusammen.
```

### 2. Sprint-Review (wöchentlich) — Pflicht-Set

- **Ziel:** Architektur-Gesundheit, Tech-Debt, Learning-Loop-Eintrag.
- **Trigger-Phrase:** „Mach das Sprint-Review."
- **Skill:** `/sprint-review`
- **Output-Ort:** `journal/sprint-{date}.md`
- **Eignung:** alle; bei aktivem `complement_insights` zusätzlich `insights-review` (Operator-Reflexion).

```text
Lauf /sprint-review für dieses Projekt: System-Snapshot, Governance-Drift, Tech-Debt-Inventur,
Backlog-Hygiene, Anti-Pattern-Selbstdiagnose und Learning-Loop-Eintrag in journal/sprint-{date}.md.
Wenn complement_insights aktiv ist: ergänze den Operator-Reflexions-Meta-Block (insights-review). Melde
die drei wichtigsten Befunde + Maßnahmen.
```

### 3. Quality-Gate-Self-Audit (monatlich) — Pflicht-Set

- **Ziel:** prüfen, ob die deklarierten Gates wirklich **verdrahtet** sind (nicht nur konfiguriert).
- **Trigger-Phrase:** „Audite die Quality-Gates."
- **Skill:** `/quality-gate-audit`
- **Output-Ort:** `docs/audits/YYYY-MM-DD-quality-gate-audit.md`
- **Eignung:** alle.

```text
Lauf /quality-gate-audit für dieses Projekt: prüfe, ob Semgrep-Wiring, Coverage-Gate, Slopsquatting und
der Layer-0-Edit-Bodyguard tatsächlich verdrahtet sind (wired vs. blind). Schreibe den Audit-Report nach
docs/audits/. Bei mindestens einem blinden Gate: melde es prominent mit Reparatur-Hinweis.
```

### 4. Dependency-Drift (wöchentlich) — Slopsquatting-Check

- **Ziel:** neue/aktualisierte Dependencies gegen Slopsquatting/Halluzinations-Pakete prüfen.
- **Trigger-Phrase:** „Prüfe Dependency-Drift."
- **Skill:** Slopsquatting-Wordlist-Check (`/slopsquatting-deep-refresh` bzw. `.github/workflows/slopsquatting-refresh.yml`)
- **Output-Ort:** `.claude/hooks/slopsquatting/wordlist.txt` + Report
- **Eignung:** Option 1/3 (Always-on bevorzugt).

```text
Prüfe die Dependencies dieses Projekts auf Slopsquatting-/Halluzinations-Pakete: aktualisiere die
Slopsquatting-Wordlist und gleiche neue oder geänderte Abhängigkeiten dagegen ab. Melde jeden Treffer
mit Paketname, Quelle und Risikoeinschätzung. Keine Auto-Installation.
```

### 5. Doku-Drift (monatlich) — CLAUDE.md vs CONVENTIONS.md

- **Ziel:** Governance-Doku synchron halten; tote References + Versions-Drift finden.
- **Trigger-Phrase:** „Prüfe Doku-Drift."
- **Skill:** `python3 .github/scripts/docs_drift_check.py` + manueller CLAUDE.md/CONVENTIONS.md-Abgleich
- **Output-Ort:** Konsole / Issue bei Drift
- **Eignung:** alle.

```text
Prüfe die Doku-Konsistenz dieses Projekts: lauf python3 .github/scripts/docs_drift_check.py und gleiche
CLAUDE.md gegen CONVENTIONS.md ab (runtime_target, governance_mode, aktive Gates, Native-Pfade-Block).
Melde jede Abweichung, tote references/-Links und Versions-Drift. Bei Drift: schlage einen konkreten Fix
vor, ändere aber nichts ohne Freigabe.
```

### 6. Cost-Drift (wöchentlich) — Token-Tracking & Cache-Hit-Rate

- **Ziel:** Token-/Kosten-Verbrauch und Cache-Effizienz im Blick behalten.
- **Trigger-Phrase:** „Prüfe Cost-Drift."
- **Skill:** ccusage-Snapshot (`docs/financials/sprint-costs.md`)
- **Output-Ort:** `docs/financials/sprint-costs.md`
- **Eignung:** alle; besonders bei Daemon-/Sprint-Run-Nutzung.

```text
Erfasse einen Token-/Kosten-Snapshot für dieses Projekt (ccusage gegen die lokalen Claude-Code-JSONL-Logs)
und hänge ihn an docs/financials/sprint-costs.md an. Vergleiche mit der Vorwoche: melde auffällige
Kosten-Drift, schlechte Cache-Hit-Rate oder Sprint-Läufe, die das Token-Budget gerissen haben.
```

### 7. Hermes-Health (monatlich) — nur wenn Hermes-VPS aktiv

- **Ziel:** Gesundheit der Hermes-Beobachtungs-/Orchestrierungs-Schicht prüfen.
- **Trigger-Phrase:** „Prüfe Hermes-Health."
- **Skill:** Hermes-Health-Check (projektspezifisch)
- **Output-Ort:** Hermes-Log / Report
- **Eignung:** nur Option 1/3 mit aktivem Hermes-VPS.

```text
Prüfe die Hermes-Schicht dieses Projekts (nur wenn aktiv): laufen die Hermes-Daemons, sind die
Beobachtungs-Trigger gesetzt, gibt es Fehler im Hermes-Log? Melde den Status in 5 Zeilen. Wenn Hermes
nicht eingerichtet ist: brich ab mit Hinweis „Hermes nicht aktiv — Routine überspringen".
```

---

## Einrichtung pro Aufstellung (Kurz)

- **Option 1 (Developer-VPS):** Routine pro Prompt-Block als Anthropic Scheduled Agent / Routine anlegen
  (siehe `/schedule`). Repo-Klon + Auth + Secrets einmalig auf dem VPS.
- **Option 2 (MacBook) / Option 3 (Server/NAS/Pi):** `cron`-Eintrag pro Routine, der die Claude-CLI im
  Projekt-Verzeichnis mit dem Prompt-Block startet. Beispiel-Frequenzen: täglich `0 8 * * *`, wöchentlich
  `0 8 * * 1`, monatlich `0 8 1 * *`.

> **Leichtgewicht (Designprinzip):** Fang mit dem Pflicht-Set (1–3) an. 4–7 nur, wenn der konkrete
> Bedarf da ist — keine Routine ohne Nutzen.
