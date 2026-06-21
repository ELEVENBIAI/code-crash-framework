# Demo preparation — set up a finished customer demo (runbook)

[🇩🇪 Deutsch](./demo-vorbereitung.md) · [🇬🇧 English](./demo-vorbereitung.en.md)

> The script *before* the demo: what you do **beforehand** so you arrive at the customer with a **finished, working demo**. Counterpart to [`customer-demo.en.md`](./customer-demo.en.md) (the flow *during* the demo). Source: BOO-238.

> [!tip] Deliberately no maintained demo repo
> Instead of maintaining a permanent demo project (which drifts and must be kept green), you set the demo up **freshly and reproducibly from this runbook**. The reset at the end (step 5) makes it repeatable.

## 0. Pre-flight checklist

- **Accounts/keys:** GitHub, Linear, Anthropic API; optional deploy platform + SonarCloud.
- **Lead time:** plan ~60–90 min.
- **Dry run** once end-to-end (timing + that the gates actually fire).
- **Offline fallback:** screenshots/recording of the core steps (in case of network/live risk at the customer).

## 1. Set up the VPS (Hostinger)

- Provision + harden the VPS → [Hostinger VPS setup](./hostinger-vps-setup.en.md); for team/multi-user → [VPS team setup](./vps-team-setup.md).
- Install the Claude Code CLI on the VPS, set up GitHub and Linear access.
- *(Locally on a Mac works too — the VPS makes the demo feel "real" and allows unattended runs; for mobile control see the "control the VPS from your phone" runbook, BOO-240.)*

## 2. Install the framework (`/bootstrap`)

- Create an empty demo project, run `/bootstrap` → `CLAUDE.md`, Git hooks, CI workflows, branch protection, skill selection.
- **Verify:** `bootstrap/references/verify-setup.sh` green; a test commit without a spec shows the **spec-gate** bites (that's your later wow moment).

## 3. Example story + ready-to-paste prompt

Pick a story that runs through **as many features as possible**. Recommended (stack **Node/TS**):

> **"POST `/login` endpoint with input validation"** — touches an `auth` path (→ **sensitive-paths gate** fires live), needs tests (→ **coverage gate**), and is small enough for a live demo.

Ready-to-paste prompts (in Claude Code, inside the demo project):

```text
/intent We want secure login so users can authenticate — security before speed.
```

```text
/ideation POST /login endpoint (Node/TS): takes email + password, validates the input,
returns a session token on success. With acceptance criteria and tests. Create the Linear issue.
```

```text
/implement <ISSUE-ID>
```

*(Optional whole sprint: `/sprint-run`; unattended to a PR: `/sprint-run --auto`.)*

## 4. Feature walkthrough (what you show)

- `/intent` → the **why** before the spec.
- `/ideation` → **Linear issue with acceptance criteria**.
- `/implement` → **gate block live**: commit without a spec → **spec-gate** blocks → create the spec → green; the `auth` path → **sensitive-paths** → human `review-ok`.
- `/sprint-run --auto` → **autopilot to a PR** (does not merge itself).
- Make **CI/CD** (GitHub Actions, SonarCloud) + the **status line** (worker-equivalent) visible.
- `/pitch` → evidence briefing for stakeholders.

→ Detailed script with timing + role use-cases: [`customer-demo.en.md`](./customer-demo.en.md).

## 5. Reset (repeatable)

- Delete demo branches, reset Linear issues, return the repo to the starting commit. This makes the demo **idempotently repeatable**.

## Related

[`customer-demo.en.md`](./customer-demo.en.md) (flow *during* the demo) · onboarding checklists ([`docs/onboarding/`](../onboarding/)) · [Developer quick-start](../quickstart-entwickler.en.md) · [Hostinger VPS setup](./hostinger-vps-setup.en.md).
