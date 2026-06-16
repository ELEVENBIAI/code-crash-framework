# Release Notes — Konvention

> 🌐 **Sprache:** Deutsch (diese Datei) · [🇬🇧 English](README.en.md)

Dieser Ordner ist die **Quelle der Release Notes**. Sie werden zusaetzlich als **GitHub Releases** veroeffentlicht:
<https://github.com/vibercoder79/intentron/releases>

## Zwei Ebenen

| Ebene | Datei | Zweck |
|-------|-------|-------|
| **Granular (pro Welle)** | `wave-<x>-<thema>.md` | Eine Datei pro Wave/Update — der einzelne Change mit Stories, Aenderungen, Migration, Smoke-Test. Im Repo, dauerhaft. |
| **Sammel (pro Version)** | `v<MAJOR.MINOR.PATCH>-overview.md` | Fasst alle Wellen einer Version zusammen (Big-Picture-Tabelle + Detail-Sektionen + Anhang-/Versions-Tabellen). Wird der **Body des GitHub Release**. |

## Konvention: GitHub Release pro Version

**Bei jedem Version-Tag** wird ein GitHub Release angelegt — Granularitaet ist **pro Version** (nicht pro Wave). Die einzelnen `wave-*.md` bleiben die granulare Quelle im Repo und sind im Release-Body verlinkt/zusammengefasst.

So wird ein Release angelegt (Beispiel v0.2.0):

```bash
# 1. Tag auf dem fertigen Stand (alle Wellen der Version done, Doku DE/EN paritaetisch)
git tag -a v0.2.0 -m "v0.2.0 — <Kurzbeschreibung>"
git push origin v0.2.0

# 2. GitHub Release mit dem Overview als Body
gh release create v0.2.0 \
  --title "v0.2.0 — <Titel>" \
  --notes-file docs/releases/v0.2.0-overview.md
```

Ein bestehendes Release nachtraeglich aktualisieren: `gh release edit v0.2.0 --notes-file docs/releases/v0.2.0-overview.md`.

## Regeln

1. **Jede Wave bekommt eine `wave-*.md`** im selben Stil (Zweck, Stories, Aenderungen, Migration, Verweise) — das ist Teil des Doku-Touchpoint-Quartetts (HANDBUCH, Release Notes, Spec, Linear).
2. **Die `v<version>-overview.md` wird pro Wave mitgepflegt** (Tabellenzeile + ggf. Detail-Sektion), damit sie beim Version-Release komplett ist.
3. **Vor dem Tag**: Doku DE/EN paritaetisch, alle Linear-Issues der Version Done, `verify-setup.sh` gruen.
4. **Tag = Stand**: erst taggen, wenn der Release-Stand wirklich fertig ist (kein Tag auf halbem EN-Stand).
5. **Release-Body = overview**: kein separates Copy-Paste pflegen — `--notes-file` zeigt direkt auf die `v<version>-overview.md`.
6. **Zweisprachig (DE + EN) Pflicht**: Jede `v<version>-overview.md` enthaelt den deutschen Teil oben, gefolgt von `---` + `# 🇬🇧 English Version` mit einem originalgetreuen englischen Spiegel (gleiche Struktur/Tabellen; Code-Identifier, BOO-Nummern, Pfade, Links wortgleich). Der GitHub-Release-Body ist damit selbst zweisprachig. Vor dem Tag pruefen, dass beide Teile gleichstand sind.

## Vorgaenger

- `v0.1.0` — GAP-Hardening (Wellen A–I), getaggt 2026-05-22.
- `v0.2.0` — Governance-OS (Wellen J–T): Privacy, Deployment, Souveraenitaet, Multi-Operator, Verifikation, Multi-Projekt, Vault-Harvest, Codex-Onboarding.

---

## Alle Releases — Index (85 Waves, neueste zuerst)

