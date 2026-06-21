# INTENTRON — Developer Quick-Start

[🇩🇪 Deutsch](./quickstart-entwickler.md) · [🇬🇧 English](./quickstart-entwickler.en.md)

> **The essentials at a glance — "When do I use what?"** Not a setup guide (that is [README §Quickstart](../README.md) + [HANDBUCH §4](../HANDBUCH.en.md)) but the **command choice in daily use**. Prints to ≤5 pages.

## 1. The flow at a glance

```
💡 Idea
  └─ /intent ........... capture the WHY (before the spec)
      └─ /ideation ..... idea → Linear issue with acceptance criteria
          └─ /backlog .. prioritization: which story next?
              └─ /implement ........ one story: spec → code → gates → commit
                  └─ /architecture-review .. risks? tech debt?
                      └─ /sprint-review ..... quarterly retro: what worked?
                          └─ /pitch ........ evidence briefing for the stakeholder demo
```

## 2. When do I use what?

| I want to … | Command |
|---|---|
| capture the *why* before the spec | `/intent` |
| turn an idea into a story with acceptance criteria | `/ideation` |
| prioritize which story comes next | `/backlog` |
| **implement a single story** | **`/implement`** |
| **run a whole sprint** (several stories, worktree, CI, merge) | **`/sprint-run`** |
| **run unattended to a ready-to-review PR** (autopilot) | **`/sprint-run --auto`** |
| review architecture (risks, tech debt) | `/architecture-review` |
| quarterly retro / sprint audit | `/sprint-review` |
| check whether my quality gates *actually bite* | `/quality-gate-audit` |
| prepare a stakeholder demo | `/pitch` |

## 3. `/implement` vs `/sprint-run` vs `--auto` (the most common question)

| | `/implement` | `/sprint-run` | `/sprint-run --auto` |
|---|---|---|---|
| **Scope** | exactly **one** story | **several** stories in sequence | several stories, **unattended** |
| **Supervision** | you ride along | you start, you watch | runs on its own to a PR |
| **Worktree/branch** | one branch | worktree + branch per story | same |
| **End point** | story commit/PR | PRs + `/sprint-review` at the 80% token boundary | PRs, then stop |
| **NOT automatic** | — | merge / deploy / secrets | merge / deploy / secrets (stay human, see [Our position](../README.md#our-position-sequential-pipeline-human-gated-merges)) |

**Rule of thumb:** one story → `/implement`. A batch of stories → `/sprint-run`. Overnight / on the VPS → `/sprint-run --auto`.

## 4. Command reference (runtime-relevant)

| Skill | What for |
|---|---|
| `/bootstrap` | **Start here:** project setup (CLAUDE.md, hooks, backlog, skill selection) |
| `/intent` · `/ideation` · `/backlog` | upstream: why → story → prioritization |
| `/implement` · `/sprint-run` | execution: one story / a whole sprint |
| `/architecture-review` · `/sprint-review` | review: architecture / sprint retro |
| `/quality-gate-audit` | checks whether gates are *wired* (not just configured) |
| `/pitch` | evidence briefing for the demo (no slides) |
| `/security-architect` · `/dpo` | security / privacy review (bundle) |
| `/knowledge-onboarding` · `/infrastructure-onboarding` | retrofit existing docs / infra layers (post-bootstrap) |

Full table: [README §The Skills](../README.md#the-skills).

## 5. Switches & modes

| Switch | Meaning |
|---|---|
| **Switch A** — `runtime_target=claude-code` | Claude-Code-first default (e.g. enables the status line) |
| **`governance_mode`** — `lite` / `standard` / `heavy` | gate strictness: solo to enterprise, same record, only dialed up/down |
| **`change_type: prototype`** | deliberate gate relaxation without breaking compliance |
| **`--auto`** | `/sprint-run` autopilot mode (unattended to a PR) |

## 6. Gates — what blocks when, how to clear it

| Gate | Blocks when … | Clear it |
|---|---|---|
| **spec-gate** | commit without a linked spec | create `specs/<ISSUE>.md` |
| **sensitive-paths** (BOO-18) | edit to auth/payment/PII paths | human `review-ok` |
| **personal-data** (BOO-69) | edit to personal-data paths | human `privacy-ok` |
| **coverage** | new code < 80 % tested | add tests |
| **slopsquatting** | suspicious (hallucinated) package name | check / remove the package |
| **Layer-0 bodyguard** | risky edit before writing | confirm deliberately |

## 7. "A gate is blocking — what now?"

1. **Read the message** — it names the gate + reason + usually the fix.
2. **spec-gate** → create the spec (`specs/<ISSUE>.md`), then commit again.
3. **sensitive-paths / personal-data** → a human sets `review-ok` / `privacy-ok` (deliberate sign-off, no auto-bypass).
4. **coverage / slopsquatting / lint** → fix the cause (tests, package name, lint), do not switch the gate off.
5. In autopilot, `/sprint-run` pauses on a non-self-healable block and waits for you.

## Going deeper

[HANDBUCH §6 "The Skills — when do I use what?"](../HANDBUCH.en.md) · [plain-language glossary](./glossar.en.md) · [Our position (sequential, human-gated)](../README.md#our-position-sequential-pipeline-human-gated-merges) · [README §Quickstart](../README.md) (installation).
