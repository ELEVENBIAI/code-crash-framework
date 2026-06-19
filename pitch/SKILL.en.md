---
name: pitch
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
version: 1.2.0
description: |
  Closes Schrader's 4P pipeline (Perceive/Prompt/Produce/Pitch).
  Gathers evidence (metrics, architecture diff, intent fulfillment) as
  a Markdown briefing for stakeholder meetings. Generates no slides —
  human builds story and runs live demo. Use when the operator says
  "prepare pitch", "/pitch", or "present sprint X".
tools: [Read, Write, Edit, Bash, Glob, Grep]
metadata:
  hermes:
    category: governance
    tags: [pitch, evidence-gathering, sprint-presentation, 4p-pipeline]
    requires_toolsets: [terminal, git, linear]
    related_skills: [sprint-review, architecture-review, intent]
---

# Pitch — Gather Evidence for Stakeholder Meetings

Schrader's pitch principle is evidence, not live coding. The skill is hybrid (Option 3): it gathers the data, the human builds the story and runs the live demo. Output is `pitch/PITCH-XX.md` — committed, NOT gitignored, because pitch briefings are part of project history. Position in the skill pipeline: runs AFTER `/sprint-review` and BEFORE the stakeholder meeting. The skill is read-only — it NEVER writes to L3 (clean separation of concerns from `/sprint-review`, which owns the learning loop).

References:
- `references/pitch-template.md` — body schema for `PITCH-XX.md`
- `references/demo-path-heuristic.md` — heuristic for the demo-path suggestion

## Workflow (6 steps)

### Step 0: Load environment

- Read `.claude/environment.json` (BOO-34). Extract `paths.pitches` — default: `pitch/`. Also read: `paths.reports_local`, `paths.reports_ci`, `paths.lessons_l3`, `paths.specs`, `paths.architecture_design`, `paths.intents`, `paths.feature_flags` (BOO-17). If `tools_available.linear == false` → skip Linear lookups with a note.
- Fallback on missing file: assume defaults + add hint "Recommendation: re-run /bootstrap or manually create `.claude/environment.json`".

### Step 1: Query pitch scope

Ask the operator:
1. Which sprint? (e.g. Sprint 12, date range, or sprint file `journal/sprint-{date}.md`)
2. Which intents are in pitch focus? (IDs from `intents/INTENT-XX.md`, multiple allowed)
3. Which stories should be presented? (Linear IDs, multiple allowed)
4. Optional stakeholder context (1 sentence — feeds into the demo-path heuristic)

PITCH-XX number: highest existing number in `pitch/PITCH-*.md` + 1, else PITCH-1.

### Step 2: Collect data from 8 sources

Maintain the following table (all sources optional, graceful skip on missing source):

| Source | Path | What is read |
|---|---|---|
| L3 lessons DB | `journal/learnings.db` | cross-sprint trends, avg iterations over time |
| Local reports | `journal/reports/local/{date}_{story}/` | iteration counts, final status per story (`meta.json`) |
| CI reports | `journal/reports/ci/run-{id}/` | coverage, performance baselines (BOO-32 convention) |
| Sprint files (L2) | `journal/sprint-{date}.md` | aggregate metrics per sprint |
| Architecture doc | `ARCHITECTURE_DESIGN.md` | architecture snapshot for diff (Step 3) |
| Intents | `intents/INTENT-XX.md` | success criteria for intent fulfillment |
| Feature flags | `.claude/feature-flags.json` (BOO-17) | active flags + rollout phase |
| Git log | `git log --since=<sprint-start>` | LOC delta (`--shortstat`), commit counts |

Build the frontmatter snapshot from the collected data (schema in `references/pitch-template.md`):
- `loc_delta` from `git log --shortstat --since=...`
- `coverage_trend` from sprint file or latest CI report
- `p95_change` from performance baseline (BOO-16)
- `iterations_avg` from local-reports `meta.json`
- `feature_flags_active` from `.claude/feature-flags.json`
- `intent_fulfillment_score` from Step 4

L3-DB read example (sqlite, read-only — NO INSERT/UPDATE):

```bash
sqlite3 "${L3_DB:-journal/learnings.db}" \
  "SELECT story_id, iterations FROM lessons WHERE sprint = '<sprint-id>'"
```

### Step 3: Compute architecture diff

```bash
LAST_PITCH=$(ls pitch/PITCH-*.md 2>/dev/null | sort -V | tail -1)
LAST_PITCH_DATE=$(grep '^created_at:' "$LAST_PITCH" | head -1 | sed 's/created_at: *//')
git diff $(git rev-list -1 --before="$LAST_PITCH_DATE" HEAD)..HEAD -- ARCHITECTURE_DESIGN.md
```

On the first pitch (no prior file): summarize the full state of `ARCHITECTURE_DESIGN.md` (3–5 bullets per §-section).

Output: short bullet list of what changed (§-number from ARCHITECTURE_DESIGN.md, what changed, why per commits).

