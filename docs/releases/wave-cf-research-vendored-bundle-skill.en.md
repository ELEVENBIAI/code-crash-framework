# Wave CF — research as a vendored bundle skill: self-contained fix (BOO-219)

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](wave-cf-research-vendored-bundle-skill.md)

**What's here now:** the `research` skill now lives as a **vendored bundle skill** directly in the `intentron` repo — analogous to `dpo` and `security-architect` (BOO-74). An external operator reported that `/research` was not installable: for the optional general-purpose skills, bootstrap pointed at the `vibercoder79/claudecodeskills` repo, which is **private** and surfaces to external users as "Could not resolve to a Repository". At the same time bootstrap makes **Phase 4.10 (Domain Deep Research)** with `/research` **mandatory** — a mandatory step hanging off a private repo unreachable for externals. With this wave, a single `git clone` of the framework is self-contained.

## The lesson — a mandatory phase must not depend on a private dependency

Bootstrap guarantees domain knowledge before stories get written (Schrader ch. 2). That guarantee was hollow as long as its engine (`/research`) only came from a private repo that the GraphQL API presents as non-existent to externals. The fix follows the established vendoring pattern: the master stays in `claudecodeskills` (via `publish_skill.py`), the framework repo holds the mirror. Solo-operator usage is preserved and the framework becomes self-contained anyway.

## Changes

- **Vendoring:** `research/` now lives as a top-level bundle skill in the `intentron` repo — including `SKILL.md` + `SKILL.en.md`, `README.md` + `README.en.md`, `references/perplexity-api.md(.en)` and overview diagrams (DE+EN). DE+EN parity was added as part of the vendoring (the master in `claudecodeskills` does not carry it yet — backfill on the next `publish_skill.py research`).
- **Bootstrap skill (v3.42.0, DE+EN):** `research` is in the **Minimum set** (because Phase 4.10 is mandatory). The "Optional general-purpose skills from claudecodeskills" block (Phase 5) is **removed** — no optional bulk-clone question anymore. Phase 4.10 carries a note that `/research` is guaranteed to be present as a bundle skill.
- **Source guarantee (`check-skill-sources.sh`):** `research` moved from `GENERAL_SKILLS` to `BUNDLE_SKILLS`; the mirror-integrity check now covers it automatically. `GENERAL_SKILLS` is empty.
- **References (DE+EN):** `skills-setup`, `provider-postflight`, `optional-components` brought up to date; the stale `git clone claudecodeskills` / `intentron/` nesting paths in the skills-setup installation and update scripts corrected to `intentron` + flat layout.
- **README (DE+EN):** `research` moved from the "Top-level companion skills" block into the "Specialist bundle skills (vendored)" table (link `research/` instead of `../research/`).

## Migration — bringing existing projects up to date

- **New bootstrap runs** install `research` automatically from the framework repo (Minimum set). No `claudecodeskills` access needed anymore.
- **Existing installs** with `research` from `claudecodeskills` keep working; a future update pulls the skill from `intentron` (see `skills-setup.en.md` update strategy).

## Scope boundary

- **Deliberately NOT vendored:** `design-md-generator` and `skill-creator` stay global/standalone; `setup-checklist` stays its own public repo (BOO-113). Only the optional bulk-clone question is dropped.
- **`migration-checklist-v1-to-v2`** is a historical document and was left untouched.
- **No separate framework version tag** — this wave is a docs/structure release note. Bootstrap skill version 3.42.0.
- Wave letter **cf** (ce = Worker-Equivalent BOO-190–193).

## References

Corrects the companion decision from **BOO-58 / F020**. Vendoring pattern from **BOO-73/74** (dpo + security-architect), source guarantee from **BOO-121**. Spec: `specs/BOO-219.md`. Related: README, HANDBUCH §4 / skill-installation.
