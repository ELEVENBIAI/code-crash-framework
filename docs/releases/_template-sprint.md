# Sprint <N> — <Sprint-Titel> (v<MAJOR.MINOR.PATCH>)

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](_template-sprint.en.md)

> Vorlage (BOO-216) für die **Sprint-Release-Note**. Ergänzt die bestehende Wave-/Version-Konvention (siehe [`README.md`](README.md)) um eine **Sprint-Ebene**: Ein Sprint endet am 80%-Token-Boundary und wird auf eine Minor-Version getaggt. Kopieren nach `v<version>-overview.md` (Body des GitHub Release) oder als Sprint-Sammelnote. DE-Teil oben, EN-Spiegel unten via `---` + `# 🇬🇧 English Version`.
>
> **SemVer-Korrelation:** Sprint 3 → **v0.11.0** · Sprint 5 → **v0.12.0** · Sprint 6 → **v0.13.0** (Major **v1.0.0** nach Sprint 6 — siehe [`_template-major.md`](_template-major.md)). Patches (`vX.Y.Z`) innerhalb eines Sprints für Nachzüge.

## Highlights

<2–4 Bullet-Sätze: was dieser Sprint dem Operator bringt. Das „Big Picture" zuerst.>

## Was sich ändert

<Was neu/anders ist — Mechanik, Skills, Gates, Templates. Pro Punkt mit BOO-Nummer.>

## Breaking Changes

<Inkompatible Änderungen. „Keine." wenn keine — den Abschnitt nie weglassen.>

## Migrations-Anleitung

<Bestandsprojekte nachziehen, idempotent/nicht-destruktiv, nummerierte Schritte. Verweis auf `references/framework-upgrade.md` (`inspect → apply-safe → apply-with-confirmation`) wo zutreffend.>

## Schalter & Konfiguration

<Neue/geänderte Opt-in-/Opt-out-Schalter, Setup-Fragen, Env-Variablen. „Keine." wenn keine.>

## Doku-Updates

<Welche Doku-Artefakte mitgezogen wurden — HANDBUCH-§/Anhang, Runbooks, Sketches, Glossar, README, Vault. Spiegelt die Doku-Konsistenz-Checkliste (`docs/standards/doku-consistency-checklist.md`).>

## Vertraute Sprache / Glossar

<Neue Fachbegriffe dieses Sprints in 1 Satz, mit Verweis auf `docs/glossar.md` + HANDBUCH Anhang C. „Keine neuen Begriffe." wenn keine.>

## Bekannte Limitierungen

<Was bewusst nicht Teil dieses Sprints ist; Abgrenzungen; nur referenzierte Folge-BOO.>

## Stories-Mapping

| BOO | Titel | Label | Wave / Note |
|-----|-------|-------|-------------|
| BOO-XXX | … | … | [wave-xx-…](wave-xx-….md) · [EN](wave-xx-….en.md) |

## ADR-Verweise

<Verlinkte ADRs (`docs/project/decisions/...` bzw. dokumentierte Architektur-Entscheidungen). „Keine." wenn keine.>

## Verifikation

`docs-drift-check` grün (0 Befunde) · DE/EN-Parität · SKILL↔README-Version gleichstand · CI grün (PR #NN).

---

# 🇬🇧 English Version

# Sprint <N> — <sprint title> (v<MAJOR.MINOR.PATCH>)

> Template (BOO-216) for the **sprint release note**. Extends the existing wave/version convention (see [`README.en.md`](README.en.md)) by a **sprint level**: a sprint ends at the 80% token boundary and is tagged on a minor version. Copy into `v<version>-overview.md` (body of the GitHub release) or as a sprint roll-up note. DE part on top, EN mirror below via `---` + `# 🇬🇧 English Version`.
>
> **SemVer correlation:** Sprint 3 → **v0.11.0** · Sprint 5 → **v0.12.0** · Sprint 6 → **v0.13.0** (major **v1.0.0** after Sprint 6 — see [`_template-major.en.md`](_template-major.en.md)). Patches (`vX.Y.Z`) within a sprint for catch-ups.

## Highlights

<2–4 bullet sentences: what this sprint delivers to the operator. The "big picture" first.>

## What changes

<What is new/different — mechanics, skills, gates, templates. One point per BOO number.>

## Breaking changes

<Incompatible changes. "None." if none — never omit the section.>

## Migration guide

<Bring existing projects up to date, idempotent/non-destructive, numbered steps. Reference `references/framework-upgrade.md` (`inspect → apply-safe → apply-with-confirmation`) where applicable.>

## Switches & configuration

<New/changed opt-in/opt-out switches, setup questions, env variables. "None." if none.>

## Documentation updates

<Which doc artifacts were carried along — HANDBUCH §/appendix, runbooks, sketches, glossary, README, vault. Mirrors the documentation consistency checklist (`docs/standards/doku-consistency-checklist.md`).>

## Familiar language / glossary

<New domain terms of this sprint in one sentence each, referencing `docs/glossar.en.md` + HANDBUCH Appendix C. "No new terms." if none.>

## Known limitations

<What is deliberately out of scope for this sprint; delimitations; only referenced follow-up BOOs.>

## Stories mapping

| BOO | Title | Label | Wave / note |
|-----|-------|-------|-------------|
| BOO-XXX | … | … | [wave-xx-…](wave-xx-….md) · [EN](wave-xx-….en.md) |

## ADR references

<Linked ADRs (`docs/project/decisions/...` or documented architecture decisions). "None." if none.>

## Verification

`docs-drift-check` green (0 findings) · DE/EN parity · SKILL↔README version in lockstep · CI green (PR #NN).
