<a name="english"></a>

# Pitch — Gather Evidence for Stakeholder Meetings

> Closes Schrader's 4P pipeline (Perceive / Prompt / Produce / Pitch). The skill collects metrics, architecture diff, and intent fulfillment as a Markdown briefing for stakeholder meetings. No slides, no outcome text, no demo video — the stage stays human.

**Version:** 1.2.0 · **Command:** `/pitch`

> **Claude Code mode:** `/pitch` gathers evidence and writes one briefing file → supervised **`acceptEdits`**. No unattended operation (you review the briefing before the meeting). Details: HANDBUCH §6 "Claude Code mode".

---

## What the skill does

Schrader's pitch principle from *Code Crash* chapter 5 is evidence, not live coding. This skill is the hybrid variant (Option 3 of three variants, decided 2026-04-28): it gathers the data, the human builds the story and runs the live demo. Output is a single Markdown briefing at `pitch/PITCH-XX.md` — committed, NOT gitignored, because pitch briefings are part of project history.

The skill is read-only with respect to the learning loop and NEVER writes to L3 (`journal/learnings.db`) — that is the clean separation from `/sprint-review`, which owns the learning loop. `/pitch` runs after `/sprint-review` and before the stakeholder meeting.

---

## How it works

```
Step 0: Load environment
   · Read .claude/environment.json (BOO-34)
   · paths.pitches, paths.reports_local, paths.reports_ci,
     paths.lessons_l3, paths.intents, paths.feature_flags
   · Fall back to defaults if file missing

Step 1: Query pitch scope
   · Which sprint? Which intents? Which stories?
   · Optional: stakeholder context (1 sentence)
   · PITCH-XX number = highest existing + 1

Step 2: Collect data from 8 sources (graceful skip)
   · L3 lessons DB (read-only) · local reports · CI reports
   · Sprint files · architecture doc · intents
   · Feature flags · git log

Step 3: Compute architecture diff
   · git diff from last PITCH date to HEAD
     on ARCHITECTURE_DESIGN.md
   · First pitch: summarize full current state

Step 4: Apply demo-path heuristic
   · Score = change delta + intent relevance
   · User-journey suggestion (e.g. Onboarding → Search → Checkout)
   · Intent fulfillment per related_intent: score 0–1 or null

Step 5: Write pitch/PITCH-XX.md
   · Frontmatter + 5 body sections
   · status: prepared
   · Operator prompted for review

Step 6 (post-pitch, optional):
   · status: delivered
   · Free-text outcome note from operator
   · No auto-outcome — user reaction is human work
```

---

## Trigger phrases

- `/pitch`
- "prepare pitch"
- "present sprint X"
- "prepare stakeholder meeting"
- "/pitch post" (post-pitch mode for Step 6)

---

## Interfaces to other skills

| Upstream | What is delivered | Downstream | What we deliver |
|----------|-------------------|------------|------------------|
| `/sprint-review` | Sprint aggregate metrics (coverage, iterations, findings) | Operator (human) | Pitch briefing as cheat sheet for the live demo |
| `/architecture-review` | `ARCHITECTURE_DESIGN.md` current state | — | — |
| `/intent` | `intents/INTENT-XX.md` with success criteria | — | — |
| `/implement` (indirect) | Local reports + iteration counts | — | — |

`/pitch` is read-only against all upstream sources and writes exclusively to `pitch/PITCH-XX.md`. No Linear writes, no L3 updates.

---

## Artifacts / outputs

- **`pitch/PITCH-XX.md`** — one file per pitch event, committed (NOT gitignored)
  - Frontmatter: `pitch_id`, `sprint`, `created_at` (ISO-8601 UTC), `related_intents`, `related_stories`, `metrics_snapshot.*`, `demo_path`, `status: prepared`
  - Body sections:
    1. Architecture diff since last pitch
    2. Quality-gate status (findings, hotspots, coverage)
    3. Intent fulfillment (per `related_intent`: criterion + state + score 0–1)
    4. Demo-path proposal (user journey)
    5. Open questions (what stakeholders might ask)
  - Optional after the meeting: `## Outcome (post-pitch)` free-text section + `status: delivered`

---

## Background / motivation

Schrader argues in *Code Crash* chapter 5: the 4P pipeline (Perceive / Prompt / Produce / Pitch) is only closed once the stakeholder meeting is a real pitch — evidence, not live coding. In the INTENTRON Framework, `/intent` (Perceive) and `/ideation` + `/backlog` + `/implement` (Prompt + Produce) cover the first three Ps. The fourth P was missing — until BOO-37.

On 2026-04-28 three variants were discussed: (1) fully automated slide generator, (2) AI-formulated pitch script, (3) hybrid with pure evidence gathering. Variant 2 was rejected because of AI-slop risk — a formulated pitch text sounds generic and undermines trust. Variant 3 (this implementation) draws the clean line: machine gathers facts, human builds story.

---

## Sources

- **Book:** Matthias Schrader, *Code Crash* (2025), chapter 5 §Pitch
- **Linear:** BOO-37 — Pitch skill (Bootstrapping Evolution)
- **ADR:** Decision for hybrid variant (Option 3) on 2026-04-28

---

## File structure

```
intentron/pitch/
├── SKILL.md                           ← Skill definition (DE — primary)
├── SKILL.en.md                        ← Skill definition (EN)
├── README.md                          ← German README
├── README.en.md                       ← This file (EN)
├── references/
│   ├── pitch-template.md              ← Body schema for PITCH-XX.md (DE)
│   ├── pitch-template.en.md           ← English mirror
│   ├── demo-path-heuristic.md         ← Scoring logic demo path (DE)
│   └── demo-path-heuristic.en.md      ← English mirror
├── pitch-overview.excalidraw          ← Overview diagram (DE)
├── pitch-overview.png                 ← Rendered PNG (DE)
├── pitch-overview.en.excalidraw       ← Overview diagram (EN)
└── pitch-overview.en.png              ← Rendered PNG (EN)
```

![Pitch skill overview](pitch-overview.en.png)
