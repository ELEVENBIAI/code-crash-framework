---
name: sprint-review
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Periodic audit for architectural health, tech debt and backlog hygiene — plus
  a mandatory learning-loop entry (L1/L2/L3). Use for periodic reviews or when
  the operator says "sprint review", "architecture audit", "tech debt", "clean up"
  or "/sprint-review".
version: 2.7.0
language: en
metadata:
  hermes:
    category: governance
    tags: [retro, lessons-loop, anti-pattern-check]
    requires_toolsets: [terminal, git, sonarqube, linear]
    related_skills: [implement, architecture-review]
---

# Sprint Review

Periodic audit of the whole system plus learning-loop entry. The skill closes the learning loop by capturing lessons-learned at the end (level L1/L2/L3 depending on project configuration).

## Workflow (10 steps)

### Step 0: Load environment

1. Read `.claude/environment.json` (if present — otherwise fall back to defaults and log a warning).
2. Read `CONVENTIONS.md` if present. Extract `governance_mode`, `execution_isolation` and active gates. Fallback: `standard` + `write-scope`.
3. Extract paths from `paths.*` as needed (e.g. `paths.reports_local`, `paths.lessons_l1`, `paths.lessons_l2_dir`, `paths.lessons_l3`, `paths.specs`, `paths.architecture_design`, `paths.conventions`).
4. Before any tool invocation, check `tools_available.<tool>`. If `false` or missing, the skill skips the call and notes it in the output.
5. Missing-file fallback: assume the schema defaults (`journal/`, `journal/reports/local/`, `specs/`, `ARCHITECTURE_DESIGN.md`, `CONVENTIONS.md`) and add a note to the output: "Note: `.claude/environment.json` is missing — defaults active. Recommendation: re-run `/bootstrap` or create the file manually."

### Step 1: System snapshot

Load in parallel:
1. Full backlog (all statuses, Linear/M365/GitHub depending on tool)
2. **Read `ARCHITECTURE_DESIGN.md` IN FULL** — to the last line — all sections and ADRs.
   **Mandatory checklist:**
   - [ ] §1 Architectural Vision + guiding principles
   - [ ] §3 Quality Attributes (active standard dimensions + add-ons)
   - [ ] §4 Component references
   - [ ] §6 Phase mapping
   - [ ] §7 ADR table in full
   - [ ] §9 References (know all linked docs)
3. Read `SYSTEM_ARCHITECTURE.md` in full
4. `lib/config.js` (current configuration, DOC_FILES list)
5. Git log of the last period (commits, branches, new files)
6. If self-healing active: check self-healing logs (most frequent warnings)
7. If learning loop active: read previous `journal/` entries (context for step 8)

### Step 1b: Governance-convention drift

Check whether project practice matches `CONVENTIONS.md`:

| Convention | Review question |
|---|---|
| `governance_mode: lite` | Are only baseline gates active, without heavy reports being forced? |
| `governance_mode: standard` | Are spec gate, baseline security check, tests/lint and sprint-review traces present? |
| `governance_mode: heavy` | Are extended security/compliance/architecture gates, reports and review evidence present? |
| `execution_isolation: write-scope` | Did parallel stories/sub-agents use clear `write_scopes`? |
| `execution_isolation: git-worktree` | Did parallel agents/agentic runs execute in separate worktrees or branches? |

Document deviations in the sprint report as `Governance Drift` and propose a backlog issue when the pattern repeats.

### Step 2: Architecture review (active dimensions)

Read the **active dimensions** from `ARCHITECTURE_DESIGN.md §3 Quality Attributes`. These are the 7 standard dimensions + all add-ons activated in bootstrap block A.4.

Per active dimension: status (OK / warning / critical) + finding + recommendation.

**Standard dimensions:** Reliability, Data Integrity, Security, Performance, Observability, Maintainability, Testability

**Add-ons (if active):** Privacy / Cost Efficiency / Signal Quality / Compliance

**Testability-specific metrics in sprint review:**
- Coverage on new code (change value, BOO-15 hook): trend across the sprint?
- Test-suite pass rate: stable green or flaky / red?
- Number of newly added contract tests on external interfaces?

Detail questions per dimension: see `architecture-review/references/dimensions-detail.en.md`.

### Step 2b: Reports aggregation + metrics (BOO-6)

Sprint Review aggregates four sources per sprint and writes the results as frontmatter into the sprint file.

