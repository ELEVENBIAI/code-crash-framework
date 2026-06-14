---
name: slopsquatting-deep-refresh
recommended_model: sonnet  # BOO-84 — tier mapping in bootstrap/references/model-tiers.json
description: |
  Quarterly layer for the slopsquatting guard (Code Crash ch. 3-4) — a thin orchestrator that runs
  /research to review the METHODOLOGY behind the slopsquatting wordlist: new advisory sources, changed
  feeds, research state, threshold adjustments. Produces an update recommendation (no auto-write).
  Boundary: the weekly auto-workflow refreshes the DATA, this skill reviews the METHOD. Use when the
  quarterly review is due, the operator says "/slopsquatting-deep-refresh", or wants to reconcile the
  wordlist methodology against the current research state. Triggers: "slopsquatting quarterly review",
  "review wordlist methodology", "new slopsquatting sources", "/slopsquatting-deep-refresh".
version: 1.0.0
metadata:
  hermes:
    category: governance
    tags: [slopsquatting, supply-chain, quarterly-review, methodology-audit, research-orchestrator]
    requires_toolsets: [terminal]
    related_skills: [research, quality-gate-audit, bootstrap]
---

# Slopsquatting Deep Refresh — the Quarterly Methodology Review

> "19.7% of AI-recommended packages do not exist." — Matthias Schrader, *Code Crash* ch. 3-4

The skill is the **manual quarterly layer** of the slopsquatting guard. It is a thin orchestrator that runs `/research` with a fixed quarterly prompt template and thereby reconciles not the wordlist *data* but the wordlist *methodology* against the current research state: have new advisory sources appeared? Have existing feeds changed or been deprecated? Is the state of slopsquatting research shifting (new attack vectors, new ecosystems)? Do thresholds (age check, 90-day freshness, source filters) need adjusting?

Output is an **update recommendation** plus an optional threshold-adjustment proposal — **no auto-write**. The operator decides what flows back into the templates (`dependency-check.sh`, the `wordlist.txt` refresh workflow, the `quality-gate-audit` gate).

## Boundary: two layers, two jobs

The slopsquatting guard has two maintenance layers with different cadence and goal. This skill is layer 2.

| Layer | What | Cadence | Maintains | Mechanism |
|-------|------|---------|-----------|-----------|
| **1 — Data refresh** | weekly auto-refresh of the wordlist *entries* | weekly (cron) | `.claude/hooks/slopsquatting/wordlist.txt` | GitHub Actions workflow `.github/workflows/slopsquatting-refresh.yml` → PR |
| **2 — Methodology review** (this skill) | quarterly review of the *methodology* behind the wordlist | quarterly (manual) | source list, filters, thresholds, method | `/slopsquatting-deep-refresh` → `/research` → recommendation |

Layer 1 keeps the list current. Layer 2 checks whether the list is being kept current **correctly** — whether the sources are still the right ones, whether the filters still bite, whether the 90-day freshness criterion still fits. Layer 1 writes (via PR). Layer 2 only recommends.

## When to use / when not to use

**Use `/slopsquatting-deep-refresh` when:**
- The quarterly review is due (every ~90 days, coupled to the freshness criterion)
- The weekly refresh workflow runs empty suspiciously often (suspicion: a source is dead or changed format)
- A new slopsquatting attack vector becomes public and the question is whether the current methodology covers it
- The `quality-gate-audit` gate (BOO-183) repeatedly reports a stale wordlist and it is unclear why the auto-refresh isn't biting

**Do NOT use `/slopsquatting-deep-refresh` when:**
- A single malicious package just needs adding → that's layer 1 (weekly workflow) or a manual entry in `slopsquatting-override.yaml`
- The wordlist is merely "old" but the workflow runs → not a methodology problem but a data problem; let layer 1 bite
- A false positive is being blocked → `never_add` entry in `slopsquatting-override.yaml`, no methodology review needed

## Workflow (3 steps)

### Step 1: load context

The skill reads on start (all read-only):

1. `.claude/hooks/slopsquatting/wordlist.txt` — current wordlist. Read the header field `# last_refreshed: YYYY-MM-DD` → determine **last refresh date** and **entry count**.
2. `.claude/hooks/slopsquatting/slopsquatting-override.yaml` (if present) — manual `never_add` / `never_remove` entries.
3. `.github/workflows/slopsquatting-refresh.yml` — the weekly refresh workflow. Extract the **current source list** (GHSA, OSV, OSSF package-analysis feed, npm advisory JSON) and the **filters** (`malicious-package`, `MAL-` IDs, ecosystem list `npm | pypi | cargo`).
4. Optional: last quarterly review report (if present from an earlier session) to build a diff against the prior quarter.

If a file is missing: the skill notes it in the output (e.g. "no refresh workflow found — methodology can only be checked against the wordlist itself") and continues with what's there. No hard fail.

The skill summarizes the loaded state:

> Current state: wordlist `last_refreshed: <date>`, <N> entries, <M> override rules. Sources in the refresh workflow: GHSA, OSV, OSSF, npm advisory. Last methodology review: <date or "none found">.

