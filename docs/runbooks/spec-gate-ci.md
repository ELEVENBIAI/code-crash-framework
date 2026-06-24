# Spec-Gate (CI) — server-seitiges Spec-Linkage-Gate (opt-in)

> **Kurz:** Ein **opt-in** GitHub-Actions-Workflow, der auf jedem PR nach `main` server-seitig prüft, dass die Änderung eine existierende `specs/<ISSUE>.md` referenziert. Schliesst die Lücke des Runtime-Spec-Gates: macht „kein Merge ohne Spec" auch gegen `--no-verify` und Nicht-Claude-Pfade wahr. Aktivierung als Required Status Check. Standard aus; Empfehlung für `governance_mode = heavy` / auditpflichtige Projekte.

## Warum

Das **Runtime-Spec-Gate** (`hooks/spec-gate.sh`, ein Claude-Code-`PreToolUse`-Hook) blockt den KI-Agenten mechanisch (Exit 1): in einer governten Session entsteht kein Commit ohne ausgefüllte `specs/<ISSUE>.md`. Das ist stärker als die advisory-Gates der Konkurrenz — aber **nicht unumgehbar**: ein `git commit --no-verify`, ein menschlicher Commit ausserhalb einer Claude-Session oder ein anderes Tool kommen vorbei. Das Enforcement-Selbst-Audit (HANDBUCH Anhang AV „Enforcement-Modell & Vertrauensgrenzen") benennt diese Vertrauensgrenze offen.

Das CI-Spec-Gate schliesst sie: Es läuft **server-seitig** in GitHub Actions, ist `--no-verify`-resistent und prüft jeden PR unabhängig vom verwendeten Tool. Es ist die Server-Schicht über dem Runtime-Hook, kein Ersatz — der Hook bleibt für schnelles Feedback während der Arbeit.

## Was es prüft

1. Zieht alle Issue-Keys (Pattern `[A-Z]+-[0-9]+`) aus **Branch-Name** und **PR-Titel**. Bewusst nicht aus Commit-Messages — bei Squash-Merge werden die gequetscht und sind unzuverlässig.
2. Findet es keinen Key → **Job failt** (kein Spec-Bezug nachweisbar).
3. Existiert für mindestens einen referenzierten Key eine `specs/<KEY>.md` → **bestanden**. Sonst → **failt**.

Ein PR ohne referenzierte Spec ist damit nicht mergebar, sobald das Gate als Required Check verdrahtet ist.

## Einrichten (scaffolden)

Der Workflow ist ein Template in `bootstrap/references/file-templates.md` (Abschnitt `.github/workflows/spec-gate-ci.yml`). Zwei Wege:

- **Neues Projekt:** Bei `governance_mode = heavy` empfiehlt der Bootstrap das Gate in §7.7 „Optionale Add-ons / Nächste Schritte". Template-Inhalt nach `.github/workflows/spec-gate-ci.yml` kopieren.
- **Bestandsprojekt:** `bash bootstrap/scripts/migrate-to-v2.sh` führt `migrate_boo_254` aus — es legt `.github/workflows/spec-gate-ci.yml` an, falls es fehlt (idempotent, nicht-destruktiv), und ergänzt den Pointer im `DEVELOPER_ONBOARDING.md`.

## Als Required Check aktivieren

Das Scaffolden allein blockt noch keinen Merge — der Workflow muss ein **Required Status Check** sein:

```bash
bash bootstrap/scripts/setup-branch-protection.sh
```

Das Skript liest die Required-Kontexte **dynamisch** aus `.github/workflows/*.yml` (Top-Level-`name:`-Feld). Da der neue Workflow `name: Spec-Linkage` trägt, genügt ein **Re-Run** — kein Hand-Klicken in den GitHub-Settings. Voraussetzung: gh-Admin-Auth (siehe HANDBUCH Anhang Y „GitHub-Connect pro VPS").

Prüfen: Im PR muss der Check `Spec-Linkage` erscheinen und grün/rot den Merge steuern.

## Issue-Key & Squash-Merge

Der Key wird aus Branch-Name **oder** PR-Titel gezogen. Konvention im Repo: Branch `…/boo-254-…` und/oder PR-Titel mit `BOO-254`. So bleibt der Bezug auch bei Squash-Merge erhalten, wo Commit-Messages verloren gehen. Mehrere Keys sind erlaubt — bestanden, sobald **einer** eine Spec hat (ein PR darf einen zweiten Issue erwähnen, ohne dass dieser eine eigene Spec braucht).

## Abgrenzung

- **Runtime-Spec-Gate** (`hooks/spec-gate.sh`, PreToolUse): blockt den KI-Agenten lokal/in-session, schnelles Feedback. Bleibt aktiv.
- **CI-Spec-Gate** (dieser Workflow): blockt den Merge server-seitig, `--no-verify`-resistent, tool-unabhängig.
- **Doku-Compliance-Gate** (`scripts/doc-drift-check.sh --strict`, BOO-229): prüft die Doku-Landkarte, nicht den Spec-Bezug — orthogonal.

## Grenzen

- Prüft die **Existenz** einer referenzierten Spec, nicht deren inhaltliche Qualität (das macht der Runtime-Hook über `## Agent-Pattern`).
- `enforce_admins=false` (Solo-/Agent-Flow-Default): ein Repo-Owner kann den Required Check übersteuern. Wer das hart ziehen will, hebt `enforce_admins` an — Governance-Entscheidung, kein Default (siehe Anhang AV, Vertrauensgrenzen).

## Verweise

- HANDBUCH Anhang AW (dieser Setup-Pointer) · Anhang AV „Enforcement-Modell & Vertrauensgrenzen" (BOO-228)
- `bootstrap/scripts/setup-branch-protection.sh` · `bootstrap/references/file-templates.md` (`spec-gate-ci.yml`)
- `docs/runbooks/audit-perspective.md` (Audit-Trail = Git + `journal/reports/` + `docs/audits/`)