**Read sources (all optional, graceful skip on missing source):**

| Source | Path | What gets read |
|---|---|---|
| Local implement reports | `journal/reports/local/{date}_{story}/` | iteration counts per tool from `meta.json`, iter-N SARIF files for pattern detection |
| CI reports | `journal/reports/ci/run-{id}/` | CI success rates, common failures (BOO-32 convention) |
| SonarQube Cloud API | `https://sonarcloud.io/api/` | new hotspots in the sprint, coverage trend, cognitive-complexity trend |
| L3 DB | `journal/learnings.db` | cross-sprint trends (only when level L3 active, otherwise skip) |

**SonarQube API read block (analogous to architecture-review BOO-6):**

```bash
# Precondition check (see architecture-review SKILL.en.md BOO-6 block)
# When SONAR_TOKEN + sonar-project.properties + tools_available.sonarqube_cloud == true:

# New findings in the current sprint window (SPRINT_START_ISO -> today)
curl -s -u "${SONAR_TOKEN}:" \
  "https://sonarcloud.io/api/issues/search?componentKeys=${PROJECT_KEY}&createdAfter=${SPRINT_START_ISO}&ps=100" \
  | jq '.issues | length'

# Coverage and complexity trend (history API)
curl -s -u "${SONAR_TOKEN}:" \
  "https://sonarcloud.io/api/measures/search_history?component=${PROJECT_KEY}&metrics=coverage,cognitive_complexity&from=${SPRINT_START_ISO}" \
  | jq '.measures'
```

On missing precondition: graceful skip with `[!info] SonarQube block skipped — metrics unavailable`.

**Local reports aggregation:**

```bash
# Read all meta.json files from the last N days (N = sprint length)
find journal/reports/local -name "meta.json" -mtime -${SPRINT_DAYS} | while read m; do
  jq '. | {story_id, iterations, final_status, pre_flight_warning}' "$m"
done | jq -s '
  {
    eslint_iterations_avg: (map(.iterations.eslint) | add / length),
    semgrep_findings_total: (map(.iterations.semgrep) | add),
    pre_flight_warnings_count: (map(select(.pre_flight_warning != null)) | length)
  }
'
```

**Cost aggregation (BOO-84):**

Read `token_tracking` from all sprint meta.json files and compute cost aggregates via `bootstrap/references/model-tiers.json` (pricing is central, not duplicated per meta.json).

```bash
TIERS_FILE="$(git rev-parse --show-toplevel)/../intentron/bootstrap/references/model-tiers.json"
# Fallback: search at typical framework paths (operator setup)
if [ ! -f "$TIERS_FILE" ]; then
  TIERS_FILE=$(find ~/Documents/GitHub/intentron -name model-tiers.json -maxdepth 4 2>/dev/null | head -1)
fi

if [ -n "$TIERS_FILE" ] && [ -f "$TIERS_FILE" ]; then
  # Cost per story comes from token_tracking.story_totals.estimated_cost_usd (already populated by implement skill when hook active)
  find journal/reports/local -name "meta.json" -mtime -${SPRINT_DAYS} | while read m; do
    jq -r '
      if .token_tracking and .token_tracking.story_totals
      then
        {
          story_id: .story_id,
          model_breakdown: (
            (.token_tracking.skill_invocations // [])
            | group_by(.model_tier_default)
            | map({tier: .[0].model_tier_default, input: (map(.input_tokens_total) | add), output: (map(.output_tokens_total) | add)})
          ),
          cache_hit_rate: .token_tracking.cache_hit_rate,
          estimated_cost_usd: .token_tracking.story_totals.estimated_cost_usd,
          override_count: (.override_audit // [] | length)
        }
      else
        {story_id: .story_id, model_breakdown: null, cache_hit_rate: null, estimated_cost_usd: null, override_count: 0}
      end
    ' "$m"
  done | jq -s '
    {
      total_cost_usd: (map(.estimated_cost_usd // 0) | add),
      stories_with_token_data: (map(select(.estimated_cost_usd != null)) | length),
      stories_without_token_data: (map(select(.estimated_cost_usd == null)) | length),
      cache_hit_rate_avg: (map(.cache_hit_rate) | map(select(. != null)) | if length > 0 then add / length else null end),
      override_count_total: (map(.override_count) | add),
      tier_breakdown: (
        map(.model_breakdown // []) | flatten
        | group_by(.tier)
        | map({tier: .[0].tier, input_tokens: (map(.input) | add), output_tokens: (map(.output) | add)})
      )
    }
  '
fi
```

