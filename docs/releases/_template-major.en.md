# v1.0.0 — <major title>

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](_template-major.md)

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