### Step 2: run the `/research` prompt template

The skill calls `/research` (deep research mode) with the fixed quarterly prompt from [references/quarterly-review-prompt.md](references/quarterly-review-prompt.md). The context loaded in step 1 (source list, current filters, `last_refreshed`) is filled into the template so `/research` researches against the **concrete current state** rather than generically.

The template has `/research` check four dimensions:

1. **New data sources** — since the last review, are there new public advisory / malicious-package feeds (e.g. new OSV exports, registry-native malware lists, CISA/ENISA feeds) that would increase wordlist coverage?
2. **Changed/deprecated feeds** — have the currently used sources (GHSA GraphQL `MALWARE`, OSV `MAL-`, OSSF package-analysis, npm advisory JSON) changed their schema, endpoint, or availability? Is a source dead?
3. **Research state of the methodology** — what is the current state on slopsquatting / package hallucination / typosquatting? New attack vectors, newly affected ecosystems (beyond `npm | pypi | cargo`), new detection methods?
4. **Threshold candidates** — are the current thresholds still sensible: age check (`<30 days` → warning), 90-day wordlist freshness, filter classifications? Is there evidence for adjustment?

`/research` validates (2-tier: Perplexity Deep Research + WebSearch cross-check) and returns a cited synthesis.

### Step 3: output — update recommendation (no auto-write)

The skill condenses the `/research` result into a structured recommendation. **The skill writes nothing into the templates or the wordlist** — it recommends, the operator decides and implements (or files a story for it).

Output structure:

1. **Summary** — 2-3 sentences: did the methodology move? Action needed yes/no?
2. **Source recommendations** — table `Source | Status (new / unchanged / changed / dead) | Recommendation (add / adjust / remove) | Rationale + citation`.
3. **Threshold-adjustment proposal** (optional) — only with evidence: `Threshold | current value | proposal | rationale`. Example: age check from 30 to 14 days, or freshness criterion from 90 to 60 days.
4. **Research notes** — relevant new findings on slopsquatting, with source links.
5. **Next steps** — concrete implementation hints: which template file (`bootstrap/references/file-templates.md` §`slopsquatting-refresh.yml` or §`dependency-check.sh`) would need touching, whether a story (BOO-XX) is needed. **No** automatic change.

The skill proposes storing the report under `journal/reports/slopsquatting/quarterly-<YYYY-Qn>.md` (derive the path from `.claude/environment.json` `paths.reports_local` if present) — but only on operator confirmation.

## Sparring-partner principle

The skill **does not decide** and **does not write** into the guard mechanics. It researches, compares against the current state, and presents a justified recommendation. Adjusting the wordlist methodology — adding a source to the refresh workflow, changing a threshold in the hook — is a deliberate operator decision, ideally as its own story through the pipeline (`/intent` → ... → `/implement`). Rationale (INTENTRON guiding principle "lightweight + pragmatic, no security compromises"): a methodology change to the supply-chain gate is security-relevant and belongs documented and reviewed, not auto-committed.

What the skill may do:
- load context (wordlist, override, refresh workflow)
- run `/research` with the fixed quarterly prompt
- produce a cited update recommendation + threshold proposal
- propose the report storage location

What the skill does NOT do:
- change the wordlist or the refresh workflow
- adjust thresholds automatically
- add a source to the workflow without operator approval

## Relation to Schrader

The skill operationalizes the supply-chain argument from *Code Crash* ch. 3-4 (Matthias Schrader, 2025): if 19.7% of AI-recommended packages do not exist, slopsquatting is its own AI-specific attack vector. The weekly auto-refresh (layer 1) keeps the known cases current — but a guard whose *sources* age goes blind unnoticed. The quarterly review forces the deliberate pause: not just "is the list fresh?" but "are we still querying the right sources, with the right filters, against the current research state?". Same logic as the wiring canary in the quality-gate audit (BOO-183): a configured gate can still be blind.

Full background: see README.en.md.

## References

- [references/quarterly-review-prompt.md](references/quarterly-review-prompt.md) — the fully written `/research` prompt template for the quarterly review

Related artefacts (produced by the parallel setup layer, not by this skill):
- `.claude/hooks/slopsquatting/wordlist.txt` — the wordlist (data layer)
- `.claude/hooks/slopsquatting/slopsquatting-override.yaml` — manual `never_add` / `never_remove` rules
- `.github/workflows/slopsquatting-refresh.yml` — weekly refresh workflow (layer 1)
- `.claude/hooks/dependency-check.sh` — the pre-commit hook that uses the wordlist (BOO-12 / BOO-197)
- HANDBUCH **Appendix AE** — slopsquatting wordlist maintenance (full picture of both layers + the `quality-gate-audit` freshness gate)

DE mirror: [SKILL.md](SKILL.md).

BOO sources: BOO-197 (slopsquatting wordlist + quarterly layer), BOO-183 (`quality-gate-audit` — freshness gate), BOO-12 (`dependency-check.sh`).
