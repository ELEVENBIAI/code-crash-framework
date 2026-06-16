# Skills Setup — New project installation

Skills are fetched from the official GitHub repo via `git clone` into a temp folder and copied into `{PROJECT_PATH}/.claude/skills/`. No symlinks to VPS paths, no global `/root/.claude/skills/`.

## Repo structure (BOO-74/121)

**Source guarantee:** All **bundle skills** (incl. `intent`) **always** come **from the `intentron` repo** — **never** from `claudecodeskills`. They live flat as top-level folders (no more `intentron/` nesting — that was the old pre-BOO-74 structure):

- **`$SKILL_SRC/<skill>/`** (intentron clone) — all bundle skills: `architecture-review`, `backlog`, `bootstrap`, `cloud-system-engineer`, `dpo`, `grafana`, `ideation`, `implement`, `intent`, `knowledge-onboarding`, `pitch`, `research`, `security-architect`, `sprint-review`, `visualize`.
- **No optional `claudecodeskills` clone question anymore (BOO-219):** `setup-checklist` is its own public repo (BOO-113); `design-md-generator`/`skill-creator` stay global/standalone and are not sourced by the framework.

> **Master vs. mirror:** `dpo`, `security-architect` and `research` are maintained in `claudecodeskills` (master) but live as a **mirror** in the intentron bundle — bootstrap installs them from intentron. **Regression guard:** `bootstrap/scripts/check-skill-sources.sh` (CI: `skill-sources.yml`) verifies mirror completeness + that no bundle skill is sourced against `claudecodeskills`. **Operator note:** keep the local `bootstrap` skill current (`git pull` in the intentron clone), otherwise stale source paths (pre-BOO-74) apply.

## Installation (standard flow)

```bash
# Temp folder
SKILL_SRC=$(mktemp -d)

# Clone the framework repo (shallow) — ALL bundle skills live here (BOO-74/121/219)
git clone --depth 1 https://github.com/vibercoder79/intentron "$SKILL_SRC"

# Create skills directory in project
cd {PROJECT_PATH}
mkdir -p .claude/skills

# All bundle skills are flat top-level folders — no path mapping needed anymore
for skill in ideation implement backlog intent research; do
  cp -R "$SKILL_SRC/$skill" ".claude/skills/$skill"
done

# Cleanup
rm -rf "$SKILL_SRC"
```

## Available skills

| Skill | Description | Tier |
|-------|-------------|------|
| `ideation` | Deep research + user story creation | Minimum |
| `implement` | Implementation workflow with governance gates | Minimum |
| `backlog` | Sprint planning + backlog overview | Minimum |
| `intent` | Pipeline entry: intent capture (Perceive of the 4P) | Minimum |
| `research` | Deep research via WebSearch + Perplexity (engine of the mandatory Phase 4.10) | Minimum |
| `architecture-review` | Architecture review (standard dimensions + active add-ons) | Standard |
| `knowledge-onboarding` | Existing-doc routing into governance artefacts (rubric + manifest, BOO-137) | Standard |
| `sprint-review` | Periodic audit + **learning-loop entry** (see `learning-loop.en.md`) | Standard |
| `security-architect` | Security review (STRIDE/OWASP) | Standard |
| `grafana` | Grafana dashboard development | Optional |
| `cloud-system-engineer` | VPS infrastructure | Optional |
| `visualize` | Architecture diagrams in Miro | Optional |

## Skill tier selection in bootstrap

```
Which skills to install?
  a) Minimum   (ideation, implement, backlog, intent, research)
  b) Standard  (+ architecture-review, sprint-review, knowledge-onboarding, security-architect)
  c) Full      (all available)
  d) Manual    (operator selects individually)
```

## Customization of installed skills

**Generic (default):** Skills are copied unchanged from the master repo. References stay generic (no project assumptions) and work directly.

**Project-specific (only when needed):** If the project requires domain-specific adjustments, the path is:

1. Edit the file in the installed skill locally
2. Document the adjustment as project-specific (e.g. in `specs/JAR-XXX.md` the first story on it)
3. Optional: Package the adjustment as a skill variant via `/skill-creator`

