# Spec-Gate (CI) — server-side spec-linkage gate (opt-in)

> **In short:** An **opt-in** GitHub Actions workflow that, on every PR to `main`, verifies server-side that the change references an existing `specs/<ISSUE>.md`. It closes the gap left by the runtime spec-gate: it makes "no merge without a spec" hold even against `--no-verify` and non-Claude paths. Activated as a required status check. Off by default; recommended for `governance_mode = heavy` / audit-bound projects.

## Why

The **runtime spec-gate** (`hooks/spec-gate.sh`, a Claude-Code `PreToolUse` hook) blocks the AI agent mechanically (exit 1): inside a governed session no commit happens without a filled-in `specs/<ISSUE>.md`. That is stronger than the field's advisory gates — but it is **not unbypassable**: a `git commit --no-verify`, a human commit outside a Claude session, or a different tool slip past it. The enforcement self-audit (HANDBUCH appendix AV "Enforcement model & trust boundaries") names this trust boundary openly.

The CI spec-gate closes it: it runs **server-side** in GitHub Actions, is `--no-verify`-resistant, and checks every PR independently of the tool used. It is the server layer above the runtime hook, not a replacement — the hook stays for fast in-session feedback.

## What it checks

1. Extracts all issue keys (pattern `[A-Z]+-[0-9]+`) from the **branch name** and the **PR title**. Deliberately not from commit messages — squash-merge collapses those and they are unreliable.
2. Finds no key → the **job fails** (no spec reference provable).
3. An existing `specs/<KEY>.md` for at least one referenced key → **pass**. Otherwise → **fail**.

A PR without a referenced spec is therefore not mergeable once the gate is wired as a required check.

## Set up (scaffold)

The workflow is a template in `bootstrap/references/file-templates.md` (section `.github/workflows/spec-gate-ci.yml`). Two routes:

- **New project:** for `governance_mode = heavy` the bootstrap recommends the gate in §7.7 "Optional add-ons / next steps". Copy the template content to `.github/workflows/spec-gate-ci.yml`.
- **Existing project:** `bash bootstrap/scripts/migrate-to-v2.sh` runs `migrate_boo_254` — it creates `.github/workflows/spec-gate-ci.yml` if missing (idempotent, non-destructive) and adds the pointer to `DEVELOPER_ONBOARDING.md`.

## Activate as a required check

Scaffolding alone does not block a merge yet — the workflow must be a **required status check**:

```bash
bash bootstrap/scripts/setup-branch-protection.sh
```

The script reads the required contexts **dynamically** from `.github/workflows/*.yml` (the top-level `name:` field). Because the new workflow carries `name: Spec-Linkage`, a **re-run** is enough — no hand-clicking in the GitHub settings. Prerequisite: gh admin auth (see HANDBUCH appendix Y "GitHub connect per VPS").

Verify: the `Spec-Linkage` check must appear on the PR and gate the merge green/red.

## Issue key & squash-merge

The key is taken from the branch name **or** the PR title. Repo convention: branch `…/boo-254-…` and/or PR title with `BOO-254`. That keeps the reference intact even under squash-merge, where commit messages are lost. Multiple keys are allowed — it passes as soon as **one** has a spec (a PR may mention a second issue without that one needing its own spec).

## Boundaries

- **Runtime spec-gate** (`hooks/spec-gate.sh`, PreToolUse): blocks the AI agent locally/in-session, fast feedback. Stays active.
- **CI spec-gate** (this workflow): blocks the merge server-side, `--no-verify`-resistant, tool-independent.
- **Docs-compliance gate** (`scripts/doc-drift-check.sh --strict`, BOO-229): checks the documentation map, not the spec reference — orthogonal.

## Limits

- Checks the **existence** of a referenced spec, not its content quality (the runtime hook does that via `## Agent-Pattern`).
- `enforce_admins=false` (the solo/agent-flow default): a repo owner can override the required check. Whoever wants it hard raises `enforce_admins` — a governance decision, not a default (see appendix AV, trust boundaries).

## References

- HANDBUCH appendix AW (this setup pointer) · appendix AV "Enforcement model & trust boundaries" (BOO-228)
- `bootstrap/scripts/setup-branch-protection.sh` · `bootstrap/references/file-templates.md` (`spec-gate-ci.yml`)
- `docs/runbooks/audit-perspective.md` (audit trail = Git + `journal/reports/` + `docs/audits/`)
