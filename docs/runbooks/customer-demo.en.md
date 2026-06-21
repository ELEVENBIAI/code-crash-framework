# Customer demo — show the framework in 1–2 h (runbook)

[🇩🇪 Deutsch](./customer-demo.md) · [🇬🇧 English](./customer-demo.en.md)

> A script to show the framework **live in 1–2 h** — "this is how we build". What to show in which order, what to say, and which role use-cases. Source: BOO-238.

> [!warning] Demo project repo = follow-up work
> A ready, clonable **demo repo** (pre-bootstrapped, with issues + CI) is separate follow-up work (see `specs/BOO-238.md`, open acceptance criterion). For now, use a small, freshly bootstrapped project.

## 0. Preparation (before the meeting)

- **Demo project** bootstrapped in advance + on GitHub: branch protection + hooks active, 2–3 Linear issues with acceptance criteria created, CI workflows green.
- **Accounts/keys ready:** GitHub, Linear, optional deploy platform + SonarCloud, Anthropic API.
- **Dry run** once end-to-end (timing checked).
- **Offline fallback:** screenshots/recording of the core steps in case of network/live risk.

## 1. Flow (1–2 h, with timing)

| Time | Step | Talking point |
|---|---|---|
| 0:00–0:10 | Intro + "Our position" | autonomous up to the PR, human at the merge — controlled trust |
| 0:10–0:25 | Idea → `/ideation` → Linear issue with ACs | "intent before spec — the AI doesn't cleanly build the wrong thing" |
| 0:25–0:45 | `/implement` live: **provoke a gate block** (commit without a spec → `spec-gate` blocks) → resolve → green | "no commit without a spec — that's the difference from a prompt" |
| 0:45–1:05 | `/sprint-run --auto`: autopilot to a PR | "runs unattended but does not merge itself" |
| 1:05–1:25 | Role lens (CISO / CTO / DPO) on concrete gates | see §2 |
| 1:25–1:40 | CI/CD visible (GitHub Actions, SonarCloud) + token / worker-equivalent (status line) | "measured, not guessed" |
| 1:40–2:00 | Q&A + reset | |

## 2. Role use-cases (demo scenes)

| Role | What I show | Evidence / runbook |
|---|---|---|
| **CISO** | `sensitive-paths` gate bites → `review-ok`; `security-architect` | [`ciso-security.en.md`](./ciso-security.en.md) |
| **CTO** | quality gates (coverage, slopsquatting, `quality-gate-audit`), `architecture-review` | [`cto-code-quality.en.md`](./cto-code-quality.en.md) |
| **DPO** | `personal-data` gate → `privacy-ok`, dpo control catalog | [`dpo-privacy.en.md`](./dpo-privacy.en.md) |
| **CEO** | worker-equivalent / ROI (status line) | [`ceo-business-case.en.md`](./ceo-business-case.en.md) |
| **Auditor** | traceability idea→issue→spec→commit, `audit-trace.sh` | [`audit-perspective.en.md`](./audit-perspective.en.md) |

## 3. The "wow" moment: gate block live

1. Change a file and commit **without** a spec → `spec-gate` blocks (show the message).
2. Create `specs/<ISSUE>.md` → commit again → green.
3. Optional: edit a `sensitive-path` → stops until a human sets `review-ok`.

→ Message: the guardrails are invisible until they catch something — and when they catch, they explain why.

## 4. Reset (repeatable)

- Delete demo branches, reset Linear issues, return the demo repo to the starting commit. Makes the demo idempotently repeatable.

## 5. What deliberately does NOT happen live

Merge to `main`, deploy, secret rotation — stay human-approved (see [Our position](../../README.md#our-position-sequential-pipeline-human-gated-merges)). That is exactly the trust argument in front of the customer.

## Related

Role runbooks ([`docs/runbooks/`](./)) · onboarding checklists ([`docs/onboarding/`](../onboarding/)) · [Developer quick-start](../quickstart-entwickler.en.md) · [Our position](../../README.md#our-position-sequential-pipeline-human-gated-merges).
