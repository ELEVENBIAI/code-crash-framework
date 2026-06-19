# Release-Index — chronologisch

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](_index.en.md)

> Chronologischer Überblick (BOO-216) über **alle Release-Ebenen** dieses Repos: Versions-Overviews, Wave-Notes und ab Sprint 3 die neue **Sprint-/Major-Konvention**. Die granulare, vollständige Wave-Liste (neueste zuerst) steht im [`README.md`](README.md) — diese Datei verlinkt sie, statt sie zu duplizieren. Konvention und Tag-Workflow: [`README.md`](README.md). GitHub Releases: <https://github.com/vibercoder79/intentron/releases>.

## Drei Release-Ebenen

| Ebene | Datei | Granularität |
|-------|-------|--------------|
| **Wave** (granular) | `wave-<x>-<thema>.md` (+ `.en.md`) | Ein einzelner Change/Update — Quelle im Repo. Vollständige Liste: [`README.md`](README.md). |
| **Version** (Sammel) | `v<MAJOR.MINOR.PATCH>-overview.md` | Fasst die Wellen einer Version zusammen — Body des GitHub Release. |
| **Sprint / Major** (ab Sprint 3) | `_template-sprint.md` · `_template-major.md` | Sprint-Sammelnote (Minor-Tag) bzw. Major-Vermarktungs-/Migrations-Note (v1.0). |

## Versions-Overviews (real vorhanden, neueste zuerst)

- **v0.13.0** — [`v0.13.0-overview.md`](v0.13.0-overview.md) — Sprint 6: Status Line + Validierung + Restklärung (BOO-205–217) · Sprint-Note: [`sprint-6.md`](sprint-6.md)
- **v0.12.0** — [`v0.12.0-overview.md`](v0.12.0-overview.md) — Sprint 5: Claude-Code-first, Schalter A/B/C + Implement-Migration (BOO-199–213) · Sprint-Note: [`sprint-5.md`](sprint-5.md)
- **v0.11.0** — [`v0.11.0-overview.md`](v0.11.0-overview.md) — Sprint 3: Build-vs-Buy-Pivot, /sprint-run auf `/goal` (BOO-198–216) · Sprint-Note: [`sprint-3.md`](sprint-3.md)
- **v0.10.1** — [`v0.10.1-overview.md`](v0.10.1-overview.md)
- **v0.10.0** — [`v0.10.0-overview.md`](v0.10.0-overview.md) — /sprint-run: Sprint-Orchestrator (BOO-157)
- **v0.7.9 … v0.7.0** — [`v0.7.9-overview.md`](v0.7.9-overview.md) … [`v0.7.0-overview.md`](v0.7.0-overview.md)
- **v0.6.3 … v0.6.0** — [`v0.6.3-overview.md`](v0.6.3-overview.md) … [`v0.6.0-overview.md`](v0.6.0-overview.md)
- **v0.5.0** — [`v0.5.0-overview.md`](v0.5.0-overview.md)
- **v0.4.0** — [`v0.4.0-overview.md`](v0.4.0-overview.md)
- **v0.3.0** — [`v0.3.0-overview.md`](v0.3.0-overview.md)
- **v0.2.0** — [`v0.2.0-overview.md`](v0.2.0-overview.md) — Governance-OS (Wellen J–T)
- **v0.1.0** — GAP-Hardening (Wellen A–I), getaggt 2026-05-22 (kein eigenes Overview-File).

> Die zugehörigen **Wave-Notes** (A … CD) sind vollständig im [`README.md`](README.md) verlinkt (neueste zuerst).

## Neue Sprint-/Major-Konvention (ab Sprint 3)

Ab Sprint 3 wird **pro Sprint** eine Sammel-Release-Note auf eine **Minor-Version** getaggt; die einzelnen Wave-Notes bleiben die granulare Quelle. Nach Sprint 6 folgt das **Major-Release v1.0**.

| Sprint | Version | Note-Vorlage |
|--------|---------|--------------|
| Sprint 3 | **v0.11.0** ✓ | [`sprint-3.md`](sprint-3.md) (+ [`.en.md`](sprint-3.en.md)) · [`v0.11.0-overview.md`](v0.11.0-overview.md) |
| Sprint 5 | **v0.12.0** ✓ | [`sprint-5.md`](sprint-5.md) · [`v0.12.0-overview.md`](v0.12.0-overview.md) |
| Sprint 6 | **v0.13.0** ✓ | [`sprint-6.md`](sprint-6.md) · [`v0.13.0-overview.md`](v0.13.0-overview.md) |
| nach Sprint 6 | **v1.0.0** | [`v1.0-native-pivot.md`](v1.0-native-pivot.md) (Doku in Sprint 6 · Tag/Rollout post-Sprint-6, BOO-9) |

Patches (`vX.Y.Z`) innerhalb eines Sprints für Nachzüge. Workflow (Tag → `gh release create --notes-file …`) wie im [`README.md`](README.md) beschrieben.

## Verweise

[`README.md`](README.md) (Konvention + vollständige Wave-Liste) · [`_template-sprint.md`](_template-sprint.md) · [`_template-major.md`](_template-major.md) · Doku-Konsistenz: [`../standards/doku-consistency-checklist.md`](../standards/doku-consistency-checklist.md). Verwandt: Wave BT (Release-Index BOO-173), BOO-216 (Release-Notes-Standard).