**Never** commit master skills from the project — the master stays generic.

## Update strategy

If a master skill gets an update:

```bash
SKILL_SRC=$(mktemp -d)
git clone --depth 1 https://github.com/vibercoder79/intentron "$SKILL_SRC"

# Show diff before overwrite — all bundle skills are flat top-level (BOO-219)
diff -r "$SKILL_SRC/<skill>" ".claude/skills/<skill>"

# Apply updates selectively — operator decides per file
```

## Install order

1. `research` — no dependencies
2. `ideation` — needs story templates (included in skill)
3. `backlog` — needs Linear/M365/GitHub connector
4. `implement` — needs `change-checklist.md` + Git
5. `architecture-review` — needs dimensions reference
6. `security-architect` — standalone
7. `sprint-review` — needs `learning-loop.en.md` if learning loop active
8. Optional (full tier): `grafana`, `cloud-system-engineer`, `visualize`

## ISSUE_WRITING_GUIDELINES.md

NOT copied from an external path; rendered from `references/issue-writing-guidelines-template.md` (prefix substituted). See SKILL.md Phase 4.3.

## implement skill — governance integration

The `implement` skill contains these mandatory steps (active when installed):

| Step | What | Governance impact |
|------|------|-------------------|
| 3 | Context — read `ARCHITECTURE_DESIGN.md` Hub + component doc | Hub-first navigation |
| 3b | Governance validation (8 dimensions + security) | Mandatory before plan |
| 3c | Spec file gate (spec-gate.sh enforces it) | Spec required |
| 5 | Implementation incl. T_last doc update | Component doc + Hub §9 + `lib/config.js` VERSION bump |
| 6a | Linting gate (ESLint/Ruff — 0 errors required) | Quality gate |

## Learning-loop integration (when active)

When Block D = L1/L2/L3:

- `sprint-review` skill gains Step 7 (learning-loop entry) — see `learning-loop.en.md`
- `ideation` skill gains Step 0.5 (read learnings context before story creation)

Activation: `.learning-loop` file in project root with content `L1`, `L2` or `L3`.

## Sync convention: vendored skills (BOO-74/219)

Since BOO-74 (Wave M), `dpo` and `security-architect` live as **vendored bundle skills** in the `intentron` repo; since BOO-219 also `research`. Bootstrap therefore installs them from the same repo as all other bundle skills (Phase 5). But: the **master** of these skills remains the `claudecodeskills` repo.

### Master vs. mirror

| Role | Repo | Maintenance |
|------|------|-------------|
| Master | `claudecodeskills` | `publish_skill.py <skill>` — source of truth, also for solo operators without the framework |
| Mirror | `intentron` | vendored 1:1 copy (`dpo/`, `security-architect/`, `research/`), the one Bootstrap installs from |

> **Note (BOO-219):** the `research` master in `claudecodeskills` currently carries no `SKILL.en.md`/`README*`. The intentron mirror adds those (the framework's DE+EN requirement). On the next `publish_skill.py research`, backfill the master accordingly so the mirror is not overwritten (drift risk, see below).

### Mandatory on every dpo, security-architect or research update

1. Change the skill locally in `~/.claude/skills/<skill>/`.
2. `python3 ~/.claude/skills/skill-creator/scripts/publish_skill.py <skill> -m "..."` — updates the master in `claudecodeskills` + SecondBrain docs.
3. **Refresh the mirror:** `cp -R ~/.claude/skills/<skill>/ ~/Documents/GitHub/intentron/<skill>/` and commit in the framework repo.
4. Verify: `diff -rq ~/.claude/skills/<skill>/ ~/Documents/GitHub/intentron/<skill>/` → no diff.

### Drift risk

If step 3 is forgotten, the framework mirror runs on an older skill revision than the master. New bootstrap runs then install the stale version. **Follow-up story (planned):** `sync_framework_mirror.sh` automates steps 3+4 — until then it is the operator's duty.