If `model-tiers.json` is not found or no story contains token data: graceful skip with `[!info] Cost aggregate skipped — model-tiers.json missing or token-tracking hook not active`.

**CI reports aggregation:**

```bash
# Read SARIF + JUnit XML files from journal/reports/ci/run-*/
# CI failure patterns from the last sprint:
find journal/reports/ci -name "*.sarif" -mtime -${SPRINT_DAYS} | xargs jq -s '
  [.[] | .runs[].results[] | .ruleId] | group_by(.) | map({rule: .[0], count: length}) | sort_by(-.count) | .[0:5]
'
```

**L3 DB read (when active):**

```sql
-- Trend across last 5 sprints
SELECT sprint_number, eslint_iterations_avg, coverage_trend, sonarqube_hotspots_new
FROM sprint_metrics
ORDER BY sprint_number DESC
LIMIT 5;
```

**Aggregate metrics into the sprint-file frontmatter:**

Extend `journal/sprint-{date}.md` frontmatter (in addition to existing fields):

```yaml
---
sprint: 12
stories: [BOO-15, BOO-16, BOO-17]
metrics:
  eslint_iterations_avg: 2.3
  eslint_recurring_rules:
    - "no-unused-vars (4x)"
    - "react-hooks/exhaustive-deps (3x)"
  semgrep_findings_total: 0
  coverage_trend: "82% -> 84% (+2pp)"
  pre_flight_warnings_count: 1
  ci_failures_top5:
    - "BOO-15: SonarQube hotspot in auth.ts"
  sonarqube_hotspots_new: 1
  sonarqube_hotspots_resolved: 3
  sonarqube_cognitive_complexity_trend: "stable"
  # BOO-84 token-efficiency metrics (all optional, empty when hook not active)
  cost_breakdown:
    total_cost_usd: 1.23
    stories_with_token_data: 3
    stories_without_token_data: 0
    cache_hit_rate_avg: 0.78
    override_count_total: 0
    tier_breakdown:
      - tier: haiku
        input_tokens: 45000
        output_tokens: 8000
      - tier: sonnet
        input_tokens: 85000
        output_tokens: 18000
      - tier: opus
        input_tokens: 12000
        output_tokens: 4000
---
```

**What sprint review additionally detects:**

- Recurring iteration patterns: "ESLint rule X blocked in 4 out of 5 stories"
- Coverage drift across multiple sprints
- CI failure patterns (which checks fail most often)
- Token pre-flight warnings (BOO-40): when the operator regularly proceeded despite warnings → calibration input for BOO-39

Results flow into step 6 (report) and step 8 (learning loop) — e.g. when ESLint rule X failed 4×, lesson "consider ESLint rule X as a custom rule for the skill generator".

### Step 3: Tech-debt inventory

- Identify code duplication (same functions in multiple files)
- Hardcoded values that belong in `lib/config.js`
- Deprecated features not yet removed
- Count and assess open code markers (unfinished spots, workarounds, TODOs)
- Stale dependencies or outdated API versions

### Step 4: Backlog hygiene

