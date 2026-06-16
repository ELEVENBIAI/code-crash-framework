# Wave CF — research als vendored Bundle-Skill: Self-Contained-Fix (BOO-219)

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](wave-cf-research-vendored-bundle-skill.en.md)

**Was jetzt da ist:** Der `research`-Skill liegt ab sofort als **vendored Bundle-Skill** direkt im `intentron`-Repo — analog `dpo` und `security-architect` (BOO-74). Ein externer Operator hatte gemeldet, dass `/research` nicht installierbar ist: Der Bootstrap verwies für die optionalen Allzweck-Skills auf das Repo `vibercoder79/claudecodeskills`, das **privat** ist und für Externe als „Could not resolve to a Repository" erscheint. Gleichzeitig macht Bootstrap **Phase 4.10 (Domain Deep Research)** `/research` zur **Pflicht** — ein Pflicht-Schritt, der an einem für Externe unerreichbaren Privat-Repo hing. Mit dieser Wave ist ein einziges `git clone` des Frameworks self-contained.

## Die Lehre — eine Pflicht-Phase darf nicht an einer privaten Abhängigkeit hängen

Bootstrap garantiert Domainwissen vor dem Story-Schreiben (Schrader Kap. 2). Diese Garantie war hohl, solange ihre Engine (`/research`) nur aus einem privaten Repo kam, das die GraphQL-API Externen gegenüber als nicht-existent ausweist. Die Korrektur folgt dem etablierten Vendoring-Muster: Master bleibt `claudecodeskills` (via `publish_skill.py`), das Framework-Repo hält den Mirror. So bleibt die Solo-Operator-Nutzung erhalten und das Framework wird trotzdem self-contained.

## Änderungen

- **Vendoring:** `research/` liegt nun als Top-Level-Bundle-Skill im `intentron`-Repo — inklusive `SKILL.md` + `SKILL.en.md`, `README.md` + `README.en.md`, `references/perplexity-api.md(.en)` und Übersichts-Diagrammen (DE+EN). Die DE+EN-Parität wurde im Zuge des Vendorings ergänzt (der Master in `claudecodeskills` trägt sie noch nicht — Backfill beim nächsten `publish_skill.py research`).
- **Bootstrap-Skill (v3.42.0, DE+EN):** `research` ist im **Minimum-Set** (weil Phase 4.10 Pflicht ist). Der Block „Optionale Allzweck-Skills aus claudecodeskills" (Phase 5) ist **entfernt** — keine optionale Sammel-Clone-Frage mehr. Phase 4.10 trägt einen Hinweis, dass `/research` garantiert als Bundle-Skill vorliegt.
- **Source-Garantie (`check-skill-sources.sh`):** `research` von `GENERAL_SKILLS` nach `BUNDLE_SKILLS` verschoben; der Mirror-Integritäts-Check greift damit automatisch. `GENERAL_SKILLS` ist leer.
- **References (DE+EN):** `skills-setup`, `provider-postflight`, `optional-components` auf den neuen Stand gebracht; die veralteten `git clone claudecodeskills`-/`intentron/`-Nesting-Pfade im skills-setup-Installations- und Update-Script auf `intentron` + Flat-Layout korrigiert.
- **README (DE+EN):** `research` aus dem „Top-Level Companion-Skills"-Block in die „Spezialisten-Bundle-Skills (vendored)"-Tabelle verschoben (Link `research/` statt `../research/`).

## Migration — bestehende Projekte nachziehen

- **Neue Bootstrap-Läufe** installieren `research` automatisch aus dem Framework-Repo (Minimum-Set). Kein `claudecodeskills`-Zugriff mehr nötig.
- **Bestehende Installationen** mit `research` aus `claudecodeskills` bleiben funktionsfähig; ein Update zieht den Skill künftig aus `intentron` (siehe `skills-setup.md` Update-Strategie).

## Abgrenzung

- **Bewusst NICHT vendored:** `design-md-generator` und `skill-creator` bleiben global/standalone; `setup-checklist` bleibt ein eigenes öffentliches Repo (BOO-113). Nur die optionale Sammel-Clone-Frage entfällt.
- **`migration-checklist-v1-to-v2`** ist ein historisches Dokument und wurde nicht angefasst.
- **Kein eigener Framework-Versions-Tag** — diese Wave ist eine Doku-/Struktur-Release-Note. Bootstrap-Skill-Version 3.42.0.
- Wave-Buchstabe **cf** (ce = Worker-Equivalent BOO-190–193).

## Verweise

Korrigiert die Companion-Entscheidung aus **BOO-58 / F020**. Vendoring-Muster aus **BOO-73/74** (dpo + security-architect), Source-Garantie aus **BOO-121**. Spec: `specs/BOO-219.md`. Verwandt: README, HANDBUCH §4/§Skill-Installation.
