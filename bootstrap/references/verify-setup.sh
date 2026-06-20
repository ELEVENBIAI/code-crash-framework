#!/usr/bin/env bash
# verify-setup.sh — Post-Install-Verifikation fuer ein INTENTRON-Projekt (BOO-79).
#
# Beantwortet die Frage "Framework installiert — funktioniert auch alles?".
# Prueft Governance-Geruest + Toolchain + Hooks + Artefakte und gibt pro Check
# PASS / WARN / FAIL aus. Read-only — aendert nichts.
#
# Nutzung (im Projekt-Root):
#   bash scripts/verify-setup.sh           # Report, Exit 1 bei FAIL
#   bash scripts/verify-setup.sh --strict  # WARN zaehlt auch als FAIL
#   bash scripts/verify-setup.sh --quiet    # nur Summary + Exit-Code
#
# BSD- und Linux-kompatibel, keine Abhaengigkeiten ausser bash/grep/sed/command.
set -uo pipefail

STRICT=0
QUIET=0
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    --quiet) QUIET=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  esac
done

PASS=0; WARN=0; FAIL=0
ENV_FILE=".claude/environment.json"

c_pass() { PASS=$((PASS+1)); [[ $QUIET -eq 1 ]] || printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
c_warn() { WARN=$((WARN+1)); [[ $QUIET -eq 1 ]] || printf '  \033[33mWARN\033[0m  %s\n' "$1"; }
c_fail() { FAIL=$((FAIL+1)); [[ $QUIET -eq 1 ]] || printf '  \033[31mFAIL\033[0m  %s\n' "$1"; }
section() { [[ $QUIET -eq 1 ]] || printf '\n\033[1m%s\033[0m\n' "$1"; }

# Liest einen flachen Wert aus environment.json ohne jq (grep/sed).
env_val() { grep -o "\"$1\"[[:space:]]*:[[:space:]]*[^,}]*" "$ENV_FILE" 2>/dev/null | head -1 | sed -E 's/.*:[[:space:]]*//; s/[[:space:]]*$//; s/^"//; s/"$//'; }
env_tool_true() { grep -o "\"$1\"[[:space:]]*:[[:space:]]*true" "$ENV_FILE" >/dev/null 2>&1; }

[[ $QUIET -eq 1 ]] || printf '\033[1mINTENTRON Post-Install-Verifikation\033[0m (BOO-79)\n'

# --- 1. environment.json ---------------------------------------------------
section "1. Environment-Manifest"
if [[ -f "$ENV_FILE" ]]; then
  if grep -q '"environment"' "$ENV_FILE"; then
    c_pass "$ENV_FILE vorhanden + lesbar (environment=$(env_val environment))"
  else
    c_fail "$ENV_FILE existiert, aber Feld 'environment' fehlt — generate-environment-json.sh neu laufen lassen"
  fi
else
  c_fail "$ENV_FILE fehlt — 'bash .claude/generate-environment-json.sh' ausfuehren"
fi

# --- 2. Toolchain erreichbar ----------------------------------------------
section "2. Toolchain (Tools, die environment.json als verfuegbar fuehrt)"
if [[ -f "$ENV_FILE" ]]; then
  for tool in eslint semgrep; do
    if env_tool_true "$tool"; then
      if command -v "$tool" >/dev/null 2>&1; then
        c_pass "$tool als verfuegbar gefuehrt UND im PATH erreichbar"
      elif [[ "$tool" == "eslint" && -f "package.json" ]] && command -v npx >/dev/null 2>&1 && npx --no-install eslint --version >/dev/null 2>&1; then
        c_pass "eslint lokal in node_modules erreichbar (npx)"
      else
        c_warn "$tool ist in environment.json als true gefuehrt, aber NICHT im PATH — installieren oder Manifest korrigieren"
      fi
    fi
  done
  tests=$(env_val tests)
  if [[ -n "$tests" && "$tests" != "null" ]]; then
    c_pass "Test-Framework konfiguriert: $tests"
  else
    c_warn "Kein Test-Framework in environment.json — Coverage-Gate inaktiv"
  fi
else
  c_warn "Toolchain-Check uebersprungen (kein environment.json)"
fi

# --- 3. Git-Hooks ----------------------------------------------------------
section "3. Git-Hooks (pro Repo — .git/hooks/ wird nicht geklont!)"
HOOKS_PATH="$(git config --get core.hooksPath 2>/dev/null || echo ".git/hooks")"
if [[ -f "$HOOKS_PATH/pre-commit" ]]; then
  c_pass "pre-commit-Hook installiert ($HOOKS_PATH/pre-commit)"
  if grep -q "spec-gate" "$HOOKS_PATH/pre-commit" 2>/dev/null || [[ -f ".claude/hooks/spec-gate.sh" ]]; then
    c_pass "spec-gate verdrahtet (kein Commit ohne Spec)"
  else
    c_warn "spec-gate im pre-commit nicht gefunden"
  fi
else
  c_fail "pre-commit-Hook fehlt unter $HOOKS_PATH — Hooks sind PRO REPO; nach 'git clone' neu installieren (Bootstrap/Setup-Skript)"
fi
if [[ -f ".claude/hooks/doc-version-sync.sh" ]]; then
  c_pass "doc-version-sync.sh vorhanden"
else
  c_warn "doc-version-sync.sh nicht gefunden (Doc-Sync-Gate inaktiv)"
fi

# --- 4. Kern-Artefakte -----------------------------------------------------
section "4. Kern-Artefakte (Governance-Geruest)"
for f in CONVENTIONS.md ARCHITECTURE_DESIGN.md; do
  if [[ -f "$f" ]]; then c_pass "$f vorhanden"; else c_fail "$f fehlt — Bootstrap unvollstaendig"; fi
done
for d in specs journal; do
  if [[ -d "$d" ]]; then c_pass "$d/ vorhanden"; else c_warn "$d/ fehlt (wird beim ersten /ideation bzw. /implement angelegt)"; fi
done
if [[ -f "DEVELOPER_ONBOARDING.md" ]]; then c_pass "DEVELOPER_ONBOARDING.md vorhanden"; else c_warn "DEVELOPER_ONBOARDING.md fehlt im Repo-Root (kanonischer Name, BOO-134) — bei Obsidian-SSoT liegt das Onboarding im Vault (dann ok); bei repo-docs hier anlegen"; fi
if [[ -f "scripts/doc-drift-check.sh" ]]; then
  if [[ -x "scripts/doc-drift-check.sh" ]]; then c_pass "scripts/doc-drift-check.sh vorhanden + ausfuehrbar (Doku-Drift-Check, BOO-229)"; else c_warn "scripts/doc-drift-check.sh vorhanden, aber nicht ausfuehrbar — 'chmod +x scripts/doc-drift-check.sh'"; fi
else
  c_warn "scripts/doc-drift-check.sh fehlt — 'intentron migrate' (migrate_boo_229) nachziehen (Doku-Drift-Check, BOO-229)"
fi
# BOO-229 B2: Compliance-Doku-Gate — wenn aktiv, ist der Checker Pflicht (sonst kann der Hard-Gate nicht greifen)
if [[ "$(env_val compliance_doc_gate)" == "true" ]]; then
  if [[ -f "scripts/doc-drift-check.sh" ]]; then
    c_pass "compliance_doc_gate=true + scripts/doc-drift-check.sh vorhanden — Compliance-Hard-Gate kann greifen (BOO-229)"
  else
    c_fail "compliance_doc_gate=true, aber scripts/doc-drift-check.sh fehlt — Compliance-Gate kann NICHT greifen ('intentron migrate --issue BOO-229')"
  fi
fi

# --- 4b. Claude-Code-first: runtime_target + Native-Pfade (ADR-2 / BOO-199) -
section "4b. Claude-Code-first (runtime_target + Native-Pfade, ADR-2)"
if [[ -f "CONVENTIONS.md" ]]; then
  if grep -qE '^runtime_target:[[:space:]]*(claude-code|codex|cross-tool|unknown)' CONVENTIONS.md; then
    rt=$(grep -E '^runtime_target:' CONVENTIONS.md | head -1 | sed 's/runtime_target:[[:space:]]*//')
    c_pass "runtime_target gesetzt: $rt"
    if [[ "$rt" == "claude-code" ]]; then
      if [[ -f "CLAUDE.md" ]] && grep -q '^native_paths:' CLAUDE.md; then
        c_pass "Native-Pfade-Block (native_paths:) in CLAUDE.md vorhanden"
      else
        c_warn "runtime_target=claude-code, aber Native-Pfade-Block fehlt in CLAUDE.md — 'intentron migrate' (migrate_boo_199) nachziehen"
      fi
    fi
  else
    c_warn "runtime_target fehlt/ungueltig in CONVENTIONS.md — erwartet: claude-code|codex|cross-tool|unknown (Default neu: claude-code, ADR-2)"
  fi
else
  c_warn "CONVENTIONS.md fehlt — runtime_target nicht pruefbar"
fi

# --- 4c. Automemory-Abgrenzungs-Header (ADR-3 / BOO-200) --------------------
section "4c. Automemory-Header (Abgrenzung zum Learning-Loop, ADR-3)"
mem_dir="$HOME/.claude/projects/$(pwd | sed 's#/#-#g')/memory"
if [[ -d "$mem_dir" ]]; then
  if [[ -f "$mem_dir/MEMORY.md" ]] && grep -q 'automemory-vs-learning-loop:' "$mem_dir/MEMORY.md"; then
    c_pass "MEMORY.md-Abgrenzungs-Header vorhanden"
  else
    c_warn "Automemory aktiv, aber MEMORY.md-Abgrenzungs-Header fehlt — 'intentron migrate' (migrate_boo_200) nachziehen"
  fi
else
  c_pass "Kein lokales Automemory fuer dieses Projekt — Abgrenzungs-Header nicht noetig"
fi

# --- 5. Privacy-Add-on (nur falls aktiv) -----------------------------------
section "5. Privacy-Add-on (nur falls aktiviert)"
if [[ -f "PRIVACY.md" || -f ".claude/personal-data-paths.json" || -f ".codex/personal-data-paths.json" ]]; then
  if [[ -f "PRIVACY.md" ]]; then c_pass "PRIVACY.md vorhanden"; else c_fail "personal-data-paths.json da, aber PRIVACY.md fehlt"; fi
  if [[ -f ".claude/personal-data-paths.json" || -f ".codex/personal-data-paths.json" ]]; then
    c_pass "personal-data-paths.json vorhanden"
  else
    c_warn "PRIVACY.md da, aber personal-data-paths.json fehlt — Gate inaktiv"
  fi
else
  [[ $QUIET -eq 1 ]] || printf '  ----  Privacy-Add-on nicht aktiv — uebersprungen\n'
fi

# --- 5b. Financials-Add-on (nur falls aktiv, BOO-190) ----------------------
section "5b. Financials-Add-on (nur falls aktiviert)"
if [[ -d "docs/financials" || -f "docs/financials/worker-equivalent-baseline.md" || -f "docs/financials/sprint-costs.md" ]]; then
  if [[ -f "docs/financials/budget.md" ]]; then
    c_pass "docs/financials/budget.md vorhanden (Projekt-Budget-Template, BOO-190)"
  else
    c_warn "docs/financials/ aktiv, aber budget.md fehlt — 'migrate-to-v2.sh --issue BOO-190' nachziehen"
  fi
  if [[ -f "docs/financials/worker-equivalent-baseline.md" ]]; then
    c_pass "docs/financials/worker-equivalent-baseline.md vorhanden (aktiver Verrechnungssatz)"
  else
    c_warn "worker-equivalent-baseline.md fehlt — aktiver Satz nicht gesetzt (Skill financials / BOO-190)"
  fi
else
  [[ $QUIET -eq 1 ]] || printf '  ----  Financials-Add-on nicht aktiv — uebersprungen\n'
fi

# --- 5c. Status-Line (BOO-205, nur bei runtime_target: claude-code) ---------
section "5c. Status-Line (Worker-Equivalent live, BOO-205)"
rt_sl=""
[[ -f "CONVENTIONS.md" ]] && rt_sl=$(grep -E '^runtime_target:' CONVENTIONS.md | head -1 | sed 's/runtime_target:[[:space:]]*//')
if [[ "$rt_sl" == "claude-code" ]]; then
  if [[ -f ".claude/statusline.sh" ]]; then
    if [[ -x ".claude/statusline.sh" ]]; then
      c_pass ".claude/statusline.sh vorhanden + ausfuehrbar"
    else
      c_warn ".claude/statusline.sh vorhanden, aber nicht ausfuehrbar — 'chmod +x .claude/statusline.sh'"
    fi
    if [[ -f ".claude/settings.json" ]] && grep -q '"statusLine"' ".claude/settings.json"; then
      c_pass "statusLine in .claude/settings.json verdrahtet"
    else
      c_warn "statusLine-Block fehlt in .claude/settings.json — 'intentron migrate' (migrate_boo_205) nachziehen"
    fi
  else
    c_warn "runtime_target=claude-code, aber .claude/statusline.sh fehlt — 'intentron migrate' (migrate_boo_205) nachziehen"
  fi
else
  [[ $QUIET -eq 1 ]] || printf '  ----  Status-Line nur bei runtime_target=claude-code — uebersprungen (aktuell: %s)\n' "${rt_sl:-fehlend}"
fi

# --- 6. Backlog-Adapter ----------------------------------------------------
section "6. Backlog-Adapter"
if [[ -f ".claude/ISSUE_WRITING_GUIDELINES.md" ]] || grep -q "backlog" "$ENV_FILE" 2>/dev/null; then
  c_pass "Backlog-Konvention konfiguriert"
else
  c_warn "Keine Backlog-Adapter-Konfig gefunden (Markdown-only-Backlog?)"
fi

# --- 7. CI-Workflow-Sanity (Next.js-Erstlauf-Haertung, BOO-140/142/143) ----
section "7. CI-Workflow-Sanity (Next.js-Erstlauf-Haertung)"
WF=".github/workflows"
# BOO-140: package.json lint-Script darf nicht 'next lint' sein (flat-config-inkompatibel)
if [[ -f "package.json" ]]; then
  if grep -Eq '"lint"[[:space:]]*:[[:space:]]*"next lint"' package.json; then
    c_fail "package.json: \"lint\": \"next lint\" — auf \"eslint .\" umbiegen (BOO-140; next lint versteht ESLint-v9-Flat-Config nicht)"
  else
    c_pass "package.json lint-Script ist nicht 'next lint' (BOO-140)"
  fi
fi
# BOO-140: eslint.yml ruft eslint direkt, nicht next lint / npm run lint
if [[ -f "$WF/eslint.yml" ]]; then
  if grep -Eq 'next lint|npm run lint' "$WF/eslint.yml"; then
    c_fail "$WF/eslint.yml nutzt 'next lint'/'npm run lint' — auf 'npx eslint .' umstellen (BOO-140)"
  else
    c_pass "eslint.yml nutzt direkten eslint-Aufruf (BOO-140)"
  fi
fi
# BOO-142: semgrep.yml ohne Container; alle SARIF-Uploads auf v4
if [[ -f "$WF/semgrep.yml" ]]; then
  if grep -Eq '^[[:space:]]*container:' "$WF/semgrep.yml"; then
    c_fail "$WF/semgrep.yml laeuft in einem Container — entfernen, Semgrep via 'pip install semgrep' (BOO-142; checkout schlaegt im Container bei PRs fehl)"
  else
    c_pass "semgrep.yml ohne Container (BOO-142)"
  fi
fi
if ls "$WF"/*.yml >/dev/null 2>&1; then
  if grep -Rql 'upload-sarif@v3' "$WF" 2>/dev/null; then
    c_warn "upload-sarif@v3 in $WF gefunden — auf @v4 anheben (v3 deprecated Dez 2026, BOO-142)"
  else
    c_pass "kein upload-sarif@v3 in Workflows (BOO-142)"
  fi
fi
# BOO-143: perf.yml skippt bei leerer Baseline (Prerequisite-Check)
if [[ -f "$WF/perf.yml" ]]; then
  if grep -q 'Check prerequisites' "$WF/perf.yml"; then
    c_pass "perf.yml hat Baseline-Prerequisite-Skip (BOO-143)"
  else
    c_warn "$WF/perf.yml ohne Prerequisite-Skip — frischer Repo failt am Perf-Gate (BOO-143)"
  fi
fi

# --- Summary ---------------------------------------------------------------
printf '\n\033[1mErgebnis:\033[0m %d PASS, %d WARN, %d FAIL\n' "$PASS" "$WARN" "$FAIL"
if [[ $FAIL -gt 0 ]]; then
  printf '\033[31m=> Setup unvollstaendig. FAIL-Punkte oben beheben.\033[0m\n'
  exit 1
fi
if [[ $WARN -gt 0 && $STRICT -eq 1 ]]; then
  printf '\033[33m=> --strict: WARN als FAIL gewertet.\033[0m\n'
  exit 1
fi
if [[ $WARN -gt 0 ]]; then
  printf '\033[33m=> Setup funktionsfaehig, WARN-Punkte pruefen.\033[0m\n'
else
  printf '\033[32m=> Setup vollstaendig verifiziert.\033[0m\n'
fi
exit 0
