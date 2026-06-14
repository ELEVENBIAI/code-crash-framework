<a name="english"></a>

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](README.md)

# /goal — native termination engine in the Code-Crash framework

> `/goal` is the **Anthropic-native** termination engine of Claude Code. It takes a machine-checkable
> **termination phrase**, orchestrates native subagents and runs turn by turn until an evaluator
> sees the phrase as satisfied. In the Code-Crash framework `/goal` has been — since **ADR-4** — the
> **sprint engine** behind [`/sprint-run`](../sprint-run/README.en.md), and alternatively the
> **story engine** for long [`/implement`](../implement/README.en.md) runs.

**Anthropic-native — documented here in the framework, not built ourselves.**

> [!info] Not a framework skill
> `/goal` is **not** a skill of this repo: there is **no** `goal/SKILL.md`, no own code, no own
> version. This folder **only documents** how the native engine is used in the Code-Crash workflow.
> Build-vs-buy doctrine (ADR-1): the framework does not rebuild what Anthropic already provides
> natively — it uses it and documents the embedding.

---

## What `/goal` is (and is not)

`/goal` is a **termination loop** with an evaluator. You give it a phrase that describes the desired
end result **objectively checkable** (all issues *Done*, all gates green, journal written). `/goal`
keeps working on its own — orchestrating native subagents, letting workers fix red gates, re-checking
— until the evaluator sees the phrase as satisfied or a limit (token budget) is reached.

`/goal` is **not** a sprint planner, **not** a spec generator and **not** a worktree manager. That
preparation is done by the framework (`/sprint-run`); `/goal` receives the **fully prepared
environment** plus the **phrase** and executes.

---

## Use 1 — sprint termination (called by `/sprint-run`)

The standard case in the framework. `/sprint-run` is a **configurator + wrapper**: it prepares the
sprint (pre-flight, specs, worktree per story, subagent definitions, token budget) and **hands
execution over to `/goal`**. From there the loop belongs to `/goal`:

```
/goal "Sprint <id> closed: all Linear issues status:done, all quality gates green
(Semgrep, ESLint, Coverage>=80%, GitHub Actions), journal/sprint-<date>.md written,
no open subagent tasks"
```

`/goal` orchestrates the stories in parallel as native subagents (each in its own worktree), fixes
red gates, pauses on sensitive paths and terminates when the phrase is satisfied or at the 80% token
boundary. The full flow is described by [`/sprint-run`](../sprint-run/README.en.md) (step 5) and the
ADR [Sprint run with `/goal`](#cross-references).

---

## Use 2 — story termination (directly in `/implement` for long stories)

For a **single, long** story `/goal` can also be used directly — without the full sprint apparatus
of `/sprint-run`. The phrase then describes the **story end** instead of the sprint end:

```
/goal "Story <ISSUE> closed: Linear status:done, all quality gates green (Semgrep, ESLint,
Coverage>=80%, GitHub Actions), merged to main, meta.json without unjustified skipped_gates"
```

This way a story that needs many iterations (red gate → fix → re-check) runs on its own to a green
end, instead of triggering every step manually. The manual 1-story E2E protocol for this lives in
[`sprint-run/references/goal-e2e-protocol.en.md`](../sprint-run/references/goal-e2e-protocol.en.md).

---

## Termination phrase library

A **termination phrase** is good when each clause is **objectively checkable** (issue status, gate
exit codes, file present) — not "sprint done", but concrete, observable states. Vague terms ("clean",
"good") cannot be checked by the evaluator; the loop then either never terminates or terminates too
early.

The curated **phrase library per phase** (standard sprint, Python stack, single story, token boundary
as an explicit terminator, anti-patterns) lives with `/sprint-run`:

- **EN:** [`sprint-run/references/goal-termination-phrases.en.md`](../sprint-run/references/goal-termination-phrases.en.md)
- **DE:** [`sprint-run/references/goal-termination-phrases.md`](../sprint-run/references/goal-termination-phrases.md)

---

## Limits

- **The evaluator only reads the transcript.** `/goal` judges the termination phrase based on the
  **conversation transcript** — it makes **no own bash calls** to, e.g., re-run a gate itself. So the
  gate results must appear as **observable facts in the transcript** (the worker subagent runs the
  gate, the result shows up in the flow). A phrase whose fulfilment cannot be read from the transcript
  does not terminate reliably.
- **No manual steps in the phrase.** Approval pauses ("operator has reviewed") belong in the
  gate-block protocol, not in the termination phrase — otherwise `/goal` never terminates.
- **Preparation is not `/goal`'s job.** Specs, worktrees and agent files are provided by
  `/sprint-run`.

---

## Prerequisites

For `/goal` to run on its own and safely to the sprint/story end, the same three safety
prerequisites must be met that `/sprint-run` checks before the `/goal` call:

1. **Bash permission auto-allow.** `.claude/settings.local.json` carries an **allowlist** with the
   gate commands (`semgrep`, `eslint`, `pytest`, `gh run`, `git`) so that `/goal` and its subagents
   run the quality gates unattended without hanging on a permission prompt. `/bootstrap` creates the
   template.
2. **`execution_isolation=worktree`.** Native subagents only write in parallel in worktree-isolated
   working trees without collisions. If isolation is not `worktree`, `/sprint-run` **aborts** before
   the `/goal` call.
3. **Layer-0 bodyguard active.** The `pre-edit-bodyguard` hook (PreToolUse on `Edit|Write`) blocks
   secrets and sensitive paths before writing. If it is not live, `/sprint-run` **pauses** and does
   not call `/goal`.

These three replace the former container boundaries (ADR-4): worktree instead of container volume,
allowlist instead of container permissions, bodyguard instead of container sandbox.

---

## Cross-references

- **Sprint engine (wrapper):** [`/sprint-run`](../sprint-run/README.en.md) — prepares the sprint and
  calls `/goal` with the termination phrase.
- **Story engine (single story):** [`/implement`](../implement/README.en.md) — 8-step protocol for one
  story; long runs can use `/goal` as termination.
- **Phrase library:** [`sprint-run/references/goal-termination-phrases.en.md`](../sprint-run/references/goal-termination-phrases.en.md) (+ DE).
- **Manual 1-story E2E protocol:** [`sprint-run/references/goal-e2e-protocol.en.md`](../sprint-run/references/goal-e2e-protocol.en.md).
- **Document index:** [`docs/INDEX.en.md`](../docs/INDEX.en.md).

Chain: `intent → ideation → backlog → sprint-run → /goal ( native subagents )* → sprint-review`.

---

## File structure

```
goal/
├── README.md      ← use of /goal in the framework (DE)
└── README.en.md   ← this file (EN)

No SKILL.md — /goal is Anthropic-native, not a framework skill.
The phrase and E2E references live with /sprint-run (references/).
```
