# Wave CD — Semgrep Custom-Rule-Wiring + Verifikations-Canary (BOO-185 / BOO-188)

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](wave-cd-semgrep-custom-rule-wiring.en.md)

**Was jetzt da ist:** Der Bootstrap rollt projekt-eigene Semgrep-Regeln nicht mehr nur nominell aus, sondern **verdrahtet** sie nachweisbar. Neu im Setup-Template: das Custom-Rule-Verzeichnis `.semgrep/`, das CI (Layer 3) und Pre-Commit (Layer 2) via `--config .semgrep/` **zusätzlich** zu den Registry-Packs aus `.semgrep.yml` laden — sobald das Verzeichnis existiert. Dazu ein **Wiring-Canary**: eine Custom-Rule plus eine Fixture-Datei mit einem absichtlichen Verstoss, die beweist, dass das Gate wirklich feuert. Die Lehre dahinter ist die eigentliche Welle: **Ein nominell konfiguriertes Gate ist ein blindes Gate.**

## Die Lehre — nominell vs. verdrahtet

Ein Custom-Rule-Verzeichnis kann existieren, korrekt befüllt sein und trotzdem **nie laufen** — nämlich dann, wenn es nie via `--config` an die Semgrep-CLI übergeben wird. Das Gate ist dann **faktisch blind**: Es sieht aus wie eine Kontrolle, prüft aber nichts. Genau dieser Befund steht hinter dem ADR „Semgrep Custom-Rule-Wiring — Verifikations-Pattern für Quality Gates" (2026-06-11).

Die Gegenmassnahme ist ein **Verifikations-Pattern**, kein Kommentar und keine Doku-Zeile: eine Testdatei mit einem absichtlichen Verstoss (Canary), die genau dann eine Meldung produziert, wenn das Gate wirklich greift. Ein Treffer beweist die lebende Verdrahtung; Stille beweist, dass das Gate blind ist. Das Pattern ist **auf andere Gates übertragbar** — Slopsquatting-Check, Coverage-Schwelle, Layer-0-Bodyguard: überall, wo ein Gate „konfiguriert" und „wirklich aktiv" auseinanderfallen können, macht eine Canary den Unterschied beweisbar statt geglaubt.

## Änderungen

- **Custom-Rule-Template `.semgrep/custom-rules.yml` (BOO-185):** projekt-eigene Semgrep-Regeln, die via `--config .semgrep/` zusätzlich zu den Registry-Packs geladen werden. Enthält die Regel `qgaudit-wiring-canary`, die ausschliesslich den literalen Tripwire `QGAUDIT-CANARY-TRIPWIRE` trifft — ein Literal, das die Registry-Packs (`p/security-audit`, `p/secrets`, …) **nicht** melden würden. Feuert die Regel beim gezielten Audit-Scan, ist `--config .semgrep/` beweisbar aktiv. (`bootstrap/references/file-templates.md` + `.en`.)
- **Canary-Fixture `.semgrep/test-fixtures/wiring-canary.py` (BOO-185):** trägt den Tripwire-Literal und den Marker `# QGAUDIT-CANARY-DO-NOT-REMOVE`. Solange der gezielte Scan (`semgrep --config .semgrep/ .semgrep/test-fixtures/wiring-canary.py`) den Canary meldet, gilt die Custom-Rule-Schicht als **verdrahtet**; meldet er nichts, ist sie **blind**.
- **`.semgrepignore` schliesst `.semgrep/test-fixtures/` aus:** der Canary ist eine `ERROR`-Severity-Regel. Liefe er im Repo-weiten Scan mit, wäre die CI neuer Projekte **dauerrot**. Der Canary wird daher **nur** vom gezielten Audit-Scan erfasst, nie vom normalen CI-/Pre-Commit-Scan.
- **CI-Workflow + Pre-Commit-Hook verdrahten `--config .semgrep/`:** sowohl `.github/workflows/semgrep.yml` (Layer 3) als auch der lokale Pre-Commit-Hook (Layer 2) laden beide Quellen — die Registry-Packs aus `.semgrep.yml` **und** die Custom-Rules aus `.semgrep/`, sobald das Verzeichnis existiert. Zwei Quellen, eine Action.
- **Anker für die Automatisierung:** Der künftige `quality-gate-audit`-Skill (BOO-183) nutzt diesen Canary als Wiring-Beweis und schlägt Alarm, wenn der gezielte Scan stumm bleibt.

## Migration — bestehende Projekte nachziehen

Bestandsprojekte ziehen die Custom-Rule-Schicht in drei Schritten nach (idempotent, nicht-destruktiv):

1. **`.semgrep/custom-rules.yml` anlegen** mit der Regel `qgaudit-wiring-canary` (Vorlage: `bootstrap/references/file-templates.md` §`.semgrep/custom-rules.yml`).
2. **`.semgrep/test-fixtures/wiring-canary.py` anlegen** mit dem Tripwire-Literal und dem `# QGAUDIT-CANARY-DO-NOT-REMOVE`-Marker, und **`.semgrep/test-fixtures/` in `.semgrepignore` eintragen** — sonst wird die CI dauerrot.
3. **`--config .semgrep/` in CI-Workflow und Pre-Commit-Hook ergänzen** (Pattern „sobald `.semgrep/` existiert" aus den `semgrep.yml`- und `pre-commit`-Templates).

Verifizieren: `semgrep --config .semgrep/ .semgrep/test-fixtures/wiring-canary.py` muss `qgaudit-wiring-canary` melden. Tut es das nicht, ist die Verdrahtung noch blind.

## Abgrenzung

- **Allgemeingültig** für alle Stacks — Custom-Rule-Verzeichnis und Canary sind tool-, nicht stackspezifisch.
- **Deterministisch** — eine ausführbare Regel gegen ein festes Tripwire-Literal, kein Prompt.
- Die Setup-Template-Technik (BOO-185) ist bereits in `bootstrap/references/file-templates.md` + `.en` umgesetzt; **diese Welle** (BOO-188) verankert die Lehre in Release-Note, README und Bootstrap-Doku.
- Die Audit-Automatisierung (gezielter Scan + Alarm) bleibt der `quality-gate-audit`-Skill **BOO-183** (nur referenziert).
- Wave-Buchstabe **cd** (cc = Linter-Verdrahtung E2E BOO-182).

## Verweise

ADR: „Semgrep Custom-Rule-Wiring — Verifikations-Pattern für Quality Gates" (2026-06-11). Verwandt: BOO-185 (Custom-Rule-Wiring im Setup-Template), BOO-183 (`quality-gate-audit`-Skill), BOO-182 (Linter-Verdrahtung E2E), BOO-176 (Quality-Gate-Integrität), BOO-4/BOO-3 (Semgrep Layer 2/3).
