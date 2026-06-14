---
audit_id: 2026-06-14-001
triggered_by: post-install
framework_version: 1.0.0
overrides: []
summary:
  verdrahtet: 4
  nominell: 0
  blind: 0
---

# Quality-Gate-Audit — 2026-06-14

> Beispiel-Report (BOO-183). Erzeugt vom `quality-gate-audit`-Skill ueber
> `scripts/gate-checks.sh`. Dieser Baseline-Lauf prueft die `project-wired`-Referenz-Fixture
> und zeigt das Soll-Bild: alle vier Gates **verdrahtet**.
>
> `docs/audits/` ist in Git eingecheckt (Audit-Trail), aber **NICHT unter Drift-Watch** —
> Reports sind zeitpunktbezogen und sollen nicht gegen DE/EN-Paritaet oder Doc-Versionen
> geprueft werden.

## 1. Zusammenfassung

| Gate | Status |
|------|--------|
| semgrep | verdrahtet |
| coverage | verdrahtet |
| slopsquatting | verdrahtet |
| bodyguard | verdrahtet |

**Exit-Code:** 0 (alle Gates verdrahtet oder akzeptiert ueberschrieben).
**Aktive Overrides:** keine.

## 2. Gate-Details

### Semgrep-Wiring — `verdrahtet`
- **Check-Pfad:** `.semgrep/`, `.semgrep/test-fixtures/wiring-canary.py`, `.github/workflows/semgrep.yml`
- **Inspizierte Dateien:** `.semgrep/custom-rules.yml` (Regel `qgaudit-wiring-canary`), Canary-Fixture mit Marker `QGAUDIT-CANARY-DO-NOT-REMOVE` + Tripwire `QGAUDIT-CANARY-TRIPWIRE`, CI-Workflow mit `--config .semgrep/`.
- **Signal-Test-Output:** `rule fired: qgaudit-wiring-canary`
- **Begruendung:** Canary feuert (qgaudit-wiring-canary) und CI verdrahtet `--config .semgrep/`.

### Coverage — `verdrahtet`
- **Check-Pfad:** `.claude/hooks/coverage-check.sh`
- **Inspizierte Dateien:** Hook mit `COVERAGE_PASS`/`COVERAGE_WARN`, Referenz in `.claude/implement-chain.md`.
- **Signal-Test-Output:** `thresholds present; referenced`
- **Begruendung:** Hook + Schwellwerte vorhanden, in der Implement-Kette registriert.

### Slopsquatting — `verdrahtet`
- **Check-Pfad:** `.claude/hooks/slopsquatting/wordlist.txt`, `.claude/hooks/dependency-check.sh`
- **Inspizierte Dateien:** Wordlist (`last_refreshed: 2026-06-14`, 0 Tage), `dependency-check.sh` referenziert die Wordlist.
- **Signal-Test-Output:** `wordlist match: pypi:colourama`
- **Begruendung:** Wordlist frisch + referenziert + Smoke-Test feuert.

### Layer-0 Bodyguard — `verdrahtet`
- **Check-Pfad:** `.claude/hooks/pre-edit-bodyguard.sh`, `bodyguard/patterns/*.yml`, `settings.json`
- **Inspizierte Dateien:** Hook, Pattern-Dateien (`_universal.yml`, `gate-configs.yml`), settings.json mit Matcher `Edit|Write|MultiEdit`.
- **Signal-Test-Output:** `blocked: [BODYGUARD] BLOCKIERT (exit 1)`
- **Begruendung:** Synthetischer AWS-Key-Edit wird hart geblockt.

## 3. Diff zur letzten Pruefung

Erster Lauf (Baseline) — kein Diff verfuegbar. Ab dem naechsten Lauf erscheint hier, welches Gate
den Status gewechselt hat.

## 4. Naechste Schritte

- Keine. Alle vier Gates sind verdrahtet — der Sprint-Pre-Flight (`/sprint-run` Schritt 1) laeuft
  fuer dieses Projekt durch.
- Bei einem `blind`-Befund stuende hier pro Gate der konkrete Reparatur-Hinweis (fehlende Datei /
  nicht registrierter Hook) mit Verweis auf `/bootstrap` (Gate-Scaffold) bzw. die Hook-Quelle.
