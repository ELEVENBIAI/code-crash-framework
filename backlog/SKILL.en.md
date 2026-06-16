---
name: backlog
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Sprint planning and backlog overview. Loads all issues, analyzes dependencies
  and proposes a prioritized order.
  Validates the dual column effort_ai_hours / effort_human_equiv_hours on new stories.
  Use when the operator says "what's up", "backlog", "sprint planning", "priorities" or "/backlog".
version: 1.6.0
language: en
metadata:
  hermes:
    category: coding
    tags: [linear, m365, intent-label, prioritization]
    requires_toolsets: [linear, github, terminal]
    related_skills: [ideation, intent]
---

# Backlog

Load the entire backlog, sort by dependencies and propose a prioritized order.

## Workflow

### Step 0: Load environment + system context

Order matters: FIRST 0.1 (environment), THEN 0.2 (system context) — the paths from `paths.architecture_design` / `paths.specs` inform where the system-context files live.

#### 0.1 Load environment

1. Read `.claude/environment.json` (if present — otherwise fall back to defaults and log a warning).
2. Extract paths from `paths.*` as needed (e.g. `paths.reports_local`, `paths.lessons_l3`, `paths.specs`, `paths.architecture_design`).
3. Before any tool invocation, check `tools_available.<tool>`. If `false` or missing, the skill skips the call and notes it in the output.
4. Missing-file fallback: assume the schema defaults (`journal/`, `journal/reports/local/`, `specs/`, `ARCHITECTURE_DESIGN.md`) and add a note to the output: "Note: `.claude/environment.json` is missing — defaults active. Recommendation: re-run `/bootstrap` or create the file manually."

#### 0.2 Load system context (in parallel)

Before analyzing issues, understand system state — otherwise blockers that have already been implemented look open, or priorities ignore existing ADR constraints.

1. **Read `CLAUDE.md`** — which stories are mentioned as implemented? (`[PROJECT]-XXX` in
   version descriptions). Current system VERSION. Known discrepancies. These stories are
   effectively "done" even if Linear doesn't mark them as completed yet.

2. **Read `ARCHITECTURE_DESIGN.md` IN FULL** — the lead document with all strategic
   constraints. Read to the last line — don't abort when you think you've read enough.
   The document grows with every new ADR.
   **Mandatory checklist — all sections must be read:**
   - [ ] §1 Architectural Vision + guiding principles
   - [ ] §2 Quality Attributes (availability, latency, security targets)
   - [ ] §3 All existing ADRs in full (ADR-1 through the last one — not just the first 5!)
   - [ ] §4 Layer-to-pipeline mapping
   - [ ] §5 Failure mode analysis
   - [ ] §6 Component relationships
   - [ ] §7 Scalability roadmap
   - [ ] §8 Testing architecture
   - [ ] References section (links to further architecture docs)

3. **Read `SYSTEM_ARCHITECTURE.md`** — agent list, signal flow, Brain DB schema, known
   weak spots. Gives clarity on current state and which paths are already implemented.

4. **Load completed issues (last 30 days)** — update blocker status: if a story is
   "Done" in Linear but still referenced as a blocker in open issues, mark it as
   "unblocked" and call it out explicitly in the presentation.

### Step 1: Load backlog

- `linear.getOpenIssues()` — all open issues
- Group by status: In Progress > Todo > Backlog > Ideation

### Step 2: Analyze dependencies

- Read issue descriptions: `## Dependencies` sections
- Build dependency graph: what blocks what?
- Detect and report circular dependencies
- Identify orphaned issues (referenced issues that don't exist)

**Schema-chain check (mandatory — runs on every backlog pass):**

1. Scan all open issues for `## DB Schema Impact` — which plan a schema update?
2. Build the schema chain: `currentSchemaVersion → targetSchemaVersion` per story
3. Sorting rule: **stories with a lower `targetSchemaVersion` ALWAYS first** — no two schema-update stories should be "In Progress" simultaneously
4. Conflict flag: two stories with the same `targetSchemaVersion` → report immediately as a **critical blocker** (one must be rewritten)
5. Mention explicitly in the priority recommendation: "schema chain: STORY-A (v17→v18) must go before STORY-B (v18→v19)"

**Dual-column check (mandatory — runs on every backlog pass):**

Every **new** story (status `Todo` or `Backlog`, created from the roll-out of this change onward) must carry the two effort fields `effort_ai_hours` (the real estimated AI effort incl. setup, iteration, review) and `effort_human_equiv_hours` (the classic senior-dev effort for the same story without the framework). The check is **deterministic** (field present + numeric), not a prompt promise.

1. For each new story, read both fields from the story frontmatter/body.
2. **Pass criterion:** both fields present AND numeric AND `> 0`.
3. If one is missing or non-numeric / `<= 0` → **FLAG the story as a hygiene finding** and do **NOT** treat it as sprint-ready in steps 3/4.
4. Emit a concrete **remediation hint:** "Story X is missing `effort_ai_hours` and/or `effort_human_equiv_hours` (numeric, >0) — add it in the story template (see HANDBUCH Appendix G, dual-column section). Not sprint-ready until added."
5. **Exception (no backfill):** the pre-rollout stories **BOO-183 through BOO-188** are **NOT** flagged — the dual column does not apply to them retroactively.

### Step 3: Propose order

Sort criteria (in this priority):
1. **In Progress** — finish running work first
2. **Blockers** — issues that block others
3. **Intent label** — `on-intent` BEFORE `neutral` at equal status + equal priority; `off-intent` stories go to the bottom with a warning ("Story X is off-intent — belongs in the backlog, not the sprint")
4. **Priority** — P1 > P2 > P3 > P4
5. **Dependency depth** — issues without dependencies before those with
6. **Age** — older issues before newer ones (same priority)

**Intent-label source:** the label is extracted from the `## Intent-Check` section in the story body (set by `/ideation` step 0.6). If the label is missing, the story is treated as `neutral`. In the output, explain: "Story X prioritized over Y because on-intent at equal points."

**Sprint-ready gate (dual column):** stories flagged by the dual-column check (step 2) count as **not sprint-ready** and are NOT recommended as the next story to implement — even if they would rank first by priority/age. They appear with a hygiene flag until the fields are added.

### Step 4: Present

Show the operator:
- Prioritized list with rationale
- Dependency conflicts or gaps
- **Dual-column hygiene findings** — new stories missing `effort_ai_hours` / `effort_human_equiv_hours`, explicitly marked **not sprint-ready**, with a remediation hint
- Issues that may be stale or obsolete
- Recommendation: "I would implement [STORY-XX] next because..."

### Step 5: Backlog hygiene (optional)

If issues are detected:
- Add missing dependencies
- Report orphaned references
- Suggest obsolete issues for the operator to close
