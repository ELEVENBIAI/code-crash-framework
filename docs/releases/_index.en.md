# Release index — chronological

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](_index.md)

> Chronological overview (BOO-216) of **all release levels** of this repo: version overviews, wave notes and, from Sprint 3, the new **sprint/major convention**. The granular, complete wave list (newest first) lives in [`README.en.md`](README.en.md) — this file links it rather than duplicating it. Convention and tag workflow: [`README.en.md`](README.en.md). GitHub releases: <https://github.com/vibercoder79/intentron/releases>.

## Three release levels

| Level | File | Granularity |
|-------|------|-------------|
| **Wave** (granular) | `wave-<x>-<topic>.md` (+ `.en.md`) | A single change/update — source in the repo. Full list: [`README.en.md`](README.en.md). |
| **Version** (roll-up) | `v<MAJOR.MINOR.PATCH>-overview.md` | Summarizes the waves of a version — body of the GitHub release. |
| **Sprint / major** (from Sprint 3) | `_template-sprint.en.md` · `_template-major.en.md` | Sprint roll-up note (minor tag) resp. major marketing/migration note (v1.0). |

## Version overviews (actually present, newest first)

- **v0.12.0** — [`v0.12.0-overview.md`](v0.12.0-overview.md) — Sprint 5: Claude-Code-first, switches A/B/C + implement migration (BOO-199–213) · sprint note: [`sprint-5.md`](sprint-5.md)
- **v0.11.0** — [`v0.11.0-overview.md`](v0.11.0-overview.md) — Sprint 3: build-vs-buy pivot, /sprint-run on `/goal` (BOO-198–216) · sprint note: [`sprint-3.en.md`](sprint-3.en.md)
- **v0.10.1** — [`v0.10.1-overview.md`](v0.10.1-overview.md)
- **v0.10.0** — [`v0.10.0-overview.md`](v0.10.0-overview.md) — /sprint-run: sprint orchestrator (BOO-157)
- **v0.7.9 … v0.7.0** — [`v0.7.9-overview.md`](v0.7.9-overview.md) … [`v0.7.0-overview.md`](v0.7.0-overview.md)
- **v0.6.3 … v0.6.0** — [`v0.6.3-overview.md`](v0.6.3-overview.md) … [`v0.6.0-overview.md`](v0.6.0-overview.md)
- **v0.5.0** — [`v0.5.0-overview.md`](v0.5.0-overview.md)
- **v0.4.0** — [`v0.4.0-overview.md`](v0.4.0-overview.md)
- **v0.3.0** — [`v0.3.0-overview.md`](v0.3.0-overview.md)
- **v0.2.0** — [`v0.2.0-overview.md`](v0.2.0-overview.md) — governance OS (waves J–T)
- **v0.1.0** — GAP hardening (waves A–I), tagged 2026-05-22 (no own overview file).

> The corresponding **wave notes** (A … CD) are fully linked in [`README.en.md`](README.en.md) (newest first).

## New sprint/major convention (from Sprint 3)

From Sprint 3 a roll-up release note is tagged **per sprint** on a **minor version**; the individual wave notes remain the granular source. After Sprint 6 the **major release v1.0** follows.

| Sprint | Version | Note template |
|--------|---------|---------------|
| Sprint 3 | **v0.11.0** ✓ | [`sprint-3.en.md`](sprint-3.en.md) (+ [`.md`](sprint-3.md)) · [`v0.11.0-overview.md`](v0.11.0-overview.md) |
| Sprint 5 | **v0.12.0** ✓ | [`sprint-5.md`](sprint-5.md) · [`v0.12.0-overview.md`](v0.12.0-overview.md) |
| Sprint 6 | **v0.13.0** | [`_template-sprint.en.md`](_template-sprint.en.md) |
| after Sprint 6 | **v1.0.0** | [`_template-major.en.md`](_template-major.en.md) |

Patches (`vX.Y.Z`) within a sprint for catch-ups. Workflow (tag → `gh release create --notes-file …`) as described in [`README.en.md`](README.en.md).

## References

[`README.en.md`](README.en.md) (convention + full wave list) · [`_template-sprint.en.md`](_template-sprint.en.md) · [`_template-major.en.md`](_template-major.en.md) · documentation consistency: [`../standards/doku-consistency-checklist.en.md`](../standards/doku-consistency-checklist.en.md). Related: Wave BT (release index BOO-173), BOO-216 (release-notes standard).