- Orphaned issues (referenced issues that don't exist)
- Issues without dependencies that should have some
- Obsolete issues (superseded by other work)
- Missing issues (tech debt without a ticket)
- Priorities still up-to-date?

### Step 5: Process compliance

- Do all recent issues have the mandatory template?
- Were dependencies documented bidirectionally?
- Are all doc files on the same VERSION (`lib/config.js` vs. DOC_FILES)?
- Were Obsidian change logs written?
- Are component docs (Obsidian or `docs/components/`) up-to-date for all active components?
- Are all new `*.md` files registered in `ARCHITECTURE_DESIGN.md §9`? (orphan-check)

### Step 6: Report + actions

Present to the operator:
- **Summary**: 3–5 sentences, overall assessment
- **Top 3 risks**: what should be tackled next?
- **Tech-debt score**: low / medium / high
- **Recommended issues**: new stories for identified tech debt
- **Backlog cleanup**: issues to close/adjust
- **Worker-equivalent** (if Financials active, BOO-191): AI cost, human-equivalent cost, ROI factor and wall clock — the sprint's output ROI in money (details + calculation see step 9b). With Financials inactive or no dual column: omit the line (graceful skip).

### Step 7: Anti-Pattern Self-Diagnosis (BOO-26)

> Reads `intentron/references/anti-pattern-katalog.en.md` and asks a brief Yes/No/Unclear question per AP.
> No hard block — this step is reflection, not a gate.
> Duration: approx. 5 minutes.

**Technical APs (Process + Quality — skill-detectable):**

| AP | Diagnostic question | Yes/No/Unclear |
|----|---------------------|----------------|
| AP1 Tool chaos | More than 2 different AI coding tools in use — without central evaluation? | |
| AP2 Review overload | Did PR reviews regularly take >24h in the last sprint? | |
| AP3 Feature inflation | Were features built without intent-linkage — just because they were "quick to do"? | |
| AP4 Security as finish line | Are security checks done as the last step before deployment rather than in the pipeline? | |
| AP5 Technical debt in turbo mode | Are duplication rates or conflicting architecture patterns rising in the code? | |
| AP6 Experience debt | Were features shipped without a UX/design review — "design comes later"? | |
| AP8 Speed without system | More than 1 rollback in the last sprint due to missing tests or observability? | |
| AP10 Slopware | More features than previous sprints — but declining outcome measurement? | |

**Culture APs (reflection only — not skill-detectable):**

| AP | Diagnostic question | Yes/No/Unclear |
|----|---------------------|----------------|
| AP7 Responsibility diffusion | Did anyone say "the AI did it that way" when something went wrong? | |
| AP9 Individual-first as isolation | Is there duplicate work because architecture decisions were not shared? | |
| AP11 Political saboteurs | Is there a pattern of systematic blockers from the same people? | |

**Evaluation:**
- **All No:** No acute AP problem — brief note in learning loop
- **1-2 Yes/Unclear:** Entry in sprint retro with concrete countermeasure from `anti-pattern-katalog.en.md`
- **3+ Yes/Unclear:** Propose an ADR (`docs/domain/adrs/`) + issue in backlog for the countermeasure

Full symptoms + countermeasures: `intentron/references/anti-pattern-katalog.en.md`

### Step 7c: DPO audit trigger (BOO-69, only if Privacy add-on active)

> **Activation:** this step runs only if `PRIVACY.md` exists in the project root AND the sprint counter has reached the `privacy_audit_cadence` threshold (from `environment.json`, default: every 4 sprints).

**Purpose:** periodic privacy compliance check via a **deterministic control catalog** (BOO-87) instead of free-text assessment. The catalog runner works through the YAML catalogs under `dpo/controls/` control by control and produces a reproducible, auditor-ready report pair.

**Steps:**

1. **Cadence check:** compare sprint counter (e.g. via count of `journal/sprints/` directory) against `environment.json.privacy_audit_cadence`. If not reached: skip with log entry "BOO-69 DPO audit: cadence not reached (sprint {{N}} of {{CADENCE}})".
2. **Run the catalog runner** (deterministic, BOO-87): from the project root
   `DPO_PROJECT_ROOT=. python3 <dpo-skill>/scripts/dpo-audit.py`
   (`<dpo-skill>` = path of the dpo skill, standalone under `~/.claude/skills/dpo/`). The runner reads `dpo/controls/gdpr.yml` + `ndsg.yml` plus optional project overlays under `.claude/dpo/controls/`.
3. **Generated report pair** under `dpo/reports/<date>_audit.md` (human-readable) + `.json` (machine-readable). Each control carries a status:
   - **PASS** — mechanical check satisfied (reproducible)
   - **GAP** — mechanical check failed, concrete gap (see `mapsTo`)
   - **REVIEW-NEEDED** — judgment check that the operator confirms manually (no auto-verdict, no legal advice)
4. **Aggregation into the sprint report:** section `## Privacy Audit (BOO-69/BOO-87)` referencing `dpo/reports/<date>_audit.md`, the PASS/GAP/REVIEW-NEEDED summary, plus the **GAP list** and the **REVIEW-NEEDED items** the operator works through.
5. **Create backlog follow-up stories** (per open GAP and per open REVIEW-NEEDED item): one story each in the backlog adapter with label `privacy`.

**Skip case:** if `PRIVACY.md` is missing or cadence not reached → skip Step 7c, no further consequences.

> **Issue reference:** BOO-69 (trigger) + BOO-87 (deterministic control catalog). DPO skill as standalone under `~/.claude/skills/dpo/`. Catalogs: `dpo/controls/`. Configuration: `environment.json.privacy_audit_cadence` (default 4). HANDBUCH background: Appendix O Privacy by Design §AUDIT mode + §Deterministic control catalog (BOO-87).

### Step 8: Learning-loop entry (mandatory if learning loop active)

> **Activation:** this step only runs if `{PROJECT_PATH}/.learning-loop` exists (contents: `L1`, `L2` or `L3`).
> If the file is missing: the skill skips step 7 and ends after step 6.

The learning loop captures systematically **three categories**: what worked, what didn't work, next experiment. Details see `bootstrap/references/learning-loop.en.md`.

#### Level L1 — Simple (learnings.md)

The skill asks:
```
Sprint review complete. Now the learning-loop entry:

1. WHAT WORKED in this period? (3 bullets, with story link if relevant)
2. WHAT DIDN'T WORK (+ root cause if known)? (3 bullets)
3. NEXT EXPERIMENT / CHANGE? (3 bullets, concrete and measurable)
```

The skill appends the entry with a date header to:
- `{PROJECT_PATH}/journal/learnings.md`
- If Obsidian active: mirror in `{OBSIDIAN_VAULT}/04 Ressourcen/{PROJECT_NAME}/learnings.md`

Commit: `docs: sprint-review learnings {TODAY}`

#### Level L2 — Structured (sprint journal)

The skill prepares frontmatter from git log + backlog API (sprint number, story counts, velocity, period).

The skill asks the 4 qualitative sections:
1. What worked (with tag list)
2. What didn't (+ root cause, with tag list)
3. Next experiment (idea + measurement criterion + assigned story)
4. Learnings for upcoming sprints (meta rules)

The skill saves:
- Primary: `{PROJECT_PATH}/journal/sprint-{YYYY-MM-XX}.md` with full frontmatter
- Mirror (if Obsidian active): `{OBSIDIAN_VAULT}/04 Ressourcen/{PROJECT_NAME}/sprints/sprint-{YYYY-MM-XX}.md`

Commit: `docs: sprint-retro {SPRINT_NUMBER} ({TODAY})`

**Quarterly meta-retro:** on every 4th sprint review, the skill consolidates the last 4 sprint retros and writes `{PROJECT_PATH}/journal/quarterly-{YYYY-QX}.md` with trends, top anti-patterns, successful experiments.

#### Level L3 — SQLite + MD (only when active)

In addition to L2:
- Parse the L2 frontmatter + bullets
- Insert into `{PROJECT_PATH}/journal/learnings.db` via `journal/write_sprint.py`
- Tables: `sprints`, `events`, `metrics`, `experiments` (schema see `bootstrap/references/learning-loop.en.md`)

The skill optionally asks for additional metrics (e.g. `avg_story_time_days`, `api_cost_total`).

### Step 9: Cost snapshot (BOO-189)

At review close, capture the **actual consumption** from the local Claude Code logs — as a measured
quantity, complementary to the estimated `token_tracking` cost aggregate from step 2b:

- Call: `bash .claude/hooks/ccusage-capture.sh "/sprint-review <sprint>"` (capture template from setup,
  internally `npx --yes ccusage@latest daily`). Appends a token/cost snapshot to
  `docs/financials/sprint-costs.md`.
- **Soft gate:** if the call fails (ccusage/npx not installed, no log), **only warn** and **do not abort**
  the review — the report stays valid.
- **Complementary to the estimate:** the actual value complements the aggregated `token_tracking` from the
  story `meta.json` (step 2b); it does not replace it — estimate (`meta.json`) vs. measurement (ccusage)
  side by side.
- **Known limitation:** ccusage does not attribute sub-agent tokens (Task tool) cleanly (issues
  #313/#806/#950) — in heavily sub-agent-driven runs the reported consumption may be incomplete or
  charged to the parent.

### Step 9b: Worker-Equivalent report (BOO-191, only if Financials active)

> **Activation:** this step runs right after step 9 — the actual consumption (ccusage, `sprint-costs.md`) is
> already available there. It surfaces the **output ROI** of the sprint in money: what it actually cost (AI),
> what it would have cost the classic way (human equivalent), how fast we were (wall clock). No new data
> collection — only aggregation of already-present sources.

**Graceful skip (no hard block):** if `docs/financials/worker-equivalent-baseline.md` is missing (Financials not
active) or the stories completed in the sprint carry no dual column (`effort_ai_hours` /
`effort_human_equiv_hours`, BOO-193) → skip this step with `[!info] Worker-Equivalent report skipped — Financials
not active or no dual-column data`. The review stays valid.

**Inputs (all already present, collect nothing new):**

| Input | Source |
|---|---|
| Active billing rate + currency | `docs/financials/worker-equivalent-baseline.md` **section 1** (`rate_per_hour`, `currency`, `geo`, `source`) — internal precedence already applies there (BOO-190) |
| Σ `effort_ai_hours` (context) | Execution-isolation block of the stories completed in the sprint (dual column, BOO-193) |
| Σ `effort_human_equiv_hours` | Execution-isolation block of the stories completed in the sprint (dual column, BOO-193) |
| AI cost | Cost aggregate from step 2b (`cost_breakdown.total_cost_usd`); complemented by the ccusage actual snapshot from step 9 (`sprint-costs.md`, BOO-189) |
| Wall clock | Sprint log / git window (first to last sprint commit) |

**Calculation (exact):**

- **Human-equivalent cost** = Σ `effort_human_equiv_hours` × `rate_per_hour` (native currency from the baseline,
  **no** FX conversion).
- **ROI factor** = human-equivalent cost ÷ AI cost.
  > Σ `effort_ai_hours` is reported **as context only** — **not** part of the ROI formula.
- **AI cost** comes from the cost aggregate (step 2b) or ccusage; native, no conversion. Note: ccusage does not
  attribute sub-agent tokens cleanly (issues #313/#806/#950) — flag the AI-cost value in the report as an
  **approximation**.

**Output block "Worker-Equivalent" (DE+EN) — shown in the review:**

```
Worker-Equivalent (BOO-191) — Sprint {N}
  - AI cost:                  {ki_cost} {currency}   (approximation, ccusage sub-agent limit)
  - Σ effort_ai_hours:        {sum_ai} h  (context, not in ROI)
  - Σ effort_human_equiv_h:   {sum_human} h
  - Billing rate:             {rate_per_hour} {currency}/h  ({source})
  - Human-equivalent cost:    {human_equiv_cost} {currency}
  - ROI factor:               {roi_factor}×  (human equiv ÷ AI)
  - Wall clock:               {wall_clock_days} days
```

**Persist the report file:** `docs/financials/sprint-XX-worker-equivalent.md` (template schema see
[`docs/financials/sprint-XX-worker-equivalent.md`](../docs/financials/sprint-XX-worker-equivalent.md)). `XX` =
sprint number. Keep the frontmatter structured so BOO-192 (forecast-vs-actual) can read it back machine-side.

**Visibility:** also surface the worker-equivalent block in **step 6 (report)** and the **conclusion summary**
(see below). ROI language stays **internal** for now (ADR-D §Open) until ≥3 sprints of data exist.

### Conclusion

After step 9b (or step 8 with learning loop, otherwise step 7):

```
Sprint review complete.

Report:
  - Architecture: {n} OK / {n} warnings / {n} critical
  - Tech debt: {score}
  - Backlog cleanup: {n} recommendations
  - Anti-pattern self-diagnosis: {n} Yes hits — {action}
  - Worker-equivalent: ROI {roi_factor}× (human equiv {human_equiv_cost} {currency} ÷ AI {ki_cost} {currency}) — or: skipped
  - Learning loop: {level} → {n} entries saved

Commits:
  - sprint-review report (if saved as MD)
  - learnings entry (step 8)

Next steps:
  1. Review recommended issues in backlog
  2. Quarterly meta-retro if sprint number % 4 == 0
```

## Integration with other skills

- **`/ideation`** reads the last 3 learning-loop entries at every story creation (step 0.5) and warns on anti-pattern match.
- **`/architecture-review --system`** can run the sprint review at system scope (all active dimensions).
- **`/breakfix`** writes breakfix learnings into the loop in parallel as `what_didnt` with root cause.

## Triggers

- Operator says: "sprint review", "architecture audit", "tech debt", "clean up", "retro"
- Slash command: `/sprint-review`
- Cron (optional): weekly / monthly — sends reminder: "time for sprint-review"
- After every 4th sprint: quarterly meta-retro trigger

## Configuration

Learning-loop activation: `{PROJECT_PATH}/.learning-loop` file with contents `L1`, `L2` or `L3`. Created in bootstrap block D.4 or later manually.