- **CE** — [Wave CE — Worker-Equivalent: zweite Steuerungs-Dimension neben Token-Verbrauch (BOO-190/191/192/193)](wave-ce-worker-equivalent.md) · [EN](wave-ce-worker-equivalent.en.md)
- **CD** — [Wave CD — Semgrep Custom-Rule-Wiring + Verifikations-Canary (BOO-185/188)](wave-cd-semgrep-custom-rule-wiring.md) · [EN](wave-cd-semgrep-custom-rule-wiring.en.md)
- **CC** — [Wave CC — Linter-Verdrahtung end-to-end: zentrales Bild + Sketch (BOO-182)](wave-cc-linter-verdrahtung-e2e.md) · [EN](wave-cc-linter-verdrahtung-e2e.en.md)
- **CB** — [Wave CB — EN-Nachzug der 43 Alt-Wave-Release-Notes: DE+EN-Parität rückwirkend (BOO-174)](wave-cb-en-parity-altwaves.md) · [EN](wave-cb-en-parity-altwaves.en.md)
- **CA** — [Wave CA — Observability sichtbar machen: Doku + Logging/Monitoring-Runbook (BOO-179)](wave-ca-observability-sichtbar.md) · [EN](wave-ca-observability-sichtbar.en.md)
- **BZ** — [Wave BZ — Neuen Stack/Linter integrieren: Runbook + HANDBUCH-Kapitel (BOO-178)](wave-bz-stack-linter-runbook.md) · [EN](wave-bz-stack-linter-runbook.en.md)
- **BY** — [Wave BY — Doku-Index-Nachzug: fehlende Runbooks im zentralen Index (BOO-181)](wave-by-doku-index-nachzug.md) · [EN](wave-by-doku-index-nachzug.en.md)
- **BX** — [Wave BX — PR- & Merge-Hygiene: Guard gegen doppelte PRs (BOO-175)](wave-bx-pr-merge-hygiene.md) · [EN](wave-bx-pr-merge-hygiene.en.md)
- **BW** — [Wave BW — Doku-Definition-of-Done als Konvention (BOO-180)](wave-bw-doku-definition-of-done.md) · [EN](wave-bw-doku-definition-of-done.en.md)
- **BV** — [Wave BV — Unit-Test-Härtung: echte Tests statt nur Coverage (BOO-177)](wave-bv-unit-test-hardening.md) · [EN](wave-bv-unit-test-hardening.en.md)
- **BU** — [Wave BU — Quality-Gate-Integrität: der Agent senkt die Messlatte nicht selbst (BOO-176)](wave-bu-quality-gate-integrity.md) · [EN](wave-bu-quality-gate-integrity.en.md)
- **BT** — [Wave BT — Release-Notes vernetzt: zentraler Wave-Index + DE↔EN-Sprachschalter (BOO-173)](wave-bt-release-index.md) · [EN](wave-bt-release-index.en.md)
- **BS** — [Wave BS — Runbook: Sprint unbeaufsichtigt auf der VPS per tmux (BOO-172)](wave-bs-runbook-tmux-vps.md) · [EN](wave-bs-runbook-tmux-vps.en.md)
- **BR** — [Wave BR — implement: Lint-Loops auf Haiku-Subagent (BOO-171)](wave-br-implement-haiku-loops.md) · [EN](wave-br-implement-haiku-loops.en.md)
- **BQ** — [Wave BQ — Model-/Modus-Routing im sprint-run-Daemon + implement auf Opus (BOO-170)](wave-bq-daemon-model-routing.md) · [EN](wave-bq-daemon-model-routing.en.md)
- **BP** — [Wave BP — Claude-Code-Modus-Empfehlung auf alle Skills + grafana/security-architect-Lücken (BOO-169)](wave-bp-claude-mode-all-skills.md) · [EN](wave-bp-claude-mode-all-skills.en.md)
- **BO** — [Wave BO — Runbooks & Doku-Vernetzung: Auditor-Runbook, Belege verlinken, INDEX + Elevator-Pitch (BOO-167)](wave-bo-runbooks-vernetzung.md) · [EN](wave-bo-runbooks-vernetzung.en.md)
- **BN** — [Wave BN — Claude-Code-Modus-Empfehlung + /sprint-run „Zwei Modi" (BOO-168)](wave-bn-claude-mode-docs.md) · [EN](wave-bn-claude-mode-docs.en.md)
- **BM** — [Wave BM — /sprint-run README-Überarbeitung (BOO-166)](wave-bm-sprint-run-readme.md) · [EN](wave-bm-sprint-run-readme.en.md)
- **BL** — [Wave BL — Governance-Framing nachgeschärft: INTENTRON ≠ autonome agentische KI (BOO-164)](wave-bl-governance-framing.md) · [EN](wave-bl-governance-framing.en.md)
- **BK** — [Wave BK — /sprint-run: Post-Story-Gate-Assertion (BOO-165)](wave-bk-gate-assertion.md) · [EN](wave-bk-gate-assertion.en.md)
- **BJ** — [Wave BJ — Rollenspezifische Runbooks: CISO · DPO · CTO · Geschäftsführung (BOO-158–163)](wave-bj-role-runbooks.md) · [EN](wave-bj-role-runbooks.en.md)
- **BI** — [Wave BI — /sprint-run: Sprint-Orchestrator für vollautomatische Sprints (BOO-157)](wave-bi-sprint-run.md) · [EN](wave-bi-sprint-run.en.md)
- **BH** — [Wave BH — Knowledge-Onboarding: Erklär-Sketches (v1.1.0)](wave-bh-knowledge-onboarding-sketches.md) · [EN](wave-bh-knowledge-onboarding-sketches.en.md)
- **BG** — [Wave BG — Runbook „Framework-Update" für Bestandsprojekte (BOO-156)](wave-bg-framework-update-runbook.md) · [EN](wave-bg-framework-update-runbook.en.md)
- **BF** — [Wave BF — Upgrade-Doku nachziehen: irreführendes `/bootstrap --update` raus (BOO-155)](wave-bf-upgrade-doku-nachziehen.md) · [EN](wave-bf-upgrade-doku-nachziehen.en.md)
- **BE** — [Wave BE — Konvention gegen Cross-Session-Drift in ideation/implement (BOO-154)](wave-be-cross-session-konvention.md) · [EN](wave-be-cross-session-konvention.en.md)
- **BD** — [Wave BD — Cross-Session-Drift normalisiert + Guard (BOO-153)](wave-bd-drift-normalisieren.md) · [EN](wave-bd-drift-normalisieren.en.md)
- **BC** — [Wave BC — Klon-Portabilität für Multi-User (BOO-152)](wave-bc-klon-portabilitaet.md) · [EN](wave-bc-klon-portabilitaet.en.md)
- **BC** — [Wave BC — eslint.config.mjs DE/EN-Basis-Block angeglichen (Linear BOO-146)](wave-bc-eslint-de-en-align.md) · [EN](wave-bc-eslint-de-en-align.en.md)
- **BB** — [Wave BB — CI-Hardening-Gaps (BOO-146–149)](wave-bb-ci-hardening-gaps.md) · [EN](wave-bb-ci-hardening-gaps.en.md)
- **BB** — [Wave BB — Multi-User-VPS + Drei-Ebenen-Kollisionsschutz (BOO-151)](wave-bb-multi-user-vps.md) · [EN](wave-bb-multi-user-vps.en.md)
- **BA** — [Wave BA — Next.js-Erstlauf-Härtung (BOO-140–143)](wave-ba-nextjs-ci-hardening.md) · [EN](wave-ba-nextjs-ci-hardening.en.md)
- **BA** — [Wave BA — Maschinen-Kontext beim Bootstrap (BOO-145)](wave-ba-maschinen-kontext.md) · [EN](wave-ba-maschinen-kontext.en.md)
- **AZ** — [Wave AZ — Runbook „SecondBrain nachziehen" (BOO-144)](wave-az-secondbrain-nachziehen.md) · [EN](wave-az-secondbrain-nachziehen.en.md)
- **AY** — [Wave AY — VPS-Standard-Projektpfad & Daily-Note-Loop (BOO-138/139)](wave-ay-vps-projektpfad.md) · [EN](wave-ay-vps-projektpfad.en.md)
- **AX** — [Wave AX — Knowledge-Onboarding: Bestands-Doku in Governance-Artefakte routen (BOO-137)](wave-ax-knowledge-onboarding.md) · [EN](wave-ax-knowledge-onboarding.en.md)
- **AW** — [Wave AW — Doku-Härtung & Onboarding-Klarheit (BOO-130–136)](wave-aw-doku-haertung.md) · [EN](wave-aw-doku-haertung.en.md)
- **AV** — [Wave AV — Doku/Runbooks, Leichtgewicht-SecondBrain & Design-Story-Entscheidung (BOO-118/119/126/128/129)](wave-av-docs-secondbrain.md) · [EN](wave-av-docs-secondbrain.en.md)
- **AU** — [Wave AU — Stack-Feinschliff, MCP, Sonar-Warn & Branching-Standard (BOO-116/121/122/124/125)](wave-au-stack-mcp-branching.md) · [EN](wave-au-stack-mcp-branching.en.md)
- **AT** — [Wave AT — Bootstrap-UX-Härtung (BOO-114/115/117/120/123/127)](wave-at-bootstrap-ux-haertung.md) · [EN](wave-at-bootstrap-ux-haertung.en.md)
- **AS** — [Wave AS — Komplementäres Tooling: setup-checklist (BOO-113)](wave-as-complementary-tooling.md) · [EN](wave-as-complementary-tooling.en.md)
- **AR** — [Wave AR — README-Refresh + Onboarding-Journey (BOO-112)](wave-ar-readme-refresh.md) · [EN](wave-ar-readme-refresh.en.md)
- **AQ** — [Wave AQ — 10 Alt-Sketches auf EN (BOO-111)](wave-aq-sketch-en-parity.md) · [EN](wave-aq-sketch-en-parity.en.md)
- **AP** — [Wave AP — dpo-Overview-Sketch (BOO-110)](wave-ap-dpo-overview-sketch.md) · [EN](wave-ap-dpo-overview-sketch.en.md)
- **AO** — [Wave AO — README-Paritaet security-architect (BOO-109)](wave-ao-security-readme-split.md) · [EN](wave-ao-security-readme-split.en.md)
- **AN** — [Wave AN — Artefakt- & Freigabe-Landkarte (BOO-108)](wave-an-artefakt-landkarte.md) · [EN](wave-an-artefakt-landkarte.en.md)
- **AM** — [Wave AM — Compliance-Mechanik-Sketch (BOO-107)](wave-am-compliance-sketch.md) · [EN](wave-am-compliance-sketch.en.md)
- **AL** — [Wave AL — EU-AI-Act-Lebenszyklus + Compliance-Mechanik-Doku (BOO-106)](wave-al-compliance-mechanik.md) · [EN](wave-al-compliance-mechanik.en.md)
- **AK** — [Wave AK — EU AI Act echtes konditionales Opt-in (BOO-105)](wave-ak-eu-ai-act-optin.md) · [EN](wave-ak-eu-ai-act-optin.en.md)
- **AJ** — [Wave AJ — Bootstrap-Vorbereitungs-Checkliste (BOO-104)](wave-aj-bootstrap-prep.md) · [EN](wave-aj-bootstrap-prep.en.md)
- **AI** — [Wave AI — Enterprise-Readiness (BOO-100…103)](wave-ai-enterprise-readiness.md) · [EN](wave-ai-enterprise-readiness.en.md)
- **AG** — [Wave AG — Doku-Sync-Sweep (BOO-97)](wave-ag-docs-sync-sweep.md) · [EN](wave-ag-docs-sync-sweep.en.md)
- **AF** — [Wave AF — Onboarding-Fix: Install + Quickstart + Self-Install/Self-Update (BOO-96)](wave-af-onboarding-fix.md) · [EN](wave-af-onboarding-fix.en.md)
- **AE** — [Wave AE — raw-pii-guard ruff-clean + Hook-Lint-Gate (BOO-95)](wave-ae-raw-pii-guard-ruff-clean.md) · [EN](wave-ae-raw-pii-guard-ruff-clean.en.md)
- **AD** — [Wave AD — HANDBUCH-Anhang Y: VPS/Cloud-Team-Runbook (BOO-94)](wave-ad-handbuch-appendix-y-vps-runbook.md) · [EN](wave-ad-handbuch-appendix-y-vps-runbook.en.md)
- **AC** — [Wave AC — Raw-PII-in-Logs-Guard (BOO-93)](wave-ac-raw-pii-guard.md) · [EN](wave-ac-raw-pii-guard.en.md)
- **AB** — [Wave AB — orphan-check Work-Item-Ausnahme (BOO-92)](wave-ab-orphan-check-exception.md) · [EN](wave-ab-orphan-check-exception.en.md)
- **AA** — [Wave AA — CONTEXT.md Ubiquitous Language: kanonisches + verbotenes Vokabular (BOO-91)](wave-aa-context-ubiquitous-language.md) · [EN](wave-aa-context-ubiquitous-language.en.md)
- **Z** — [Wave Z — Contribute-Back-Schleife: contribute-fix.sh (BOO-90)](wave-z-contribute-back.md) · [EN](wave-z-contribute-back.en.md)
- **Y** — [Wave Y — coverage-check.sh Single-Source + Drift-Guard (BOO-89)](wave-y-hook-single-source.md) · [EN](wave-y-hook-single-source.en.md)
- **X** — [Release Notes - Wave X Deterministischer dpo-Kontrollkatalog](wave-x-dpo-control-catalog.md) · [EN](wave-x-dpo-control-catalog.en.md)
- **W** — [Release Notes - Wave W Coverage-Hook-Nenner-Fix](wave-w-coverage-denominator-fix.md) · [EN](wave-w-coverage-denominator-fix.en.md)
- **V** — [Release Notes - Wave V Layer-0 Edit-Bodyguard](wave-v-layer0-bodyguard.md) · [EN](wave-v-layer0-bodyguard.en.md)
- **U** — [Release Notes - Wave U Vault-Harvest-Aktivierungs-Anleitung](wave-u-vault-harvest-activation-guide.md) · [EN](wave-u-vault-harvest-activation-guide.en.md)
- **T** — [Release Notes - Wave T Vault-Sync-Verbesserungen](wave-t-vault-sync-improvements.md) · [EN](wave-t-vault-sync-improvements.en.md)
- **S** — [Release Notes - Wave S Optionales Container-Profil](wave-s-container-profile.md) · [EN](wave-s-container-profile.en.md)
- **R** — [Release Notes - Wave R Multi-Projekt-Betrieb](wave-r-multi-project-operation.md) · [EN](wave-r-multi-project-operation.en.md)
- **Q** — [Release Notes - Wave Q Post-Install-Verifikation](wave-q-verification.md) · [EN](wave-q-verification.en.md)
- **P** — [Release Notes - Wave P README-Aktualisierung + Toolchain-Doku](wave-p-readme-and-toolchain-doc.md) · [EN](wave-p-readme-and-toolchain-doc.en.md)
- **O** — [Release Notes - Wave O Framework-native Vault-Sync-Engine](wave-o-vault-sync-engine.md) · [EN](wave-o-vault-sync-engine.en.md)
- **N** — [Release Notes - Wave N Vault-Harvest + Skill-Installations-Strategie](wave-n-vault-harvest-and-skill-location.md) · [EN](wave-n-vault-harvest-and-skill-location.en.md)
- **M** — [Release Notes - Wave M Bundle-Adoption DPO + security-architect](wave-m-bundle-adoption-dpo-security.md) · [EN](wave-m-bundle-adoption-dpo-security.en.md)
- **L** — [Release Notes - Wave L Multi-Operator-Koordination](wave-l-multi-operator-coordination.md) · [EN](wave-l-multi-operator-coordination.en.md)
- **K** — [Release Notes - Wave K Deployment-Szenarien + Souveraenitaets-Stack](wave-k-deployment-and-sovereignty.md) · [EN](wave-k-deployment-and-sovereignty.en.md)
- **J** — [Release Notes - Wave J Privacy-by-Design](wave-j-privacy-by-design.md) · [EN](wave-j-privacy-by-design.en.md)
- **I** — [Release Notes - Wave I Token-Effizienz-Policy](wave-i-token-efficiency.md) · [EN](wave-i-token-efficiency.en.md)
- **H** — [Release Notes - Wave H Documentation-SSoT & Onboarding](wave-h-documentation-ssot-onboarding.md) · [EN](wave-h-documentation-ssot-onboarding.en.md)
- **G** — [Release Notes — Wave G Security-Workflow-Sketch](wave-g-security-workflow-sketch.md) · [EN](wave-g-security-workflow-sketch.en.md)
- **F** — [Release Notes — Wave F Security-Dokumentationsmodell](wave-f-security-doc-model.md) · [EN](wave-f-security-doc-model.en.md)
- **E** — [Release Notes — Wave E Provider und Upgrade](wave-e-provider-upgrade.md) · [EN](wave-e-provider-upgrade.en.md)
- **D** — [Release Notes — Wave D Sketches](wave-d-sketches.md) · [EN](wave-d-sketches.en.md)
- **C** — [Release Notes — Wave C](wave-c.md) · [EN](wave-c.en.md)
- **B** — [Release Notes — Wave B](wave-b.md) · [EN](wave-b.en.md)
- **A** — [Release Notes — Wave A](wave-a.md) · [EN](wave-a.en.md)
