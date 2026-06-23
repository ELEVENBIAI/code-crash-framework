# Release Notes — Convention

> 🌐 **Language:** English (this file) · [🇩🇪 Deutsch](README.md)

This folder is the **source of the release notes**. They are additionally published as **GitHub Releases**:
<https://github.com/vibercoder79/intentron/releases>

## Two levels

| Level | File | Purpose |
|-------|------|---------|
| **Granular (per wave)** | `wave-<x>-<topic>.md` | One file per wave/update — the single change with stories, changes, migration, smoke test. In the repo, permanent. |
| **Aggregate (per version)** | `v<MAJOR.MINOR.PATCH>-overview.md` | Summarizes all waves of a version (big-picture table + detail sections + appendix/version tables). Becomes the **body of the GitHub Release**. |

## Convention: one GitHub Release per version

**On every version tag** a GitHub Release is created — granularity is **per version** (not per wave). The individual `wave-*.md` stay the granular source in the repo and are linked/summarized in the release body.

How a release is created (example v0.2.0):

```bash
# 1. Tag the finished state (all waves of the version done, docs DE/EN parity)
git tag -a v0.2.0 -m "v0.2.0 — <short description>"
git push origin v0.2.0

# 2. GitHub Release with the overview as body
gh release create v0.2.0 \
  --title "v0.2.0 — <title>" \
  --notes-file docs/releases/v0.2.0-overview.md
```

Update an existing release afterwards: `gh release edit v0.2.0 --notes-file docs/releases/v0.2.0-overview.md`.

## Rules

1. **Every wave gets a `wave-*.md`** in the same style (purpose, stories, changes, migration, references) — part of the documentation touchpoint quartet (HANDBUCH, release notes, spec, Linear).
2. **The `v<version>-overview.md` is maintained per wave** (table row + detail section if needed) so it is complete at the version release.
3. **Before the tag**: docs DE/EN parity, all Linear issues of the version Done, `verify-setup.sh` green.
4. **Tag = state**: only tag once the release state is truly finished (no tag on a half-finished EN state).
5. **Release body = overview**: no separate copy-paste — `--notes-file` points directly at the `v<version>-overview.md`.
6. **Bilingual (DE + EN) mandatory**: each `v<version>-overview.md` has the German part on top, followed by `---` + `# 🇬🇧 English Version` with a faithful English mirror (same structure/tables; code identifiers, BOO numbers, paths, links verbatim). The GitHub release body is thus bilingual itself. Before tagging, check both parts are in sync.

## Predecessors

- `v0.1.0` — GAP hardening (waves A–I), tagged 2026-05-22.
- `v0.2.0` — Governance OS (waves J–T): privacy, deployment, sovereignty, multi-operator, verification, multi-project, vault harvest, Codex onboarding.

---

## All releases — index (89 waves, newest first)