### Step 4: Apply demo-path heuristic

Logic lives in `references/demo-path-heuristic.md`. Two factors:
1. **Highest delta since last pitch** — which components/endpoints have the most commits / LOC delta in scope?
2. **Highest intent relevance** — which components are named in the success criteria of `related_intents`?

The skill computes a per-component score and suggests a user journey (e.g. "Onboarding → Search → Checkout"). The operator may override the path in Step 5.

Per intent: score 0–1 for fulfillment. The skill matches the success criterion against sprint reports + feature-flag state. If the criterion is not unambiguously measurable: score `null` with note "manual operator score needed".

### Step 5: Write `pitch/PITCH-XX.md`

Body schema (see `references/pitch-template.md`):
1. **Architecture diff since last pitch** (from Step 3)
2. **Quality-gate status** — open findings, closed hotspots, coverage movement (from sprint file + SonarQube if `tools_available.sonarqube_cloud == true`)
3. **Intent fulfillment** — per related intent: success criterion + current state + score 0–1 (from Step 4)
4. **Demo-path proposal** (from Step 4)
5. **Open questions** — what the skill doesn't know, what stakeholders might ask

Write the frontmatter from the issue schema verbatim (`pitch_id`, `sprint`, `created_at` ISO-8601 UTC, `related_intents`, `related_stories`, `metrics_snapshot.*`, `demo_path`, `status: prepared`).

Prompt the operator:

> PITCH-XX.md created at `pitch/PITCH-XX.md`. Walk through it before the stakeholder meeting — the skill is your cheat sheet, not your script.

### Step 6 (optional, post-pitch): Set status to `delivered` + outcome note

Called by the operator AFTER the stakeholder meeting ("/pitch post" or "the X pitch happened"). The skill:
1. Loads the most recent PITCH-XX.md
2. Sets `status: delivered`
3. Asks the operator for a free-form outcome note (1–3 sentences): who attended, what questions came up, what decision was made
4. Appends the outcome note as `## Outcome (post-pitch)` section — NO auto-generation, ONLY operator free-text input
5. Optionally sets status `post-mortem` (if the pitch went badly — operator's call)

## Anti-Scope (what the skill does NOT do)

- **No slide generation** — no PowerPoint, no Reveal.js, no Marp
- **No outcome text** — user reactions emerge ONLY in the demo, free-text from the operator (Step 6)
- **No voiceover / no demo video**
- **No writes to L3** — read-only position, protects separation from `/sprint-review`
- **No stakeholder mail** — communication is human work

If these features are wanted: separate issue, not BOO-37's scope.

## Differentiating components — 13 without an Anthropic equivalent (BOO-209)

The framework substitutes where native features suffice (ADR-1, build-vs-buy) and builds only what Anthropic doesn't provide natively. These 13 are the USP for stakeholder meetings — canonical list with source links: [HANDBUCH Appendix AP](../HANDBUCH.en.md). Marketing/pitch synthesis (native pivot, before/after, migration path): [v1.0-native-pivot.md](../docs/releases/v1.0-native-pivot.md).

1. **`/intent`** — Claude Code doesn't enforce a methodical "why before spec".
2. **`/pitch`** — no native tool collects stakeholder evidence along a demo path.
3. **Three-layer quality gate** — a tiered Semgrep/coverage/slopsquatting scaffold doesn't exist natively.
4. **Layer-0 PreToolUse bodyguard** — a deterministic edit gate before writing is missing natively.
5. **Spec-gate as a Git hook** — "no commit without a spec" isn't enforced natively.
6. **dpo control catalog (YAML)** — privacy compliance as a deterministic catalog is no native feature.
7. **CONVENTIONS.md** — a tool-neutral adapter contract across Claude/Codex is missing natively.
8. **AGENTS.md generator** — a portable Codex entry isn't generated by Claude Code.
9. **Knowledge-onboarding** — deterministic doc routing doesn't exist natively.
10. **DevContainer template** — a governance-ready DevContainer is no native asset.
11. **Quality-gate self-audit** — "are the gates actually wired?" is checked by no native tool.
12. **`change_type: prototype`** — a deliberate gate relaxation without breaking compliance is framework logic.
13. **Vendored cross-cutting skills** — security-architect, dpo, cloud-system-engineer bundled.

## Position in pipeline

```
/intent → /ideation → /backlog → /implement → /architecture-review → /sprint-review → /pitch
```

4P pipeline phases (Schrader Ch. 5):
- **Perceive** → `/intent`
- **Prompt + Produce** → `/ideation` + `/backlog` + `/implement`
- **Pitch** → `/pitch` (this skill)

## Operator hints

- `pitch/` directory is committed (NOT gitignored) — pitch briefings are part of project history
- PITCH-XX.md is a cheat sheet, not a script — the stage stays human
- Optional: VS Code Markdown preview turns the briefing into a readable screen during the demo
