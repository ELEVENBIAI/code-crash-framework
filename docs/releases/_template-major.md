# v1.0.0 — <Major-Titel>

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](_template-major.en.md)

> Vorlage (BOO-216) für das **Major-Release v1.0** nach Sprint 6. Anders als die Sprint-/Wave-Notes ist dies ein **Vermarktungs- und Migrations-Dokument**: Es fasst den Weg von der `sprint-run`-Mechanik zur `/goal`-Engine zusammen und positioniert INTENTRON gegenüber dem Anthropic-Standard. Body des GitHub Release `v1.0.0`. DE-Teil oben, EN-Spiegel unten via `---` + `# 🇬🇧 English Version`.
>
> **SemVer-Kontext:** Sprint 3 → v0.11.0 · Sprint 5 → v0.12.0 · Sprint 6 → v0.13.0 · **Major v1.0.0** danach. Sprint-Detail steht in [`_template-sprint.md`](_template-sprint.md).

## Executive Summary

<3–5 Sätze für Entscheider: was v1.0 bedeutet, was sich gegenüber 0.x grundlegend ändert, warum jetzt.>

## Pitch — was INTENTRON kann, das der Anthropic-Standard nicht hat

<USP-Komponenten ohne Anthropic-Pendant, je 1 Satz Nutzen. Ehrlich abgegrenzt: nur Komponenten nennen, die im Repo real existieren.>

| Komponente | Was sie leistet | Anthropic-Pendant |
|------------|-----------------|-------------------|
| <Komponente A> | … | — (keins) |
| <Komponente B> | … | — (keins) |

## Operator-Migrations-Pfad (0.x → 1.0)

<Nummerierte Schritte für Bestandsprojekte. Idempotent/nicht-destruktiv. Verweis auf `references/framework-upgrade.md` und HANDBUCH Anhang U (Bestands-Onboarding).>

## Schalter-Übersicht A / B / C

<Die zentralen Konfigurations-Schalter dieser Major, gruppiert. „A/B/C" als Platzhalter für die realen Schalter-Gruppen — nicht erfinden, aus dem Setup-Template ableiten.>

| Gruppe | Schalter | Default | Wirkung |
|--------|----------|---------|---------|
| A | … | … | … |
| B | … | … | … |
| C | … | … | … |

## Vorher / Nachher — Sprint-Run alt vs. /goal-Engine

<Konkreter Vergleich: wie ein Sprint vor v1.0 lief (`/sprint-run`-Orchestrator) gegen die `/goal`-Engine. Spalten Vorher/Nachher.>

| Aspekt | Vorher (Sprint-Run) | Nachher (/goal-Engine) |
|--------|---------------------|------------------------|
| <Aspekt 1> | … | … |
| <Aspekt 2> | … | … |

## ADR-Verweise

ADR-1 <…> · ADR-2 <…> · ADR-3 <…> · ADR-4 <…> · ADR-5 <…> (`docs/project/decisions/...` bzw. dokumentierte Architektur-Entscheidungen — nur real existierende verlinken).

## Verifikation

`docs-drift-check` grün (0 Befunde) · DE/EN-Parität · alle Sprint-3…6-Stories Done · CI grün · `verify-setup.sh` grün.

---

# 🇬🇧 English Version

# v1.0.0 — <major title>

> Template (BOO-216) for the **major release v1.0** after Sprint 6. Unlike the sprint/wave notes this is a **marketing and migration document**: it summarizes the path from the `sprint-run` mechanic to the `/goal` engine and positions INTENTRON against the Anthropic standard. Body of the GitHub release `v1.0.0`. DE part on top, EN mirror below via `---` + `# 🇬🇧 English Version` (the German source file carries both).
>
> **SemVer context:** Sprint 3 → v0.11.0 · Sprint 5 → v0.12.0 · Sprint 6 → v0.13.0 · **major v1.0.0** afterwards. Sprint detail lives in [`_template-sprint.en.md`](_template-sprint.en.md).

## Executive summary

<3–5 sentences for decision-makers: what v1.0 means, what fundamentally changes versus 0.x, why now.>

## Pitch — what INTENTRON does that the Anthropic standard does not

<USP components with no Anthropic counterpart, one benefit sentence each. Honestly delimited: only name components that actually exist in the repo.>

| Component | What it delivers | Anthropic counterpart |
|-----------|------------------|-----------------------|
| <component A> | … | — (none) |
| <component B> | … | — (none) |

## Operator migration path (0.x → 1.0)

<Numbered steps for existing projects. Idempotent/non-destructive. Reference `references/framework-upgrade.md` and HANDBUCH Appendix U (existing-project onboarding).>

## Switch overview A / B / C

<The central configuration switches of this major, grouped. "A/B/C" as placeholders for the real switch groups — do not invent, derive from the setup template.>

| Group | Switch | Default | Effect |
|-------|--------|---------|--------|
| A | … | … | … |
| B | … | … | … |
| C | … | … | … |

## Before / after — sprint-run old vs. /goal engine

<Concrete comparison: how a sprint ran before v1.0 (`/sprint-run` orchestrator) versus the `/goal` engine. Before/after columns.>

| Aspect | Before (sprint-run) | After (/goal engine) |
|--------|---------------------|----------------------|
| <aspect 1> | … | … |
| <aspect 2> | … | … |

## ADR references

ADR-1 <…> · ADR-2 <…> · ADR-3 <…> · ADR-4 <…> · ADR-5 <…> (`docs/project/decisions/...` or documented architecture decisions — link only those that actually exist).

## Verification

`docs-drift-check` green (0 findings) · DE/EN parity · all Sprint 3…6 stories done · CI green · `verify-setup.sh` green.
