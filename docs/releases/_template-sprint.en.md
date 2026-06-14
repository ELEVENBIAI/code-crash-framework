# Sprint <N> — <sprint title> (v<MAJOR.MINOR.PATCH>)

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](_template-sprint.md)

> Template (BOO-216) for the **sprint release note**. Extends the existing wave/version convention (see [`README.en.md`](README.en.md)) by a **sprint level**: a sprint ends at the 80% token boundary and is tagged on a minor version. Copy into `v<version>-overview.md` (body of the GitHub release) or as a sprint roll-up note. DE part on top, EN mirror below via `---` + `# 🇬🇧 English Version` (the German source file carries both).
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

<Which doc artifacts were carried along — HANDBUCH §/appendix, runbooks, sketches, glossary, README, vault. Mirrors the documentation consistency checklist (`docs/standards/doku-consistency-checklist.en.md`).>

## Familiar language / glossary

<New domain terms of this sprint in one sentence each, referencing `docs/glossar.en.md` + HANDBUCH Appendix C. "No new terms." if none.>

## Known limitations

<What is deliberately out of scope for this sprint; delimitations; only referenced follow-up BOOs.>

## Stories mapping

| BOO | Title | Label | Wave / note |
|-----|-------|-------|-------------|
| BOO-XXX | … | … | [wave-xx-…](wave-xx-….en.md) |

## ADR references

<Linked ADRs (`docs/project/decisions/...` or documented architecture decisions). "None." if none.>

## Verification

`docs-drift-check` green (0 findings) · DE/EN parity · SKILL↔README version in lockstep · CI green (PR #NN).