- **CI** — [Wave CI — Codex reviewer: independent code review as an opt-in layer (BOO-239)](wave-ci-codex-reviewer.en.md) · [DE](wave-ci-codex-reviewer.md)
- **CH** — [Wave CH — Post-install: optional add-ons / next-steps section (BOO-248)](wave-ch-postinstall-addons.en.md) · [DE](wave-ch-postinstall-addons.md)
- **CG** — [Wave CG — Position block + Hermes rationale + README refresh (BOO-227, BOO-236)](wave-cg-position-readme-refresh.en.md) · [DE](wave-cg-position-readme-refresh.md)
- **CF** — [Wave CF — research as a vendored bundle skill: self-contained fix (BOO-219)](wave-cf-research-vendored-bundle-skill.en.md) · [DE](wave-cf-research-vendored-bundle-skill.md)
- **CE** — [Wave CE — Worker-equivalent: a second steering dimension alongside token consumption (BOO-190/191/192/193)](wave-ce-worker-equivalent.en.md) · [DE](wave-ce-worker-equivalent.md)
- **CD** — [Wave CD — Semgrep custom-rule wiring + verification canary (BOO-185/188)](wave-cd-semgrep-custom-rule-wiring.en.md) · [DE](wave-cd-semgrep-custom-rule-wiring.md)
- **CC** — [Wave CC — Linter wiring end-to-end: central picture + sketch (BOO-182)](wave-cc-linter-verdrahtung-e2e.en.md) · [DE](wave-cc-linter-verdrahtung-e2e.md)
- **CB** — [Wave CB — EN catch-up for the 43 legacy wave release notes: DE+EN parity, retroactively (BOO-174)](wave-cb-en-parity-altwaves.en.md) · [DE](wave-cb-en-parity-altwaves.md)
- **CA** — [Wave CA — Make observability visible: docs + logging/monitoring runbook (BOO-179)](wave-ca-observability-sichtbar.en.md) · [DE](wave-ca-observability-sichtbar.md)
- **BZ** — [Wave BZ — Integrate a new stack/linter: runbook + HANDBOOK chapter (BOO-178)](wave-bz-stack-linter-runbook.en.md) · [DE](wave-bz-stack-linter-runbook.md)
- **BY** — [Wave BY — Doc index catch-up: missing runbooks in the central index (BOO-181)](wave-by-doku-index-nachzug.en.md) · [DE](wave-by-doku-index-nachzug.md)
- **BX** — [Wave BX — PR & merge hygiene: guard against duplicate PRs (BOO-175)](wave-bx-pr-merge-hygiene.en.md) · [DE](wave-bx-pr-merge-hygiene.md)
- **BW** — [Wave BW — Documentation Definition of Done as a convention (BOO-180)](wave-bw-doku-definition-of-done.en.md) · [DE](wave-bw-doku-definition-of-done.md)
- **BV** — [Wave BV — Unit-test hardening: real tests, not just coverage (BOO-177)](wave-bv-unit-test-hardening.en.md) · [DE](wave-bv-unit-test-hardening.md)
- **BU** — [Wave BU — Quality-gate integrity: the agent cannot lower the bar itself (BOO-176)](wave-bu-quality-gate-integrity.en.md) · [DE](wave-bu-quality-gate-integrity.md)
- **BT** — [Wave BT — Release notes networked: central wave index + DE↔EN language switch (BOO-173)](wave-bt-release-index.en.md) · [DE](wave-bt-release-index.md)
- **BS** — [Wave BS — Runbook: run a sprint unattended on the VPS with tmux (BOO-172)](wave-bs-runbook-tmux-vps.en.md) · [DE](wave-bs-runbook-tmux-vps.md)
- **BR** — [Wave BR — implement: lint loops on a Haiku subagent (BOO-171)](wave-br-implement-haiku-loops.en.md) · [DE](wave-br-implement-haiku-loops.md)
- **BQ** — [Wave BQ — Model/mode routing in the sprint-run daemon + implement on Opus (BOO-170)](wave-bq-daemon-model-routing.en.md) · [DE](wave-bq-daemon-model-routing.md)
- **BP** — [Wave BP — Claude Code mode recommendation across all skills + grafana/security-architect gaps (BOO-169)](wave-bp-claude-mode-all-skills.en.md) · [DE](wave-bp-claude-mode-all-skills.md)
- **BO** — [Wave BO — Runbooks & doc interlinking: audit runbook, linked evidence, INDEX + elevator pitch (BOO-167)](wave-bo-runbooks-vernetzung.en.md) · [DE](wave-bo-runbooks-vernetzung.md)
- **BN** — [Wave BN — Claude Code mode recommendation + /sprint-run "two modes" (BOO-168)](wave-bn-claude-mode-docs.en.md) · [DE](wave-bn-claude-mode-docs.md)
- **BM** — [Wave BM — /sprint-run README overhaul (BOO-166)](wave-bm-sprint-run-readme.en.md) · [DE](wave-bm-sprint-run-readme.md)
- **BL** — [Wave BL — Governance framing sharpened: INTENTRON ≠ autonomous agentic AI (BOO-164)](wave-bl-governance-framing.en.md) · [DE](wave-bl-governance-framing.md)
- **BK** — [Wave BK — /sprint-run: post-story gate assertion (BOO-165)](wave-bk-gate-assertion.en.md) · [DE](wave-bk-gate-assertion.md)
- **BJ** — [Wave BJ — Role-specific runbooks: CISO · DPO · CTO · managing director (BOO-158–163)](wave-bj-role-runbooks.en.md) · [DE](wave-bj-role-runbooks.md)
- **BI** — [Wave BI — /sprint-run: sprint orchestrator for fully automatic sprints (BOO-157)](wave-bi-sprint-run.en.md) · [DE](wave-bi-sprint-run.md)
- **BH** — [Wave BH — Knowledge-Onboarding: explainer sketches (v1.1.0)](wave-bh-knowledge-onboarding-sketches.en.md) · [DE](wave-bh-knowledge-onboarding-sketches.md)
- **BG** — [Wave BG — "Framework update" runbook for existing projects (BOO-156)](wave-bg-framework-update-runbook.en.md) · [DE](wave-bg-framework-update-runbook.md)
- **BF** — [Wave BF — Upgrade docs catch-up: misleading `/bootstrap --update` removed (BOO-155)](wave-bf-upgrade-doku-nachziehen.en.md) · [DE](wave-bf-upgrade-doku-nachziehen.md)
- **BE** — [Wave BE — Convention against cross-session drift in ideation/implement (BOO-154)](wave-be-cross-session-konvention.en.md) · [DE](wave-be-cross-session-konvention.md)
- **BD** — [Wave BD — Cross-session drift normalized + guard (BOO-153)](wave-bd-drift-normalisieren.en.md) · [DE](wave-bd-drift-normalisieren.md)
- **BC** — [Wave BC — Clone portability for multi-user (BOO-152)](wave-bc-klon-portabilitaet.en.md) · [DE](wave-bc-klon-portabilitaet.md)
- **BC** — [Wave BC — eslint.config.mjs DE/EN base block aligned (Linear BOO-146)](wave-bc-eslint-de-en-align.en.md) · [DE](wave-bc-eslint-de-en-align.md)
- **BB** — [Wave BB — CI Hardening Gaps (BOO-146–149)](wave-bb-ci-hardening-gaps.en.md) · [DE](wave-bb-ci-hardening-gaps.md)
- **BB** — [Wave BB — Multi-user VPS + three-level collision protection (BOO-151)](wave-bb-multi-user-vps.en.md) · [DE](wave-bb-multi-user-vps.md)
- **BA** — [Wave BA — Next.js First-CI-Run Hardening (BOO-140–143)](wave-ba-nextjs-ci-hardening.en.md) · [DE](wave-ba-nextjs-ci-hardening.md)
- **BA** — [Wave BA — Machine context at bootstrap (BOO-145)](wave-ba-maschinen-kontext.en.md) · [DE](wave-ba-maschinen-kontext.md)
- **AZ** — [Wave AZ — Runbook "Retrofit the SecondBrain" (BOO-144)](wave-az-secondbrain-nachziehen.en.md) · [DE](wave-az-secondbrain-nachziehen.md)
- **AY** — [Wave AY — VPS Standard Project Path & Daily-Note Loop (BOO-138/139)](wave-ay-vps-projektpfad.en.md) · [DE](wave-ay-vps-projektpfad.md)
- **AX** — [Wave AX — Knowledge-Onboarding: route existing docs into governance artefacts (BOO-137)](wave-ax-knowledge-onboarding.en.md) · [DE](wave-ax-knowledge-onboarding.md)
- **AW** — [Wave AW — Documentation hardening & onboarding clarity (BOO-130–136)](wave-aw-doku-haertung.en.md) · [DE](wave-aw-doku-haertung.md)
- **AV** — [Wave AV — Docs/runbooks, lightweight SecondBrain & design-story decision (BOO-118/119/126/128/129)](wave-av-docs-secondbrain.en.md) · [DE](wave-av-docs-secondbrain.md)
- **AU** — [Wave AU — Stack polish, MCP, Sonar warning & branching standard (BOO-116/121/122/124/125)](wave-au-stack-mcp-branching.en.md) · [DE](wave-au-stack-mcp-branching.md)
- **AT** — [Wave AT — Bootstrap UX hardening (BOO-114/115/117/120/123/127)](wave-at-bootstrap-ux-haertung.en.md) · [DE](wave-at-bootstrap-ux-haertung.md)
- **AS** — [Wave AS — Complementary tooling: setup-checklist (BOO-113)](wave-as-complementary-tooling.en.md) · [DE](wave-as-complementary-tooling.md)
- **AR** — [Wave AR — README refresh + onboarding journey (BOO-112)](wave-ar-readme-refresh.en.md) · [DE](wave-ar-readme-refresh.md)
- **AQ** — [Wave AQ — 10 legacy sketches to EN (BOO-111)](wave-aq-sketch-en-parity.en.md) · [DE](wave-aq-sketch-en-parity.md)
- **AP** — [Wave AP — dpo overview sketch (BOO-110)](wave-ap-dpo-overview-sketch.en.md) · [DE](wave-ap-dpo-overview-sketch.md)
- **AO** — [Wave AO — README parity security-architect (BOO-109)](wave-ao-security-readme-split.en.md) · [DE](wave-ao-security-readme-split.md)
- **AN** — [Wave AN — Artifact & sign-off map (BOO-108)](wave-an-artefakt-landkarte.en.md) · [DE](wave-an-artefakt-landkarte.md)
- **AM** — [Wave AM — Compliance mechanics sketch (BOO-107)](wave-am-compliance-sketch.en.md) · [DE](wave-am-compliance-sketch.md)
- **AL** — [Wave AL — EU AI Act lifecycle + compliance mechanics docs (BOO-106)](wave-al-compliance-mechanik.en.md) · [DE](wave-al-compliance-mechanik.md)
- **AK** — [Wave AK — EU AI Act real conditional opt-in (BOO-105)](wave-ak-eu-ai-act-optin.en.md) · [DE](wave-ak-eu-ai-act-optin.md)
- **AJ** — [Wave AJ — Bootstrap-Preparation-Checklist (BOO-104)](wave-aj-bootstrap-prep.en.md) · [DE](wave-aj-bootstrap-prep.md)
- **AI** — [Wave AI — Enterprise-Readiness (BOO-100…103)](wave-ai-enterprise-readiness.en.md) · [DE](wave-ai-enterprise-readiness.md)
- **AG** — [Wave AG — Docs-Sync-Sweep (BOO-97)](wave-ag-docs-sync-sweep.en.md) · [DE](wave-ag-docs-sync-sweep.md)
- **AF** — [Wave AF — Onboarding-Fix: Install + Quickstart + Self-Install/Self-Update (BOO-96)](wave-af-onboarding-fix.en.md) · [DE](wave-af-onboarding-fix.md)
- **AE** — [Wave AE — raw-pii-guard ruff-clean + Hook-Lint-Gate (BOO-95)](wave-ae-raw-pii-guard-ruff-clean.en.md) · [DE](wave-ae-raw-pii-guard-ruff-clean.md)
- **AD** — [Wave AD — HANDBUCH Anhang Y: VPS/Cloud team runbook (BOO-94)](wave-ad-handbuch-appendix-y-vps-runbook.en.md) · [DE](wave-ad-handbuch-appendix-y-vps-runbook.md)
- **AC** — [Wave AC — Raw-PII-in-Logs-Guard (BOO-93)](wave-ac-raw-pii-guard.en.md) · [DE](wave-ac-raw-pii-guard.md)
- **AB** — [Wave AB — orphan-check work-item exception (BOO-92)](wave-ab-orphan-check-exception.en.md) · [DE](wave-ab-orphan-check-exception.md)
- **AA** — [Wave AA — CONTEXT.md ubiquitous language: canonical + forbidden vocabulary (BOO-91)](wave-aa-context-ubiquitous-language.en.md) · [DE](wave-aa-context-ubiquitous-language.md)
- **Z** — [Wave Z — Contribute-Back Loop: contribute-fix.sh (BOO-90)](wave-z-contribute-back.en.md) · [DE](wave-z-contribute-back.md)
- **Y** — [Wave Y — coverage-check.sh Single-Source + Drift Guard (BOO-89)](wave-y-hook-single-source.en.md) · [DE](wave-y-hook-single-source.md)
- **X** — [Release Notes - Wave X Deterministic dpo Control Catalog](wave-x-dpo-control-catalog.en.md) · [DE](wave-x-dpo-control-catalog.md)
- **W** — [Release Notes - Wave W Coverage Hook Denominator Fix](wave-w-coverage-denominator-fix.en.md) · [DE](wave-w-coverage-denominator-fix.md)
- **V** — [Release Notes - Wave V Layer-0 Edit Bodyguard](wave-v-layer0-bodyguard.en.md) · [DE](wave-v-layer0-bodyguard.md)
- **U** — [Release Notes - Wave U Vault Harvest Activation Guide](wave-u-vault-harvest-activation-guide.en.md) · [DE](wave-u-vault-harvest-activation-guide.md)
- **T** — [Release Notes - Wave T Vault Sync Improvements](wave-t-vault-sync-improvements.en.md) · [DE](wave-t-vault-sync-improvements.md)
- **S** — [Release Notes - Wave S Optional Container Profile](wave-s-container-profile.en.md) · [DE](wave-s-container-profile.md)
- **R** — [Release Notes - Wave R Multi-Project Operation](wave-r-multi-project-operation.en.md) · [DE](wave-r-multi-project-operation.md)
- **Q** — [Release Notes - Wave Q Post-Install Verification](wave-q-verification.en.md) · [DE](wave-q-verification.md)
- **P** — [Release Notes - Wave P README Update + Toolchain Doc](wave-p-readme-and-toolchain-doc.en.md) · [DE](wave-p-readme-and-toolchain-doc.md)
- **O** — [Release Notes - Wave O Framework-native Vault-Sync Engine](wave-o-vault-sync-engine.en.md) · [DE](wave-o-vault-sync-engine.md)
- **N** — [Release Notes - Wave N Vault Harvest + Skill Installation Strategy](wave-n-vault-harvest-and-skill-location.en.md) · [DE](wave-n-vault-harvest-and-skill-location.md)
- **M** — [Release Notes - Wave M Bundle Adoption DPO + security-architect](wave-m-bundle-adoption-dpo-security.en.md) · [DE](wave-m-bundle-adoption-dpo-security.md)
- **L** — [Release Notes - Wave L Multi-Operator Coordination](wave-l-multi-operator-coordination.en.md) · [DE](wave-l-multi-operator-coordination.md)
- **K** — [Release Notes - Wave K Deployment Scenarios + Sovereignty Stack](wave-k-deployment-and-sovereignty.en.md) · [DE](wave-k-deployment-and-sovereignty.md)
- **J** — [Release Notes - Wave J Privacy-by-Design](wave-j-privacy-by-design.en.md) · [DE](wave-j-privacy-by-design.md)
- **I** — [Release Notes - Wave I Token Efficiency Policy](wave-i-token-efficiency.en.md) · [DE](wave-i-token-efficiency.md)
- **H** — [Release Notes - Wave H Documentation SSoT & Onboarding](wave-h-documentation-ssot-onboarding.en.md) · [DE](wave-h-documentation-ssot-onboarding.md)
- **G** — [Release Notes — Wave G Security Workflow Sketch](wave-g-security-workflow-sketch.en.md) · [DE](wave-g-security-workflow-sketch.md)
- **F** — [Release Notes — Wave F Security Documentation Model](wave-f-security-doc-model.en.md) · [DE](wave-f-security-doc-model.md)
- **E** — [Release Notes — Wave E Provider and Upgrade](wave-e-provider-upgrade.en.md) · [DE](wave-e-provider-upgrade.md)
- **D** — [Release Notes — Wave D Sketches](wave-d-sketches.en.md) · [DE](wave-d-sketches.md)
- **C** — [Release Notes — Wave C](wave-c.en.md) · [DE](wave-c.md)
- **B** — [Release Notes — Wave B](wave-b.en.md) · [DE](wave-b.md)
- **A** — [Release Notes — Wave A](wave-a.en.md) · [DE](wave-a.md)
