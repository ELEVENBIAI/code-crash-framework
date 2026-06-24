#!/usr/bin/env bash
# migrate-to-v2.sh
#
# DE: Idempotentes Skelett-Skript fuer die Migration von Bestands-Projekten
#     auf INTENTRON-Governance v2. Fuehrt nur deterministische Auto-Schritte
#     aus. Manuelle Operator-Schritte werden mit `[MANUAL]` markiert und
#     loggen die noetige Aktion ohne sie auszufuehren. Mehrfaches Ausfuehren
#     ist sicher: bestehende Dateien werden nicht ueberschrieben, idempotente
#     Append-Operationen pruefen vor dem Schreiben.
#
# EN: Idempotent skeleton script for migrating existing projects to
#     INTENTRON governance v2. Runs deterministic auto steps only.
#     Manual operator steps are tagged `[MANUAL]` and logged without being
#     executed. Safe to run multiple times: existing files are kept,
#     idempotent appends check before writing.

set -euo pipefail

# -----------------------------------------------------------------------------
# Globale Variablen / Globals
# -----------------------------------------------------------------------------

DRY_RUN="${DRY_RUN:-false}"
FORCE="${FORCE:-false}"
SCRIPT_NAME="$(basename "$0")"

# -----------------------------------------------------------------------------
# Logging-Helfer / Logging Helpers
# -----------------------------------------------------------------------------

log_info()   { printf '[INFO]   %s\n' "$*"; }
log_warn()   { printf '[WARN]   %s\n' "$*" >&2; }
log_skip()   { printf '[SKIP]   %s\n' "$*"; }
log_manual() { printf '[MANUAL] %s\n' "$*"; }
log_dry()    { printf '[DRY]    %s\n' "$*"; }

# -----------------------------------------------------------------------------
# Datei-/Verzeichnis-Helfer / File and directory helpers (idempotent)
# -----------------------------------------------------------------------------

ensure_dir() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        log_skip "dir exists: $dir"
        return 0
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "mkdir -p $dir"
        return 0
    fi
    mkdir -p "$dir"
    log_info "created dir: $dir"
}

ensure_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        log_skip "file exists: $file"
        return 0
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "touch $file"
        return 0
    fi
    ensure_dir "$(dirname "$file")"
    : > "$file"
    log_info "created file: $file"
}

append_if_missing() {
    # append_if_missing <file> <line>
    local file="$1"
    local line="$2"
    ensure_file "$file"
    if grep -Fxq "$line" "$file" 2>/dev/null; then
        log_skip "line already in $file"
        return 0
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "append to $file: $line"
        return 0
    fi
    printf '%s\n' "$line" >> "$file"
    log_info "appended to $file: $line"
}

# -----------------------------------------------------------------------------
# Pro BOO-Issue eine Funktion / One function per BOO issue
# -----------------------------------------------------------------------------

# ---------------- Phase 1 — Fundament / Foundation ----------------

migrate_boo_1() {
    # BOO-1 — /intent-Skill bauen (Schrader Kap. 4) — Skill v1.0.0 seit 2026-05-01
    # https://linear.app/owlist/issue/BOO-1
    log_info "BOO-1: /intent-Skill — intents/-Verzeichnis im Bestands-Projekt anlegen"
    ensure_dir "intents"
    ensure_file "intents/.gitkeep"
    if [[ ! -f "intents/README.md" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write intents/README.md"
        else
            cat > "intents/README.md" <<'EOF'
# Intents

Pro Initiative eine Intent-Datei nach Schrader-Template (Code Crash Kap. 4):

- `intents/INTENT-XX.md` — Intent-Statement + 5-Schritte-Session-Output (XX = lfd. Nummer mit fuehrenden Nullen)
- `intents/INTENT-XX.validation.md` — Self-Check-Report mit Status gruen / gelb / rot

Workflow + Templates siehe Skill `/intent` (`intentron/intent/`).
Pipeline-Verortung: `/intent` -> `/ideation` -> `/backlog` -> `/implement`.
EOF
            log_info "created intents/README.md"
        fi
    else
        log_skip "intents/README.md exists"
    fi
    log_manual "Operator: pruefen ob bestehende docs/intent.md oder vergleichbare Notizen existieren — falls ja, in intents/legacy.md migrieren"
    log_manual "Operator: /intent-Skill verfuegbar machen (via /bootstrap-Update oder durch Kopieren von intentron/intent/ nach ~/.claude/skills/intent/)"
    return 0
}

migrate_boo_2() {
    # BOO-2 — ESLint-Regelsatz haerten (Airbnb + security + sonarjs) — v3.2.2 seit 2026-05-01
    # https://linear.app/owlist/issue/BOO-2
    log_info "BOO-2: ESLint-/Ruff-Regelsatz haerten"

    # --- Node.js: npm install nur wenn package.json vorhanden ---
    if [[ -f "package.json" ]]; then
        local pkgs="eslint @eslint/js eslint-config-airbnb-base eslint-plugin-security eslint-plugin-sonarjs @eslint/compat"
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "npm install --save-dev $pkgs"
        else
            log_info "Node-Projekt erkannt — npm install der ESLint-Layer"
            if command -v npm >/dev/null 2>&1; then
                # shellcheck disable=SC2086
                npm install --save-dev $pkgs && log_info "npm install erfolgreich" || log_warn "npm install fehlgeschlagen — Operator pruefen"
            else
                log_warn "npm nicht gefunden — Operator: '$pkgs' manuell installieren"
            fi
        fi
        log_manual "Operator (Node): eslint.config.mjs aus bootstrap/references/file-templates.md §eslint.config.mjs uebernehmen (4-Layer-Stack)"
        log_manual "Operator (Node, mit React): 'eslint-config-airbnb' statt '-base' nachinstallieren"
    else
        log_skip "kein package.json im aktuellen Verzeichnis — Node-Schritte uebersprungen"
    fi

    # --- Python: Hinweise fuer pyproject.toml ---
    if [[ -f "pyproject.toml" ]]; then
        log_info "Python-Projekt erkannt — Ruff-Konfiguration anpassen"
        log_manual "Operator (Python): [tool.ruff.lint]-Block aus bootstrap/references/file-templates.md §pyproject.toml uebernehmen"
        log_manual "Operator (Python): select sollte E, W, F, I, B, C4, S enthalten; per-file-ignores fuer tests/ und migrations/ pruefen"
    else
        log_skip "kein pyproject.toml im aktuellen Verzeichnis — Python-Schritte uebersprungen"
    fi

    log_manual "Operator: Erstlauf 'npx eslint . --max-warnings 0' bzw. 'ruff check .' — Findings erwartbar; via /implement deklarativ iterieren oder Lint-Cleanup-Story einplanen"
    return 0
}

# ---------------- Phase 2 — Production-Readiness ----------------

migrate_boo_3() {
    # BOO-3 — /bootstrap: .semgrep.yml Auto-Setup (sprach-aware) — v3.2.3 seit 2026-05-06
    # https://linear.app/owlist/issue/BOO-3
    log_info "BOO-3: .semgrep.yml + .semgrepignore anlegen (sprach-aware)"

    # Sprach-Erkennung — Layer 2 wird basierend auf vorhandenen Manifest-Dateien aktiviert
    local has_node="false"
    local has_python="false"
    [[ -f "package.json" ]] && has_node="true"
    [[ -f "pyproject.toml" ]] && has_python="true"

    if [[ ! -f ".semgrep.yml" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write .semgrep.yml (Node:$has_node Python:$has_python)"
        else
            {
                printf '%s\n' "# .semgrep.yml — SAST-Default fuer Governance v2 (BOO-3, v3.2.3)"
                printf '%s\n' "# DE: Konsumiert von Pre-Commit-Hook (BOO-4) und CI (geplant)."
                printf '%s\n' "# EN: Consumed by pre-commit hook (BOO-4) and CI (planned)."
                printf '%s\n' "rules: []"
                printf '%s\n' "include:"
                printf '%s\n' "  # Layer 1 — Pflicht (alle Stacks) / mandatory (all stacks)"
                printf '%s\n' "  - p/security-audit"
                printf '%s\n' "  - p/secrets"
                printf '\n'
                printf '%s\n' "  # Layer 2 — sprach-spezifisch (auto-erkannt) / language-specific (auto-detected)"
                if [[ "$has_node" == "true" ]]; then
                    printf '%s\n' "  - p/javascript"
                else
                    printf '%s\n' "  # - p/javascript        # bei package.json einkommentieren"
                fi
                if [[ "$has_python" == "true" ]]; then
                    printf '%s\n' "  - p/python"
                else
                    printf '%s\n' "  # - p/python            # bei pyproject.toml einkommentieren"
                fi
                printf '\n'
                printf '%s\n' "  # Layer 3 — Optional fuer Web-Projekte (manuell einkommentieren)"
                printf '%s\n' "  # - p/owasp-top-ten     # bei Web-Frontend, REST-APIs, GraphQL"
            } > ".semgrep.yml"
            log_info "created .semgrep.yml (Node:$has_node Python:$has_python)"
        fi
    else
        log_skip ".semgrep.yml exists"
    fi

    if [[ ! -f ".semgrepignore" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write .semgrepignore default excludes"
        else
            cat > ".semgrepignore" <<'EOF'
# .semgrepignore — Default-Excludes fuer Governance v2 (BOO-3)
node_modules/
dist/
build/
journal/reports/
.venv/
__pycache__/
EOF
            log_info "created .semgrepignore"
        fi
    else
        log_skip ".semgrepignore exists"
    fi

    log_manual "Operator: bei Web-Projekt 'p/owasp-top-ten' in .semgrep.yml einkommentieren (Layer 3)"
    log_manual "Operator: Semgrep CLI installieren falls nicht vorhanden ('brew install semgrep' oder 'pip install semgrep')"
    return 0
}

migrate_boo_4() {
    # BOO-4 — /implement Schritt 6a-bis: Semgrep als Pre-Commit + CI Gate — v3.2.4 seit 2026-05-06
    # https://linear.app/owlist/issue/BOO-4
    log_info "BOO-4: Pre-Commit-Hook + GitHub Action mit Manifest-Reader anlegen"

    # --- Pre-Commit-Hook ---
    local hook_path=".git/hooks/pre-commit"
    if [[ ! -d ".git" ]]; then
        log_skip "kein .git/-Verzeichnis — Pre-Commit-Hook uebersprungen (Operator: 'git init' zuerst)"
    elif [[ -f "$hook_path" ]]; then
        log_skip "$hook_path existiert — manuelle Inspektion noetig"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $hook_path (Manifest-Reader fuer ESLint + Semgrep)"
    else
        # Hook-Inhalt aus file-templates.md §.git/hooks/pre-commit
        cat > "$hook_path" <<'HOOK_EOF'
#!/usr/bin/env bash
# .git/hooks/pre-commit — Quality-Gate Layer 2 (lokal, blockierend)
# DE: Konsumiert eslint.config.mjs (BOO-2) und .semgrep.yml (BOO-3 Manifest).
set -euo pipefail
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"

# --- ESLint-Gate (BOO-2) ---
if [[ -f "eslint.config.mjs" ]]; then
    CHANGED_JS=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(js|mjs|jsx|ts|tsx)$' || true)
    if [[ -n "$CHANGED_JS" ]]; then
        echo "[PRE-COMMIT] ESLint auf $(echo "$CHANGED_JS" | wc -l | tr -d ' ') Datei(en)"
        echo "$CHANGED_JS" | xargs npx eslint --max-warnings=0 || {
            echo "[PRE-COMMIT] ESLint-Gate BLOCKIERT."
            exit 1
        }
    fi
fi

# --- Semgrep-Gate (BOO-4, Manifest-Reader) ---
if [[ -f ".semgrep.yml" ]]; then
    PACKS=$(grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml | sed -E 's/^[[:space:]]*-[[:space:]]+//' || true)
    if [[ -n "$PACKS" ]]; then
        ARGS=""
        for pack in $PACKS; do
            ARGS="$ARGS --config $pack"
        done
        echo "[PRE-COMMIT] Semgrep mit Packs: $(echo "$PACKS" | tr '\n' ' ')"
        if ! command -v semgrep >/dev/null 2>&1; then
            echo "[PRE-COMMIT] Semgrep CLI nicht installiert — 'brew install semgrep' oder 'pip install semgrep'"
            exit 1
        fi
        # shellcheck disable=SC2086
        if ! semgrep $ARGS --error --quiet 2>&1; then
            echo "[PRE-COMMIT] Semgrep-Gate BLOCKIERT."
            exit 1
        fi
    else
        echo "[PRE-COMMIT] .semgrep.yml hat keine aktiven Packs — Gate uebersprungen"
    fi
fi

exit 0
HOOK_EOF
        chmod +x "$hook_path"
        log_info "created $hook_path (executable)"
    fi

    # --- GitHub Action Workflow ---
    local workflow_dir=".github/workflows"
    local workflow_path="$workflow_dir/semgrep.yml"
    ensure_dir "$workflow_dir"
    if [[ -f "$workflow_path" ]]; then
        log_skip "$workflow_path existiert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $workflow_path (Manifest-Reader-CI)"
    else
        cat > "$workflow_path" <<'WORKFLOW_EOF'
# .github/workflows/semgrep.yml — Quality-Gate Layer 3 (CI, blockiert Merge)
name: Semgrep
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  security-events: write

jobs:
  semgrep:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Semgrep
        run: pip install semgrep

      - name: Read manifest and run Semgrep
        run: |
          mkdir -p .ci-reports
          ARGS=""
          while IFS= read -r line; do
              pack=$(echo "$line" | sed -E 's/^[[:space:]]*-[[:space:]]+//')
              ARGS="$ARGS --config $pack"
          done < <(grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml)
          if [[ -z "$ARGS" ]]; then
              echo "::error::No active packs in .semgrep.yml"
              exit 1
          fi
          semgrep $ARGS --error --sarif --output=.ci-reports/semgrep.sarif

      - uses: github/codeql-action/upload-sarif@v4
        with:
          sarif_file: .ci-reports/semgrep.sarif
        if: always() && hashFiles('.ci-reports/semgrep.sarif') != ''

      - uses: actions/upload-artifact@v4
        with:
          name: semgrep-report
          path: .ci-reports/semgrep.sarif
WORKFLOW_EOF
        log_info "created $workflow_path"
    fi

    log_manual "Operator: Branch-Protection in GitHub aktivieren — Required Status Check 'Semgrep' (siehe BOO-29)"
    log_manual "Operator: Bei Husky-Setup .husky/pre-commit anpassen statt .git/hooks/pre-commit"
    return 0
}

migrate_boo_5() {
    # BOO-5 — /bootstrap: SonarQube Cloud Auto-Setup
    # https://linear.app/owlist/issue/BOO-5
    log_info "BOO-5: SonarQube Cloud — Auto + Manual"
    log_manual "Operator: SonarCloud-Account verifizieren, Org 'owlist' bestaetigen"
    log_manual "Operator: Projekt in SonarCloud anlegen, SONAR_TOKEN in GitHub-Secrets eintragen"
    # TODO: implementiert beim Done von BOO-5 — sonar-project.properties + Workflow-File aus file-templates.md
    log_manual "Operator: sonar-project.properties + .github/workflows/sonarcloud.yml aus file-templates.md kopieren (Auto-Schritt folgt beim Done von BOO-5)"
    return 0
}

migrate_boo_12() {
    # BOO-12 — Dependency + Halluzinations-Check Pre-Commit (Slopsquatting-Schutz) — v3.2.5 seit 2026-05-06
    # https://linear.app/owlist/issue/BOO-12
    log_info "BOO-12: Slopsquatting-Schutz — dependency-check.sh anlegen + Pre-Commit-Hook erweitern"

    # --- Hook-Skript anlegen ---
    local hooks_dir=".claude/hooks"
    local hook_script="$hooks_dir/dependency-check.sh"
    ensure_dir "$hooks_dir"
    if [[ -f "$hook_script" ]]; then
        log_skip "$hook_script existiert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $hook_script (drei Checks: Existenz/Age/CVE)"
    else
        cat > "$hook_script" <<'DEPCHECK_EOF'
#!/usr/bin/env bash
# .claude/hooks/dependency-check.sh — Slopsquatting-Schutz (BOO-12)
# Inhalt aus bootstrap/references/file-templates.md §hooks/dependency-check.sh
# (komplettes Bash-Skript hier eingebettet)
set -euo pipefail

CHANGED=$(git diff --cached --name-only --diff-filter=ACMR)
TRIGGERS_NPM=$(echo "$CHANGED" | grep -E '^package\.json$' || true)
TRIGGERS_PIP=$(echo "$CHANGED" | grep -E '^(requirements\.txt|pyproject\.toml)$' || true)
TRIGGERS_CARGO=$(echo "$CHANGED" | grep -E '^Cargo\.toml$' || true)

if [[ -z "$TRIGGERS_NPM" && -z "$TRIGGERS_PIP" && -z "$TRIGGERS_CARGO" ]]; then
    exit 0
fi

AGE_THRESHOLD_DAYS=30
BLOCKED=0

extract_new_npm_deps() {
    # POSIX-konform (BSD-grep/sed-kompatibel): match nur "+"-Zeilen mit
    # "key": "version-wert" — Wert muss mit Versionsnummer beginnen
    # (optional ^, ~, >=, <= prefix). Filtert Top-Level-"version".
    git diff --cached package.json 2>/dev/null \
        | grep -E '^\+[[:space:]]+"[^"]+":[[:space:]]*"[~^>=<]?[0-9]' \
        | sed -E 's/^\+[[:space:]]+"([^"]+)":.*/\1/' \
        | grep -vE '^(version)$' \
        || true
}

extract_new_pypi_deps() {
    if [[ -n "$TRIGGERS_PIP" ]] && echo "$TRIGGERS_PIP" | grep -q "requirements.txt"; then
        git diff --cached requirements.txt 2>/dev/null \
            | grep -E '^\+[a-zA-Z]' \
            | sed -E 's/^\+([a-zA-Z0-9_-]+).*/\1/' \
            || true
    fi
    if [[ -n "$TRIGGERS_PIP" ]] && echo "$TRIGGERS_PIP" | grep -q "pyproject.toml"; then
        git diff --cached pyproject.toml 2>/dev/null \
            | grep -E '^\+[[:space:]]+"[a-zA-Z]' \
            | sed -E 's/^\+[[:space:]]+"([a-zA-Z0-9_-]+).*/\1/' \
            || true
    fi
}

check_npm_existence() {
    local pkg="$1"
    if command -v npm >/dev/null 2>&1; then
        npm view "$pkg" name >/dev/null 2>&1 && return 0 || return 1
    else
        curl -fsSL --max-time 5 "https://registry.npmjs.org/$pkg" >/dev/null 2>&1 && return 0 || return 1
    fi
}

check_pypi_existence() {
    local pkg="$1"
    curl -fsSL --max-time 5 "https://pypi.org/pypi/$pkg/json" >/dev/null 2>&1 && return 0 || return 1
}

check_npm_age() {
    local pkg="$1"
    local created
    if command -v npm >/dev/null 2>&1; then
        created=$(npm view "$pkg" time.created 2>/dev/null || echo "")
    else
        created=$(curl -fsSL --max-time 5 "https://registry.npmjs.org/$pkg" 2>/dev/null \
            | grep -oE '"created":"[^"]+"' | head -1 | sed -E 's/"created":"([^"]+)"/\1/' || echo "")
    fi
    [[ -z "$created" ]] && return 0
    local pkg_epoch
    pkg_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${created%.*}" +"%s" 2>/dev/null || \
                date -d "$created" +"%s" 2>/dev/null || echo "0")
    [[ "$pkg_epoch" == "0" ]] && return 0
    local now_epoch days
    now_epoch=$(date +"%s")
    days=$(( (now_epoch - pkg_epoch) / 86400 ))
    if (( days < AGE_THRESHOLD_DAYS )); then
        echo "[DEP-CHECK] WARNUNG: Paket '$pkg' ist nur $days Tage alt — Typosquatter-Risiko, manuell verifizieren"
    fi
    return 0
}

check_npm_cve() {
    if command -v npm >/dev/null 2>&1 && [[ -f "package-lock.json" ]]; then
        local audit_output
        audit_output=$(npm audit --audit-level=high 2>&1 || true)
        if echo "$audit_output" | grep -qE 'high|critical'; then
            echo "[DEP-CHECK] BLOCK: npm audit meldet High/Critical Vulnerabilities. Lauf 'npm audit' fuer Details."
            return 1
        fi
    fi
    return 0
}

check_pypi_cve() {
    if command -v pip-audit >/dev/null 2>&1; then
        local audit_output
        audit_output=$(pip-audit --strict 2>&1 || true)
        if echo "$audit_output" | grep -qiE 'vulnerability|cve'; then
            echo "[DEP-CHECK] BLOCK: pip-audit meldet Vulnerabilities. Lauf 'pip-audit' fuer Details."
            return 1
        fi
    fi
    return 0
}

echo "[DEP-CHECK] Slopsquatting-Schutz aktiv"

if [[ -n "$TRIGGERS_NPM" ]]; then
    NEW_NPM=$(extract_new_npm_deps)
    for pkg in $NEW_NPM; do
        if ! check_npm_existence "$pkg"; then
            echo "[DEP-CHECK] BLOCK: npm-Paket '$pkg' existiert nicht in der Registry — Halluzination?"
            BLOCKED=1
        else
            check_npm_age "$pkg"
        fi
    done
    check_npm_cve || BLOCKED=1
fi

if [[ -n "$TRIGGERS_PIP" ]]; then
    NEW_PYPI=$(extract_new_pypi_deps)
    for pkg in $NEW_PYPI; do
        if ! check_pypi_existence "$pkg"; then
            echo "[DEP-CHECK] BLOCK: PyPI-Paket '$pkg' existiert nicht — Halluzination?"
            BLOCKED=1
        fi
    done
    check_pypi_cve || BLOCKED=1
fi

if [[ -n "$TRIGGERS_CARGO" ]]; then
    echo "[DEP-CHECK] HINWEIS: Cargo-Diff erkannt — Cargo-Check wird in zukuenftiger Iteration ergaenzt. Operator: 'cargo audit' manuell laufen lassen."
fi

if (( BLOCKED == 1 )); then
    echo "[DEP-CHECK] Gate BLOCKIERT. Slopsquatting-Risiko vermeiden — Pakete verifizieren, dann erneut committen."
    exit 1
fi

echo "[DEP-CHECK] Gate bestanden"
exit 0
DEPCHECK_EOF
        chmod +x "$hook_script"
        log_info "created $hook_script (executable)"
    fi

    # --- Pre-Commit-Hook erweitern: Aufruf von dependency-check.sh nach Semgrep ergaenzen ---
    local pre_commit_hook=".git/hooks/pre-commit"
    if [[ ! -f "$pre_commit_hook" ]]; then
        log_manual "Pre-Commit-Hook fehlt — erst BOO-4 ('--issue BOO-4') laufen lassen"
    elif grep -q "dependency-check.sh" "$pre_commit_hook" 2>/dev/null; then
        log_skip "Pre-Commit-Hook ruft dependency-check.sh bereits auf"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "append dependency-check.sh-Aufruf an $pre_commit_hook (vor 'exit 0')"
    else
        # Aufruf vor das letzte 'exit 0' einfuegen
        # Idempotent: zweite Lauf-Erkennung via grep oben
        local tmp
        tmp=$(mktemp)
        awk '
            /^exit 0$/ && !done {
                print "# --- Dependency-Gate (BOO-12) ---"
                print "if [[ -x \".claude/hooks/dependency-check.sh\" ]]; then"
                print "    bash .claude/hooks/dependency-check.sh || exit 1"
                print "fi"
                print ""
                done = 1
            }
            { print }
        ' "$pre_commit_hook" > "$tmp"
        mv "$tmp" "$pre_commit_hook"
        chmod +x "$pre_commit_hook"
        log_info "Pre-Commit-Hook um dependency-check.sh-Aufruf erweitert"
    fi

    log_manual "Operator (Node): 'npm audit' verfuegbar — fuer CVE-Pruefung"
    log_manual "Operator (Python): 'pip install pip-audit' fuer CVE-Pruefung"
    return 0
}

migrate_boo_15() {
    # BOO-15 — /implement Coverage-Gate (>=80% fuer neuen Code) — v3.2.6 seit 2026-05-06
    # https://linear.app/owlist/issue/BOO-15
    log_info "BOO-15: coverage-check.sh anlegen (Diff-Coverage-Gate)"

    local script_dir; script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local canonical="$script_dir/../references/hooks/coverage-check.sh"
    local hooks_dir=".claude/hooks"
    local hook_script="$hooks_dir/coverage-check.sh"
    ensure_dir "$hooks_dir"
    # BOO-89: Single-Source — Skript wird aus references/hooks/coverage-check.sh kopiert
    # (kein eingebetteter Heredoc mehr). BOO-88: v2 ersetzt alte v1, marker-basiert, idempotent.
    if [[ ! -f "$canonical" ]]; then
        log_skip "Kanonische Quelle fehlt ($canonical) — coverage-check.sh uebersprungen"
    else
        local needs_write=false replace_v1=false
        if [[ ! -f "$hook_script" ]]; then
            needs_write=true
        elif ! grep -q 'coverage-check v2' "$hook_script" 2>/dev/null; then
            needs_write=true; replace_v1=true
        else
            log_skip "$hook_script bereits v2 (BOO-88)"
        fi
        if [[ "$needs_write" == "true" && "$DRY_RUN" == "true" ]]; then
            [[ "$replace_v1" == "true" ]] && log_dry "backup $hook_script -> .bak (BOO-88 v1->v2)"
            log_dry "copy $canonical -> $hook_script (Diff-Coverage-Gate v2)"
        elif [[ "$needs_write" == "true" ]]; then
            [[ "$replace_v1" == "true" ]] && { cp "$hook_script" "$hook_script.bak"; log_info "BOO-88: alte v1 nach $hook_script.bak gesichert"; }
            cp "$canonical" "$hook_script"
            chmod +x "$hook_script"
            log_info "created $hook_script (executable, v2, aus references/hooks/)"
        fi
    fi

    log_manual "Operator (Node): 'npm install --save-dev c8' falls nicht installiert"
    log_manual "Operator (Python): pytest-cov in pyproject.toml ergaenzen"
    log_manual "Operator: /implement-Skill ruft den Hook automatisch in Schritt 6a-quart auf — Test-Lauf vorher mit Coverage-Output noetig"
    return 0
}

migrate_boo_27() {
    # BOO-27 — Issue-Template: 4 Schrader-Prompt-Bestandteile als Pflichtfelder (Governance v2)
    # https://linear.app/owlist/issue/BOO-27
    log_info "BOO-27: Schrader-Prompt-Bestandteile als Pflichtfelder + HARD GATE in /implement"
    ensure_dir ".github/ISSUE_TEMPLATE"
    if [[ ! -f ".github/ISSUE_TEMPLATE/story.yml" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write .github/ISSUE_TEMPLATE/story.yml"
        else
            cat > ".github/ISSUE_TEMPLATE/story.yml" <<'EOF'
name: Story / Feature
description: "INTENTRON Governance v2 — Schrader Prompt Components (Pflichtfelder)"
title: "[STORY] "
body:
  - type: dropdown
    id: execution_mode
    attributes:
      label: "Ausführungsmodus"
      description: "agentic = Lead + parallele Sub-Agents | sub-agents = sequentiell | linear = direkt (<50 Zeilen, 1-2 SP)"
      options:
        - linear
        - sub-agents
        - agentic
    validations:
      required: true
  - type: textarea
    id: insight
    attributes:
      label: "Insight — Warum jetzt?"
      description: "Welches Problem oder welche Beobachtung steckt hinter dieser Story? Min. 1 Satz."
      placeholder: "Bsp: Der aktuelle Prozess X ist fehleranfällig weil ..."
    validations:
      required: true
  - type: textarea
    id: constraints
    attributes:
      label: "Constraints — Rahmenbedingungen"
      description: "Technische, zeitliche oder fachliche Grenzen für die Lösung."
      placeholder: "Bsp: Muss rückwärtskompatibel bleiben, kein Breaking Change in API v1"
    validations:
      required: true
  - type: textarea
    id: success_criteria
    attributes:
      label: "Erfolgskriterien"
      description: "Woran erkennt man den Erfolg? Konkret und messbar."
      placeholder: "Bsp: CI grün, alle bestehenden Tests bestehen, neue Tests für Pfad X"
    validations:
      required: true
  - type: textarea
    id: desired_outcome
    attributes:
      label: "Gewünschtes Ergebnis"
      description: "Welcher Zustand herrscht nach der Umsetzung?"
      placeholder: "Bsp: Operator kann /implement BOO-XX ohne manuelle Vorbereitung aufrufen"
    validations:
      required: true
  - type: textarea
    id: dod
    attributes:
      label: "Definition of Done"
      value: "- [ ] Tests grün\n- [ ] Kein Lint-Fehler\n- [ ] SecondBrain / HANDBUCH aktualisiert\n- [ ] Commit-Message-Convention eingehalten\n- [ ] Keine offenen TODOs im diff"
    validations:
      required: false
EOF
            log_info "created .github/ISSUE_TEMPLATE/story.yml"
        fi
    else
        log_skip ".github/ISSUE_TEMPLATE/story.yml exists"
    fi
    log_manual "Operator: /implement hat seit BOO-27 einen HARD GATE in Schritt 1b — bestehende Linear-Issues brauchen alle 4 Schrader-Bestandteile (Insight / Constraints / Erfolgskriterien / Gewuenschtes Ergebnis, je min. 20 Zeichen) bevor /implement aufgerufen werden kann"
    log_manual "Operator: Optional CLAUDE.md ergaenzen: 'Jedes Linear-Issue muss die 4 Schrader-Prompt-Bestandteile enthalten. /implement blockt sonst in Schritt 1b.'"
    return 0
}

migrate_boo_28() {
    # BOO-28 — /bootstrap: ESLint als GitHub Action (CI-Gate) — v3.17.0 seit 2026-05-12
    # https://linear.app/owlist/issue/BOO-28
    #
    # Legt Stack-abhaengig einen oder zwei CI-Workflow-Files an:
    #   1. .github/workflows/eslint.yml   — wenn package.json vorhanden (Node/JS/TS)
    #   2. .github/workflows/ruff.yml     — wenn pyproject.toml ODER requirements.txt vorhanden (Python)
    #   Mixed-Stack (beide Manifest-Files vorhanden) -> beide Workflows parallel.
    #
    # SARIF-Output ist Pflicht (BOO-32-Vorbereitung) — beide Workflows schreiben nach
    # .ci-reports/<tool>.sarif und uploaden via github/codeql-action/upload-sarif@v4.
    #
    # Stack-Detection: identisches Pattern zu migrate_boo_16/migrate_boo_25.
    #   - package.json                                 -> Node
    #   - pyproject.toml ODER requirements.txt         -> Python
    #   - beide                                        -> Mixed (beide Workflows)
    #   - keines                                       -> Unknown (log_warn, kein Workflow)
    #
    # Idempotenz: bestehende Workflow-Files werden ge[SKIP]ped; --force ueberschreibt.
    log_info "BOO-28: ESLint/Ruff als GitHub Action (CI-Lint-Gate mit SARIF)"

    # --- Stack-Detection ---
    local has_node="false"
    local has_python="false"
    [[ -f "package.json" ]] && has_node="true"
    [[ -f "pyproject.toml" || -f "requirements.txt" ]] && has_python="true"

    if [[ "$has_node" != "true" && "$has_python" != "true" ]]; then
        log_warn "BOO-28: weder package.json noch pyproject.toml/requirements.txt gefunden — Stack unbekannt"
        log_manual "Operator: Stack manuell festlegen oder Manifest-File ergaenzen, dann erneut '--issue BOO-28' laufen lassen"
        return 0
    fi

    ensure_dir ".github/workflows"

    # --- Node-Stack: .github/workflows/eslint.yml ---
    if [[ "$has_node" == "true" ]]; then
        local eslint_yml=".github/workflows/eslint.yml"
        if [[ -f "$eslint_yml" && "$FORCE" != "true" ]]; then
            log_skip "$eslint_yml existiert (use --force to overwrite)"
        elif [[ "$DRY_RUN" == "true" ]]; then
            if [[ -f "$eslint_yml" ]]; then
                log_dry "overwrite $eslint_yml (--force) — Inhalt aus file-templates.md §.github/workflows/eslint.yml (BOO-28)"
            else
                log_dry "write $eslint_yml (Inhalt aus file-templates.md §.github/workflows/eslint.yml (BOO-28))"
            fi
        else
            # Heredoc 1:1 aus bootstrap/references/file-templates.md §.github/workflows/eslint.yml (BOO-28)
            cat > "$eslint_yml" <<'ESLINT_YML_EOF'
name: ESLint
on: [push, pull_request]
permissions:
  contents: read
  security-events: write
jobs:
  eslint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npx eslint . --format=@microsoft/eslint-formatter-sarif --output-file=.ci-reports/eslint.sarif
      - uses: github/codeql-action/upload-sarif@v4
        with: { sarif_file: .ci-reports/eslint.sarif }
        if: always() && hashFiles('.ci-reports/eslint.sarif') != ''
ESLINT_YML_EOF
            log_info "created $eslint_yml (SARIF-Output nach .ci-reports/eslint.sarif)"
        fi

        # SARIF-Formatter als devDependency ergaenzen (idempotent via jq)
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "ergaenze package.json devDependencies um '@microsoft/eslint-formatter-sarif' (via jq oder Operator)"
        elif command -v jq >/dev/null 2>&1; then
            if jq -e '.devDependencies["@microsoft/eslint-formatter-sarif"] // empty' package.json >/dev/null 2>&1; then
                log_skip "package.json devDependencies enthaelt bereits '@microsoft/eslint-formatter-sarif'"
            else
                jq '.devDependencies = (.devDependencies // {}) + {"@microsoft/eslint-formatter-sarif": "^3.1.0"}' package.json > package.json.tmp \
                    && mv package.json.tmp package.json
                log_info "package.json devDependencies um '@microsoft/eslint-formatter-sarif' ergaenzt — 'npm install' im Anschluss noetig"
            fi
        else
            log_warn "jq nicht gefunden — Operator: 'npm install --save-dev @microsoft/eslint-formatter-sarif' manuell ausfuehren"
        fi
    fi

    # --- Python-Stack: .github/workflows/ruff.yml ---
    if [[ "$has_python" == "true" ]]; then
        local ruff_yml=".github/workflows/ruff.yml"
        if [[ -f "$ruff_yml" && "$FORCE" != "true" ]]; then
            log_skip "$ruff_yml existiert (use --force to overwrite)"
        elif [[ "$DRY_RUN" == "true" ]]; then
            if [[ -f "$ruff_yml" ]]; then
                log_dry "overwrite $ruff_yml (--force) — Inhalt aus file-templates.md §.github/workflows/ruff.yml (BOO-28)"
            else
                log_dry "write $ruff_yml (Inhalt aus file-templates.md §.github/workflows/ruff.yml (BOO-28))"
            fi
        else
            # Heredoc aus bootstrap/references/file-templates.md §.github/workflows/ruff.yml (BOO-28)
            cat > "$ruff_yml" <<'RUFF_YML_EOF'
name: Ruff
on: [push, pull_request]
permissions:
  contents: read
  security-events: write
jobs:
  ruff:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install ruff
      - run: |
          mkdir -p .ci-reports
          ruff check . --output-format=sarif --output-file=.ci-reports/ruff.sarif
      - uses: github/codeql-action/upload-sarif@v4
        with: { sarif_file: .ci-reports/ruff.sarif }
        if: always() && hashFiles('.ci-reports/ruff.sarif') != ''
RUFF_YML_EOF
            log_info "created $ruff_yml (SARIF-Output nach .ci-reports/ruff.sarif)"
        fi
    fi

    # --- .ci-reports/ aus dem Repo-Index halten (Konvention analog journal/reports/perf/) ---
    append_if_missing ".gitignore" ".ci-reports/"

    # --- Operator-Schritte ---
    log_manual "Operator-Schritte: siehe migration-checklist-v1-to-v2.md §BOO-28"
    if [[ "$has_node" == "true" ]]; then
        log_manual "Operator (Node): 'npm install' nach package.json-Update — verifiziert '@microsoft/eslint-formatter-sarif' im node_modules vorhanden"
    fi
    log_manual "Operator: ersten CI-Lauf abwarten (Push oder PR auf main) — gruener 'ESLint'-Check (bzw. 'Ruff') sollte erscheinen"
    log_manual "Operator: SARIF-Upload im GitHub Security-Tab pruefen (Settings -> Security -> Code scanning alerts)"
    log_manual "Operator: nach BOO-28-Done in BOO-29 Branch-Protection aktivieren mit Required Status Check 'ESLint' (bzw. 'Ruff')"
    return 0
}

migrate_boo_29() {
    # BOO-29 — /bootstrap: Branch-Protection mit Required Status Checks — v3.18.0 seit 2026-05-12
    # https://linear.app/owlist/issue/BOO-29
    #
    # Setzt via `gh api` Branch-Protection auf main:
    #   - required_status_checks.strict = true
    #   - required_status_checks.contexts[] — dynamisch aus .github/workflows/*.yml
    #     (erstes Top-Level `name:`-Feld pro Workflow-Datei)
    #   - enforce_admins = false
    #   - required_pull_request_reviews.dismiss_stale_reviews = true
    #   - required_pull_request_reviews.required_approving_review_count = 0  # BOO-149 (vorher 1)
    #   - restrictions = null
    #   - allow_force_pushes = false
    #
    # Eigentliche Logik in scripts/setup-branch-protection.sh — diese Funktion
    # ist Wrapper, der Voraussetzungen prueft, das Skript aufruft (oder bei
    # DRY_RUN/FORCE die richtige Flag-Kombination logged) und auf Fehler klar
    # an den Operator zurueckspielt.
    #
    # Idempotenz: PUT-Call ist Replace — re-run-safe.
    log_info "BOO-29: Branch-Protection mit Required Status Checks"

    # --- Voraussetzungs-Check 1: gh CLI installiert? ---
    if ! command -v gh >/dev/null 2>&1; then
        log_warn "gh CLI nicht gefunden — BOO-29 uebersprungen"
        log_manual "Operator: 'brew install gh' (Mac) oder https://cli.github.com/ — danach erneut '--issue BOO-29' laufen lassen"
        return 0
    fi

    # --- Voraussetzungs-Check 2: gh auth status — eingeloggt? ---
    if ! gh auth status >/dev/null 2>&1; then
        log_warn "gh CLI nicht eingeloggt — BOO-29 uebersprungen"
        log_manual "Operator: 'gh auth login' ausfuehren (Browser-Flow oder Token mit 'repo'-Scope), danach erneut '--issue BOO-29' laufen lassen"
        return 0
    fi

    # --- Voraussetzungs-Check 3: Remote 'origin' vorhanden? ---
    if ! git remote get-url origin >/dev/null 2>&1; then
        log_warn "Kein git remote 'origin' im aktuellen Repo — BOO-29 uebersprungen"
        log_manual "Operator: 'git remote add origin git@github.com:<owner>/<repo>.git' und 'git push -u origin main' laufen lassen, dann erneut '--issue BOO-29'"
        return 0
    fi

    # --- Skript-Pfad finden — neben migrate-to-v2.sh im selben Verzeichnis ---
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local bp_script="$script_dir/setup-branch-protection.sh"

    if [[ ! -f "$bp_script" ]]; then
        log_warn "setup-branch-protection.sh nicht gefunden unter $bp_script — BOO-29 uebersprungen"
        log_manual "Operator: scripts/setup-branch-protection.sh aus dem Bootstrap-Repo (intentron/bootstrap/scripts/) ins Projekt kopieren und dann erneut laufen lassen"
        return 0
    fi

    # --- Dispatch: Dry-Run vs. echter Lauf ---
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "bash $bp_script --dry-run (Branch-Protection setzen mit dynamischen Required Status Checks aus .github/workflows/*.yml)"
    else
        log_info "Rufe $bp_script auf — Branch-Protection wird gesetzt"
        if bash "$bp_script"; then
            log_info "Branch-Protection erfolgreich gesetzt"
        else
            log_warn "setup-branch-protection.sh fehlgeschlagen — Operator-Schritte unten beachten"
            log_manual "Operator: bash $bp_script manuell ausfuehren und Fehlerausgabe pruefen (Permissions? main remote? Free-Plan-Limit?)"
        fi
    fi

    log_manual "Operator: in GitHub-UI verifizieren (Settings -> Branches -> main) — Protection-Rule sollte aktiv sein mit den detected Checks"
    log_manual "Operator: Test-PR oeffnen ohne gruene Checks — Merge muss blockiert sein"
    return 0
}

migrate_boo_30() {
    # BOO-30 — Linear-Workflow-States + Definition-of-Done — v3.19.0 seit 2026-05-12
    # https://linear.app/owlist/issue/BOO-30
    #
    # Bestands-Projekte ziehen das Issue-Template-Update nach (DoD-Pflichtsektion).
    # Linear-Setup (6 Workflow-States + GitHub-Integration) bleibt bewusst manuell
    # — Operator-Hinweise via [MANUAL]-Logs.
    #
    # Idempotenz: prueft Marker-Zeile "Story darf erst auf Linear-Status \"Done\""
    # in jedem Ziel-File. Vorhandener Marker -> [SKIP]. Fehlender Marker:
    #   1) .github/ISSUE_TEMPLATE/story.yml: dod-Block patchen (value-Feld)
    #   2) .claude/ISSUE_WRITING_GUIDELINES.md: DoD-Pflicht-Sektion anhaengen
    log_info "BOO-30: Linear-Workflow-States + Definition-of-Done — Issue-Template-Erweiterung"

    # --- DoD-Marker (1:1 aus BOO-30) ---
    local dod_marker='Story darf erst auf Linear-Status "Done" wenn:'

    # ====== Teil 1: .github/ISSUE_TEMPLATE/story.yml DoD-Block patchen ======
    local story_yml=".github/ISSUE_TEMPLATE/story.yml"
    if [[ ! -f "$story_yml" ]]; then
        log_warn "$story_yml fehlt — BOO-27 zuerst laufen lassen (migrate-to-v2.sh --issue BOO-27)"
        log_manual "Operator: 'bash <pfad>/migrate-to-v2.sh --issue BOO-27' ausfuehren, dann BOO-30 wiederholen"
    else
        if grep -Fq "$dod_marker" "$story_yml" 2>/dev/null; then
            log_skip "$story_yml: DoD-Block schon auf BOO-30-Stand"
        elif [[ "$DRY_RUN" == "true" ]]; then
            log_dry "patch $story_yml: dod value-Feld auf BOO-30-Canonical (5er-Checkliste)"
        else
            # Idempotenter In-place-Patch via Python: liest YAML als Text, ersetzt den 'id: dod'-Block
            # bis zum naechsten Top-Level-Eintrag ('- type:' oder EOF). Python ist bei BOO-15/BOO-34
            # bereits Voraussetzung — keine neue Dependency.
            if ! command -v python3 >/dev/null 2>&1; then
                log_warn "python3 nicht gefunden — $story_yml unveraendert. Manuelles Update notwendig (Vorlage in HANDBUCH §8g)."
            else
                local tmp_yml
                tmp_yml="$(mktemp)"
                python3 - "$story_yml" "$tmp_yml" <<'PYEOF'
import sys
import re

src, dst = sys.argv[1], sys.argv[2]
with open(src, "r", encoding="utf-8") as fh:
    lines = fh.readlines()

# Canonical-Block (1:1 aus BOO-30). Indent matcht das Bestand-Schema von migrate_boo_27.
canonical = [
    "  - type: textarea\n",
    "    id: dod\n",
    "    attributes:\n",
    "      label: \"Definition of Done (Pflicht)\"\n",
    "      description: \"Story darf erst auf Linear-Status Done wenn alle Punkte abgehakt sind (1:1 aus BOO-30, nicht pro Story anpassen).\"\n",
    "      value: |\n",
    "        Story darf erst auf Linear-Status \"Done\" wenn:\n",
    "        - [ ] Alle lokalen Gates gruen (ESLint, Semgrep, Tests, Coverage)\n",
    "        - [ ] PR ist gemerged auf main\n",
    "        - [ ] Alle Required Status Checks gruen (siehe BOO-29)\n",
    "        - [ ] Kein offener \"QA Failed\"-Status\n",
    "        - [ ] Spec-File `specs/BOO-XX.md` aktualisiert mit Result-Summary (Implement-Skill Schritt 8)\n",
    "    validations:\n",
    "      required: true\n",
]

# Bestehenden dod-Block lokalisieren: 'id: dod' nach oben bis zum letzten '- type:' suchen.
out = []
i = 0
patched = False
n = len(lines)
while i < n:
    # dod-Textarea-Block beginnt typischerweise mit "  - type: textarea" + "    id: dod"
    if (re.match(r"^[ \t]*-[ \t]+type:[ \t]+textarea[ \t]*$", lines[i])
            and i + 1 < n
            and re.match(r"^[ \t]*id:[ \t]+dod[ \t]*$", lines[i + 1])):
        # Block-Ende suchen: naechstes Top-Level "- type:" oder Datei-Ende.
        j = i + 2
        while j < n and not re.match(r"^[ \t]*-[ \t]+type:", lines[j]):
            j += 1
        # Block i..j-1 ersetzen
        out.extend(canonical)
        patched = True
        i = j
        continue
    out.append(lines[i])
    i += 1

if not patched:
    # Kein dod-Block vorhanden — am Ende anhaengen.
    if out and not out[-1].endswith("\n"):
        out.append("\n")
    out.extend(canonical)

with open(dst, "w", encoding="utf-8") as fh:
    fh.writelines(out)
PYEOF
                if [[ -s "$tmp_yml" ]]; then
                    mv "$tmp_yml" "$story_yml"
                    log_info "patched $story_yml: dod-Block auf BOO-30-Canonical (5er-Checkliste)"
                else
                    rm -f "$tmp_yml"
                    log_warn "Python-Patch lieferte leeren Output — $story_yml unveraendert. Manuelles Update notwendig."
                fi
            fi
        fi
    fi

    # ====== Teil 2: .claude/ISSUE_WRITING_GUIDELINES.md DoD-Sektion ergaenzen ======
    local guidelines=".claude/ISSUE_WRITING_GUIDELINES.md"
    if [[ ! -f "$guidelines" ]]; then
        log_skip "$guidelines fehlt — kein gerendetes Bootstrap-Artefakt, BOO-30-Erweiterung nicht anwendbar"
    elif grep -Fq "$dod_marker" "$guidelines" 2>/dev/null; then
        log_skip "$guidelines: DoD-Sektion schon auf BOO-30-Stand"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "append DoD-Pflicht-Sektion an $guidelines (5er-Checkliste 1:1 aus BOO-30)"
    else
        cat >> "$guidelines" <<'DOD_GUIDELINES_EOF'

---

## Definition of Done (Pflicht) — BOO-30

Story darf erst auf Linear-Status "Done" wenn:
* [ ] Alle lokalen Gates gruen (ESLint, Semgrep, Tests, Coverage)
* [ ] PR ist gemerged auf main
* [ ] Alle Required Status Checks gruen (siehe BOO-29)
* [ ] Kein offener "QA Failed"-Status
* [ ] Spec-File `specs/BOO-XX.md` aktualisiert mit Result-Summary (Implement-Skill Schritt 8)

**Regeln:**
- Checklisten-Punkte nicht pro Story anpassen oder weglassen.
- Wenn ein Gate nicht zutrifft (z.B. keine Tests bei einer reinen Doku-Story), explizit kennzeichnen: `* [N/A] Tests — reine Doku-Story`.
- Spec-File-Update ist unabhaengig von der Story-Groesse Pflicht.

Quelle: BOO-30 + HANDBUCH §8g Linear-Setup pro Projekt.
DOD_GUIDELINES_EOF
        log_info "appended DoD-Pflicht-Sektion an $guidelines"
    fi

    # ====== Teil 3: Manuelle Operator-Schritte fuer Linear-Setup ======
    log_manual "Operator: Linear-Workflow-States manuell anlegen — Linear -> Settings -> <Team> -> Workflow"
    log_manual "Operator: 6 States in dieser Reihenfolge anlegen — Backlog, In Progress, In Review, QA Failed, Done, Cancelled (Namen exakt, sie steuern Auto-Transitions)"
    log_manual "Operator: GitHub-Integration aktivieren — Linear -> Settings -> Integrations -> GitHub -> Connect Repository -> Projekt-Repo auswaehlen"
    log_manual "Operator: Auto-Recognition wirkt sofort fuer Branch-Names / PR-Titles / Commit-Messages / PR-Body mit '{ISSUE_PREFIX}-XX'-Prefix bzw. 'Closes {ISSUE_PREFIX}-XX'"
    log_manual "Operator: Test-Story mit Branch '{ISSUE_PREFIX}-XX-test' anlegen — PR-Open transitioniert Issue auf 'In Review'"
    log_manual "Operator: vollstaendige Anleitung in HANDBUCH §8g 'Linear-Setup pro Projekt' (DE) / §8g 'Linear setup per project' (EN)"
    return 0
}

migrate_boo_34() {
    # BOO-34 — /bootstrap: .claude/environment.json — Skill-Umgebungs-Awareness — v3.3.0 seit 2026-05-06
    # https://linear.app/owlist/issue/BOO-34
    log_info "BOO-34: .claude/generate-environment-json.sh + .claude/environment.json anlegen"

    ensure_dir ".claude"

    # --- Schritt 1: Generator-Skript anlegen ---
    local gen_script=".claude/generate-environment-json.sh"
    local write_gen=false
    if [[ -f "$gen_script" && "$FORCE" != "true" ]]; then
        log_skip "$gen_script existiert (use --force to overwrite)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "$gen_script" ]]; then
            log_dry "overwrite $gen_script (--force) — Inhalt aus file-templates.md §.claude/generate-environment-json.sh"
        else
            log_dry "write $gen_script (Inhalt aus file-templates.md §.claude/generate-environment-json.sh)"
        fi
    else
        write_gen=true
    fi

    if [[ "$write_gen" == "true" ]]; then
        # Heredoc 1:1 aus bootstrap/references/file-templates.md §.claude/generate-environment-json.sh
        cat > "$gen_script" <<'GENENV_EOF'
#!/usr/bin/env bash
# .claude/generate-environment-json.sh — Environment-Awareness-Generator (BOO-34)
# DE: Erzeugt .claude/environment.json mit Detection von Mac/VPS/CI, verfuegbaren
#     Tools (eslint, semgrep, Test-Framework) und Standard-Pfaden. BSD- und
#     Linux-kompatibel, ohne Abhaengigkeiten ausser bash, uname, command, cat,
#     grep, sed, date.
# EN: Generates .claude/environment.json with Mac/VPS/CI detection, available
#     tools (eslint, semgrep, test framework) and default paths. BSD- and
#     Linux-compatible, no deps beyond bash, uname, command, cat, grep, sed, date.
set -euo pipefail

# --- CLI-Flags ---
FORCE=0
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        --help|-h)
            cat <<'HLP'
Usage: bash .claude/generate-environment-json.sh [--force]
  --force   Overwrite existing .claude/environment.json
HLP
            exit 0 ;;
    esac
done

OUT=".claude/environment.json"
mkdir -p .claude

if [[ -f "$OUT" && $FORCE -eq 0 ]]; then
    echo "[ENV] $OUT existiert bereits — Skip (use --force to overwrite)."
    exit 0
fi

# --- environment: ci > mac > vps ---
# CI-Check ZUERST: ein CI-Runner kann Linux ODER Mac sein.
if [[ -n "${CI:-}" ]]; then
    ENVIRONMENT="ci"
elif [[ "$(uname -s)" = "Darwin" ]]; then
    ENVIRONMENT="mac"
else
    ENVIRONMENT="vps"
fi

# --- tools_available ---
# eslint: command -v ODER lokal in node_modules
HAS_ESLINT="false"
if command -v eslint >/dev/null 2>&1; then
    HAS_ESLINT="true"
elif [[ -f "package.json" ]] && command -v npm >/dev/null 2>&1; then
    if npm ls eslint --silent >/dev/null 2>&1; then
        HAS_ESLINT="true"
    fi
fi

# semgrep: nur via command -v (PATH)
HAS_SEMGREP="false"
if command -v semgrep >/dev/null 2>&1; then
    HAS_SEMGREP="true"
fi

# tests: erkennen aus package.json (vitest/jest/mocha) oder pyproject.toml (pytest)
TESTS="null"
if [[ -f "package.json" ]]; then
    if grep -q '"vitest"' package.json 2>/dev/null; then
        TESTS='"vitest"'
    elif grep -q '"jest"' package.json 2>/dev/null; then
        TESTS='"jest"'
    elif grep -q '"mocha"' package.json 2>/dev/null; then
        TESTS='"mocha"'
    fi
fi
if [[ "$TESTS" = "null" && -f "pyproject.toml" ]]; then
    if grep -qE '(pytest|^\[tool\.pytest)' pyproject.toml 2>/dev/null; then
        TESTS='"pytest"'
    fi
fi

# sonarqube_ide_plugin: nicht erkennbar via CLI — Default false, Operator ergaenzt manuell auf Mac.
SONAR_IDE="false"

# sonarqube_cloud: Cloud-API ist von ueberall erreichbar — hardcoded true.
SONAR_CLOUD="true"

# --- metadata.stack: analog BOO-3 Semgrep-Stack-Erkennung ---
HAS_PKG=0
HAS_PY=0
[[ -f "package.json" ]] && HAS_PKG=1
[[ -f "pyproject.toml" ]] && HAS_PY=1

if [[ $HAS_PKG -eq 1 && $HAS_PY -eq 1 ]]; then
    STACK="mixed"
elif [[ $HAS_PKG -eq 1 ]]; then
    # TS vs JS: tsconfig.json oder "typescript" als devDep
    if [[ -f "tsconfig.json" ]] || grep -q '"typescript"' package.json 2>/dev/null; then
        STACK="node-typescript"
    else
        STACK="node-javascript"
    fi
elif [[ $HAS_PY -eq 1 ]]; then
    STACK="python"
else
    STACK="unknown"
fi

# --- metadata.created_at: ISO-8601 UTC ---
CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# --- metadata.bootstrap_version: aktuelle Bootstrap-Version ---
BOOTSTRAP_VERSION="3.3.0"

# --- JSON via Heredoc (kein jq noetig) ---
cat > "$OUT" <<EOF
{
  "environment": "${ENVIRONMENT}",
  "tools_available": {
    "eslint": ${HAS_ESLINT},
    "semgrep": ${HAS_SEMGREP},
    "tests": ${TESTS},
    "sonarqube_ide_plugin": ${SONAR_IDE},
    "sonarqube_cloud": ${SONAR_CLOUD}
  },
  "paths": {
    "journal": "journal/",
    "reports_local": "journal/reports/local/",
    "reports_ci": "journal/reports/ci/",
    "lessons_l1": "journal/learnings.md",
    "lessons_l2_dir": "journal/",
    "lessons_l3": "journal/learnings.db",
    "specs": "specs/",
    "architecture_design": "ARCHITECTURE_DESIGN.md",
    "intents": "intents/",
    "pitches": "pitch/"
  },
  "metadata": {
    "created_at": "${CREATED_AT}",
    "bootstrap_version": "${BOOTSTRAP_VERSION}",
    "stack": "${STACK}"
  }
}
EOF

echo "[ENV] $OUT geschrieben (environment=${ENVIRONMENT}, stack=${STACK})."
GENENV_EOF
        chmod +x "$gen_script"
        log_info "created $gen_script (executable)"
    fi

    # --- Schritt 2: Generator ausfuehren — schreibt .claude/environment.json ---
    local env_file=".claude/environment.json"
    if [[ -f "$env_file" && "$FORCE" != "true" ]]; then
        log_skip "$env_file existiert (use --force to overwrite)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "$env_file" ]]; then
            log_dry "run bash $gen_script --force (overwrite $env_file)"
        else
            log_dry "run bash $gen_script (write $env_file)"
        fi
    elif [[ ! -x "$gen_script" ]]; then
        log_warn "$gen_script fehlt oder nicht ausfuehrbar — Schritt 1 zuerst laufen lassen"
        return 1
    else
        local gen_rc=0
        if [[ "$FORCE" == "true" ]]; then
            bash "$gen_script" --force || gen_rc=$?
        else
            bash "$gen_script" || gen_rc=$?
        fi
        if [[ "$gen_rc" -eq 0 ]]; then
            log_info "$env_file via Generator erzeugt"
        else
            log_warn "$gen_script schlug fehl (rc=$gen_rc) — manuell pruefen"
            return 1
        fi
    fi

    log_manual "Operator: nach Tool-Aenderung (z.B. 'brew install semgrep') 'bash .claude/generate-environment-json.sh --force' laufen lassen"
    log_manual "Operator (Mac): falls SonarLint VS-Code-Plugin aktiv, 'sonarqube_ide_plugin' in $env_file manuell auf true setzen"
    return 0
}

migrate_boo_36() {
    # BOO-36 — /implement: journal/reports/local/ Persistenz
    # https://linear.app/owlist/issue/BOO-36
    log_info "BOO-36: journal/reports/local/ + .gitignore-Eintrag"
    ensure_dir "journal/reports/local"
    ensure_file "journal/reports/local/.gitkeep"
    append_if_missing ".gitignore" "journal/reports/local/*"
    append_if_missing ".gitignore" "!journal/reports/local/.gitkeep"
    return 0
}

migrate_boo_38() {
    # BOO-38 — Sprint-Sizing-Konvention dokumentieren
    # https://linear.app/owlist/issue/BOO-38
    log_info "BOO-38: Sprint-Sizing-Konvention (Doku-only, kein Projekt-Schritt)"
    log_manual "Operator: Doku im Skill — keine Migration im Bestands-Projekt"
    return 0
}

migrate_boo_39() {
    # BOO-39 — /ideation: Token-Heuristik
    # https://linear.app/owlist/issue/BOO-39
    log_info "BOO-39: Token-Heuristik in /ideation"
    # TODO: implementiert beim Done von BOO-39
    log_manual "Operator: implementiert beim Done von BOO-39 — Skill-Update, ggf. README-Hinweis im Bestands-Projekt"
    return 0
}

migrate_boo_40() {
    # BOO-40 — /implement: Token-Window-Pre-Flight (Schritt 0b)
    # https://linear.app/owlist/issue/BOO-40
    log_info "BOO-40: Token-Window-Pre-Flight"
    # TODO: implementiert beim Done von BOO-40
    log_manual "Operator: implementiert beim Done von BOO-40 — Skill-Update"
    return 0
}

# ---------------- Phase 3 — Observability + Performance ----------------

migrate_boo_8() {
    # BOO-8 — Testability als 7. Standard-Dimension einfuehren (Re-Scope 2026-05-06)
    # https://linear.app/owlist/issue/BOO-8
    #
    # Re-Scope-Hinweis: Issue war 2026-04-23 als "Operations -> Testability + Observability"
    # formuliert. Status-Quo-Check ergab: keine "Operations"-Sammel-Dimension, Observability
    # bereits Standard #5. BOO-8 ist additiv — nur Testability dazu.
    #
    # Auto-Edit der ARCHITECTURE_DESIGN.md ist bewusst nicht implementiert: das File ist
    # projekt-spezifisch (eigene §-Nummerierung, eigene Add-ons, eigene Pruef-Fragen) und
    # ein automatisches Insert wuerde die Struktur brechen. Operator-getrieben, idempotent
    # ohne File-Operationen.
    log_info "BOO-8: Testability als 7. Standard-Dimension einfuehren"
    log_manual "Operator: ARCHITECTURE_DESIGN.md oeffnen, §3 Quality Attributes / Qualitaets-Dimensionen suchen"
    log_manual "Operator: Testability-Zeile zwischen Maintainability (#6) und Cost Efficiency / Domain Quality einfuegen"
    log_manual "Operator: Pruef-Frage uebernehmen: 'Coverage auf neuem Code? Test-Pyramide (Unit/Contract/Integration)? Pass-Rate stabil?'"
    log_manual "Operator: Detail-Inhalt aus intentron/architecture-review/references/dimensions-detail.md §7 Testability ins Projekt-spezifische Dokument uebertragen"
    log_manual "Operator: pruefen ob Test-Aspekte heute unter Maintainability/Reliability vermischt sind — ggf. nach Testability migrieren (Operator-Entscheidung pro Projekt)"
    log_manual "Operator: Sanity-Test 'grep -E Testability ARCHITECTURE_DESIGN.md' → mindestens ein Treffer"
    log_manual "Operator (DoD, optional): /architecture-review auf Bestands-Projekt durchlaufen lassen — neue Dimension end-to-end validieren"
    log_manual "Operator: Details in intentron/bootstrap/references/migration-checklist-v1-to-v2.md §BOO-8"
    return 0
}

migrate_boo_13() {
    # BOO-13 — Scalability als 8. Standard-Architektur-Dimension einfuehren (Re-Scope 2026-05-08)
    # https://linear.app/owlist/issue/BOO-13
    #
    # Re-Scope-Hinweis: Issue war urspruenglich als reine Sektions-Erweiterung in
    # ARCHITECTURE_DESIGN.md mit 4 Invarianten formuliert. Beim Re-Scope wurde der Zuschnitt
    # mit BOO-8 (Testability als 7. Standard-Dimension) harmonisiert: Scalability wird als
    # 8. Standard-Architektur-Dimension verankert, inklusive 4 Pro-Invarianten und 4
    # Anti-Patterns. Quelle: architecture-review/references/dimensions-detail.md §8.
    #
    # Auto-Edit der ARCHITECTURE_DESIGN.md ist bewusst nicht implementiert: das File ist
    # projekt-spezifisch (eigene §-Nummerierung, eigene Add-ons, eigene Pruef-Fragen) und
    # ein automatisches Insert wuerde die Struktur brechen. Operator-getrieben, idempotent
    # ohne File-Operationen — analog zu migrate_boo_8.
    #
    # Stack-unabhaengig: Scalability gilt fuer alle Stacks gleichermassen — keine
    # Stack-Detection (kein package.json/pyproject.toml-Check) noetig.
    log_info "BOO-13: Scalability als 8. Standard-Architektur-Dimension einfuehren"
    log_manual "Operator: docs/ARCHITECTURE_DESIGN.md oeffnen, §3 Quality Attributes / Qualitaets-Dimensionen suchen"
    log_manual "Operator: Scalability-Zeile zwischen Testability (#7) und Cost Efficiency / Domain Quality einfuegen"
    log_manual "Operator: 4 Pro-Invarianten dokumentieren — Stateless, Horizontal-Scaling-Faehigkeit, 12-Factor, Async-Entkopplung"
    log_manual "Operator: 4 Anti-Patterns als Anti-Bullets ergaenzen (siehe architecture-review/references/dimensions-detail.md §8)"
    log_manual "Operator: pro Pro-Invariante Status (erfuellt/nicht erfuellt/n/a) + Begruendung im Bestands-Projekt eintragen"
    log_manual "Operator: Anti-Pattern-Sweep — grep -RIn 'globalThis\\.sessions|\\.lock|setInterval|node-cron|node-schedule' src/ lib/ services/ — Funde als ADR oder Backlog-Issue dokumentieren"
    log_manual "Operator: ADR docs/domain/adrs/NNN-scalability-disabled.md anlegen, falls Scalability fuer dieses Projekt bewusst deaktiviert wird (z.B. Single-User-CLI, Local-Tool ohne Skalierungs-Pfad)"
    log_manual "Operator (DoD, optional): /architecture-review --system durchlaufen lassen — der Skill prueft jetzt 8 Standard-Dimensionen, Report archivieren in journal/reports/"
    log_manual "Operator: Skill-Check — grep -E '^## §?8\\.? Scalability' .claude/skills/architecture-review/references/dimensions-detail.md → falls leer: 'git pull' im Skill-Klon oder Phase 5 von /bootstrap erneut laufen lassen (Skill v1.6.0+)"
    log_manual "Operator: Details in intentron/bootstrap/references/migration-checklist-v1-to-v2.md §BOO-13"
    return 0
}

migrate_boo_14() {
    # BOO-14 — Observability-Skelett (Logging + Metrics + Alerts) — v3.5.0 seit 2026-05-07
    # https://linear.app/owlist/issue/BOO-14
    #
    # Legt drei Files an:
    #   1. observability.md          — zentrales Skelett (Root)
    #   2. observability/alerts/.gitkeep — Verzeichnis-Marker fuer Pro-Service-Alert-Rules
    #   3. observability/.env.observability — Routing-Stub (gitignored)
    # Plus .gitignore-Eintrag fuer .env.observability (idempotent).
    #
    # Idempotenz: bestehende Files werden ge[SKIP]ped; --force ueberschreibt
    # observability.md und observability/.env.observability (NICHT die alerts/-Files
    # — die sind operator-spezifisch und stehen unter Schritt 5 der Migration-Checklist).
    log_info "BOO-14: Observability-Skelett (observability.md + alerts/ + .env.observability)"

    # Idempotenz-Quick-Check: alle drei Pfade vorhanden?
    if [[ -f "observability.md" && -d "observability/alerts" && -f "observability/.env.observability" ]]; then
        if [[ "$FORCE" != "true" ]]; then
            log_skip "BOO-14 already applied (observability.md + observability/alerts/ + .env.observability vorhanden) — use --force to overwrite"
            log_manual "Operator-Schritte: siehe migration-checklist-v1-to-v2.md §BOO-14"
            return 0
        fi
    fi

    # --- Schritt 1: observability.md (Root-Skelett) ---
    if [[ -f "observability.md" && "$FORCE" != "true" ]]; then
        log_skip "observability.md existiert (use --force to overwrite)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "observability.md" ]]; then
            log_dry "overwrite observability.md (--force) — Inhalt aus file-templates.md §observability.md"
        else
            log_dry "write observability.md (Inhalt aus file-templates.md §observability.md)"
        fi
    else
        cat > "observability.md" <<'OBS_EOF'
# Observability

DE: Zentrales Observability-Skelett (BOO-14). Drei Pflicht-Sektionen — Operator
fuellt Service-spezifische Inhalte (Komponenten aus ARCHITECTURE_DESIGN.md §4)
manuell ein.

EN: Central observability skeleton (BOO-14). Three mandatory sections — operator
fills in service-specific content (components from ARCHITECTURE_DESIGN.md §4)
manually.

## 1. Logging-Schema / Logging schema

Strukturierte JSON-Logs mit folgenden Pflicht-Feldern pro Log-Eintrag:

| Feld         | Typ      | Pflicht | Beispiel                                  |
| ------------ | -------- | ------- | ----------------------------------------- |
| `timestamp`  | ISO-8601 | ja      | `2026-05-07T08:31:14.123Z`                |
| `level`      | string   | ja      | `info` \| `warn` \| `error` \| `debug`    |
| `service`    | string   | ja      | `auth-service`                            |
| `trace_id`   | string   | ja      | `7f9b2a1c-...` (UUID v4)                  |
| `event`      | string   | ja      | `user.login.success`                      |
| `message`    | string   | ja      | menschenlesbarer Kontext                  |

Stack-Defaults:
- Node.js → `pino` (https://github.com/pinojs/pino)
- Python → `structlog` (https://www.structlog.org)

## 2. Metrics-Endpoint / Metrics endpoint

Pro Service ein `/metrics`-Endpoint im Prometheus-Format.

**Port-Konvention:** `9090 + N` — Service-Index aus der Komponenten-Reihenfolge in
ARCHITECTURE_DESIGN.md §4. Beispiel:

| Service        | Port  |
| -------------- | ----- |
| (auth-service) | 9091  |
| (api-service)  | 9092  |
| (db-service)   | 9093  |
| ...            | 9090+N|

Stack-Defaults:
- Node.js → `prom-client`
- Python → `prometheus_client`

## 3. Alert-Rules / Alert rules

Pro Service ein File `observability/alerts/<service>.yml` mit den drei
**Pflicht-Alerts**:

| Alert         | Schwellwert                  | Auswertung |
| ------------- | ---------------------------- | ---------- |
| ErrorRate     | `>5%` HTTP-5xx               | 5 min      |
| LatencyP99    | `>1s` p99 Request-Latency    | 10 min     |
| ServiceDown   | `up == 0`                    | 1 min      |

Routing der Alerts ueber `observability/.env.observability` (Telegram / Slack /
Email — nicht im Repo committed, gitignored).

Validierung lokal:
```bash
promtool check rules observability/alerts/*.yml
```

---

## Service-Sektionen (Operator fuellt)

Pro Service aus ARCHITECTURE_DESIGN.md §4 Komponenten-Uebersicht eine eigene
Sektion. Vorlage:

### Service: <name>

- **Port (`9090+N`):** _z.B. 9091_
- **Logger:** _z.B. pino (Node) / structlog (Python)_
- **Metrics-Endpoint:** _http://localhost:9091/metrics_
- **Alert-File:** `observability/alerts/<name>.yml`
- **Runbook:** _Pfad zum Runbook fuer Pager-Alerts_

> Schrader Code Crash Kap. 3 §Production Readiness §Observability + Kap. 4
> §Run the System (Saeule 3 Observability): "Wer ohne Observability deployed,
> fliegt blind."
OBS_EOF
        log_info "created observability.md"
    fi

    # --- Schritt 2: observability/alerts/-Verzeichnis (mit .gitkeep) ---
    ensure_dir "observability/alerts"
    ensure_file "observability/alerts/.gitkeep"

    # --- Schritt 3: observability/.env.observability (Routing-Stub) ---
    if [[ -f "observability/.env.observability" && "$FORCE" != "true" ]]; then
        log_skip "observability/.env.observability existiert (use --force to overwrite)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "observability/.env.observability" ]]; then
            log_dry "overwrite observability/.env.observability (--force)"
        else
            log_dry "write observability/.env.observability (Routing-Stub)"
        fi
    else
        cat > "observability/.env.observability" <<'ENV_EOF'
# observability/.env.observability — Routing-Konfiguration (BOO-14)
# DE: NICHT committen — diese Datei ist via .gitignore ausgeschlossen.
#     Echte Bot-Tokens / Webhook-URLs / SMTP-Credentials nur lokal.
#     Eine .env.observability.example (ohne Secrets) darf committed werden.
# EN: DO NOT commit — this file is excluded via .gitignore.
#     Real bot tokens / webhook URLs / SMTP credentials only locally.
#     A .env.observability.example (no secrets) may be committed.

# --- Telegram (Default-Channel laut OWLIST-Setup) ---
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=

# --- Slack ---
SLACK_WEBHOOK_URL=

# --- Email (SMTP fuer kritische Alerts) ---
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
SMTP_FROM=
SMTP_TO=
ENV_EOF
        log_info "created observability/.env.observability"
    fi

    # --- Schritt 4: .gitignore-Eintrag (idempotent) ---
    append_if_missing ".gitignore" "observability/.env.observability"

    # --- Operator-Schritte (Pflicht-Lese-Hinweis) ---
    log_manual "Operator-Schritte: siehe migration-checklist-v1-to-v2.md §BOO-14 (Schritte 2-6 + 8)"
    log_manual "Operator: Services aus ARCHITECTURE_DESIGN.md §4 in observability.md als '### Service: <name>' Sektionen anlegen"
    log_manual "Operator: Port-Konvention 9090+N pro Service vergeben (auth=9091, api=9092, ...)"
    log_manual "Operator: pro Service observability/alerts/<service>.yml mit ErrorRate/LatencyP99/ServiceDown anlegen (Vorlage in file-templates.md)"
    log_manual "Operator: Routing-Werte in observability/.env.observability eintragen (Telegram/Slack/Email)"
    log_manual "Operator (DoD): 'promtool check rules observability/alerts/*.yml' lokal validieren — falls promtool fehlt: 'brew install prometheus' (Mac) bzw. 'apt install prometheus' (VPS)"
    return 0
}

migrate_boo_16() {
    # BOO-16 — Performance-Baseline-Gate (Pre-Production-Gate) — v3.8.0 seit 2026-05-11
    # https://linear.app/owlist/issue/BOO-16
    #
    # Legt vier Artefakte an (Stack-abhaengig):
    #   1. journal/perf-baseline.json                — lebende Baseline (committed, services: [])
    #   2. bench/<service>.bench.js (Node) ODER
    #      bench/<service>_bench.py (Python)        — Pro Service Benchmark-Stub
    #   3. .github/workflows/perf.yml                — CI-Performance-Gate (Matrix aus Service-Liste)
    #   4. journal/reports/perf/.gitkeep + overrides.log (leer)
    # Plus stack-spezifische devDeps-Hinweise (autocannon / pytest-benchmark+httpx)
    # und .gitignore-Eintraege idempotent.
    #
    # Stack-Detection:
    #   - package.json vorhanden                      → Node
    #   - pyproject.toml ODER requirements.txt        → Python
    #   - beide                                       → Mixed (beide Varianten)
    #   - keines                                      → Unknown (log_warn, kein Bench-Stub)
    #
    # Service-Liste:
    #   - ENV BOO16_SERVICES="auth-service api-gateway" hat Vorrang
    #   - sonst: aus observability.md (Heading "### Service: <name>") parsen
    #   - falls beide nicht vorhanden: Default-Liste ["service"] + log_manual-Hinweis
    #
    # Idempotenz: bestehende Files werden ge[SKIP]ped; --force ueberschreibt
    # perf-baseline.json (NICHT die bench/-Files — operator-spezifisch).
    log_info "BOO-16: Performance-Baseline-Gate (perf-baseline.json + bench/ + perf.yml + overrides.log)"

    # Idempotenz-Quick-Check: Kernpfade vorhanden?
    if [[ -f "journal/perf-baseline.json" && -d "bench" && -f ".github/workflows/perf.yml" && -d "journal/reports/perf" ]]; then
        if [[ "$FORCE" != "true" ]]; then
            log_skip "BOO-16 already applied (perf-baseline.json + bench/ + perf.yml + reports/perf/ vorhanden) — use --force to overwrite"
            log_manual "Operator-Schritte: siehe migration-checklist-v1-to-v2.md §BOO-16"
            return 0
        fi
    fi

    # --- Stack-Detection ---
    local has_node="false"
    local has_python="false"
    [[ -f "package.json" ]] && has_node="true"
    [[ -f "pyproject.toml" || -f "requirements.txt" ]] && has_python="true"

    if [[ "$has_node" != "true" && "$has_python" != "true" ]]; then
        log_warn "BOO-16: weder package.json noch pyproject.toml/requirements.txt gefunden — Stack unbekannt"
        log_manual "Operator: Stack manuell festlegen oder Manifest-File ergaenzen, dann erneut '--issue BOO-16' laufen lassen"
    fi

    # --- Service-Liste ermitteln ---
    local services=()
    if [[ -n "${BOO16_SERVICES:-}" ]]; then
        # ENV-Variable schlaegt observability.md
        # shellcheck disable=SC2206
        services=( ${BOO16_SERVICES} )
        log_info "Service-Liste aus ENV BOO16_SERVICES uebernommen: ${services[*]}"
    elif [[ -f "observability.md" ]]; then
        # Parse "### Service: <name>" Headings aus observability.md (analog BOO-14)
        while IFS= read -r svc; do
            [[ -n "$svc" ]] && services+=( "$svc" )
        done < <(grep -E '^### Service:' observability.md 2>/dev/null | sed -E 's/^### Service:[[:space:]]*//; s/[[:space:]]+$//' || true)
        if [[ "${#services[@]}" -eq 0 ]]; then
            log_warn "observability.md gefunden, aber keine '### Service: <name>'-Headings — Default-Service-Liste verwenden"
            services=( "service" )
        else
            log_info "Service-Liste aus observability.md geparst: ${services[*]}"
        fi
    else
        log_warn "weder ENV BOO16_SERVICES noch observability.md gefunden — Default-Service-Liste ['service'] verwenden"
        services=( "service" )
    fi

    # --- Schritt 1: journal/perf-baseline.json (Initial leer mit services: []) ---
    if [[ -f "journal/perf-baseline.json" && "$FORCE" != "true" ]]; then
        log_skip "journal/perf-baseline.json existiert (use --force to overwrite)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "journal/perf-baseline.json" ]]; then
            log_dry "overwrite journal/perf-baseline.json (--force) — Inhalt aus file-templates.md §journal/perf-baseline.json"
        else
            log_dry "write journal/perf-baseline.json (services: [])"
        fi
    else
        ensure_dir "journal"
        cat > "journal/perf-baseline.json" <<'PERF_BASELINE_EOF'
{
  "$schema_version": 1,
  "services": []
}
PERF_BASELINE_EOF
        log_info "created journal/perf-baseline.json (services: [])"
    fi

    # --- Schritt 2: bench/<service>.bench.js (Node) bzw. <service>_bench.py (Python) ---
    ensure_dir "bench"

    # Helper: schreibt einen Bench-Stub aus Template-Heredoc mit Service-Name-Substitution
    _boo16_write_node_bench() {
        local svc_kebab="$1"
        local target="bench/${svc_kebab}.bench.js"
        if [[ -f "$target" ]]; then
            log_skip "$target existiert (operator-spezifisch — manuell loeschen wenn neu rendern)"
            return 0
        fi
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write $target (Node-Bench-Stub aus file-templates.md §bench/<service>.bench.js)"
            return 0
        fi
        cat > "$target" <<'NODE_BENCH_EOF'
// bench/{{SERVICE_NAME_KEBAB}}.bench.js
// BOO-16 Service-Benchmark — laeuft in CI ueber .github/workflows/perf.yml.
// Voraussetzung: Service laeuft auf {{PORT}} unter {{PATH}} (siehe README).

const autocannon = require('autocannon');
const fs = require('node:fs');
const path = require('node:path');
const { execSync } = require('node:child_process');

const SERVICE_NAME = '{{SERVICE_NAME_KEBAB}}';
const TARGET_URL = process.env.BENCH_URL || 'http://localhost:{{PORT}}{{PATH}}';
const CONNECTIONS = Number(process.env.BENCH_CONNECTIONS || 10);
const DURATION = Number(process.env.BENCH_DURATION || 30); // Sekunden

async function main() {
  // Warmup: 5 Sekunden, Resultat verworfen — schuetzt vor JIT-/Cache-Effekten in der Messung.
  await autocannon({ url: TARGET_URL, connections: CONNECTIONS, duration: 5 });

  const result = await autocannon({
    url: TARGET_URL,
    connections: CONNECTIONS,
    duration: DURATION,
  });

  // autocannon hat kein natives p95 — p97_5 ist die naechste verfuegbare Percentile (>=95).
  // Konservative Approximation, dokumentiert in journal/perf-baseline.json -> bench_tool: "autocannon".
  const sha = execSync('git rev-parse HEAD').toString().trim();
  const shortSha = sha.slice(0, 7);

  const report = {
    service: SERVICE_NAME,
    p50_ms: result.latency.p50,
    p95_ms: result.latency.p97_5, // Approximation, siehe Kommentar oben
    p99_ms: result.latency.p99,
    req_per_sec: result.requests.average,
    recorded_at: new Date().toISOString(),
    commit_sha: sha,
    bench_tool: 'autocannon',
  };

  const outDir = path.join('journal', 'reports', 'perf');
  fs.mkdirSync(outDir, { recursive: true });
  const outPath = path.join(outDir, `${SERVICE_NAME}-bench-${shortSha}.json`);
  fs.writeFileSync(outPath, JSON.stringify(report, null, 2));

  console.log(`[BOO-16] Bench-Report: ${outPath}`);
  console.log(JSON.stringify(report, null, 2));
}

main().catch((err) => {
  console.error('[BOO-16] Bench failed:', err);
  process.exit(1);
});
NODE_BENCH_EOF
        # Service-Name-Substitution (Platzhalter -> echter Kebab-Case-Service-Name)
        # Plattform-unabhaengig (BSD/GNU sed) via Tempfile.
        sed -e "s/{{SERVICE_NAME_KEBAB}}/${svc_kebab}/g" "$target" > "${target}.tmp" && mv "${target}.tmp" "$target"
        log_info "created $target"
    }

    _boo16_write_python_bench() {
        local svc_kebab="$1"
        # snake-case = kebab-case mit _ statt -
        local svc_snake="${svc_kebab//-/_}"
        local target="bench/${svc_snake}_bench.py"
        if [[ -f "$target" ]]; then
            log_skip "$target existiert (operator-spezifisch — manuell loeschen wenn neu rendern)"
            return 0
        fi
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write $target (Python-Bench-Stub aus file-templates.md §bench/<service>_bench.py)"
            return 0
        fi
        cat > "$target" <<'PY_BENCH_EOF'
# bench/{{SERVICE_NAME_SNAKE}}_bench.py
# BOO-16 Service-Benchmark — laeuft in CI ueber .github/workflows/perf.yml.
# Aufruf: pytest bench/ --benchmark-json=journal/reports/perf/{{SERVICE_NAME_KEBAB}}-bench.json

import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path

import httpx
import pytest

SERVICE_NAME = "{{SERVICE_NAME_KEBAB}}"
TARGET_URL = os.environ.get("BENCH_URL", "http://localhost:{{PORT}}{{PATH}}")


@pytest.fixture(scope="module")
def client():
    with httpx.Client(timeout=10.0) as c:
        # Warmup: 50 Requests, Resultat verworfen.
        for _ in range(50):
            c.get(TARGET_URL).raise_for_status()
        yield c


def test_request_latency(benchmark, client):
    """Misst Latenz pro HTTP-Call. p50 = median, p95 ueber Approximation (siehe Header)."""
    result = benchmark(lambda: client.get(TARGET_URL).raise_for_status())
    # pytest-benchmark schreibt stats automatisch via --benchmark-json.
    # Der Comparator-Step in perf.yml konvertiert stats -> p50/p95/p99 (siehe perf.yml).
    return result


# Optional: Operator-Choice B — eigene Histogram-Aufzeichnung fuer echte Quantile.
# Aktivieren durch Auskommentieren und in perf.yml den Konvertierungs-Pfad anpassen.
#
# def test_request_latency_with_histogram(client):
#     import time
#     samples_ms: list[float] = []
#     for _ in range(1000):
#         t0 = time.perf_counter()
#         client.get(TARGET_URL).raise_for_status()
#         samples_ms.append((time.perf_counter() - t0) * 1000)
#     samples_ms.sort()
#     report = _build_report(
#         p50=samples_ms[len(samples_ms) // 2],
#         p95=samples_ms[int(len(samples_ms) * 0.95)],
#         p99=samples_ms[int(len(samples_ms) * 0.99)],
#         req_per_sec=1000.0 / (sum(samples_ms) / len(samples_ms) / 1000),
#     )
#     _write_report(report, bench_tool="pytest-benchmark+histogram")


def _build_report(p50: float, p95: float, p99: float, req_per_sec: float) -> dict:
    sha = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()
    return {
        "service": SERVICE_NAME,
        "p50_ms": p50,
        "p95_ms": p95,
        "p99_ms": p99,
        "req_per_sec": req_per_sec,
        "recorded_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "commit_sha": sha,
        "bench_tool": "pytest-benchmark",
    }


def _write_report(report: dict, bench_tool: str = "pytest-benchmark") -> None:
    report["bench_tool"] = bench_tool
    out_dir = Path("journal/reports/perf")
    out_dir.mkdir(parents=True, exist_ok=True)
    short_sha = report["commit_sha"][:7]
    out_path = out_dir / f"{SERVICE_NAME}-bench-{short_sha}.json"
    out_path.write_text(json.dumps(report, indent=2))
PY_BENCH_EOF
        # Service-Name-Substitution (Snake + Kebab)
        sed -e "s/{{SERVICE_NAME_SNAKE}}/${svc_snake}/g" \
            -e "s/{{SERVICE_NAME_KEBAB}}/${svc_kebab}/g" "$target" > "${target}.tmp" && mv "${target}.tmp" "$target"
        log_info "created $target"
    }

    # Pro Service Bench-Stub anlegen
    local svc
    for svc in "${services[@]}"; do
        if [[ "$has_node" == "true" ]]; then
            _boo16_write_node_bench "$svc"
        fi
        if [[ "$has_python" == "true" ]]; then
            _boo16_write_python_bench "$svc"
        fi
    done

    # --- Schritt 3: Stack-spezifische devDeps idempotent ---
    if [[ "$has_node" == "true" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "ergaenze package.json devDependencies um 'autocannon' (via jq oder Operator)"
        elif command -v jq >/dev/null 2>&1; then
            # Idempotenz: nur wenn autocannon noch nicht in devDependencies
            if jq -e '.devDependencies.autocannon // empty' package.json >/dev/null 2>&1; then
                log_skip "package.json devDependencies enthaelt bereits 'autocannon'"
            else
                jq '.devDependencies = (.devDependencies // {}) + {"autocannon": "^7.15.0"}' package.json > package.json.tmp \
                    && mv package.json.tmp package.json
                log_info "package.json devDependencies um 'autocannon' ergaenzt — 'npm install' im Anschluss noetig"
            fi
        else
            log_warn "jq nicht gefunden — Operator: 'npm install --save-dev autocannon' manuell ausfuehren"
        fi
    fi

    if [[ "$has_python" == "true" ]]; then
        if [[ -f "pyproject.toml" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_dry "ergaenze pyproject.toml [project.optional-dependencies].test um pytest-benchmark + httpx (Operator)"
            elif grep -q 'pytest-benchmark' pyproject.toml 2>/dev/null && grep -q 'httpx' pyproject.toml 2>/dev/null; then
                log_skip "pyproject.toml enthaelt bereits pytest-benchmark + httpx"
            else
                log_manual "Operator (Python): pyproject.toml [project.optional-dependencies] um Block 'test = [\"pytest>=8\", \"pytest-benchmark>=5\", \"httpx>=0.27\"]' ergaenzen (siehe file-templates.md §bench/<service>_bench.py)"
            fi
        elif [[ -f "requirements.txt" ]]; then
            log_manual "Operator (Python, requirements.txt): 'pytest-benchmark>=5' und 'httpx>=0.27' in requirements-dev.txt (oder Test-Section) ergaenzen"
        fi
    fi

    # --- Schritt 4: .github/workflows/perf.yml mit Service-Matrix ---
    ensure_dir ".github/workflows"
    local perf_yml=".github/workflows/perf.yml"
    if [[ -f "$perf_yml" && "$FORCE" != "true" ]]; then
        log_skip "$perf_yml existiert (use --force to overwrite)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "$perf_yml" ]]; then
            log_dry "overwrite $perf_yml (--force) — Inhalt aus file-templates.md §.github/workflows/perf.yml"
        else
            log_dry "write $perf_yml (Service-Matrix: ${services[*]})"
        fi
    else
        # Service-Matrix als YAML-Liste rendern: [auth-service, api-gateway]
        local matrix_list=""
        local first="true"
        for svc in "${services[@]}"; do
            if [[ "$first" == "true" ]]; then
                matrix_list="${svc}"
                first="false"
            else
                matrix_list="${matrix_list}, ${svc}"
            fi
        done
        cat > "$perf_yml" <<'PERF_YML_EOF'
# .github/workflows/perf.yml
# BOO-16 Performance-Baseline-Gate — vergleicht aktuellen Bench-Lauf gegen
# journal/perf-baseline.json. Schwellen: <=5% PASS, 5-20% WARNING, >20% FAIL.

name: Performance

on:
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  bench:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        # Operator pflegt Service-Liste hier — synchron zu observability.md.
        service: [{{SERVICE_MATRIX}}]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # --- Prerequisite-Check (BOO-143): leere/fehlende Baseline => Benchmarks skippen, Gate gruen ---
      - name: Check prerequisites
        id: prereq
        run: |
          if [ ! -f journal/perf-baseline.json ]; then
            echo "INFO: journal/perf-baseline.json fehlt — Benchmarks werden uebersprungen (Gate gruen)."
            echo "skip=true" >> "$GITHUB_OUTPUT"
            exit 0
          fi
          SERVICES=$(python3 -c "import json; print(len(json.load(open('journal/perf-baseline.json')).get('services', [])))" 2>/dev/null || echo 0)
          if [ "$SERVICES" = "0" ]; then
            echo "INFO: Baseline noch leer (services: []) — Benchmarks uebersprungen, bis die Baseline befuellt ist (Gate gruen)."
            echo "skip=true" >> "$GITHUB_OUTPUT"
          else
            echo "skip=false" >> "$GITHUB_OUTPUT"
          fi

      # --- Stack-Setup: eines von beiden, je nach Stack-Choice (Block A) ---
      - name: Setup Node.js
        if: ${{ hashFiles('package.json') != '' }}
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Setup Python
        if: ${{ hashFiles('pyproject.toml') != '' }}
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install deps (Node)
        if: ${{ hashFiles('package.json') != '' }}
        run: npm ci

      - name: Install deps (Python)
        if: ${{ hashFiles('pyproject.toml') != '' }}
        run: pip install -e '.[test]'

      # --- Service starten — Operator passt Command pro Projekt an ---
      # Annahme: Service horcht auf Port 8080. Fuer Multi-Service-Projekte
      # pro Service einen eigenen Workflow-Job mit eigenem Port.
      - name: Start service (background)
        if: steps.prereq.outputs.skip == 'false'
        run: |
          # TODO Operator: hier den Start-Command fuer ${{ matrix.service }} eintragen.
          # Beispiele:
          #   Node:   npm run start:${{ matrix.service }} &
          #   Python: python -m {{MODULE}} &
          echo "Operator: Start-Command fuer ${{ matrix.service }} hier eintragen" && exit 1

      - name: Wait for service
        if: steps.prereq.outputs.skip == 'false'
        run: |
          for i in $(seq 1 30); do
            if curl -sf http://localhost:8080/health > /dev/null; then
              echo "Service ready"; exit 0
            fi
            sleep 1
          done
          echo "Service did not start within 30s"; exit 1

      # --- Bench laufen lassen (eines von beiden) ---
      - name: Run bench (Node)
        if: ${{ steps.prereq.outputs.skip == 'false' && hashFiles('package.json') != '' }}
        env:
          BENCH_URL: http://localhost:8080/
          BENCH_DURATION: '30'
        run: node bench/${{ matrix.service }}.bench.js

      - name: Run bench (Python)
        if: ${{ steps.prereq.outputs.skip == 'false' && hashFiles('pyproject.toml') != '' }}
        env:
          BENCH_URL: http://localhost:8080/
        run: |
          mkdir -p journal/reports/perf
          pytest bench/ \
            --benchmark-json=journal/reports/perf/${{ matrix.service }}-bench-raw.json

      # --- Comparator: Ratio current_p95 / baseline_p95 ---
      - name: Compare against baseline
        id: compare
        if: steps.prereq.outputs.skip == 'false'
        env:
          SERVICE: ${{ matrix.service }}
          PR_LABELS: ${{ toJson(github.event.pull_request.labels.*.name) }}
          COMMIT_MSG: ${{ github.event.pull_request.title }}
        run: |
          set -euo pipefail
          SHORT_SHA=$(git rev-parse --short HEAD)
          REPORT_PATH="journal/reports/perf/${SERVICE}-bench-${SHORT_SHA}.json"

          # Python-Stack: stats -> Baseline-Schema konvertieren (Operator-Choice A).
          if [ -f "journal/reports/perf/${SERVICE}-bench-raw.json" ] && [ ! -f "$REPORT_PATH" ]; then
            python3 - <<PY
          import json, subprocess
          from datetime import datetime, timezone
          raw = json.load(open("journal/reports/perf/${SERVICE}-bench-raw.json"))
          stats = raw["benchmarks"][0]["stats"]
          sha = subprocess.check_output(["git","rev-parse","HEAD"]).decode().strip()
          mean_ms = stats["mean"] * 1000
          stddev_ms = stats["stddev"] * 1000
          report = {
            "service": "${SERVICE}",
            "p50_ms": stats["median"] * 1000,
            "p95_ms": mean_ms + 1.645 * stddev_ms,
            "p99_ms": stats["max"] * 1000,
            "req_per_sec": 1000.0 / mean_ms if mean_ms > 0 else 0.0,
            "recorded_at": datetime.now(timezone.utc).isoformat().replace("+00:00","Z"),
            "commit_sha": sha,
            "bench_tool": "pytest-benchmark",
          }
          json.dump(report, open("${REPORT_PATH}","w"), indent=2)
          PY
          fi

          if [ ! -f "$REPORT_PATH" ]; then
            echo "FAIL: Bench-Report fehlt: $REPORT_PATH"; exit 1
          fi

          CURRENT=$(python3 -c "import json; print(json.load(open('$REPORT_PATH'))['p95_ms'])")
          BASELINE=$(python3 -c "
          import json, sys
          data = json.load(open('journal/perf-baseline.json'))
          for s in data.get('services', []):
              if s['service'] == '${SERVICE}':
                  print(s['p95_ms']); sys.exit(0)
          sys.exit(2)
          " || echo "MISSING")

          if [ "$BASELINE" = "MISSING" ]; then
            echo "FAIL: Baseline fuer ${SERVICE} fehlt in journal/perf-baseline.json."
            echo "Bench-Output: $REPORT_PATH — Werte manuell uebernehmen + Operator-Freigabe."
            exit 1
          fi

          RATIO=$(python3 -c "print(${CURRENT} / ${BASELINE})")
          echo "ratio=${RATIO}" >> "$GITHUB_OUTPUT"
          echo "current=${CURRENT}" >> "$GITHUB_OUTPUT"
          echo "baseline=${BASELINE}" >> "$GITHUB_OUTPUT"

          PASS=$(python3 -c "print('1' if ${RATIO} <= 1.05 else '0')")
          WARN=$(python3 -c "print('1' if ${RATIO} > 1.05 and ${RATIO} <= 1.20 else '0')")
          FAIL=$(python3 -c "print('1' if ${RATIO} > 1.20 else '0')")

          if [ "$PASS" = "1" ]; then
            echo "PASS: p95 ratio ${RATIO} (<= 1.05)"; exit 0
          fi
          if [ "$WARN" = "1" ]; then
            echo "WARNING: p95 ratio ${RATIO} (5-20% above baseline)"
            echo "outcome=warning" >> "$GITHUB_OUTPUT"
            exit 0
          fi
          # FAIL-Pfad — Override pruefen
          if echo "$PR_LABELS" | grep -q '"perf-override"' \
             || git log -1 --pretty=%B | grep -qi '^Perf-Override:'; then
            echo "FAIL overridden by operator. Logging to overrides.log."
            mkdir -p journal/reports/perf
            REASON=$(git log -1 --pretty=%B | grep -i '^Perf-Override:' | head -1 || echo "via PR label")
            echo "$(date -u +%FT%TZ) | ${SERVICE} | ratio=${RATIO} | sha=$(git rev-parse HEAD) | ${REASON}" \
              >> journal/reports/perf/overrides.log
            exit 0
          fi
          echo "FAIL: p95 ratio ${RATIO} > 1.20 (no override)"
          exit 1

      - name: Comment on PR (warning only)
        if: steps.compare.outputs.outcome == 'warning' && github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const ratio = '${{ steps.compare.outputs.ratio }}';
            const current = '${{ steps.compare.outputs.current }}';
            const baseline = '${{ steps.compare.outputs.baseline }}';
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `BOO-16 Perf-Warning: \`${{ matrix.service }}\` p95 ratio **${ratio}** ` +
                    `(current ${current} ms vs baseline ${baseline} ms). ` +
                    `Below 1.20 FAIL-Threshold but above 1.05 PASS-Threshold — review recommended.`
            });

      - name: Upload bench artifact
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: perf-bench-${{ matrix.service }}
          path: journal/reports/perf/
          retention-days: 30
PERF_YML_EOF
        # Service-Matrix substituieren
        sed -e "s/{{SERVICE_MATRIX}}/${matrix_list}/g" "$perf_yml" > "${perf_yml}.tmp" && mv "${perf_yml}.tmp" "$perf_yml"
        log_info "created $perf_yml (Service-Matrix: ${matrix_list})"
    fi

    # --- Schritt 5: journal/reports/perf/.gitkeep + overrides.log ---
    ensure_dir "journal/reports/perf"
    ensure_file "journal/reports/perf/.gitkeep"
    ensure_file "journal/reports/perf/overrides.log"

    # --- Schritt 6: .gitignore-Eintraege idempotent ---
    append_if_missing ".gitignore" "coverage/"
    append_if_missing ".gitignore" "journal/reports/perf/*.json"

    # --- Operator-Schritte (Pflicht-Lese-Hinweis) ---
    log_manual "Operator-Schritte: siehe migration-checklist-v1-to-v2.md §BOO-16"
    if [[ -f "observability.md" && -z "${BOO16_SERVICES:-}" ]]; then
        log_manual "Operator: Service-Liste manuell verifizieren — wurde aus observability.md geparst (${services[*]})"
    fi
    log_manual "Operator: ersten CI-Lauf abwarten, Artefakt 'perf-bench-<service>' herunterladen, perf-baseline.json mit p50/p95/p99/req_per_sec pro Service befuellen, committen ('BOO-16: initial baseline for <service>')"
    log_manual "Operator: Branch-Protection fuer 'Perf' Required Status Check aktivieren (oder ADR-Begruendung unter docs/domain/adrs/NNN-perf-gate-disabled.md)"
    log_manual "Operator (Node): falls jq fehlt oder devDeps nicht ergaenzt — 'npm install --save-dev autocannon' nachholen"
    log_manual "Operator (Python): 'pip install -e .[test]' nach pyproject.toml-Update — verifiziert pytest-benchmark + httpx verfuegbar"
    log_manual "Operator: Service-Start-Command in .github/workflows/perf.yml im Step 'Start service (background)' eintragen (Platzhalter exit 1 ersetzen)"
    return 0
}

migrate_boo_45() {
    # BOO-45 — Lighthouse-CI Setup-Integration (Frontend-Pendant zu BOO-16)
    # https://linear.app/owlist/issue/BOO-45
    # Aktiviert nur wenn Frontend-Anteil vorhanden — Operator-Frage statt Auto-Detect, weil
    # "package.json mit react-Eintrag" nicht zuverlaessig diskriminiert (z.B. Storybook in
    # einem reinen Backend-Repo). Operator entscheidet beim ersten Run.
    log_info "BOO-45: Lighthouse-CI fuer Frontend-Performance"

    # Idempotenz-Check
    if [[ -f "lighthouserc.json" && -f ".github/workflows/lighthouse.yml" ]]; then
        log_skip "Lighthouse-CI bereits aktiv (lighthouserc.json + lighthouse.yml existieren)"
        return 0
    fi

    # Frontend-Stack-Heuristik: package.json mit Frontend-Framework
    local has_frontend=false
    if [[ -f "package.json" ]]; then
        if grep -qE '"(react|vue|svelte|astro|next|nuxt|vite|webpack)"' package.json; then
            has_frontend=true
        fi
    fi

    if [[ "$has_frontend" != "true" ]]; then
        log_warn "BOO-45 ist Frontend-Pendant zu BOO-16 — Stack scheint Backend-only (kein React/Vue/Svelte/Astro/Next/Nuxt/Vite/Webpack in package.json)"
        log_manual "Operator: Wenn Frontend-Anteil vorhanden ist (z.B. via Drittanbieter-Hosting), 'FRONTEND_OVERRIDE=true bash migrate-to-v2.sh --issue BOO-45' setzen — sonst BOO-45 ueberspringen"
        if [[ "${FRONTEND_OVERRIDE:-false}" != "true" ]]; then
            return 0
        fi
        log_info "FRONTEND_OVERRIDE=true gesetzt — fahre mit Lighthouse-CI-Setup fort"
    fi

    # Lighthouserc anlegen
    if [[ ! -f "lighthouserc.json" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write lighthouserc.json (BOO-45 Performance-Budgets)"
        else
            cat > "lighthouserc.json" <<'LIGHTHOUSE_RC_EOF'
{
  "ci": {
    "collect": {
      "url": ["http://localhost:3000/"],
      "numberOfRuns": 3,
      "settings": {
        "preset": "desktop",
        "throttlingMethod": "simulate"
      }
    },
    "assert": {
      "preset": "lighthouse:recommended",
      "assertions": {
        "categories:performance": ["error", {"minScore": 0.9}],
        "categories:accessibility": ["error", {"minScore": 0.9}],
        "categories:best-practices": ["warn", {"minScore": 0.9}],
        "categories:seo": ["warn", {"minScore": 0.9}],
        "largest-contentful-paint": ["error", {"maxNumericValue": 2500}],
        "cumulative-layout-shift": ["error", {"maxNumericValue": 0.1}],
        "total-blocking-time": ["error", {"maxNumericValue": 300}]
      }
    },
    "upload": {
      "target": "filesystem",
      "outputDir": "journal/reports/ci/lighthouse-out"
    }
  }
}
LIGHTHOUSE_RC_EOF
            log_info "created lighthouserc.json"
        fi
    else
        log_skip "lighthouserc.json exists"
    fi

    # Workflow anlegen
    ensure_dir ".github/workflows"
    if [[ ! -f ".github/workflows/lighthouse.yml" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write .github/workflows/lighthouse.yml"
        else
            cat > ".github/workflows/lighthouse.yml" <<'LIGHTHOUSE_YML_EOF'
name: Lighthouse CI

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }

      - name: Install dependencies
        run: npm ci

      - name: Build frontend
        run: npm run build

      - name: Start preview server in background
        run: |
          npx serve -s dist -l 3000 &
          npx wait-on http://localhost:3000 --timeout 60000

      - name: Run Lighthouse CI
        run: |
          npm install -g @lhci/cli@0.14.x
          lhci autorun --config=./lighthouserc.json

      - name: Collect reports for Hermes (BOO-32)
        if: always()
        run: |
          mkdir -p journal/reports/ci/run-${{ github.run_id }}
          cp -rf journal/reports/ci/lighthouse-out/* journal/reports/ci/run-${{ github.run_id }}/ 2>/dev/null || true
          if [ -f "journal/reports/ci/lighthouse-out/manifest.json" ]; then
            cp -f journal/reports/ci/lighthouse-out/manifest.json journal/reports/ci/run-${{ github.run_id }}/lighthouse.json
          fi

      - name: Upload reports as artifact
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ci-reports-${{ github.run_id }}
          path: journal/reports/ci/run-${{ github.run_id }}/
          retention-days: 30
LIGHTHOUSE_YML_EOF
            log_info "created .github/workflows/lighthouse.yml"
        fi
    else
        log_skip ".github/workflows/lighthouse.yml exists"
    fi

    log_manual "Operator: lighthouserc.json anpassen — Frontend-URL pro Environment (preview/staging/prod), Performance-Budgets justieren (LCP/CLS/TBT), Mobile-Throttling-Profil waehlen (desktop vs. mobile)"
    log_manual "Operator: .github/workflows/lighthouse.yml Build-Command an Stack anpassen (npm run build / next build / vite build) und Preview-Server-Command (npx serve / npm run start)"
    log_manual "Operator (optional): LHCI_GITHUB_APP_TOKEN als GitHub-Secret setzen fuer Lighthouse-CI-Server-Status-Checks — sonst Filesystem-Reports"
    log_manual "Operator: nach erstem CI-Lauf den Artifact 'ci-reports-{id}' im Actions-Tab pruefen — sollte lighthouse.json + lighthouse-out/*.json enthalten"
    return 0
}

migrate_boo_46() {
    # BOO-46 — Self-Hosted-Runner + 10%-Threshold-Schaerfung fuer Performance-Gate
    # https://linear.app/owlist/issue/BOO-46
    # Folgeschnitt zu BOO-16: reservierter Runner -> weniger Varianz -> schaerferer Threshold.
    # Idempotente perf.yml-Anpassung (runs-on + Threshold). Operator macht VPS-Setup selbst.
    log_info "BOO-46: Self-Hosted-Runner + 10%-Threshold-Schaerfung"

    local perf_yml=".github/workflows/perf.yml"
    if [[ ! -f "$perf_yml" ]]; then
        log_warn "$perf_yml fehlt — BOO-16 zuerst durchlaufen (migrate_boo_16) bevor BOO-46"
        return 0
    fi

    # Idempotenz: ist runs-on schon self-hosted?
    if grep -qE '^\s*runs-on:\s*self-hosted' "$perf_yml"; then
        log_skip "perf.yml hat bereits runs-on: self-hosted"
    else
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "sed: runs-on: ubuntu-latest -> runs-on: self-hosted in $perf_yml"
        else
            # Backup
            cp -f "$perf_yml" "${perf_yml}.boo46-backup"
            sed -i '' 's/runs-on: ubuntu-latest/runs-on: self-hosted/g' "$perf_yml"
            log_info "patched runs-on: ubuntu-latest -> self-hosted (Backup: ${perf_yml}.boo46-backup)"
        fi
    fi

    # Threshold-Schaerfung: 1.20 -> 1.10 (20% -> 10%)
    if grep -qE 'ratio.*1\.10' "$perf_yml"; then
        log_skip "perf.yml hat bereits 10%-Threshold (1.10)"
    else
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "sed: 1.20 -> 1.10 (Threshold-Schaerfung) in $perf_yml"
        else
            # 20% -> 10%: alle '1.20' und '> 1.20' Vorkommen ersetzen
            sed -i '' 's/1\.20/1.10/g' "$perf_yml"
            # Auch im Comment '20%-Threshold' -> '10%-Threshold'
            sed -i '' 's/20%-Threshold/10%-Threshold/g' "$perf_yml"
            sed -i '' 's/20 %/10 %/g' "$perf_yml"
            log_info "patched Threshold 20%% -> 10%% (Self-Hosted-Runner weniger Varianz)"
        fi
    fi

    log_manual "Operator: GitHub-Actions-Runner-Software auf VPS installieren — Settings -> Actions -> Runners -> New self-hosted runner, dann './config.sh --url ... --token ...' auf VPS ausfuehren"
    log_manual "Operator: systemd-Service-Unit anlegen ('sudo ./svc.sh install' im Runner-Verzeichnis) damit Runner als Daemon laeuft"
    log_manual "Operator: Runner-Health-Check via Cron alle 6h (e.g. 'gh api repos/{owner}/{repo}/actions/runners | jq .runners[].status') — Alert bei status != 'online' > 10min"
    log_manual "Operator: nach erstem self-hosted CI-Lauf den 20%->10% Threshold validieren — bei zuviel False-Positives auf 15% justieren"
    log_manual "Operator: ggf. zweiten Runner als Failover anlegen (matrix.runs-on: [self-hosted, fallback-hosted]) — out-of-scope von BOO-46"
    return 0
}

migrate_boo_25() {
    # BOO-25 — Reliability als eigene Architektur-Dimension (Schraders 6. Saeule) — v3.7.0 seit 2026-05-07
    # https://linear.app/owlist/issue/BOO-25
    #
    # Legt vier Skelett-Files an (Stack-abhaengig):
    #   1. lib/idempotency.{js,py}     — Idempotency-Key-Middleware-Stub
    #   2. lib/retry.{js,py}           — Retry-mit-Exponential-Backoff-Helper-Stub
    #   3. lib/circuit-breaker.{js,py} — Circuit-Breaker-Wrapper-Stub
    #   4. docs/SLO.md                 — Service-Level-Objectives-Skelett (Stack-unabhaengig)
    #
    # Stack-Detection:
    #   - package.json vorhanden  → .js-Variante anlegen
    #   - pyproject.toml ODER requirements.txt vorhanden → .py-Variante anlegen
    #   - beide vorhanden (Mixed-Stack) → beide Varianten parallel
    #   - keines vorhanden (Unknown)  → log_warn + Operator-Hinweis, nur docs/SLO.md anlegen
    #
    # Idempotenz: bestehende Files werden ge[SKIP]ped; --force ueberschreibt mit
    # `.bak`-Backup. Operator-Schritte (Middleware-Wiring, .env, Tests) werden
    # NICHT automatisch ausgefuehrt — siehe migration-checklist §BOO-25.
    log_info "BOO-25: Reliability-Skelett (idempotency + retry + circuit-breaker + SLO.md)"

    local has_node="false"
    local has_python="false"
    [[ -f "package.json" ]] && has_node="true"
    [[ -f "pyproject.toml" || -f "requirements.txt" ]] && has_python="true"

    if [[ "$has_node" != "true" && "$has_python" != "true" ]]; then
        log_warn "BOO-25: weder package.json noch pyproject.toml/requirements.txt gefunden — Stack unbekannt"
        log_manual "Operator: Stack manuell festlegen oder Manifest-File ergaenzen, dann erneut '--issue BOO-25' laufen lassen"
        log_manual "BOO-25: docs/SLO.md wird trotzdem angelegt (Stack-unabhaengig)"
    fi

    # Helper: schreibt eine Skelett-Datei mit --force-Backup-Logik
    _boo25_write_skeleton() {
        local target="$1"
        local content="$2"
        if [[ -f "$target" ]]; then
            if [[ "$FORCE" != "true" ]]; then
                log_skip "$target existiert (use --force to overwrite)"
                return 0
            fi
            if [[ "$DRY_RUN" == "true" ]]; then
                log_dry "backup $target -> $target.bak; overwrite $target"
                return 0
            fi
            cp "$target" "$target.bak"
            log_info "backup created: $target.bak"
        elif [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write $target (Skelett — Inhalt aus file-templates.md §$(basename "$target"))"
            return 0
        fi
        ensure_dir "$(dirname "$target")"
        printf '%s' "$content" > "$target"
        log_info "created $target"
    }

    # --- Schritt 1a: lib/idempotency.{js,py} ---
    if [[ "$has_node" == "true" ]]; then
        _boo25_write_skeleton "lib/idempotency.js" "$(cat <<'IDEMP_JS_EOF'
// lib/idempotency.js — Idempotency-Middleware-Skelett (BOO-25)
//
// DE: Skelett. Echte Implementierung aus file-templates.md §lib/idempotency uebernehmen.
//     Cache-Backend: Redis (REDIS_URL aus .env). Pflicht-Header: Idempotency-Key.
//     Verhalten:
//       - gleicher Key + gleicher Body  -> cached Response zurueckgeben
//       - gleicher Key + anderer Body   -> HTTP 422
//       - kein Key auf POST/PUT/PATCH/DELETE -> HTTP 400 (konfigurierbar)
//
// EN: Skeleton. Replace with the implementation from file-templates.en.md §lib/idempotency.
//     Cache backend: Redis (REDIS_URL from .env). Required header: Idempotency-Key.
//
// Schrader Code Crash chap. 4 §Run the System (pillar 6 reliability) — pillar 1 idempotency.

module.exports = function idempotencyMiddleware(/* { redisClient, ttlSeconds } */) {
  return async function (req, res, next) {
    // TODO(BOO-25): Operator implementiert — siehe file-templates.md §lib/idempotency
    return next();
  };
};
IDEMP_JS_EOF
)"
    fi
    if [[ "$has_python" == "true" ]]; then
        _boo25_write_skeleton "lib/idempotency.py" "$(cat <<'IDEMP_PY_EOF'
"""lib/idempotency.py — Idempotency-Middleware-Skelett (BOO-25).

DE: Skelett. Echte Implementierung aus file-templates.md §lib/idempotency uebernehmen.
    Cache-Backend: Redis (REDIS_URL aus .env). Pflicht-Header: Idempotency-Key.
    Verhalten:
      - gleicher Key + gleicher Body  -> cached Response zurueckgeben
      - gleicher Key + anderer Body   -> HTTP 422
      - kein Key auf POST/PUT/PATCH/DELETE -> HTTP 400 (konfigurierbar)

EN: Skeleton. Replace with the implementation from file-templates.en.md §lib/idempotency.
    Cache backend: Redis (REDIS_URL from .env). Required header: Idempotency-Key.

Schrader Code Crash chap. 4 §Run the System (pillar 6 reliability) — pillar 1 idempotency.
"""
from typing import Callable


def idempotency_dependency(*_args, **_kwargs) -> Callable:
    """FastAPI Depends() target — Operator implementiert (siehe file-templates.md §lib/idempotency)."""
    # TODO(BOO-25): Operator implementiert — siehe file-templates.md §lib/idempotency
    def _noop(*_a, **_kw):
        return None
    return _noop
IDEMP_PY_EOF
)"
    fi

    # --- Schritt 1b: lib/retry.{js,py} ---
    if [[ "$has_node" == "true" ]]; then
        _boo25_write_skeleton "lib/retry.js" "$(cat <<'RETRY_JS_EOF'
// lib/retry.js — Retry-mit-Exponential-Backoff-Skelett (BOO-25)
//
// DE: Skelett. Echte Implementierung aus file-templates.md §lib/retry uebernehmen.
//     Default-Config: maxRetries=3, baseDelayMs=200, factor=2, jitter=true.
//     Status-Code-Filter: KEIN Retry bei 4xx (Client-Fehler). 5xx und Netzwerk-Fehler
//     werden retried. Idempotency-Konflikte (422) werden NICHT retried.
//
// EN: Skeleton. Replace with the implementation from file-templates.en.md §lib/retry.
//     Default config: maxRetries=3, baseDelayMs=200, factor=2, jitter=true.
//
// Schrader Code Crash chap. 4 §Run the System (pillar 6 reliability) — pillar 2 retry+backoff.

module.exports = async function withRetry(fn, /* options */) {
  // TODO(BOO-25): Operator implementiert — siehe file-templates.md §lib/retry
  return fn();
};
RETRY_JS_EOF
)"
    fi
    if [[ "$has_python" == "true" ]]; then
        _boo25_write_skeleton "lib/retry.py" "$(cat <<'RETRY_PY_EOF'
"""lib/retry.py — Retry-mit-Exponential-Backoff-Skelett (BOO-25).

DE: Skelett. Echte Implementierung aus file-templates.md §lib/retry uebernehmen.
    Default-Config: max_retries=3, base_delay=0.2, factor=2, jitter=True.
    Status-Code-Filter: KEIN Retry bei 4xx (Client-Fehler). 5xx und Netzwerk-Fehler
    werden retried. Idempotency-Konflikte (422) werden NICHT retried.

EN: Skeleton. Replace with the implementation from file-templates.en.md §lib/retry.
    Default config: max_retries=3, base_delay=0.2, factor=2, jitter=True.

Schrader Code Crash chap. 4 §Run the System (pillar 6 reliability) — pillar 2 retry+backoff.
"""
from typing import Awaitable, Callable, TypeVar

T = TypeVar("T")


async def with_retry(fn: Callable[[], Awaitable[T]], *_args, **_kwargs) -> T:
    """Operator implementiert — siehe file-templates.md §lib/retry."""
    # TODO(BOO-25): Operator implementiert — siehe file-templates.md §lib/retry
    return await fn()
RETRY_PY_EOF
)"
    fi

    # --- Schritt 1c: lib/circuit-breaker.{js,py} ---
    if [[ "$has_node" == "true" ]]; then
        _boo25_write_skeleton "lib/circuit-breaker.js" "$(cat <<'CB_JS_EOF'
// lib/circuit-breaker.js — Circuit-Breaker-Wrapper-Skelett (BOO-25)
//
// DE: Skelett. Echte Implementierung aus file-templates.md §lib/circuit-breaker uebernehmen.
//     Default-Config: errorThresholdPercentage=50, resetTimeout=30000, volumeThreshold=10.
//     Pro externer Abhaengigkeit (DB, Auth-Service, externe API, Message Bus) eine
//     eigene Breaker-Instanz konfigurieren. Schwellen pro Abhaengigkeit anpassen.
//
// EN: Skeleton. Replace with the implementation from file-templates.en.md §lib/circuit-breaker.
//     Default config: errorThresholdPercentage=50, resetTimeout=30000, volumeThreshold=10.
//
// Schrader Code Crash chap. 4 §Run the System (pillar 6 reliability) — pillar 3 circuit breaker.

module.exports = function createBreaker(fn, /* options */) {
  // TODO(BOO-25): Operator implementiert — siehe file-templates.md §lib/circuit-breaker
  return { fire: (...args) => fn(...args), getStats: () => ({}) };
};
CB_JS_EOF
)"
    fi
    if [[ "$has_python" == "true" ]]; then
        _boo25_write_skeleton "lib/circuit-breaker.py" "$(cat <<'CB_PY_EOF'
"""lib/circuit_breaker.py — Circuit-Breaker-Wrapper-Skelett (BOO-25).

DE: Skelett. Echte Implementierung aus file-templates.md §lib/circuit-breaker uebernehmen.
    Default-Config: error_threshold_percent=50, reset_timeout=30.0, volume_threshold=10.
    Pro externer Abhaengigkeit (DB, Auth-Service, externe API, Message Bus) eine
    eigene Breaker-Instanz konfigurieren. Schwellen pro Abhaengigkeit anpassen.

EN: Skeleton. Replace with the implementation from file-templates.en.md §lib/circuit-breaker.
    Default config: error_threshold_percent=50, reset_timeout=30.0, volume_threshold=10.

Schrader Code Crash chap. 4 §Run the System (pillar 6 reliability) — pillar 3 circuit breaker.
"""
from typing import Awaitable, Callable, TypeVar

T = TypeVar("T")


def create_breaker(fn: Callable[..., Awaitable[T]], *_args, **_kwargs):
    """Operator implementiert — siehe file-templates.md §lib/circuit-breaker."""
    # TODO(BOO-25): Operator implementiert — siehe file-templates.md §lib/circuit-breaker
    async def _fire(*args, **kwargs) -> T:
        return await fn(*args, **kwargs)
    return _fire
CB_PY_EOF
)"
    fi

    # --- Schritt 1d: docs/SLO.md (Stack-unabhaengig) ---
    _boo25_write_skeleton "docs/SLO.md" "$(cat <<'SLO_EOF'
# Service-Level-Objectives (SLO) — BOO-25

DE: Skelett. Operator fuellt Availability-Ziel, Error-Budget-Tabelle und SLIs aus.
    Vorlage: `bootstrap/references/file-templates.md` §`docs/SLO.md`.
EN: Skeleton. Operator fills in availability target, error-budget table and SLIs.
    Template: `bootstrap/references/file-templates.en.md` §`docs/SLO.md`.

> Schrader Code Crash Kap. 4 §Run the System (Saeule 6 Reliability) — Saeule 5
> SLO + Error-Budget. "Wer kein Error-Budget hat, weiss nicht, wann er stoppen
> muss."

## 1. Availability-Ziel / Availability target

- **Ziel / Target:** _z.B. 99.9% (drei-Neuner) — Operator entscheidet pro Service_
- **Begruendung / Rationale:** _warum genau dieses Ziel? (Kosten, Markt, Risiko)_

## 2. Error-Budget pro Quartal / Quarterly error budget

| Quartal | Budget (Minuten) | Verbraucht (Minuten) | Rest |
| ------- | ---------------- | -------------------- | ---- |
| Q?-YYYY | _berechnen_      | _0_                  | _0_  |

Berechnung: Budget = (1 - SLO) * 90 Tage * 24 h * 60 min.

## 3. SLIs / Service-Level-Indicators

Mindestens drei SLIs mit Mess-Methode (Verweis auf BOO-14-Metrics-Endpoint):

| SLI | Definition | Quelle / Source |
| --- | ---------- | --------------- |
| `error_rate` | Anteil HTTP-5xx an Gesamt-Requests | BOO-14 `/metrics` (`http_requests_total{status=~"5.."}`) |
| `p95_latency` | 95.-Perzentil Request-Dauer | BOO-14 `/metrics` (`http_request_duration_seconds`) |
| `availability` | Anteil Zeit mit `up == 1` | BOO-14 Alert-Rule `{service}_down` |

## 4. Review-Cadence / Review cadence

- Pflicht: Error-Budget-Status pro `/sprint-review`-Run pruefen.
- Bei Budget-Exhaustion: Stop-Ship-Regel — neue Features pausiert bis Budget wieder gruen.

## 5. Operator-Notizen / Operator notes

_<Platz fuer Service-spezifische Anpassungen — aktivierte Reliability-Saeulen,
ADR-Verweis auf docs/domain/adrs/NNN-reliability-pillars.md, etc.>_
SLO_EOF
)"

    # --- Operator-Schritte (Pflicht-Lese-Hinweis) ---
    log_manual "Operator-Schritte: siehe migration-checklist-v1-to-v2.md §BOO-25 (Schritte 2-8)"
    log_manual "Operator: Skelette aus lib/idempotency.{js,py} / lib/retry.{js,py} / lib/circuit-breaker.{js,py} mit Inhalten aus file-templates.md fuellen"
    log_manual "Operator: Idempotency-Middleware in Service-Entry-Point einhaengen (app.use() pro POST/PUT/PATCH/DELETE — NICHT global)"
    log_manual "Operator: REDIS_URL in .env ergaenzen (Beispielwert in .env.example committen)"
    log_manual "Operator: pro externer Abhaengigkeit (DB, Auth, externe API, Message Bus) eigenen Circuit-Breaker konfigurieren"
    log_manual "Operator: Retry-Helper auf alle Downstream-Calls anwenden — KEIN Retry bei 4xx, kein Retry bei 422 (Idempotency-Konflikt)"
    log_manual "Operator: docs/SLO.md befuellen (Availability-Ziel, Error-Budget, mindestens 3 SLIs)"
    log_manual "Operator: Tests fuer Idempotenz + Retry-Pfad ergaenzen (BOO-15 Coverage-Gate >=80% greift)"
    log_manual "Operator: docs/ARCHITECTURE_DESIGN.md §3 Quality Attributes pruefen — aktive Saeulen dokumentieren oder ADR docs/domain/adrs/NNN-reliability-pillars.md anlegen"
    return 0
}

# ---------------- Phase 4 — Intent-Propagation + KI-taugliche Architektur ----------------

migrate_boo_7() {
    # BOO-7 — KI-Tauglichkeit-Checkliste
    # https://linear.app/owlist/issue/BOO-7
    log_info "BOO-7: KI-Tauglichkeit-Checkliste in /architecture-review"
    # TODO: implementiert beim Done von BOO-7
    log_manual "Operator: implementiert beim Done von BOO-7 — Skill-Update, im Projekt nur Verweis im README"
    return 0
}

migrate_boo_10() {
    # BOO-10 — Intent-Propagation
    # https://linear.app/owlist/issue/BOO-10
    log_info "BOO-10: Intent-Propagation in Issue-/PR-Templates"
    log_manual "Operator: Issue-Template um Feld 'Intent-Referenz' erweitern (Pfad zu intents/<key>.md)"
    log_manual "Operator: PR-Template um Block 'Intent erfuellt? (Beleg via Test/ADR)' erweitern"
    return 0
}

migrate_boo_21() {
    # BOO-21 — Domainwissen ins Projekt
    # https://linear.app/owlist/issue/BOO-21
    log_info "BOO-21: docs/domain/ Verzeichnisstruktur"
    ensure_dir "docs/domain"
    ensure_dir "docs/domain/research"
    ensure_dir "docs/domain/adrs"
    if [[ ! -f "docs/domain/README.md" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write docs/domain/README.md stub"
        else
            cat > "docs/domain/README.md" <<'EOF'
# Domain Knowledge

- `research/` — Recherche-Notizen (YYYY-MM-DD-thema.md)
- `adrs/` — Domain-spezifische Architecture Decision Records (NNN-titel.md)
EOF
            log_info "created docs/domain/README.md"
        fi
    else
        log_skip "docs/domain/README.md exists"
    fi
    log_manual "Operator: Domain-ADR-Template aus bootstrap/references/file-templates.md nach docs/domain/adrs/000-template.md kopieren"
    return 0
}

migrate_boo_24() {
    # BOO-24 — 4 KI-Architektur-Prinzipien Pflicht-Block
    # https://linear.app/owlist/issue/BOO-24
    log_info "BOO-24: 4 KI-Architektur-Prinzipien + 4 Anti-Patterns Pflichtblock"
    log_manual "Operator: in docs/ARCHITECTURE_DESIGN.md §1 Pflichtblock einfuegen (Inhalt aus file-templates.md)"
    return 0
}

migrate_boo_26() {
    # BOO-26 — Anti-Pattern-Katalog
    # https://linear.app/owlist/issue/BOO-26
    log_info "BOO-26: Anti-Pattern-Katalog (Schrader Kap. 7)"
    # TODO: implementiert beim Done von BOO-26
    log_manual "Operator: implementiert beim Done von BOO-26 — Reference-Datei im Skill, im Projekt nur Verweis"
    return 0
}

migrate_boo_35() {
    # BOO-35 — /ideation: Pre-Flight-Check ARCHITECTURE_DESIGN.md
    # https://linear.app/owlist/issue/BOO-35
    log_info "BOO-35: ARCHITECTURE_DESIGN-Aktualitaets-Pre-Flight"
    # TODO: implementiert beim Done von BOO-35
    log_manual "Operator: implementiert beim Done von BOO-35 — Skill-Update"
    return 0
}

# ---------------- Phase 5 — Enterprise Governance ----------------

migrate_boo_11() {
    # BOO-11 — Issue-Writing-Guidelines
    # https://linear.app/owlist/issue/BOO-11
    log_info "BOO-11: Issue-Writing-Guidelines + Ausfuehrungsmodus"
    log_manual "Operator: docs/issue-writing-guidelines.md aus bootstrap/references/issue-writing-guidelines-template.de.md kopieren"
    log_manual "Operator: Issue-Template um Felder 'Ausfuehrungsmodus' und 'Sub-Agent-Kontext' erweitern"
    return 0
}

migrate_boo_17() {
    # BOO-17 — Feature-Flag-Konvention
    # https://linear.app/owlist/issue/BOO-17
    log_info "BOO-17: Feature-Flag-Konvention fuer AI-Code"
    # TODO: implementiert beim Done von BOO-17
    log_manual "Operator: implementiert beim Done von BOO-17 — Spec-Template um 'Rollout-Stufen' erweitern"
    return 0
}

migrate_boo_18() {
    # BOO-18 — Mandatory Human Review fuer sensible Pfade
    # https://linear.app/owlist/issue/BOO-18
    log_info "BOO-18: .claude/sensitive-paths.json"
    ensure_dir ".claude"
    if [[ ! -f ".claude/sensitive-paths.json" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write .claude/sensitive-paths.json stub"
        else
            cat > ".claude/sensitive-paths.json" <<'EOF'
{
  "paths": [
    ".env",
    "secrets/",
    "infra/terraform/",
    "migrations/"
  ],
  "policy": "manual-review-required"
}
EOF
            log_info "created .claude/sensitive-paths.json"
        fi
    else
        log_skip ".claude/sensitive-paths.json exists"
    fi
    log_manual "Operator: Pre-Commit-Hook erweitern — Hard-Stop bei Aenderung in sensiblen Pfaden"
    return 0
}

migrate_boo_19() {
    # BOO-19 — Prompt-Audit-Trail
    # https://linear.app/owlist/issue/BOO-19
    log_info "BOO-19: Prompt-Audit-Trail (Session-Logs + Spec-Referenz)"
    # TODO: implementiert beim Done von BOO-19
    log_manual "Operator: implementiert beim Done von BOO-19 — journal/sessions/ + PR-Template-Erweiterung"
    return 0
}

# ---------------- Phase 6 — Dokumentation + Rollout ----------------

migrate_boo_20() {
    # BOO-20 — HANDBUCH.md Schrader-Appendix
    # https://linear.app/owlist/issue/BOO-20
    log_info "BOO-20: HANDBUCH Schrader-Appendix (skill-only, keine Migration)"
    log_manual "Operator: Skill-interne Doku — keine Projekt-Migration"
    return 0
}

migrate_boo_37() {
    # BOO-37 — /pitch-Skill: pitch/-Dir + paths.pitches in environment.json
    # https://linear.app/owlist/issue/BOO-37
    # Skill-Source ist im Bundle (git pull); diese Migration setzt nur die Projekt-
    # seitigen Voraussetzungen: pitch/-Verzeichnis anlegen und paths.pitches in
    # .claude/environment.json sicherstellen.
    log_info "BOO-37: /pitch — pitch/-Dir + paths.pitches in environment.json"

    # 1) pitch/-Verzeichnis anlegen (idempotent), mit .gitkeep damit der leere
    #    Ordner committed werden kann. pitch/ wird NICHT gitignored — Briefings
    #    sind Teil der Projekt-Geschichte.
    ensure_dir "pitch"
    ensure_file "pitch/.gitkeep"

    # 2) intents/-Verzeichnis ebenfalls (BOO-1 Voraussetzung — wird vom Pitch-Skill
    #    als Quelle gelesen). Idempotent.
    ensure_dir "intents"
    ensure_file "intents/.gitkeep"

    # 3) paths.pitches in .claude/environment.json sicherstellen. Wenn die Datei
    #    fehlt, ueberlassen wir das BOO-34 (eigener Migrations-Schritt). Wenn sie
    #    existiert, aber den Key noch nicht hat: --force-Regen ueber den Generator
    #    empfehlen, weil der Generator in v3.23.0 die neuen Keys schreibt.
    local env_file=".claude/environment.json"
    if [[ -f "$env_file" ]]; then
        if grep -q '"pitches"' "$env_file"; then
            log_skip "$env_file enthaelt bereits paths.pitches"
        else
            if [[ "$DRY_RUN" == "true" ]]; then
                log_dry "regenerate $env_file (paths.pitches fehlt)"
            else
                log_manual "Operator: 'bash .claude/generate-environment-json.sh --force' ausfuehren, damit paths.pitches + paths.intents in environment.json landen"
            fi
        fi
    else
        log_manual "Operator: erst migrate_boo_34 ausfuehren (legt .claude/environment.json an), dann diesen Schritt wiederholen — paths.pitches kommt dann automatisch"
    fi

    return 0
}

# ---------------- Phase 7 — Hermes-Integration ----------------

migrate_boo_31() {
    # BOO-31 — metadata.hermes-Block in alle Skill-Frontmatter
    # https://linear.app/owlist/issue/BOO-31
    log_info "BOO-31: Hermes-Frontmatter in SKILL.md"
    # TODO: implementiert beim Done von BOO-31
    log_manual "Operator: implementiert beim Done von BOO-31 — Frontmatter-Aenderung in Skills, Bestands-Projekte unbetroffen"
    return 0
}

migrate_boo_32() {
    # BOO-32 — CI-Output-Standardisierung fuer Hermes
    # https://linear.app/owlist/issue/BOO-32
    # Layout: journal/reports/ci/run-{github-action-id}/{tool}.{ext}
    # Siehe HANDBUCH Anhang E "Reports-Konvention" fuer Pfad-Hierarchie + Tool-Mapping
    log_info "BOO-32: journal/reports/ Layout (ci/ + local/)"

    # Zwei Sub-Trees: ci/ (BOO-32) + local/ (BOO-36)
    ensure_dir "journal/reports/ci"
    ensure_dir "journal/reports/local"
    ensure_file "journal/reports/ci/.gitkeep"
    ensure_file "journal/reports/local/.gitkeep"

    # .gitignore idempotent ergaenzen — Reports sind kurzlebiges Signal, nicht versionieren
    if [[ -f ".gitignore" ]]; then
        if ! grep -qE "^journal/reports/?$" .gitignore; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_dry "append 'journal/reports/' to .gitignore"
            else
                echo "" >> .gitignore
                echo "# BOO-32: CI + local tool reports (Hermes-konsumiert via GitHub Actions artifacts)" >> .gitignore
                echo "journal/reports/" >> .gitignore
                log_info "appended 'journal/reports/' to .gitignore"
            fi
        else
            log_skip ".gitignore already contains journal/reports/"
        fi
    else
        log_warn ".gitignore fehlt — bitte manuell anlegen mit 'journal/reports/'"
    fi

    log_manual "Operator: pro existierendem CI-Workflow (eslint.yml/ruff.yml/semgrep.yml/perf.yml/sonar.yml) Collect+Upload-Step am Job-Ende ergaenzen — Template-Snippet in HANDBUCH Anhang E §Aggregator-Step"
    log_manual "Operator: SonarCloud-Post-Step ergaenzen, der sonarqube.json via Web-API zieht (nicht Teil der SonarSource-Action)"
    log_manual "Operator: nach erstem CI-Lauf den Artifact 'ci-reports-{id}' im Actions-Tab pruefen — sollte eslint.sarif / tests.junit.xml etc. enthalten"
    return 0
}

migrate_boo_33() {
    # BOO-33 — Hermes-Setup-Anleitung im HANDBUCH
    # https://linear.app/owlist/issue/BOO-33
    log_info "BOO-33: Hermes-Setup-Anleitung (skill-only, keine Migration)"
    log_manual "Operator: Skill-interne Doku — keine Projekt-Migration"
    return 0
}

migrate_boo_84() {
    # BOO-84 — Token-Effizienz-Policy (Modell-Routing + Prompt-Caching)
    # https://linear.app/owlist/issue/BOO-84
    log_info "BOO-84: Model-Routing-Sektion + Prompt-Caching-Hinweis in CLAUDE.md"

    if [[ ! -f "CLAUDE.md" ]]; then
        log_warn "CLAUDE.md nicht gefunden — Migration uebersprungen. Bootstrap-Skill nutzen, um CLAUDE.md anzulegen."
        return 0
    fi

    # Idempotenter Append: nur einfuegen wenn Sektion noch nicht da
    if grep -q "^## Model-Routing-Policy (BOO-84)" CLAUDE.md; then
        log_skip "CLAUDE.md enthaelt bereits 'Model-Routing-Policy (BOO-84)'"
    else
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "append Model-Routing-Policy + Prompt-Caching sections to CLAUDE.md"
        else
            cat >> CLAUDE.md <<'EOF'

## Model-Routing-Policy (BOO-84)

Pro Skill ist ein **empfohlenes Modell-Tier** definiert (siehe Skill-Frontmatter `recommended_model`). Tier-zu-Version + Pricing zentral in `bootstrap/references/model-tiers.json` von INTENTRON.

| Tier | Wofuer | Default fuer Skills |
|------|-------|---------------------|
| `haiku` | Iterations-Loops, Lints, Frage-Generierung, kleine Smoke-Tests | `/implement` Schritte 6a/6a-bis/6a-tris/6a-quart, Lint-Loops |
| `sonnet` | Sicherer Default fuer die meisten Skill-Aufgaben | `bootstrap`, `backlog`, `visualize`, `sprint-review`, `pitch`, `ideation`, `intent`, `grafana` |
| `opus` | Architektur-Reviews, Security-Findings, Threat Modeling | `architecture-review`, `cloud-system-engineer`, `/implement` Schritt 6e |

### Projekt-weite Overrides

```yaml
model_overrides:
  # Skill-Name: gewuenschtes Tier (haiku | sonnet | opus)
  # Beispiel: implement-iterations: sonnet
```

### Einmalige Overrides

CLI-Flag, z.B. `/implement --model opus`. Praezedenz: **CLI-Flag > CLAUDE.md `model_overrides:` > Skill-Default**. Audit in `meta.json` (`override_audit[]`).

### Pflicht-Bleibt-Opus

Security-relevante Skills (`architecture-review`, `cloud-system-engineer`, `/implement` Schritt 6e) duerfen pro Story-Lauf nicht automatisch downgrade-en. Operator-Override moeglich, im Audit-Trail festgehalten.

## Prompt-Caching (BOO-84)

Prompt-Caching nutzt Anthropics ephemeral cache markers fuer:

- **SKILL.md-Files** aller geladenen Skills
- `CONVENTIONS.md`, `SECURITY.md`, `ARCHITECTURE_DESIGN.md`
- Repo-Map (in `/implement` Schritt 3 erzeugt)

Constraints: Mindest-Block-Groesse 1024 Tokens, Cache TTL 5 Minuten, keine Secrets in Cache-Bloecken. Cache-Hit-Rate in `meta.json.token_tracking.cache_hit_rate`.
EOF
            log_info "CLAUDE.md um Model-Routing + Prompt-Caching Sektionen erweitert"
        fi
    fi

    log_manual "Operator: optionalen PostToolUse-Hook fuer Token-Capture aktivieren (siehe HANDBUCH Anhang N.2). Ohne Hook: meta.json.token_tracking bleibt leer, kein Story-Lauf blockiert."
    log_manual "Operator: pro Skill-Frontmatter pruefen, ob 'recommended_model:' jetzt vorhanden ist (Framework-Pull noetig fuer Bestands-Projekte)"
    return 0
}

# -----------------------------------------------------------------------------
# Aggregator / All-in-one
# -----------------------------------------------------------------------------

migrate_all() {
    log_info "DE: Starte Gesamt-Migration v1 -> v2 (idempotent)"
    log_info "EN: Starting full v1 -> v2 migration (idempotent)"

    # Phase 1
    migrate_boo_1
    migrate_boo_2

    # Phase 2
    migrate_boo_3
    migrate_boo_4
    migrate_boo_5
    migrate_boo_12
    migrate_boo_15
    migrate_boo_27
    migrate_boo_28
    migrate_boo_29
    migrate_boo_30
    migrate_boo_34
    migrate_boo_36
    migrate_boo_38
    migrate_boo_39
    migrate_boo_40

    # Phase 3
    migrate_boo_8
    migrate_boo_13
    migrate_boo_14
    migrate_boo_16
    migrate_boo_25

    # Phase 4
    migrate_boo_7
    migrate_boo_10
    migrate_boo_21
    migrate_boo_24
    migrate_boo_26
    migrate_boo_35

    # Phase 5
    migrate_boo_11
    migrate_boo_17
    migrate_boo_18
    migrate_boo_19

    # Phase 6
    migrate_boo_20
    migrate_boo_37

    # Phase 7
    migrate_boo_31
    migrate_boo_32
    migrate_boo_33

    # Wave I — Token-Efficiency (BOO-84)
    migrate_boo_84

    # Wave — Next.js-Erstlauf-Haertung (BOO-140-143): CI-Template-Bugfixes, kein Opt-in
    migrate_boo_140
    migrate_boo_141
    migrate_boo_142
    migrate_boo_143

    # Wave — CI-Hardening-Gaps (BOO-146-149): SARIF-Permissions, PROJEKT-TYP-Marker, Review-Count
    migrate_boo_146
    migrate_boo_148
    migrate_boo_149

    # Wave — Quality-Gate-Integritaet (BOO-176): Gate-Configs unter Bodyguard-Schutz
    migrate_boo_176

    # Wave — Unit-Test-Haertung (BOO-177): Anti-Platzhalter-Check fuer Test-Dateien
    migrate_boo_177

    # Wave — Doku-Definition-of-Done (BOO-180): Doku-DoD als Konvention
    migrate_boo_180

    # Wave — Financials-Aktivierung (BOO-190): Budget-Template + Worker-Equivalent-Baseline-Pointer
    migrate_boo_190

    # Wave — Claude-Code-first (BOO-199): runtime_target=claude-code-Default + Native-Pfade-Block (ADR-2)
    migrate_boo_199

    # Wave — Memory-Abgrenzung (BOO-200): Automemory-Header in MEMORY.md (ADR-3)
    migrate_boo_200

    # Sprint 6 — Status-Line (BOO-205): statusline.sh + settings.json-Verdrahtung (Schalter A)
    migrate_boo_205

    # Sprint 7+ — Doku-Drift-Checker (BOO-229): doc-drift-check.sh ins Projekt
    migrate_boo_229

    # Sprint 10 — Post-Install Optionale-Add-ons-Surfacing (BOO-248): Add-ons-Sektion in DEVELOPER_ONBOARDING.md
    migrate_boo_248

    # Sprint 10 — Codex-Reviewer AGENTS.md-Review-Guidelines (BOO-239)
    migrate_boo_239

    # Sprint 11 — CI-Spec-Gate-Workflow (BOO-254): spec-gate-ci.yml scaffolden (idempotent)
    migrate_boo_254

    log_info "DE: Migration abgeschlossen. Status pro Projekt in migration-status.md eintragen."
    log_info "EN: Migration finished. Record per-project status in migration-status.md."
}

# -----------------------------------------------------------------------------
# BOO-69 — Privacy by Design Standalone-Skill Adoption (DPO + PRIVACY.md + Hook)
# -----------------------------------------------------------------------------

migrate_boo_69() {
    log_info "BOO-69: Privacy by Design — DPO-Standalone-Skill, PRIVACY.md, personal-data-paths.json"
    log_info "BOO-69: Privacy by Design — DPO standalone skill, PRIVACY.md, personal-data-paths.json"

    # 1. PRIVACY.md aus Template rendern (idempotent — nur wenn nicht vorhanden, sonst Skip mit Hinweis)
    if [[ ! -f "PRIVACY.md" ]]; then
        # SCRIPT_DIR lokal berechnen (Script kann von beliebigem Working-Directory aufgerufen werden)
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local tmpl="${script_dir}/../references/privacy-template.md"

        if [[ -f "$tmpl" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_info "[dry-run] PRIVACY.md aus $tmpl rendern"
            else
                cp "$tmpl" PRIVACY.md
                # Platzhalter ersetzen (best-effort)
                local project_name today
                project_name="$(basename "$(pwd)")"
                today="$(date +%Y-%m-%d)"
                sed -i.bak "s|{{PROJECT_NAME}}|${project_name}|g; s|{{TODAY}}|${today}|g; s|{{VERSION_START}}|0.1.0|g" PRIVACY.md
                rm -f PRIVACY.md.bak
                log_info "PRIVACY.md erzeugt (BOO-69). Operator pflegt Verarbeitungsverzeichnis + Loeschkonzept manuell nach."
            fi
        else
            log_warn "BOO-69: privacy-template.md nicht gefunden unter $tmpl — Operator muss PRIVACY.md manuell anlegen."
        fi
    else
        log_info "BOO-69: PRIVACY.md existiert bereits — keine Aenderung."
    fi

    # 2. personal-data-paths.json (.claude und/oder .codex je nach existierender Runtime-Verzeichnisse)
    local pd_template='{
  "patterns": [
    "**/user*",
    "**/customer*",
    "**/profile*",
    "**/*pii*",
    "**/auth/profile/**",
    "**/billing/**",
    "**/onboarding/**",
    "**/consent/**",
    "**/tracking/**",
    "**/analytics/**",
    "db/migrations/*personal*",
    "db/migrations/*user*",
    "**/email-templates/**"
  ],
  "review_required_by": ["operator"],
  "privacy_review_reminder": "Diese Story berührt personenbezogene Daten — DPO REVIEW-Modus empfohlen oder manuelle Pruefung mit privacy-ok.",
  "dpo_skill_path": "~/.claude/skills/dpo/"
}'

    for runtime_dir in .claude .codex; do
        if [[ -d "$runtime_dir" ]]; then
            local target="${runtime_dir}/personal-data-paths.json"
            if [[ ! -f "$target" ]]; then
                if [[ "$DRY_RUN" == "true" ]]; then
                    log_info "[dry-run] $target erzeugen"
                else
                    printf '%s\n' "$pd_template" > "$target"
                    log_info "$target erzeugt (BOO-69). Operator ergaenzt projektspezifische Pattern."
                fi
            else
                log_info "BOO-69: $target existiert bereits — keine Aenderung."
            fi
        fi
    done

    # 3. DPO-Skill-Verfuegbarkeits-Check (rein informativ, nicht-destruktiv)
    if [[ -d "${HOME}/.claude/skills/dpo" ]]; then
        log_info "BOO-69: DPO-Skill global verfuegbar unter ~/.claude/skills/dpo/."
    else
        log_warn "BOO-69: DPO-Skill nicht unter ~/.claude/skills/dpo/ gefunden. Operator-Aktion: Skill von INTENTRON oder Skill-Repo installieren."
    fi

    # 4. security-architect-Verfuegbarkeit
    if [[ -d "${HOME}/.claude/skills/security-architect" ]]; then
        log_info "BOO-69: security-architect-Skill global verfuegbar."
    else
        log_warn "BOO-69: security-architect-Skill nicht gefunden. Operator-Aktion: Standalone-Skill installieren (Voraussetzung fuer DPO ↔ security-architect-Zusammenspiel)."
    fi

    # 5. environment.json um privacy_audit_cadence ergaenzen (idempotent, nur wenn Datei existiert und Feld fehlt)
    if [[ -f ".claude/environment.json" ]]; then
        if ! grep -q "privacy_audit_cadence" .claude/environment.json; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_info "[dry-run] .claude/environment.json um privacy_audit_cadence erweitern"
            else
                python3 -c "
import json, sys
p = '.claude/environment.json'
with open(p) as f:
    cfg = json.load(f)
cfg['privacy_audit_cadence'] = 4
with open(p, 'w') as f:
    json.dump(cfg, f, indent=2)
" && log_info ".claude/environment.json um privacy_audit_cadence (Default 4) ergaenzt."
            fi
        else
            log_info "BOO-69: privacy_audit_cadence bereits in environment.json."
        fi
    fi

    log_info "BOO-69 done. Operator-Schritte: PRIVACY.md inhaltlich fuellen, ggf. DPIA anlegen, Backlog-Label 'privacy' setzen."
}

# -----------------------------------------------------------------------------
# BOO-70 — HANDBUCH Anhang P (Deployment-Szenarien) — Wave K
# -----------------------------------------------------------------------------

migrate_boo_70() {
    log_info "BOO-70: Deployment-Szenarien — HANDBUCH Anhang P (Solo-Mac / Solo-VPS / Multi-User-VPS / Team-Server)"
    log_info "BOO-70: Deployment scenarios — HANDBUCH Appendix P (Solo-Mac / Solo-VPS / Multi-User VPS / Team server)"

    # Reines Doku-Issue: keine File-Operationen, nur Hinweis an den Operator.
    # Pure documentation issue: no file operations, operator hint only.
    log_info "BOO-70: HANDBUCH Anhang P / Appendix P ist jetzt im Framework verfuegbar."
    log_info "BOO-70: Operator-Schritte:"
    log_info "  1. HANDBUCH Anhang P (DE) bzw. Appendix P (EN) lesen — Decision-Matrix + 4 Szenarien."
    log_info "  2. Aktuelles Deployment-Szenario in 'migration-status.md' unter §BOO-70 vermerken."
    log_info "  3. Bei Szenarienwechsel (z.B. Solo-Mac -> Solo-VPS) die dort beschriebenen Setup-Schritte einmalig abarbeiten."
    log_info "BOO-70 done. Doku-only, keine Repository-Aenderung noetig."
}

# -----------------------------------------------------------------------------
# BOO-71 — Souveraenitaets-Stack + LLM-Proxy-Hook — Wave K
# -----------------------------------------------------------------------------

migrate_boo_71() {
    log_info "BOO-71: Souveraenitaets-Stack-Guide + llm_proxy_url-Hook"
    log_info "BOO-71: Sovereignty stack guide + llm_proxy_url hook"

    # environment.json um optionales Feld llm_proxy_url ergaenzen (Default null).
    # Idempotent: nur wenn Datei existiert und Feld noch fehlt.
    if [[ -f ".claude/environment.json" ]]; then
        if ! grep -q "llm_proxy_url" .claude/environment.json; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_info "[dry-run] .claude/environment.json um llm_proxy_url (Default null) erweitern"
            else
                python3 -c "
import json
p = '.claude/environment.json'
with open(p) as f:
    cfg = json.load(f)
cfg['llm_proxy_url'] = None
with open(p, 'w') as f:
    json.dump(cfg, f, indent=2)
" && log_info ".claude/environment.json um llm_proxy_url (Default null) ergaenzt."
            fi
        else
            log_info "BOO-71: llm_proxy_url bereits in environment.json."
        fi
    else
        log_warn "BOO-71: .claude/environment.json fehlt. Operator-Aktion: 'bash .claude/generate-environment-json.sh' ausfuehren (Bootstrap Phase 4.4e), danach migrate_boo_71 wiederholen."
    fi

    log_info "BOO-71: HANDBUCH Anhang Q / Appendix Q ist jetzt im Framework verfuegbar."
    log_info "BOO-71: Operator-Schritte:"
    log_info "  1. HANDBUCH Anhang Q (DE) bzw. Appendix Q (EN) lesen — Decision-Matrix + EU-Alternativen-Tabelle + LLM-Proxy-Hook."
    log_info "  2. Falls Souveraenitaets-Switch geplant: pro Komponente (Code-Hosting / Vault-Sync / LLM / Issue-Tracker / CI) Migrations-Anleitung in Anhang Q lesen und durchfuehren."
    log_info "  3. Optional: 'llm_proxy_url' in .claude/environment.json auf einen Operator-betriebenen Proxy-Endpunkt setzen (Default bleibt null = direkter LLM-Call)."
    log_info "BOO-71 done. Audit-Spur ueber 'meta.json.llm_routing' (siehe implement-Skill Schritt 0)."
}

# -----------------------------------------------------------------------------
# BOO-72 — HANDBUCH Anhang R Multi-Operator-Koordination — Wave L
# -----------------------------------------------------------------------------

migrate_boo_72() {
    log_info "BOO-72: Multi-Operator-Koordination — HANDBUCH Anhang R (3-Layer-Modell fuer 5-20+ Operatoren)"
    log_info "BOO-72: Multi-operator coordination — HANDBUCH Appendix R (3-layer model for 5-20+ operators)"

    # Reines Doku-Issue: keine File-Operationen, nur Hinweis an den Operator.
    # Pure documentation issue: no file operations, operator hint only.
    log_info "BOO-72: HANDBUCH Anhang R / Appendix R ist jetzt im Framework verfuegbar."
    log_info "BOO-72: Operator-Schritte:"
    log_info "  1. HANDBUCH Anhang R (DE) bzw. Appendix R (EN) lesen — 3-Layer-Modell + Decision-Matrix pro Team-Groesse + 10-Schritte-Setup-Anleitung."
    log_info "  2. Aktuelle Team-Groesse + Pattern-Wahl (Branch-Strategie / Team-Topologie / Doku-SSoT) in 'migration-status.md' unter §BOO-72 vermerken."
    log_info "  3. Ab 5 Operatoren: '.github/CODEOWNERS' anlegen (Beispiel im Anhang R)."
    log_info "  4. Ab 10 Operatoren: Vier-Augen-Konvention fuer 'review-ok' und 'privacy-ok' in CONVENTIONS.md dokumentieren."
    log_info "  5. Ab 10 Operatoren: Konflikt-Eskalations-Pfad in CONVENTIONS.md (3 Stufen aus Anhang R)."
    log_info "BOO-72 done. Doku-only, keine Repository-Aenderung noetig."
}

# -----------------------------------------------------------------------------
# BOO-74 — DPO + security-architect als Framework-Bundle-Skills — Wave M
# -----------------------------------------------------------------------------

migrate_boo_74() {
    log_info "BOO-74: DPO + security-architect aus Framework-Bundle nach ~/.claude/skills/ nachziehen"
    log_info "BOO-74: pull DPO + security-architect from the framework bundle into ~/.claude/skills/"

    # Idempotent + nicht-destruktiv: nur kopieren wenn Ziel-Skill noch nicht vorhanden.
    # Quelle ist das Framework-Repo selbst (dieses Skript liegt darin).
    local script_dir framework_root
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    framework_root="$(cd "${script_dir}/../.." && pwd)"

    local target_base="${HOME}/.claude/skills"
    mkdir -p "$target_base" 2>/dev/null || true

    local skill
    for skill in dpo security-architect; do
        local src="${framework_root}/${skill}"
        local dst="${target_base}/${skill}"

        if [[ ! -d "$src" ]]; then
            log_warn "BOO-74: ${skill} nicht im Framework-Repo gefunden (${src}). Vendoring unvollstaendig — bitte Repo-Stand pruefen."
            continue
        fi

        if [[ -d "$dst" ]]; then
            log_info "BOO-74: ${skill} bereits unter ${dst} vorhanden — keine Aenderung (nicht-destruktiv)."
        else
            if [[ "$DRY_RUN" == "true" ]]; then
                log_info "[dry-run] ${skill} von ${src} nach ${dst} kopieren"
            else
                cp -R "$src" "$dst" && log_info "BOO-74: ${skill} aus Framework-Bundle nach ${dst} installiert."
            fi
        fi
    done

    log_info "BOO-74: Master des Skills bleibt 'claudecodeskills' (publish_skill.py). Framework-Repo ist Vendored-Mirror."
    log_info "BOO-74 done. Bestehende Installationen bleiben unveraendert. Solo-Use via claudecodeskills weiter moeglich."
}

# -----------------------------------------------------------------------------
# BOO-75 — Vault-Harvest-Pattern (HANDBUCH Anhang R Layer 3) — Wave N
# -----------------------------------------------------------------------------

migrate_boo_75() {
    log_info "BOO-75: Vault-Harvest-Pattern — HANDBUCH Anhang R Layer 3 (Repo-Docs + persoenlicher Vault)"
    log_info "BOO-75: Vault-harvest pattern — HANDBUCH Appendix R Layer 3 (repo docs + personal vault)"

    # Reines Doku-Issue: keine File-Operationen, nur Hinweis. Engine bleibt in Stefans Repo.
    log_info "BOO-75: HANDBUCH Anhang R Layer 3 + Bootstrap Block B.3 Option [e] sind jetzt verfuegbar."
    log_info "BOO-75: Operator-Schritte:"
    log_info "  1. HANDBUCH Anhang R Layer 3 (Vault-Harvest-Pattern, 2-Fluss-Modell) lesen."
    log_info "  2. Grundsatz: Obsidian = Solo-Werkzeug. Im Team lebt die Doku im GitHub-Repo unter docs/."
    log_info "  3. Bei Team-mit-Obsidian-Nutzern: Bootstrap-Frage B.3 Option [e] waehlen (Repo-Docs + persoenlicher Vault-Harvest)."
    log_info "  4. Config-Scaffold: bootstrap/references/vault-sync-pattern.md (Team-Vertrag + local.json-Schema)."
    log_info "  5. Engine (Sync-Skript) liegt in StefanWeimarPRODOC/project-template (Phase 2 = Vendoring, separate Story)."
    log_info "BOO-75 done. Doku-only, keine Repository-Aenderung noetig."
}

# -----------------------------------------------------------------------------
# BOO-76 — Skill-Installations-Strategie (HANDBUCH Anhang S) — Wave N
# -----------------------------------------------------------------------------

migrate_boo_76() {
    log_info "BOO-76: Skill-Installations-Strategie — HANDBUCH Anhang S (wo gehoeren Skills hin)"
    log_info "BOO-76: Skill installation strategy — HANDBUCH Appendix S (where do skills belong)"

    # Reines Doku-Issue: keine File-Operationen, nur Hinweis.
    log_info "BOO-76: HANDBUCH Anhang S / Appendix S ist jetzt im Framework verfuegbar."
    log_info "BOO-76: Operator-Schritte:"
    log_info "  1. HANDBUCH Anhang S lesen — 3 Install-Ebenen (global pro User / pro Projekt / System-Pool) + Decision-Matrix."
    log_info "  2. Install-Ebene pro Deployment-Szenario waehlen: Solo → ~/.claude/skills/; Multi-User-VPS → /opt/claude/skills/ (Wartungs-Owner); Team-Server → System-Pool oder pro-Projekt."
    log_info "  3. Pro-Projekt-Pinning nur fuer audit-pflichtige oder extern uebergebene Projekte."
    log_info "  4. Multi-Tool-Teams: pro-Projekt committed ist portabler (Cross-Tool via Anhang K)."
    log_info "BOO-76 done. Doku-only, keine Repository-Aenderung noetig."
}

# -----------------------------------------------------------------------------
# BOO-77 — Framework-native Vault-Sync-Engine in Bestands-Projekt nachziehen
# -----------------------------------------------------------------------------

migrate_boo_77() {
    log_info "BOO-77: framework-native Vault-Sync-Engine — Engine-Files in bestehendes Projekt kopieren"
    log_info "BOO-77: framework-native vault-sync engine — copy engine files into an existing project"

    # Quelle: bootstrap/references/vault-sync/ im Framework-Repo (dieses Skript liegt darin).
    local script_dir framework_root src_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    framework_root="$(cd "${script_dir}/../.." && pwd)"
    src_dir="${framework_root}/bootstrap/references/vault-sync"

    if [[ ! -d "$src_dir" ]]; then
        log_warn "BOO-77: Engine-Quelle ${src_dir} nicht gefunden — Repo-Stand pruefen."
        return 1
    fi

    # Idempotent + nicht-destruktiv: nur kopieren wenn Ziel fehlt. Schreibt NICHT in den Vault.
    _copy_if_absent() {
        local src="$1" dst="$2"
        if [[ -f "$dst" ]]; then
            log_info "BOO-77: ${dst} existiert bereits — keine Aenderung."
        elif [[ "$DRY_RUN" == "true" ]]; then
            log_info "[dry-run] ${src} -> ${dst} kopieren"
        else
            mkdir -p "$(dirname "$dst")"
            cp "$src" "$dst" && log_info "BOO-77: ${dst} angelegt."
        fi
    }

    _copy_if_absent "${src_dir}/vault-sync.py"          "scripts/vault-sync.py"
    _copy_if_absent "${src_dir}/install-vault-sync.sh"  "scripts/install-vault-sync.sh"
    _copy_if_absent "${src_dir}/post-merge.sh"          ".claude/hooks/post-merge.sh"
    _copy_if_absent "${src_dir}/tracked-paths.json"     ".vault-sync/tracked-paths.json"

    # .gitignore-Eintrag fuer die persoenliche local.json sicherstellen
    if [[ "$DRY_RUN" != "true" ]] && ! grep -qxF ".vault-sync/local.json" .gitignore 2>/dev/null; then
        printf '\n# Persoenliche Vault-Harvest-Konfig (BOO-77) — nie committen\n.vault-sync/local.json\n' >> .gitignore
        log_info "BOO-77: .vault-sync/local.json in .gitignore eingetragen."
    fi

    log_info "BOO-77: Operator-Schritt: 'bash scripts/install-vault-sync.sh' pro Mitarbeiter (Default-Modus dry-run)."
    log_info "BOO-77: Sicherheit: einseitig Repo->Vault, Pfad-Containment, exit 0 ohne local.json. Im Team DocSync (D.2) = nein."
    log_info "BOO-77 done."
}

# -----------------------------------------------------------------------------
# BOO-79 — verify-setup.sh in Bestands-Projekt nachziehen (Post-Install-Verifikation)
# -----------------------------------------------------------------------------

migrate_boo_79() {
    log_info "BOO-79: Post-Install-Verifikation — verify-setup.sh ins Projekt kopieren"
    log_info "BOO-79: post-install verification — copy verify-setup.sh into the project"

    local script_dir framework_root src
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    framework_root="$(cd "${script_dir}/../.." && pwd)"
    src="${framework_root}/bootstrap/references/verify-setup.sh"

    if [[ ! -f "$src" ]]; then
        log_warn "BOO-79: ${src} nicht gefunden — Repo-Stand pruefen."
        return 1
    fi

    local dst="scripts/verify-setup.sh"
    if [[ -f "$dst" ]]; then
        log_info "BOO-79: ${dst} existiert bereits — keine Aenderung."
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_info "[dry-run] ${src} -> ${dst} kopieren + chmod +x"
    else
        mkdir -p scripts
        cp "$src" "$dst" && chmod +x "$dst" && log_info "BOO-79: ${dst} angelegt (ausfuehrbar)."
    fi

    log_info "BOO-79: Operator-Schritt: 'bash scripts/verify-setup.sh' ausfuehren — PASS/WARN/FAIL-Report."
    log_info "BOO-79: Manuelle Checkliste: HANDBUCH Anhang T. Check 5 (Skill schreibt Artefakte) bleibt manueller /implement-Probelauf."
    log_info "BOO-79 done."
}

# -----------------------------------------------------------------------------
# BOO-229 — Gemeinsamer Doku-Drift-Checker (doc-drift-check.sh ins Projekt)
# -----------------------------------------------------------------------------
migrate_boo_229() {
    log_info "BOO-229: Doku-Drift-Checker — doc-drift-check.sh ins Projekt kopieren"
    log_info "BOO-229: doc drift checker — copy doc-drift-check.sh into the project"

    local script_dir framework_root src
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    framework_root="$(cd "${script_dir}/../.." && pwd)"
    src="${framework_root}/bootstrap/references/doc-drift-check.sh"

    if [[ ! -f "$src" ]]; then
        log_warn "BOO-229: ${src} nicht gefunden — Repo-Stand pruefen."
        return 1
    fi

    local dst="scripts/doc-drift-check.sh"
    if [[ -f "$dst" ]]; then
        log_info "BOO-229: ${dst} existiert bereits — keine Aenderung."
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_info "[dry-run] ${src} -> ${dst} kopieren + chmod +x"
    else
        mkdir -p scripts
        cp "$src" "$dst" && chmod +x "$dst" && log_info "BOO-229: ${dst} angelegt (ausfuehrbar)."
    fi

    log_info "BOO-229: Operator-Schritt: 'bash scripts/doc-drift-check.sh' ausfuehren — PASS/WARN/FAIL-Report (§Referenzen/INDEX als SSoT)."
    log_info "BOO-229: /implement, /ideation, /architecture-review rufen das Skript im Pre-Flight (Standard: warn-only)."
    log_info "BOO-229 (B2): Compliance-Doku-Gate optional — 'compliance_doc_gate' in CONVENTIONS.md §3 + .claude/environment.json 'governance.compliance_doc_gate' (Default false). true = FAIL blockiert die drei Skills. SSoT = CONVENTIONS.md."
    log_manual "BOO-229 (B2): Fuer auditpflichtige Projekte 'compliance_doc_gate' in CONVENTIONS.md (Platzhalter {{COMPLIANCE_DOC_GATE}} -> true) + environment.json 'governance.compliance_doc_gate=true' setzen. Sonst nichts zu tun (Default false = bisheriges Verhalten)."
    log_info "BOO-229 done."
}

# -----------------------------------------------------------------------------
# BOO-80 — Multi-Projekt-Betrieb (HANDBUCH Anhang U) — Wave R
# -----------------------------------------------------------------------------

migrate_boo_80() {
    log_info "BOO-80: Multi-Projekt-Betrieb — HANDBUCH Anhang U (Projekt 2..N + bestehendes Projekt onboarden)"
    log_info "BOO-80: Multi-project operation — HANDBUCH Appendix U (project 2..N + onboard existing project)"

    # Reines Doku-Issue: keine File-Operationen, nur Hinweis.
    log_info "BOO-80: HANDBUCH Anhang U / Appendix U ist jetzt verfuegbar."
    log_info "BOO-80: Operator-Schritte:"
    log_info "  1. Anhang U lesen — Maschinen-Ebene (einmal) vs Projekt-Ebene (jedes Mal) + 3 Onboarding-Wege."
    log_info "  2. Projekt 2..N: Bootstrap-Schnellpfad (Block B erkennt Basis, Phase 5 Skip) — nur CLAUDE.md, Hooks (pro Repo!), environment.json, Doku-SSoT, verify-setup.sh."
    log_info "  3. Bestehendes Projekt: bootstrap Merge-Modus + 'migrate-to-v2.sh --all', dann verify-setup.sh."
    log_info "  4. Pro-Projekt-Minimal-Checkliste (Anhang U) abhaken."
    log_info "BOO-80 done. Doku-only, keine Repository-Aenderung noetig."
}

# -----------------------------------------------------------------------------
# BOO-81 — Optionales Container-Profil (.devcontainer/) in Projekt kopieren
# -----------------------------------------------------------------------------

migrate_boo_81() {
    log_info "BOO-81: optionales Container-Profil — .devcontainer/ ins Projekt kopieren (System-Install bleibt Default)"
    log_info "BOO-81: optional container profile — copy .devcontainer/ into the project (system install stays default)"

    local script_dir framework_root src
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    framework_root="$(cd "${script_dir}/../.." && pwd)"
    src="${framework_root}/bootstrap/references/devcontainer"

    if [[ ! -d "$src" ]]; then
        log_warn "BOO-81: ${src} nicht gefunden — Repo-Stand pruefen."
        return 1
    fi

    if [[ -d ".devcontainer" ]]; then
        log_info "BOO-81: .devcontainer/ existiert bereits — keine Aenderung."
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_info "[dry-run] ${src}/{Dockerfile,devcontainer.json,README.md} -> .devcontainer/"
    else
        mkdir -p .devcontainer
        cp "$src/Dockerfile" "$src/devcontainer.json" "$src/README.md" .devcontainer/ \
          && log_info "BOO-81: .devcontainer/ angelegt (Dockerfile + devcontainer.json + README.md)."
    fi

    log_info "BOO-81: OPTIONAL — nur fuer Team-Setups mit reproduzierbarer Toolchain. Solo = System-Install (Anhang S)."
    log_info "BOO-81: Nutzung: VS Code 'Reopen in Container' bzw. 'devcontainer up'. Danach 'bash scripts/verify-setup.sh'."
    log_info "BOO-81 done."
}

# -----------------------------------------------------------------------------
# BOO-86 — Layer-0 PreToolUse-Bodyguard-Hook (Security ab Erzeugung) — Wave V
# -----------------------------------------------------------------------------

migrate_boo_86() {
    # BOO-86 — Layer-0 Edit-Bodyguard: PreToolUse-Hook auf Edit|Write|MultiEdit, der
    # unsichere Muster (Secrets, eval, abgeschaltete TLS-Pruefung, SQL-Konkatenation)
    # abfaengt, BEVOR die KI sie schreibt. Geschwister-Hook zu spec-gate.sh.
    # Inhalt 1:1 aus bootstrap/references/file-templates.md §hooks/pre-edit-bodyguard.sh.
    # Idempotent + additiv: vorhandene Dateien/Registrierungen werden erkannt, das
    # Overlay (.claude/bodyguard.local.yml, Kunden-Eigentum) wird NIE ueberschrieben.
    # https://linear.app/owlist/issue/BOO-86
    log_info "BOO-86: Layer-0 Edit-Bodyguard-Hook anlegen (PreToolUse Edit|Write|MultiEdit)"

    local hooks_dir=".claude/hooks"
    local pattern_dir="$hooks_dir/bodyguard/patterns"
    local hook_script="$hooks_dir/pre-edit-bodyguard.sh"
    local overlay=".claude/bodyguard.local.yml"
    ensure_dir "$pattern_dir"

    # --- 1. Hook-Skript .claude/hooks/pre-edit-bodyguard.sh (chmod +x) ---
    if [[ -f "$hook_script" ]]; then
        log_skip "$hook_script existiert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $hook_script (Layer-0 Bodyguard, Default warn, BODYGUARD_STRICT=1 -> block)"
    else
        cat > "$hook_script" <<'BODYGUARD_HOOK_EOF'
#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  PRE-EDIT-BODYGUARD — Layer-0 Governance Hook (BOO-86)
#  Faengt unsichere Muster ab, BEVOR die KI sie schreibt.
#
#  Claude Code PreToolUse Hook (Bash) — Matcher: Edit|Write
#  Input: JSON via stdin: {"tool_input": {"file_path": "...", "content"/"new_string": "..."}}
#  Exit 1 → Tool-Call blockiert | Exit 0 → erlaubt (Default: Warnung)
#  BODYGUARD_STRICT=1 → warn-Muster werden zu block (opt-in Hard-Block)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERN_DIR="${SCRIPT_DIR}/bodyguard/patterns"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
OVERLAY="${PROJECT_ROOT}/.claude/bodyguard.local.yml"
STRICT="${BODYGUARD_STRICT:-0}"

INPUT="$(cat)"

printf '%s' "$INPUT" | python3 -c "$(cat <<'PYEOF'
import sys, json, re, os
pattern_dir, overlay, strict = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
try:
    data = json.loads(sys.stdin.read())
except Exception:
    sys.exit(0)  # nicht parsebar → nicht blockieren
ti = data.get("tool_input", {}) or {}
file_path = ti.get("file_path", "") or ""
content = ti.get("content") or ti.get("new_string") or ""
if not content and isinstance(ti.get("edits"), list):
    content = "\n".join(e.get("new_string", "") for e in ti["edits"])
if not content:
    sys.exit(0)
ext = os.path.splitext(file_path)[1].lower()
lang_map = {".js":"javascript",".mjs":"javascript",".cjs":"javascript",".ts":"javascript",
            ".tsx":"javascript",".jsx":"javascript",".py":"python",".java":"java",
            ".c":"c-cpp",".h":"c-cpp",".cpp":"c-cpp",".cc":"c-cpp",".hpp":"c-cpp"}
lang = lang_map.get(ext)
def parse_patterns(path):
    out, cur = [], None
    if not os.path.isfile(path):
        return out
    for line in open(path, encoding="utf-8"):
        s = line.rstrip("\n")
        if not s.strip() or s.lstrip().startswith("#"):
            continue
        if s.lstrip().startswith("- "):
            if cur: out.append(cur)
            cur, s = {}, s.lstrip()[2:]
        if ":" in s and cur is not None:
            k, v = s.split(":", 1)
            cur[k.strip()] = v.strip().strip("'\"")
    if cur: out.append(cur)
    return out
files = [os.path.join(pattern_dir, "_universal.yml")]
if lang: files.append(os.path.join(pattern_dir, lang + ".yml"))
files.append(overlay)  # Overlay zuletzt → uebersteuert per name
patterns, order = {}, []
for f in files:
    for p in parse_patterns(f):
        n = p.get("name")
        if not n or not p.get("pattern"): continue
        if n not in patterns: order.append(n)
        patterns[n] = p
blocks, warns = [], []
for n in order:
    p = patterns[n]
    try: rx = re.compile(p["pattern"])
    except re.error: continue
    if rx.search(content):
        action = (p.get("action") or "warn").lower()
        if strict and action == "warn": action = "block"
        msg = "  [%s] %s — %s" % (n, p.get("quelle","?"), file_path or "?")
        (blocks if action == "block" else warns).append(msg)
if warns:
    sys.stderr.write("[BODYGUARD] WARNUNG — unsichere Muster im neuen Code:\n" + "\n".join(warns) + "\n")
if blocks:
    sys.stderr.write("\n[BODYGUARD] BLOCKIERT — sicherheitskritische Muster:\n" + "\n".join(blocks) +
                     "\n  Bitte entfernen/ersetzen: Secret in env/Secret-Manager, parametrisierte Query, sichere API/TLS.\n")
    sys.exit(1)
sys.exit(0)
PYEOF
)" "$PATTERN_DIR" "$OVERLAY" "$STRICT"
BODYGUARD_HOOK_EOF
        chmod +x "$hook_script"
        log_info "created $hook_script (executable)"
    fi

    # --- 2. Muster-Kataloge bodyguard/patterns/*.yml ---
    local f="$pattern_dir/_universal.yml"
    if [[ -f "$f" ]]; then
        log_skip "$f existiert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $f (Secrets, sprachunabhaengig)"
    else
        cat > "$f" <<'UNIVERSAL_YML_EOF'
# Bodyguard Layer-0 — universelle Muster (sprachunabhaengig)
# Schema: - name / pattern / sprache / quelle / action(block|warn)
- name: aws-access-key-id
  pattern: 'AKIA[0-9A-Z]{16}'
  sprache: alle
  quelle: 'gitleaks / CWE-798'
  action: block
- name: private-key-block
  pattern: '-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----'
  sprache: alle
  quelle: 'gitleaks / CWE-321'
  action: block
- name: slack-token
  pattern: 'xox[baprs]-[0-9A-Za-z-]{10,}'
  sprache: alle
  quelle: 'gitleaks / CWE-798'
  action: block
- name: github-token
  pattern: 'gh[pousr]_[0-9A-Za-z]{36,}'
  sprache: alle
  quelle: 'gitleaks / CWE-798'
  action: block
- name: generic-secret-assignment
  pattern: '(?i)(api[_-]?key|secret|token|passwd|password)\s*[:=]\s*[\x27"][^\x27"]{8,}[\x27"]'
  sprache: alle
  quelle: 'gitleaks / CWE-798'
  action: warn
UNIVERSAL_YML_EOF
        log_info "created $f"
    fi

    f="$pattern_dir/python.yml"
    if [[ -f "$f" ]]; then
        log_skip "$f existiert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $f (python-spezifisch)"
    else
        cat > "$f" <<'PYTHON_YML_EOF'
- name: python-subprocess-shell-true
  pattern: 'subprocess\.(run|call|Popen|check_output)\([^)]*shell\s*=\s*True'
  sprache: python
  quelle: 'CWE-78 / Bandit B602'
  action: block
- name: python-requests-verify-false
  pattern: 'verify\s*=\s*False'
  sprache: python
  quelle: 'CWE-295'
  action: block
- name: python-eval
  pattern: '\beval\s*\('
  sprache: python
  quelle: 'CWE-95 / Bandit B307'
  action: warn
- name: python-yaml-load-unsafe
  pattern: 'yaml\.load\s*\((?![^)]*SafeLoader)'
  sprache: python
  quelle: 'CWE-20 / Bandit B506'
  action: warn
- name: python-sql-fstring
  pattern: '(?i)(execute|executemany)\s*\(\s*f[\x27"]'
  sprache: python
  quelle: 'CWE-89'
  action: warn
PYTHON_YML_EOF
        log_info "created $f"
    fi

    f="$pattern_dir/javascript.yml"
    if [[ -f "$f" ]]; then
        log_skip "$f existiert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $f (javascript/typescript-spezifisch)"
    else
        cat > "$f" <<'JAVASCRIPT_YML_EOF'
- name: js-tls-reject-unauthorized-false
  pattern: 'rejectUnauthorized\s*:\s*false'
  sprache: javascript
  quelle: 'CWE-295'
  action: block
- name: js-node-tls-env-0
  pattern: 'NODE_TLS_REJECT_UNAUTHORIZED\s*=\s*[\x27"]?0'
  sprache: javascript
  quelle: 'CWE-295'
  action: block
- name: js-eval
  pattern: '\beval\s*\('
  sprache: javascript
  quelle: 'CWE-95 / eslint no-eval'
  action: warn
- name: js-child-process-exec
  pattern: '(?i)child_process[\s\S]{0,20}\bexec\s*\('
  sprache: javascript
  quelle: 'CWE-78'
  action: warn
- name: js-sql-string-concat
  pattern: '(?i)(query|execute)\s*\(\s*[`\x27"][^`\x27"]*\+'
  sprache: javascript
  quelle: 'CWE-89'
  action: warn
JAVASCRIPT_YML_EOF
        log_info "created $f"
    fi

    f="$pattern_dir/java.yml"
    if [[ -f "$f" ]]; then
        log_skip "$f existiert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $f (java-spezifisch)"
    else
        cat > "$f" <<'JAVA_YML_EOF'
- name: java-runtime-exec
  pattern: 'Runtime\.getRuntime\(\)\.exec\s*\('
  sprache: java
  quelle: 'CWE-78'
  action: warn
- name: java-deserialize
  pattern: 'new\s+ObjectInputStream\s*\('
  sprache: java
  quelle: 'CWE-502'
  action: warn
- name: java-sql-concat
  pattern: '(?i)(createStatement|executeQuery)\s*\([^)]*\+'
  sprache: java
  quelle: 'CWE-89'
  action: warn
JAVA_YML_EOF
        log_info "created $f"
    fi

    f="$pattern_dir/c-cpp.yml"
    if [[ -f "$f" ]]; then
        log_skip "$f existiert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $f (c/c++-spezifisch)"
    else
        cat > "$f" <<'CCPP_YML_EOF'
- name: c-gets
  pattern: '\bgets\s*\('
  sprache: c-cpp
  quelle: 'CWE-242'
  action: block
- name: c-strcpy
  pattern: '\bstrcpy\s*\('
  sprache: c-cpp
  quelle: 'CWE-120'
  action: warn
- name: c-system
  pattern: '\bsystem\s*\('
  sprache: c-cpp
  quelle: 'CWE-78'
  action: warn
- name: c-sprintf
  pattern: '\bsprintf\s*\('
  sprache: c-cpp
  quelle: 'CWE-120'
  action: warn
CCPP_YML_EOF
        log_info "created $f"
    fi

    # --- 3. SOURCES.md (Herkunft + Pflege-Konvention) ---
    local sources="$hooks_dir/bodyguard/SOURCES.md"
    if [[ -f "$sources" ]]; then
        log_skip "$sources existiert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $sources"
    else
        cat > "$sources" <<'SOURCES_MD_EOF'
# Bodyguard-Muster — Quellen & Pflege (BOO-86)

Die Muster sind **kuratiert aus anerkannten Katalogen**, nicht erfunden. Jedes Muster
traegt im `quelle`-Feld seinen Beleg.

| Quelle | Wofuer |
|--------|--------|
| CWE (Common Weakness Enumeration) | kanonische Schwachstellen-IDs pro Muster |
| OWASP (Top 10, ASVS, Cheat Sheets) | Priorisierung/Begruendung |
| gitleaks (open source) | Secret-Muster (`_universal.yml`) |
| Semgrep Registry / Bandit / eslint-plugin-security | sprachspezifische Unsafe-Code-Muster |

## Pflege-Konvention
- **Kuratiert + klein halten** — wenige Muster mit hoher Trefferquote. Lieber 30
  wasserdichte als 300 nervige (sonst Alarm-Muedigkeit → Hook wird abgeschaltet).
- **Basis** kommt mit Framework-Versionen (dieses Template). **Projekt-Overlay**
  `.claude/bodyguard.local.yml` ist kundeneigen und ueberlebt Updates.
- Optionales `sync-bodyguard-patterns.sh` gleicht gegen Upstream ab und **schlaegt** Muster
  **vor** — Mensch entscheidet, KEIN Auto-Merge (Supply-Chain-Schutz).
- Default-Schweregrad ist `warn`; `block` nur fuer eindeutige, kontextunabhaengige Treffer
  (Secrets, abgeschaltete TLS-Pruefung, `gets`).
SOURCES_MD_EOF
        log_info "created $sources"
    fi

    # --- 4. Overlay .claude/bodyguard.local.yml — NUR wenn nicht vorhanden (Kunden-Eigentum) ---
    if [[ -f "$overlay" ]]; then
        log_skip "$overlay existiert — Kunden-Overlay wird NIE ueberschrieben"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $overlay (optionales Projekt-Overlay, Kunden-Eigentum)"
    else
        cat > "$overlay" <<'OVERLAY_YML_EOF'
# Projekt-eigene Bodyguard-Muster — uebersteuert die Framework-Basis per `name`.
# Ueberlebt Framework-Updates. Gleiches Schema wie patterns/*.yml.
# Beispiel: internen Legacy-Endpoint verbieten
# - name: no-legacy-internal-api
#   pattern: 'https?://legacy-intern\.example\.local'
#   sprache: alle
#   quelle: 'projekt-policy'
#   action: block
OVERLAY_YML_EOF
        log_info "created $overlay (Kunden-Overlay — ab jetzt nie ueberschrieben)"
    fi

    # --- 5. Matcher in settings.json UND settings.local.json registrieren (idempotent) ---
    local settings_file
    for settings_file in ".claude/settings.json" ".claude/settings.local.json"; do
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "register Edit|Write|MultiEdit-Bodyguard-Matcher in $settings_file (nur falls fehlend)"
            continue
        fi
        python3 - "$settings_file" <<'REGISTER_PYEOF'
import json, os, sys
path = sys.argv[1]
hook_cmd = "bash .claude/hooks/pre-edit-bodyguard.sh"
matcher = "Edit|Write|MultiEdit"

if os.path.isfile(path):
    try:
        with open(path, encoding="utf-8") as f:
            cfg = json.load(f)
    except Exception:
        print("[WARN]   %s ist kein gueltiges JSON — Bodyguard-Matcher NICHT registriert (Operator pruefen)." % path)
        sys.exit(0)
else:
    cfg = {}

hooks = cfg.setdefault("hooks", {})
pre = hooks.setdefault("PreToolUse", [])

# Schon registriert? (irgendein Eintrag mit unserem command)
def has_cmd(entry):
    for h in entry.get("hooks", []) or []:
        if h.get("command") == hook_cmd:
            return True
    return False

if any(has_cmd(e) for e in pre if isinstance(e, dict)):
    print("[SKIP]   %s enthaelt bereits den Bodyguard-Matcher" % path)
    sys.exit(0)

# Bestehende Bash-/andere Matcher NICHT anfassen — eigenen Edit|Write|MultiEdit-Block ergaenzen.
# Falls bereits ein Edit|Write|MultiEdit-Block existiert (z.B. anderer Hook), nur den command anhaengen.
target = None
for e in pre:
    if isinstance(e, dict) and e.get("matcher") == matcher:
        target = e
        break

if target is not None:
    target.setdefault("hooks", []).append({"type": "command", "command": hook_cmd})
else:
    pre.append({"matcher": matcher, "hooks": [{"type": "command", "command": hook_cmd}]})

with open(path, "w", encoding="utf-8") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
print("[INFO]   Bodyguard-Matcher (%s) in %s registriert" % (matcher, path))
REGISTER_PYEOF
    done

    log_manual "Operator: Default ist WARNUNG (low-false-positive). Hard-Block opt-in via 'BODYGUARD_STRICT=1'."
    log_manual "Operator: Projekt-eigene Muster in .claude/bodyguard.local.yml ergaenzen (uebersteuert Basis per name, ueberlebt Updates)."
    log_manual "Operator: Smoke-Test — Test-Secret in einer .py/.js wird abgefangen; sauberer Code laeuft durch (Exit 0)."
    log_info "BOO-86 done. Idempotent + additiv: zweiter Lauf erzeugt keine Diffs."
    return 0
}

# -----------------------------------------------------------------------------
# BOO-87 — Deterministischer dpo-Kontrollkatalog: Projekt-Overlay + Reports-Dir — Wave X
# -----------------------------------------------------------------------------

migrate_boo_87() {
    # BOO-87 — Leichtgewichtige Projekt-Migration fuer den deterministischen dpo-
    # Kontrollkatalog. Kataloge (dpo/controls/gdpr.yml + ndsg.yml) und Runner
    # (dpo/scripts/dpo-audit.py) werden MIT dem dpo-Skill (v1.2.0) verteilt und NICHT
    # pro Projekt gescaffoldet. Diese Funktion legt nur das Projekt-Overlay-Verzeichnis
    # (.claude/dpo/controls/) und das Reports-Verzeichnis (dpo/reports/) an.
    # Idempotent + additiv: vorhandene Dateien/Verzeichnisse werden NIE ueberschrieben;
    # das Kunden-Overlay ueberlebt Framework-Updates.
    # https://linear.app/owlist/issue/BOO-87
    log_info "BOO-87: dpo-Kontrollkatalog — Projekt-Overlay (.claude/dpo/controls/) + Reports-Dir (dpo/reports/) anlegen"
    log_info "BOO-87: dpo control catalog — project overlay (.claude/dpo/controls/) + reports dir (dpo/reports/)"

    local overlay_dir=".claude/dpo/controls"
    local overlay_readme="$overlay_dir/README.md"
    local reports_dir="dpo/reports"
    local reports_keep="$reports_dir/.gitkeep"

    # --- 1. Projekt-Overlay-Verzeichnis .claude/dpo/controls/ ---
    ensure_dir "$overlay_dir"

    # --- 2. Overlay-README.md (BYO-Overlay erklaeren) ---
    if [[ -f "$overlay_readme" ]]; then
        log_skip "$overlay_readme existiert (Kunden-Overlay nicht angetastet)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $overlay_readme (BYO-Overlay-Doku, flaches dpo-Schema)"
    else
        cat > "$overlay_readme" <<'OVERLAY_README_EOF'
# dpo — Projekt-Overlay (Bring Your Own Controls)

Dieses Verzeichnis (`.claude/dpo/controls/`) ist das **Projekt-Overlay** fuer den
deterministischen dpo-Kontrollkatalog. Hier ergaenzt du **projekt-eigene** Datenschutz-
Kontrollen, die der Runner `dpo-audit.py` zusaetzlich zu den Framework-Katalogen
(`dpo/controls/gdpr.yml` + `ndsg.yml`, kommen mit dem dpo-Skill) auswertet.

Dieses Overlay **ueberlebt Framework-Updates** — der Skill-Katalog wird beim Update
ersetzt, dein Overlay nie.

## Format

Dateien: `*.yml` oder `*.json` in diesem Verzeichnis. Gleiches **flaches Schema** wie
`dpo/controls/*.yml`. Eine Liste von Kontroll-Eintraegen mit folgenden Feldern:

| Feld        | Pflicht | Beschreibung                                                              |
|-------------|---------|---------------------------------------------------------------------------|
| `id`        | ja      | Eindeutige Kontroll-ID (z.B. `OV-001`).                                    |
| `titel`     | ja      | Kurztitel der Kontrolle.                                                   |
| `evidenz`   | ja      | Welcher Nachweis belegt die Kontrolle (auditor-ready Evidenz-Beschreibung).|
| `check_typ` | ja      | Einer von: `file-exists`, `file-contains`, `grep-absent`, `review`.       |
| `check_arg` | ja*     | Argument zum Check (Pfad bzw. Pfad + Muster). Bei `review` optional/leer.  |
| `mapsTo`    | nein    | Verweis auf Regulierung/Artikel (z.B. `GDPR Art. 30`, `nDSG Art. 12`).     |
| `quelle`    | nein    | Herkunft/Begruendung der Kontrolle (Policy, Interne Richtlinie, …).        |

`*` `check_arg` ist Pflicht fuer alle Check-Typen ausser `review`.

### check_typ — Semantik

- `file-exists`  — PASS, wenn die in `check_arg` genannte Datei existiert; sonst GAP.
- `file-contains`— PASS, wenn die Datei das Muster enthaelt (`check_arg`: `pfad::muster`); sonst GAP.
- `grep-absent`  — PASS, wenn das Muster **nicht** vorkommt (`check_arg`: `pfad::muster`); sonst GAP.
- `review`       — immer REVIEW-NEEDED (manuelle Pruefung durch DPO/Operator erforderlich).

## Beispiel (`overlay.yml`)

```yaml
- id: OV-001
  titel: Auftragsverarbeitungsvertrag dokumentiert
  evidenz: docs/privacy/avv-liste.md listet alle Auftragsverarbeiter mit AVV-Status.
  check_typ: file-exists
  check_arg: docs/privacy/avv-liste.md
  mapsTo: GDPR Art. 28
  quelle: Interne Datenschutz-Richtlinie §4

- id: OV-002
  titel: Keine Klartext-Personendaten in Logs
  evidenz: Quellcode enthaelt kein Logging von E-Mail/Name auf INFO-Level.
  check_typ: grep-absent
  check_arg: src/::logger.info\(.*email
  mapsTo: GDPR Art. 5 (1)(f)
  quelle: Security-Review-Befund 2026

- id: OV-003
  titel: Loeschkonzept fachlich freigegeben
  evidenz: DPO bestaetigt Loeschfristen pro Verarbeitungstaetigkeit.
  check_typ: review
  mapsTo: GDPR Art. 17
  quelle: Jaehrliches Datenschutz-Audit
```

## Audit ausfuehren

Der Runner kommt mit dem dpo-Skill (v1.2.0+), nicht aus diesem Repo:

```bash
DPO_PROJECT_ROOT=. python3 <dpo-skill>/scripts/dpo-audit.py
```

Er liest die Framework-Kataloge `dpo/controls/*.yml`, ergaenzt dieses Overlay und
schreibt den Report nach `dpo/reports/`.
OVERLAY_README_EOF
        log_info "created $overlay_readme (BOO-87, BYO-Overlay-Doku)"
    fi

    # --- 3. Reports-Verzeichnis dpo/reports/ (mit .gitkeep) ---
    ensure_dir "$reports_dir"
    ensure_file "$reports_keep"

    # --- 4. KEIN Scaffolding von Katalog/Runner/Skill — nur Operator-Hinweis ---
    log_manual "Operator: Kataloge (dpo/controls/*.yml) + Runner (dpo-audit.py) kommen MIT dem dpo-Skill (v1.2.0) — werden NICHT pro Projekt scaffolded."
    log_manual "Operator: Audit laeuft via 'DPO_PROJECT_ROOT=. python3 <dpo-skill>/scripts/dpo-audit.py' und nutzt die Framework-Kataloge dpo/controls/*.yml; Report landet in dpo/reports/."
    log_manual "Operator: Projekt-eigene Kontrollen in .claude/dpo/controls/*.yml ergaenzen (siehe README — flaches Schema, ueberlebt Framework-Updates)."

    log_info "BOO-87 done. Idempotent + additiv: zweiter Lauf erzeugt nur SKIPs, Kunden-Overlay bleibt unberuehrt."
    return 0
}

migrate_boo_91() {
    # BOO-91 — CONTEXT.md Ubiquitous Language seeden (Guidance, kein Hard-Gate)
    # https://linear.app/owlist/issue/BOO-91
    log_info "BOO-91: CONTEXT.md (Ubiquitous Language) seeden"
    local script_dir; script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local base="$script_dir/../references/context-base.md"
    local target="CONTEXT.md"
    if [[ -f "$target" ]]; then
        log_skip "$target existiert — Projekt-Overlay bleibt unberuehrt"
    elif [[ ! -f "$base" ]]; then
        log_skip "Basis fehlt ($base) — CONTEXT.md uebersprungen"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "seed $target aus context-base.md + leere Domaenen-Sektion"
    else
        {
            sed '/<!-- SEED-ENDE/d' "$base"
            printf '## Projekt-Domaene (vom Operator fuellen)\n\n'
            printf 'Projekteigene Begriffe hier ergaenzen (z.B. `Police` statt `Vertrag` im\n'
            printf 'Versicherungs-Kontext). Diese Sektion ueberlebt Framework-Updates.\n\n'
            printf '| kanonisch | verboten | quelle |\n| --- | --- | --- |\n|  |  |  |\n'
        } > "$target"
        log_info "created $target (Basis + Domaenen-Sektion)"
    fi
    log_manual "Operator: projekteigene Begriffe in CONTEXT.md unter 'Projekt-Domaene' ergaenzen."
    return 0
}

migrate_boo_92() {
    # BOO-92 — orphan-check: Work-Item-Docs (specs/, backlog-records) vom Hub-Zwang ausnehmen
    # https://linear.app/owlist/issue/BOO-92
    log_info "BOO-92: orphan-check Work-Item-Ausnahme (specs/, backlog-records)"
    local hook=".claude/hooks/orphan-check.sh"
    if [[ ! -f "$hook" ]]; then
        log_skip "$hook nicht installiert (optionaler Hub-Hook) — nichts zu patchen"
    elif grep -q 'ORPHAN_EXCLUDE' "$hook"; then
        log_skip "$hook bereits gepatcht (ORPHAN_EXCLUDE vorhanden)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "patch $hook: ORPHAN_EXCLUDE-Ausnahme in NEW_MDS einsetzen"
    else
        cp "$hook" "$hook.bak"
        local result
        result=$(python3 - "$hook" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read()
old = "NEW_MDS=$(git diff --cached --name-only --diff-filter=A | grep -E '\\.md$' || true)"
repl = ("# Work-Item-Docs haben eigene Indizes — kein Hub-Eintrag noetig (BOO-92).\n"
        "ORPHAN_EXCLUDE=\"${ORPHAN_EXCLUDE:-^(docs/project/backlog/record-.*\\.md|specs/[A-Z]+-[0-9]+\\.md)$}\"\n"
        "NEW_MDS=$(git diff --cached --name-only --diff-filter=A \\\n"
        "  | grep -E '\\.md$' \\\n"
        "  | grep -vE \"$ORPHAN_EXCLUDE\" || true)")
if old in s:
    open(p, "w").write(s.replace(old, repl, 1))
    print("patched")
else:
    print("pattern-not-found")
PYEOF
)
        if [[ "$result" == "patched" ]]; then
            log_info "patched $hook (Backup: $hook.bak)"
        else
            log_warn "$hook: NEW_MDS-Zeile nicht gefunden — manuell pruefen (Backup: $hook.bak)"
        fi
    fi
    return 0
}

migrate_boo_93() {
    # BOO-93 — optionaler Raw-PII-in-Logs-Guard (AST), opt-in, Default = Warnung
    # https://linear.app/owlist/issue/BOO-93
    log_info "BOO-93: raw-pii-guard (PII-in-Logs, optional) scaffolden"
    local script_dir; script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local src="$script_dir/../references/hooks/raw-pii-guard.py"
    local dest=".claude/hooks/raw-pii-guard.py"
    if [[ ! -f "$src" ]]; then
        log_skip "Kanonische Quelle fehlt ($src) — raw-pii-guard uebersprungen"
    elif [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
        log_skip "$dest bereits aktuell (byte-identisch zur Quelle)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "copy $src -> $dest (optionaler PII-in-Logs-Guard)"
    else
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        chmod +x "$dest"
        log_info "scaffolded $dest (optional, default = Warnung)"
    fi
    log_manual "Opt-in: raw-pii-guard in Pre-Commit/CI verdrahten (siehe hooks-setup.md). Default = Warnung; --strict fuer Hard-Block."
    return 0
}

migrate_boo_108() {
    # BOO-108 — Artefakt-Landkarte (solution-artefakte.md) fuer Bestandsprojekte seeden
    # https://linear.app/owlist/issue/BOO-108
    log_info "BOO-108: Artefakt-Landkarte (solution-artefakte.md) seeden"
    local script_dir; script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # Master-Vorlage: im Monorepo unter docs/onboarding/, optional als Skill-Mitlieferung unter bootstrap/references/
    local base=""
    local cand
    for cand in "$script_dir/../../docs/onboarding/artefakt-landkarte.md" "$script_dir/../references/artefakt-landkarte.md"; do
        if [[ -f "$cand" ]]; then base="$cand"; break; fi
    done
    local target="solution-artefakte.md"
    if [[ -f "$target" ]]; then
        log_skip "$target existiert — Operator-Instanz bleibt unberuehrt"
    elif [[ ! -f "$base" ]]; then
        log_skip "Master-Vorlage fehlt ($base) — Landkarte uebersprungen"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "seed $target aus docs/onboarding/artefakt-landkarte.md (volle Matrix, danach manuell filtern)"
    else
        cp "$base" "$target"
        log_info "created $target (volle Matrix — nicht getriggerte Zeilen manuell streichen)"
    fi
    log_manual "Operator: $target auf diese Solution filtern (Leichtgewicht-Prinzip) und mit den Abnehmer-Rollen durchgehen. EN-Master: docs/onboarding/artefakt-landkarte.en.md. Details: HANDBUCH Anhang Z."
    return 0
}

migrate_boo_140() {
    # BOO-140 — Next.js package.json lint-Script: 'next lint' -> 'eslint .'
    # https://linear.app/owlist/issue/BOO-140
    log_info "BOO-140: package.json lint-Script auf 'eslint .' umbiegen (falls 'next lint')"
    if [[ ! -f "package.json" ]]; then
        log_skip "BOO-140: kein package.json — uebersprungen"
        return 0
    fi
    if ! grep -Eq '"lint"[[:space:]]*:[[:space:]]*"next lint"' package.json; then
        log_skip "BOO-140: package.json lint-Script ist nicht 'next lint' — nichts zu tun (idempotent)"
        return 0
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "patch package.json: \"lint\": \"next lint\" -> \"eslint .\""
        return 0
    fi
    if command -v jq >/dev/null 2>&1; then
        jq '.scripts.lint = "eslint ."' package.json > package.json.tmp && mv package.json.tmp package.json
        log_info "BOO-140: package.json lint-Script auf 'eslint .' gesetzt"
    else
        log_warn "BOO-140: jq nicht gefunden — Operator: \"lint\"-Script in package.json manuell auf 'eslint .' setzen"
    fi
    log_manual "BOO-140: ESLint-v9-Flat-Config braucht 'eslint .' statt 'next lint' (Erstlauf-Fix). CI nutzt ohnehin 'npx eslint .' (BOO-28)."
    return 0
}

migrate_boo_141() {
    # BOO-141 — eslint.config.mjs: React-/Browser-Globals fuer TSX
    # https://linear.app/owlist/issue/BOO-141
    log_info "BOO-141: Frontend/React-Globals-Block in eslint.config.mjs (TSX)"
    if [[ ! -f "eslint.config.mjs" ]]; then
        log_skip "BOO-141: kein eslint.config.mjs — uebersprungen (kein Node/Frontend-Stack)"
        return 0
    fi
    # Nur relevant fuer React/Frontend (react/next in package.json ODER .tsx-Dateien vorhanden)
    local is_frontend="false"
    if [[ -f package.json ]] && grep -Eq '"(react|next)"[[:space:]]*:' package.json 2>/dev/null; then
        is_frontend="true"
    fi
    if [[ "$is_frontend" != "true" && -n "$(find . -path ./node_modules -prune -o -name '*.tsx' -print 2>/dev/null | head -1)" ]]; then
        is_frontend="true"
    fi
    if [[ "$is_frontend" != "true" ]]; then
        log_skip "BOO-141: kein React/TSX erkannt — Frontend-Globals-Block nicht noetig"
        return 0
    fi
    if grep -q "globals.browser" eslint.config.mjs 2>/dev/null; then
        log_skip "BOO-141: eslint.config.mjs hat bereits browser-Globals — nichts zu tun (idempotent)"
        return 0
    fi
    # eslint.config.mjs wird operator-gerendert — kein Auto-Patch (analog migrate_boo_2). Manueller Hinweis:
    log_manual "BOO-141: 'npm install --save-dev globals' und in eslint.config.mjs ergaenzen: 'import globals from \"globals\";' plus ein Frontend-Block:"
    log_manual "  { files: ['**/*.ts','**/*.tsx'], languageOptions: { ecmaVersion: 2022, sourceType: 'module', globals: { ...globals.browser, React: 'readonly' } }, rules: { 'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }], 'no-undef': 'error' } }"
    log_manual "  Vorlage: bootstrap/references/file-templates.md §eslint.config.mjs -> 'Mit React / Frontend (TSX)'. Sonst wirft no-undef 'React is not defined' bei jeder .tsx."
    return 0
}

migrate_boo_142() {
    # BOO-142 — Semgrep-Container raus + 'pip install semgrep' + upload-sarif@v3 -> @v4
    # https://linear.app/owlist/issue/BOO-142
    log_info "BOO-142: Semgrep-Container entfernen + upload-sarif v3->v4 in CI-Workflows"
    local wf=".github/workflows"
    if [[ ! -d "$wf" ]]; then
        log_skip "BOO-142: $wf fehlt — keine Workflows zu patchen"
        return 0
    fi
    # --- 1. semgrep.yml: container-Zeile entfernen + pip-install-Step nach checkout ---
    if [[ -f "$wf/semgrep.yml" ]]; then
        if grep -Eq '^[[:space:]]*container:' "$wf/semgrep.yml"; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_dry "patch $wf/semgrep.yml: container-Zeile entfernen + 'pip install semgrep'-Step nach checkout"
            else
                cp -f "$wf/semgrep.yml" "$wf/semgrep.yml.boo142-backup"
                sed -i '' -E '/^[[:space:]]*container:[[:space:]]*returntocorp\/semgrep[[:space:]]*$/d' "$wf/semgrep.yml"
                if ! grep -q 'pip install semgrep' "$wf/semgrep.yml"; then
                    awk '
                      /uses:[[:space:]]*actions\/checkout@v4/ && !ins {
                        print
                        print "      - name: Install Semgrep"
                        print "        run: pip install semgrep"
                        ins=1
                        next
                      }
                      { print }
                    ' "$wf/semgrep.yml" > "$wf/semgrep.yml.tmp" && mv "$wf/semgrep.yml.tmp" "$wf/semgrep.yml"
                fi
                log_info "BOO-142: $wf/semgrep.yml entcontainert + pip-install ergaenzt (Backup: semgrep.yml.boo142-backup)"
            fi
        else
            log_skip "BOO-142: $wf/semgrep.yml hat keinen Container — nichts zu tun"
        fi
    fi
    # --- 2. upload-sarif@v3 -> @v4 in allen Workflows ---
    local patched_v4="false"
    local f
    for f in "$wf"/*.yml; do
        [[ -f "$f" ]] || continue
        if grep -q 'upload-sarif@v3' "$f"; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_dry "patch $f: upload-sarif@v3 -> @v4"
            else
                sed -i '' 's|upload-sarif@v3|upload-sarif@v4|g' "$f"
                patched_v4="true"
            fi
        fi
    done
    [[ "$patched_v4" == "true" ]] && log_info "BOO-142: upload-sarif@v3 -> @v4 in CI-Workflows angehoben"
    log_manual "BOO-142: optional die 'if: always()' der upload-sarif-Steps verschaerfen zu 'if: always() && hashFiles(\"...sarif\") != \"\"' (Vorlage: file-templates.md §semgrep/eslint/ruff.yml)."
    return 0
}

migrate_boo_143() {
    # BOO-143 — perf.yml skippt bei leerer Baseline (Prerequisite-Check)
    # https://linear.app/owlist/issue/BOO-143
    log_info "BOO-143: perf.yml Prerequisite-Skip bei leerer perf-baseline.json"
    local perf_yml=".github/workflows/perf.yml"
    if [[ ! -f "$perf_yml" ]]; then
        log_skip "BOO-143: $perf_yml fehlt — kein Perf-Gate (Frontend-only nutzt Lighthouse) — uebersprungen"
        return 0
    fi
    if grep -q 'Check prerequisites' "$perf_yml"; then
        log_skip "BOO-143: $perf_yml hat bereits den Prerequisite-Skip — nichts zu tun (idempotent)"
        return 0
    fi
    # perf.yml traegt operator-spezifische Service-Matrix — kein riskanter Auto-Patch der if-Guards.
    log_warn "BOO-143: $perf_yml failt bei leerer Baseline (exit 1) — Prerequisite-Skip fehlt."
    log_manual "BOO-143: sauberster Pfad — 'migrate_boo_16 --force' regeneriert perf.yml inkl. Skip (danach Service-Matrix neu eintragen)."
    log_manual "BOO-143: alternativ manuell: 'Check prerequisites'-Step (services.length==0 -> skip=true) nach Checkout einfuegen und Start/Wait/Run-bench/Compare-Steps mit \"if: steps.prereq.outputs.skip == 'false'\" gaten. Vorlage: file-templates.md §.github/workflows/perf.yml."
    return 0
}

migrate_boo_146() {
    # BOO-146 — SARIF-Upload braucht permissions.security-events: write in CI-Workflows
    # https://linear.app/owlist/issue/BOO-146
    #
    # GitHub-Default-GITHUB_TOKEN hat seit der Hardened-Runner-Policy nur noch
    # 'contents: read' — der upload-sarif-Step der Lint-/SAST-Workflows scheitert
    # ohne expliziten permissions-Block. Diese Funktion ruestet den Block in
    # vorhandenen semgrep.yml / eslint.yml / ruff.yml nach (SSoT: file-templates.md
    # + migrate-to-v2.sh-Heredocs tragen ihn bereits fuer Neu-Renders).
    #
    # Idempotenz: grep auf "security-events: write" pro File -> vorhanden = [SKIP].
    # Fehlt der Block: vor die erste 'jobs:'-Zeile eingefuegt (via awk, !ins-Guard).
    log_info "BOO-146: permissions-Block (security-events: write) in CI-Workflows nachruesten"
    local wf=".github/workflows"
    if [[ ! -d "$wf" ]]; then
        log_skip "BOO-146: $wf fehlt — keine Workflows zu patchen"
        return 0
    fi
    local yml
    for yml in semgrep eslint ruff; do
        local f="$wf/$yml.yml"
        if [[ ! -f "$f" ]]; then
            log_skip "BOO-146: $f fehlt — uebersprungen"
            continue
        fi
        if grep -q 'security-events: write' "$f" 2>/dev/null; then
            log_skip "BOO-146: $f hat bereits permissions.security-events: write — nichts zu tun (idempotent)"
            continue
        fi
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "patch $f: permissions-Block (contents: read / security-events: write) vor erster 'jobs:'-Zeile einfuegen"
            continue
        fi
        # permissions-Block vor die erste 'jobs:'-Zeile einfuegen (awk, !ins-Guard analog BOO-142)
        awk '
          /^jobs:[[:space:]]*$/ && !ins {
            print "permissions:"
            print "  contents: read"
            print "  security-events: write"
            print ""
            print
            ins=1
            next
          }
          { print }
        ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
        log_info "BOO-146: permissions-Block in $f vor 'jobs:' eingefuegt"
    done
    log_manual "BOO-146: SARIF-Upload (github/codeql-action/upload-sarif) braucht 'security-events: write' — ohne den Block scheitert der CI-Step still. Vorlage: file-templates.md §semgrep/eslint/ruff.yml."
    return 0
}

migrate_boo_148() {
    # BOO-148 — CLAUDE.md PROJEKT-TYP-Marker (AKTIV/GOVERNANCE-REFERENZ) als erste Zeile nach H1
    # https://linear.app/owlist/issue/BOO-148
    #
    # Der PROJEKT-TYP-Marker steuert, ob Deployment-/CI-Gates fuer das Repo
    # greifen. Default 'AKTIV' (Code + Deployment im Repo). Bestands-Projekte
    # ziehen den Marker als erste Zeile nach dem H1-Titel der CLAUDE.md nach.
    #
    # Idempotenz: grep auf "PROJEKT-TYP:" -> vorhanden = [SKIP].
    # Fehlt der Marker: nach der ersten H1-Zeile (^# ) eingefuegt (via awk, !ins-Guard).
    log_info "BOO-148: PROJEKT-TYP-Marker in CLAUDE.md nachruesten (Default: AKTIV)"
    local claude_md="CLAUDE.md"
    if [[ ! -f "$claude_md" ]]; then
        log_skip "BOO-148: $claude_md fehlt — uebersprungen"
        return 0
    fi
    if grep -q 'PROJEKT-TYP:' "$claude_md" 2>/dev/null; then
        log_skip "BOO-148: $claude_md hat bereits einen PROJEKT-TYP-Marker — nichts zu tun (idempotent)"
        return 0
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "patch $claude_md: PROJEKT-TYP-Marker (AKTIV) als erste Zeile nach H1-Titel einfuegen"
        return 0
    fi
    # Marker nach der ersten H1-Zeile (^# ) einfuegen (awk, !ins-Guard)
    awk '
      /^# / && !ins {
        print
        print ""
        print "> **PROJEKT-TYP: AKTIV** — Code + Deployment in diesem Repo"
        ins=1
        next
      }
      { print }
    ' "$claude_md" > "$claude_md.tmp" && mv "$claude_md.tmp" "$claude_md"
    log_info "BOO-148: PROJEKT-TYP-Marker (AKTIV) in $claude_md nach H1 eingefuegt"
    log_manual "BOO-148: bei reinen Doku-/Spec-Repos ohne Deployment den Marker manuell auf 'PROJEKT-TYP: GOVERNANCE-REFERENZ' setzen — dann greifen Deployment-Gates nicht."
    return 0
}

migrate_boo_149() {
    # BOO-149 — Branch-Protection erneut anwenden (required_approving_review_count 1->0)
    # https://linear.app/owlist/issue/BOO-149
    #
    # Der Review-Count wurde in setup-branch-protection.sh von 1 auf 0 gesenkt
    # (Solo-/Agent-Flow hat keine Fremd-Approval; GitHub erlaubt keine
    # Self-Approval). Status-Checks bleiben Pflicht. Bestands-Projekte ziehen
    # den neuen Wert nach, indem die Branch-Protection erneut gesetzt wird.
    #
    # Eigentliche Logik in scripts/setup-branch-protection.sh — diese Funktion
    # ist Wrapper analog migrate_boo_29 (gleiche Voraussetzungs-Checks + Dispatch).
    #
    # Idempotenz: PUT-Call ist Replace — re-run-safe, count=0 wird durch Re-Run wirksam.
    log_info "BOO-149: Branch-Protection erneut anwenden (Review-Count 1->0)"

    # --- Voraussetzungs-Check 1: gh CLI installiert? ---
    if ! command -v gh >/dev/null 2>&1; then
        log_warn "gh CLI nicht gefunden — BOO-149 uebersprungen"
        log_manual "Operator: 'brew install gh' (Mac) oder https://cli.github.com/ — danach erneut '--issue BOO-149' laufen lassen"
        return 0
    fi

    # --- Voraussetzungs-Check 2: gh auth status — eingeloggt? ---
    if ! gh auth status >/dev/null 2>&1; then
        log_warn "gh CLI nicht eingeloggt — BOO-149 uebersprungen"
        log_manual "Operator: 'gh auth login' ausfuehren (Browser-Flow oder Token mit 'repo'-Scope), danach erneut '--issue BOO-149' laufen lassen"
        return 0
    fi

    # --- Voraussetzungs-Check 3: Remote 'origin' vorhanden? ---
    if ! git remote get-url origin >/dev/null 2>&1; then
        log_warn "Kein git remote 'origin' im aktuellen Repo — BOO-149 uebersprungen"
        log_manual "Operator: 'git remote add origin git@github.com:<owner>/<repo>.git' und 'git push -u origin main' laufen lassen, dann erneut '--issue BOO-149'"
        return 0
    fi

    # --- Skript-Pfad finden — neben migrate-to-v2.sh im selben Verzeichnis ---
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local bp_script="$script_dir/setup-branch-protection.sh"

    if [[ ! -f "$bp_script" ]]; then
        log_warn "setup-branch-protection.sh nicht gefunden unter $bp_script — BOO-149 uebersprungen"
        log_manual "Operator: scripts/setup-branch-protection.sh aus dem Bootstrap-Repo (intentron/bootstrap/scripts/) ins Projekt kopieren und dann erneut laufen lassen"
        return 0
    fi

    # --- Dispatch: Dry-Run vs. echter Lauf ---
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "bash $bp_script --dry-run (Branch-Protection erneut setzen, Review-Count=0)"
    else
        log_info "Rufe $bp_script auf — Branch-Protection wird erneut gesetzt (Review-Count=0)"
        if bash "$bp_script"; then
            log_info "Branch-Protection erfolgreich erneut gesetzt (Review-Count=0)"
        else
            log_warn "setup-branch-protection.sh fehlgeschlagen — Operator-Schritte unten beachten"
            log_manual "Operator: bash $bp_script manuell ausfuehren und Fehlerausgabe pruefen (Permissions? main remote? Free-Plan-Limit?)"
        fi
    fi

    log_manual "Operator: in GitHub-UI verifizieren (Settings -> Branches -> main) — 'Require approvals' sollte auf 0 stehen, Status-Checks weiter Pflicht"
    return 0
}

migrate_boo_176() {
    # BOO-176 — Quality-Gate-Integritaet: Gate-Configs unter Bodyguard-Schutz
    # https://linear.app/owlist/issue/BOO-176
    #
    # Der Agent darf die Qualitaets-Messlatte nicht selbst absenken (PHPStan-Level
    # runter, Coverage-Schwelle senken, Linter-Regeln deaktivieren). Diese Funktion
    # ruestet Bestandsprojekte nach:
    #   (1) Gate-Config-Pfade in .claude/sensitive-paths.json -> Aenderung loest
    #       Gate-Block-Pause (Operator-Freigabe) aus (gleiche Mechanik wie BOO-86).
    #   (2) bodyguard/patterns/gate-configs.yml -> Muster fuer Regel-Deaktivierung
    #       (bare eslint-disable, @ts-nocheck, nacktes # noqa / # type: ignore,
    #       modulweite Test-Skips) + WARN bei Edit der Schwellen-Zeilen.
    # Idempotent, nicht-destruktiv, .bak-Backup vor Aenderung. Fehlt das Projekt-
    # Setup (.claude/sensitive-paths.json bzw. bodyguard/patterns/), wird nur ein
    # Hinweis geloggt und uebersprungen — nichts neu angelegt.
    log_info "BOO-176: Gate-Configs unter Bodyguard-Schutz nachruesten (sensitive-paths + Pattern)"

    # --- 1. Gate-Config-Pfade in .claude/sensitive-paths.json ergaenzen ---
    local spaths=".claude/sensitive-paths.json"
    if [[ ! -f "$spaths" ]]; then
        log_skip "BOO-176: $spaths fehlt — Projekt nicht gebootstrapped (BOO-18), Gate-Config-Pfade uebersprungen"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "patch $spaths: Gate-Config-Pfade in patterns[] ergaenzen (falls fehlend)"
    else
        local result
        result=$(python3 - "$spaths" <<'PYEOF'
import json, sys
p = sys.argv[1]
gate_paths = [
    "**/eslint.config.*",
    "**/.eslintrc*",
    "**/ruff.toml",
    "**/pyproject.toml",
    "**/.semgrep.yml",
    "**/.semgrep.yaml",
    "**/phpstan.neon",
    "**/phpstan.neon.dist",
    "**/.coveragerc",
    "**/jest.config.*",
    "**/vitest.config.*",
    "**/sonar-project.properties",
]
try:
    with open(p) as f:
        data = json.load(f)
except Exception as e:
    print("parse-error: %s" % e)
    sys.exit(0)
patterns = data.get("patterns")
if not isinstance(patterns, list):
    print("no-patterns-array")
    sys.exit(0)
missing = [g for g in gate_paths if g not in patterns]
if not missing:
    print("already-present")
    sys.exit(0)
# Backup nur schreiben, wenn wir tatsaechlich aendern (nicht-destruktiv).
import shutil
shutil.copyfile(p, p + ".bak")
patterns.extend(missing)
data["patterns"] = patterns
with open(p, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
print("added:%d" % len(missing))
PYEOF
)
        case "$result" in
            already-present)
                log_skip "BOO-176: $spaths enthaelt bereits alle Gate-Config-Pfade — nichts zu tun (idempotent)"
                ;;
            added:*)
                log_info "BOO-176: ${result#added:} Gate-Config-Pfade in $spaths ergaenzt (Backup: $spaths.bak)"
                ;;
            no-patterns-array)
                log_warn "BOO-176: $spaths hat kein 'patterns'-Array — Operator: Datei manuell pruefen"
                ;;
            *)
                log_warn "BOO-176: $spaths konnte nicht gepatcht werden ($result) — Operator: manuell pruefen"
                ;;
        esac
    fi

    # --- 2. Bodyguard-Pattern gate-configs.yml installieren (falls Pattern-Dir existiert) ---
    local pattern_dir=".claude/hooks/bodyguard/patterns"
    local pattern_file="$pattern_dir/gate-configs.yml"
    if [[ ! -d "$pattern_dir" ]]; then
        log_skip "BOO-176: $pattern_dir fehlt — Bodyguard (BOO-86) nicht installiert, Gate-Config-Pattern uebersprungen"
    elif [[ -f "$pattern_file" ]]; then
        log_skip "BOO-176: $pattern_file existiert bereits — nicht ueberschrieben (idempotent)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "install $pattern_file (Regel-Deaktivierungs-Muster fuer Gate-Configs)"
    else
        cat > "$pattern_file" <<'YMLEOF'
# Bodyguard Layer-0 — Quality-Gate-Aufweichung (sprachunabhaengig)
# Schema: - name / pattern / sprache / quelle / action(block|warn)
# Immer geladen (wie _universal.yml), weil Gate-Configs auf vielen Datei-Endungen leben.
# KANONISCH identisch zu bootstrap/references/file-templates.md (SSoT) — bei Aenderung beide ziehen.
- name: eslint-disable-file-wide
  pattern: '/\*\s*eslint-disable\s*\*/'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: ts-nocheck
  pattern: '@ts-nocheck'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: python-bare-noqa
  pattern: '#\s*noqa(?!\s*:)'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: python-bare-type-ignore
  pattern: '#\s*type:\s*ignore(?!\[)'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: pytest-mark-skip
  pattern: '@pytest\.mark\.skip\b'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: js-suite-skip
  pattern: '\b(describe|it|test|xit)\.skip\s*\(|\bxit\s*\('
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: phpstan-level-edit
  pattern: '(?m)^\s*level:\s*\d'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
- name: coverage-threshold-edit
  pattern: '(?i)(fail_under|coverageThreshold|minimum_coverage)\s*[:=]'
  sprache: alle
  quelle: 'BOO-176 / Quality-Gate-Integritaet'
  action: warn
YMLEOF
        log_info "BOO-176: $pattern_file installiert (Regel-Deaktivierungs-Muster)"
    fi

    log_manual "BOO-176: Die Qualitaets-Messlatte aendert nur der Operator — Gate-Config-Aenderung loest jetzt eine Gate-Block-Pause aus (Freigabe via review-ok). Code fixen statt Gate aufweichen. Override nur explizit + protokolliert (override_audit). Details: HANDBUCH (change_type-Governance)."
    return 0
}

migrate_boo_177() {
    # BOO-177 — Anti-Platzhalter-Check fuer Test-Dateien (Unit-Test-Haertung)
    # https://linear.app/owlist/issue/BOO-177
    #
    # Gezielter, deterministischer Check NUR auf Test-Dateien (kein Linter): flaggt
    # triviale/leere Tests (expect(true).toBe(true), assert True, leerer Koerper) und
    # unbegruendete Skips (it.skip/xit/@pytest.mark.skip ohne reason=). Greift im
    # implement-Test-Gate (Schritt 6a-quint, nach Coverage). Gleiches Grundproblem wie
    # BOO-176 ("Agent gamed das Gate"), hier auf der Test-Ebene.
    #
    # Single-Source-Konvention (BOO-89, wie raw-pii-guard/coverage-check): die kanonische
    # Quelle wird VERBATIM kopiert — kein eingebetteter Heredoc (sonst Drift). Idempotent,
    # nicht-destruktiv: existiert das Ziel bereits byte-identisch, passiert nichts.
    log_info "BOO-177: anti-placeholder-check (Test-Qualitaet) scaffolden"
    local script_dir; script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local src="$script_dir/../references/hooks/anti-placeholder-check.py"
    local dest=".claude/hooks/anti-placeholder-check.py"
    if [[ ! -f "$src" ]]; then
        log_skip "BOO-177: Kanonische Quelle fehlt ($src) — anti-placeholder-check uebersprungen"
    elif [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
        log_skip "BOO-177: $dest bereits aktuell (byte-identisch zur Quelle) — idempotent"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "copy $src -> $dest (Anti-Platzhalter-Check fuer Test-Dateien)"
    else
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        chmod +x "$dest"
        log_info "BOO-177: scaffolded $dest (Default = Warnung; im Test-Gate --strict)"
    fi
    log_manual "BOO-177: Anti-Platzhalter-Check laeuft im /implement-Test-Gate (Schritt 6a-quint, nach Coverage) gegen die gestageten Test-Dateien. Treffer = Gate-Fail; echte Assertion schreiben oder Skip begruenden (reason=/Kommentar). Override nur explizit + protokolliert (override_audit). Details: hooks-setup.md."
    return 0
}

migrate_boo_180() {
    # BOO-180 — Doku-Definition-of-Done als Konvention
    # https://linear.app/owlist/issue/BOO-180
    #
    # Reine Doku-Konvention: die Doku-DoD (Vernetzung, 3 Indizes, DE+EN, Release-Note,
    # Touchpoint-Quartett) ist im kanonischen Guidelines-Template
    # (issue-writing-guidelines-template) + CONVENTIONS.md §3 verankert. Neue Projekte
    # erben sie ueber den Guidelines-Copy beim Bootstrap. Bestandsprojekte: die
    # projektlokale Kopie neu ziehen, ohne eigene Anpassungen zu ueberschreiben —
    # daher nur Hinweis (log_manual), kein Auto-Overwrite.
    log_info "BOO-180: Doku-Definition-of-Done als Konvention (reine Doku, kein Code)"
    log_manual "BOO-180: Doku-DoD neu in issue-writing-guidelines-template + CONVENTIONS.md §3 (Vernetzung, 3 Indizes, DE+EN, Release-Note pro Issue, Touchpoint-Quartett: HANDBUCH/Doku - Release-Note - Spec - Linear). Bestandsprojekt: docs/issue-writing-guidelines.md aus bootstrap/references/issue-writing-guidelines-template.de.md neu ziehen (eigene Anpassungen vorher sichern)."
    return 0
}

migrate_boo_200() {
    # BOO-200 — Automemory/Learning-Loop-Abgrenzung: MEMORY.md-Header (ADR-3)
    # https://linear.app/owlist/issue/BOO-200
    #
    # Stellt der operator-lokalen Automemory-Index-Datei einen Abgrenzungs-Header voran: Automemory =
    # Operator-Praeferenzen (lokal); Projekt-Wissen gehoert in den Repo-Learning-Loop
    # (journal/learnings.md). Verhindert, dass Projekt-Lessons faelschlich im Automemory landen.
    # Automemory liegt unter ~/.claude/projects/<enc>/memory/MEMORY.md (Claude-Code-Konvention:
    # Projekt-Pfad mit '/' -> '-'). Idempotent + nicht-destruktiv: bestehende Index-Zeilen bleiben, der
    # Header wird nur vorangestellt wenn der Marker noch fehlt. Aktion NUR wenn das memory/-Verzeichnis
    # bereits existiert (kein Orphan an evtl. falschem Pfad).
    log_info "BOO-200: Automemory-Abgrenzungs-Header in MEMORY.md voranstellen"
    local enc mem_dir mem
    enc=$(pwd | sed 's#/#-#g')
    mem_dir="$HOME/.claude/projects/$enc/memory"
    mem="$mem_dir/MEMORY.md"
    if [[ ! -d "$mem_dir" ]]; then
        log_skip "Automemory-Verzeichnis fehlt ($mem_dir) — Header per /bootstrap (D.4b) anlegen"
        return 0
    fi
    if [[ -f "$mem" ]] && grep -q 'automemory-vs-learning-loop:' "$mem"; then
        log_skip "MEMORY.md-Header bereits vorhanden — nicht dupliziert"
        return 0
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "prepend Automemory-Abgrenzungs-Header an $mem"
        return 0
    fi
    local header
    header='<!-- automemory-vs-learning-loop: ADR-3 / BOO-200 -->
> **Operator-lokales Automemory** — Stil, Tool-Konfig, persoenliche Trigger. NICHT im Repo.
> Projekt-Wissen (Story-Patterns, Anti-Patterns, Architektur-Lessons) gehoert in den **Learning-Loop**: `journal/learnings.md`. Abgrenzung: ADR-3.
'
    if [[ -f "$mem" ]]; then
        printf '%s\n%s\n' "$header" "$(cat "$mem")" > "$mem"
    else
        printf '%s' "$header" > "$mem"
    fi
    log_info "MEMORY.md-Header vorangestellt ($mem)"
}

migrate_boo_205() {
    # BOO-205 — Status-Line-Custom-Script mit Worker-Equivalent live (Schalter A)
    # https://linear.app/owlist/issue/BOO-205
    #
    # Ruestet die native Claude-Code-Status-Line nach. NUR bei runtime_target: claude-code
    # (Schalter A) — bei codex/cross-tool/unknown wird nichts verdrahtet.
    #   (1) .claude/statusline.sh — Skript, BYTE-IDENTISCH zur SSoT bootstrap/templates/statusline.sh
    #       und zum Template-Block in bootstrap/references/file-templates.md (Triplikat, BOO-205).
    #   (2) .claude/settings.json — nativer "statusLine"-Block (Claude Code rendert daraus). Idempotent:
    #       nur wenn noch kein statusLine vorhanden. jq-Merge wenn verfuegbar, sonst minimal-Datei/MANUAL.
    #   (3) .claude/environment.json — Manifest-Referenz "status_line" (AC#2; environment.json ist das
    #       Framework-Manifest, settings.json die native Render-Verdrahtung). Nur wenn Datei existiert
    #       und Feld fehlt; jq-Merge wenn verfuegbar, sonst MANUAL.
    # Idempotent, nicht-destruktiv. Zweiter Lauf doppelt nichts.
    log_info "BOO-205: Status-Line nachruesten (statusline.sh + settings.json-Verdrahtung)"

    # --- Schalter-A-Gate: nur bei runtime_target: claude-code ---
    local rt=""
    [[ -f "CONVENTIONS.md" ]] && rt=$(grep -E '^runtime_target:' CONVENTIONS.md | head -1 | sed 's/runtime_target:[[:space:]]*//')
    if [[ "$rt" != "claude-code" ]]; then
        log_skip "runtime_target=${rt:-fehlend} (nicht claude-code) — Status-Line nicht verdrahtet (Schalter A inaktiv)"
        return 0
    fi

    # --- 1. .claude/statusline.sh (byte-identisch zur SSoT bootstrap/templates/statusline.sh) ---
    local sl=".claude/statusline.sh"
    if [[ -f "$sl" ]]; then
        log_skip "$sl existiert — nicht ueberschrieben (idempotent)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $sl (byte-identisch zu bootstrap/templates/statusline.sh) + chmod +x"
    else
        ensure_dir ".claude"
        cat > "$sl" <<'STATUSLINE_SH_EOF'
#!/usr/bin/env bash
# statusline.sh — INTENTRON Custom-Status-Line mit Worker-Equivalent (BOO-205).
#
# Native Claude-Code-Status-Line: liest das von Claude Code auf stdin uebergebene
# JSON und rendert EINE Zeile auf stdout. Aktiv NUR bei runtime_target: claude-code
# (Schalter A) — verdrahtet ueber .claude/settings.json ("statusLine"). Build-vs-Buy
# (ADR-1): native Status-Line statt Eigenbau-UI; dieses Skript reichert nur an.
#
# Beispiel-Ausgabe:
#   Sonnet 4.7 | 142k/200k ctx | Worker-Equiv: 2.5h / 16h | Story BOO-205 | $4.20
#
# Felder & Quellen:
#   Modell        .model.display_name                       (nativ, stdin)
#   ctx           .context_window.total_input_tokens /      (nativ, stdin)
#                 .context_window.context_window_size
#   Worker-Equiv  effort_ai_hours / effort_human_equiv_hours aus specs/<story>.md
#                 (Framework-Anreicherung — Execution-Isolation-Block, BOO-193)
#   Story         BOO-<n> aus .worktree.branch / .workspace.git_worktree / git branch
#   $-Kosten      .cost.total_cost_usd                      (nativ, stdin; Schattenpreis
#                 bei Max-Pro, Echtkosten bei API)
#
# Defensiv: jedes Feld ist optional. Fehlt eine Quelle (kein jq, kein Spec, kein Wert),
# wird das Feld weggelassen — das Skript endet IMMER mit Exit 0 (nie ein Render-Fehler
# in der Status-Line). Keine Secrets; keine Netzwerk-Calls.

set -uo pipefail

INPUT="$(cat 2>/dev/null || true)"

# Repo-Wurzel: bevorzugt aus dem stdin-JSON, sonst aktuelles Verzeichnis.
parse() {
  # parse <jq-pfad> — liest einen Wert aus $INPUT; leer bei Fehler/null/fehlendem jq.
  command -v jq >/dev/null 2>&1 || return 0
  printf '%s' "$INPUT" | jq -r "$1 // empty" 2>/dev/null
}

CWD="$(parse '.workspace.current_dir')"
[[ -z "$CWD" ]] && CWD="$(parse '.workspace.project_dir')"
[[ -z "$CWD" ]] && CWD="$PWD"

PARTS=()

# --- 1. Modell ---------------------------------------------------------------
MODEL="$(parse '.model.display_name')"
[[ -n "$MODEL" ]] && PARTS+=("$MODEL")

# --- 2. Context-Fenster (Nk/Mk ctx) -----------------------------------------
USED="$(parse '.context_window.total_input_tokens')"
SIZE="$(parse '.context_window.context_window_size')"
if [[ "$USED" =~ ^[0-9]+$ && "$SIZE" =~ ^[0-9]+$ && "$SIZE" -gt 0 ]]; then
  PARTS+=("$((USED / 1000))k/$((SIZE / 1000))k ctx")
fi

# --- 3. Story-ID aus Branch / Worktree --------------------------------------
BRANCH="$(parse '.worktree.branch')"
[[ -z "$BRANCH" ]] && BRANCH="$(parse '.workspace.git_worktree')"
if [[ -z "$BRANCH" ]] && command -v git >/dev/null 2>&1; then
  BRANCH="$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
fi
STORY=""
if [[ "$BRANCH" =~ [Bb][Oo][Oo]-([0-9]+) ]]; then
  STORY="BOO-${BASH_REMATCH[1]}"
fi

# --- 4. Worker-Equivalent (h/h) aus der Story-Spec --------------------------
if [[ -n "$STORY" ]]; then
  SPEC="$CWD/specs/$STORY.md"
  if [[ -f "$SPEC" ]]; then
    AI_H="$(grep -E '^[[:space:]]*effort_ai_hours:' "$SPEC" | head -1 | sed -E 's/.*:[[:space:]]*//; s/[[:space:]]*(#.*)?$//')"
    HUM_H="$(grep -E '^[[:space:]]*effort_human_equiv_hours:' "$SPEC" | head -1 | sed -E 's/.*:[[:space:]]*//; s/[[:space:]]*(#.*)?$//')"
    if [[ "$AI_H" =~ ^[0-9.]+$ && "$HUM_H" =~ ^[0-9.]+$ ]]; then
      PARTS+=("Worker-Equiv: ${AI_H}h / ${HUM_H}h")
    fi
  fi
  PARTS+=("Story $STORY")
fi

# --- 5. Kosten ($) -----------------------------------------------------------
COST="$(parse '.cost.total_cost_usd')"
if [[ "$COST" =~ ^[0-9.]+$ ]]; then
  PARTS+=("$(printf '$%.2f' "$COST")")
fi

# --- Render: eine Zeile, Felder mit " | " getrennt, leere weggelassen --------
OUT=""
for p in "${PARTS[@]:-}"; do
  [[ -z "$p" ]] && continue
  if [[ -z "$OUT" ]]; then OUT="$p"; else OUT="$OUT | $p"; fi
done
printf '%s' "$OUT"

exit 0
STATUSLINE_SH_EOF
        chmod +x "$sl"
        log_info "created $sl (byte-identisch zur SSoT) + chmod +x"
    fi

    # --- 2. .claude/settings.json — nativer statusLine-Block ---
    local settings=".claude/settings.json"
    if [[ -f "$settings" ]] && grep -q '"statusLine"' "$settings"; then
        log_skip "$settings hat bereits einen statusLine-Block — nicht dupliziert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "wire statusLine in $settings (command: bash .claude/statusline.sh)"
    elif command -v jq >/dev/null 2>&1; then
        ensure_dir ".claude"
        [[ -f "$settings" ]] || printf '{}\n' > "$settings"
        local tmp; tmp=$(mktemp)
        if jq '.statusLine = {"type":"command","command":"bash .claude/statusline.sh","padding":0}' "$settings" > "$tmp" 2>/dev/null; then
            mv "$tmp" "$settings"
            log_info "statusLine in $settings verdrahtet (jq-Merge)"
        else
            rm -f "$tmp"
            log_manual "$settings konnte nicht per jq gemerged werden — statusLine-Block manuell ergaenzen (HANDBUCH Anhang AQ)"
        fi
    else
        log_manual "kein jq — statusLine-Block manuell in $settings ergaenzen: {\"type\":\"command\",\"command\":\"bash .claude/statusline.sh\"} (HANDBUCH Anhang AQ)"
    fi

    # --- 3. .claude/environment.json — Manifest-Referenz (AC#2) ---
    local envf=".claude/environment.json"
    if [[ ! -f "$envf" ]]; then
        log_skip "$envf fehlt — Manifest-Referenz uebersprungen (generate-environment-json.sh)"
    elif grep -q '"status_line"' "$envf"; then
        log_skip "$envf hat bereits status_line-Referenz"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "add status_line reference to $envf"
    elif command -v jq >/dev/null 2>&1; then
        local tmp; tmp=$(mktemp)
        if jq '.status_line = ".claude/statusline.sh"' "$envf" > "$tmp" 2>/dev/null; then
            mv "$tmp" "$envf"
            log_info "status_line-Referenz in $envf ergaenzt (AC#2)"
        else
            rm -f "$tmp"
            log_manual "$envf: status_line-Referenz manuell ergaenzen (\"status_line\": \".claude/statusline.sh\")"
        fi
    else
        log_manual "kein jq — \"status_line\": \".claude/statusline.sh\" manuell in $envf ergaenzen"
    fi
}

migrate_boo_199() {
    # BOO-199 — Schalter A (runtime_target=claude-code-Default) + Native-Pfade-Block (ADR-2)
    # https://linear.app/owlist/issue/BOO-199
    #
    # Ruestet BESTEHENDE Projekte additiv auf den Claude-Code-first-Pfad nach (ADR-2 §Offen-Item 2 —
    # Migration ohne Bootstrap-Neulauf). Zwei idempotente, nicht-destruktive Schritte:
    #   (1) runtime_target in CONVENTIONS.md auf claude-code setzen — NUR wenn aktuell unknown/fehlend.
    #       Eine explizite codex/cross-tool-Wahl wird NIE ueberschrieben (Operator-Entscheidung bleibt).
    #   (2) Native-Pfade-Block (native_paths:) an CLAUDE.md anhaengen, falls noch nicht vorhanden. Der
    #       Block ist BYTE-IDENTISCH zum Template in bootstrap/references/file-templates.md §Native-Pfade
    #       und zum HANDBUCH-Beispiel (Triplikat-Konsistenz, BOO-199).
    # Zweiter Lauf doppelt nichts.
    log_info "BOO-199: Claude-Code-first nachruesten (runtime_target + Native-Pfade-Block)"

    # --- 1. runtime_target in CONVENTIONS.md (nur wenn unknown/fehlend) ---
    if [[ ! -f "CONVENTIONS.md" ]]; then
        log_skip "CONVENTIONS.md fehlt — runtime_target nicht setzbar (erst Bootstrap)"
    elif grep -qE '^runtime_target:[[:space:]]*(claude-code|codex|cross-tool)' CONVENTIONS.md; then
        local cur; cur=$(grep -E '^runtime_target:' CONVENTIONS.md | head -1 | sed 's/runtime_target:[[:space:]]*//')
        log_skip "runtime_target bereits explizit gesetzt ($cur) — Operator-Wahl nicht ueberschrieben"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "set runtime_target: claude-code in CONVENTIONS.md (war unknown/fehlend)"
    else
        if grep -qE '^runtime_target:' CONVENTIONS.md; then
            sed -i.bak 's/^runtime_target:.*/runtime_target: claude-code/' CONVENTIONS.md && rm -f CONVENTIONS.md.bak
        else
            printf 'runtime_target: claude-code\n' >> CONVENTIONS.md
        fi
        log_info "runtime_target: claude-code in CONVENTIONS.md gesetzt (war unknown/fehlend)"
    fi

    # --- 2. Native-Pfade-Block an CLAUDE.md (byte-identisch zum file-templates.md-Template) ---
    if [[ ! -f "CLAUDE.md" ]]; then
        log_skip "CLAUDE.md fehlt — Native-Pfade-Block nicht einfuegbar"
    elif grep -q '^native_paths:' CLAUDE.md; then
        log_skip "Native-Pfade-Block bereits in CLAUDE.md — nicht dupliziert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "append Native-Pfade-Block (native_paths:) an CLAUDE.md"
    else
        cat >> "CLAUDE.md" <<'NATIVE_PATHS_EOF'

## Native-Pfade (ADR-2 / BOO-199)

Claude-Code-Native-Features vor Framework-Eigenbau. Pro Projekt überschreibbar. Die Flags gelten **nur** bei `runtime_target: claude-code` (Schalter A) — bei `codex`/`cross-tool` sind sie inaktiv.

```yaml
native_paths:
  prefer_native_subagents: true   # /implement generiert echte .claude/agents/<story>-<agent>.md (eigenes 200k-Window) statt Text-Block-Briefings
  prefer_goal_termination: true   # /sprint-run nutzt /goal als Termination-Engine
  prefer_ultraplan: auto          # /architecture-review + /ideation schlagen /ultraplan vor — auto | always | never
  complement_insights: true       # /sprint-review ruft /insights auf und integriert Meta-Block
```
NATIVE_PATHS_EOF
        log_info "Native-Pfade-Block an CLAUDE.md angehaengt (byte-identisch zum Template)"
    fi
}

migrate_boo_239() {
    # BOO-239 — Unabhaengiger Codex-Reviewer: AGENTS.md-Review-Guidelines-Block
    # https://linear.app/owlist/issue/BOO-239
    #
    # Reine Doku/Vertrag: das AGENTS.md-Template (bootstrap/references/file-templates.md) traegt jetzt
    # einen Review-Guidelines-Block (Senior-Dev-Perspektive, Report-only, Findings-Flow). Neue Projekte
    # erben ihn ueber den AGENTS.md-Pfad (RUNTIME_TARGET=codex, Anhang J). Bestandsprojekt: den
    # Review-Guidelines-Block additiv an ein vorhandenes AGENTS.md anhaengen, falls der Marker fehlt.
    # Nicht-destruktiv, idempotent. KEIN Gate, kein Auto-Fix.
    log_info "BOO-239: AGENTS.md-Review-Guidelines-Block sichern"
    local agents="AGENTS.md"
    if [[ ! -f "$agents" ]]; then
        log_skip "AGENTS.md fehlt — wird beim Bootstrap (RUNTIME_TARGET=codex) aus file-templates.md erzeugt (inkl. Review-Guidelines)"
        return 0
    fi
    if grep -q "Review-Guidelines — unabhaengiger Code-Reviewer (BOO-239)" "$agents" 2>/dev/null; then
        log_skip "Review-Guidelines-Block bereits in AGENTS.md"
        return 0
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "append Review-Guidelines-Block an $agents"
        return 0
    fi
    cat >> "$agents" <<'REVGUIDE_EOF'

## Review-Guidelines — unabhaengiger Code-Reviewer (BOO-239)
Wenn Codex als Reviewer laeuft (kein Auto-Fix, nur Befund):
- Perspektive: Senior-Developer — Design, Handwerk, Edge-Cases, Wartbarkeit. NICHT das, was die deterministischen Gates (Semgrep/Sonar/Coverage) schon abdecken.
- Pruef-Massstab: der Diff gegen SECURITY.md, ARCHITECTURE_DESIGN.md und CONVENTIONS.md — nicht generisch.
- Output: ein Befund/Report mit Prioritaet (P0/P1). Kein Patch, kein Merge — Codex aendert nie Code.
- Findings-Flow: echter Fund -> triagieren -> Backlog-Story + Spec -> /implement -> Gates -> menschlicher Merge.
- Dedup: bereits gemeldete Funde ueber memory.md filtern.
- Setup-Pfade (Komfort GitHub-native / Souveraenitaet CLI+Azure-EU): docs/runbooks/codex-reviewer.md.
REVGUIDE_EOF
    log_info "Review-Guidelines-Block an $agents angehaengt"
}

migrate_boo_248() {
    # BOO-248 — Post-Install "Optionale Add-ons / Next-Steps"-Sektion (Surfacing)
    # https://linear.app/owlist/issue/BOO-248
    #
    # Reine Doku/Surfacing: bootstrap §7.7 + Developer-Onboarding-Template listen die opt-in
    # Add-ons (Codex-Reviewer, Daily-Bug-Scanner, Headless-VPS, VPS-vom-Handy) als erweiterbare
    # Pointer-Liste statt als Interview-Frage (kein Bloat). Bestandsprojekt: die
    # "Optionale Add-ons"-Sektion additiv an DEVELOPER_ONBOARDING.md anhaengen, falls der Marker
    # fehlt. Nicht-destruktiv, idempotent. KEIN neuer Interview-Schritt.
    log_info "BOO-248: Post-Install Optionale-Add-ons-Sektion in DEVELOPER_ONBOARDING.md sichern"
    local onb="DEVELOPER_ONBOARDING.md"
    if [[ ! -f "$onb" ]]; then
        log_skip "DEVELOPER_ONBOARDING.md fehlt — wird beim Bootstrap aus dem Template (inkl. Optionale Add-ons) erzeugt"
        return 0
    fi
    if grep -q "Optionale Add-ons / Naechste Schritte" "$onb" 2>/dev/null; then
        log_skip "Optionale-Add-ons-Sektion bereits in DEVELOPER_ONBOARDING.md"
        return 0
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "append Optionale-Add-ons-Sektion an $onb"
        return 0
    fi
    cat >> "$onb" <<'ADDONS_EOF'

## Optionale Add-ons / Naechste Schritte

Optionale, opt-in Betriebs-/Governance-Add-ons sind nicht eingerichtet und bewusst nicht im Interview abgefragt (Leichtgewicht-Designprinzip). Bei Bedarf im Nachgang ueber das jeweilige Framework-Runbook aktivieren (Hintergrund: HANDBUCH Anhang AT):

- Unabhaengiger Code-Reviewer (Codex) — Runbook `codex-reviewer`.
- Daily-Bug-Scanner — Runbook `daily-bug-scanner`.
- Headless-VPS — Runbook `headless-vps`.
- Developer-VPS vom Handy — Runbook `vps-vom-handy`.

Die Liste ist erweiterbar: neue Opt-in-Features kommen hier dazu, statt als Interview-Frage.
ADDONS_EOF
    log_info "Optionale-Add-ons-Sektion an $onb angehaengt"
}

migrate_boo_254() {
    # BOO-254 — CI-Spec-Gate: opt-in server-seitiges Spec-Linkage-Gate
    # https://linear.app/owlist/issue/BOO-254
    #
    # Legt .github/workflows/spec-gate-ci.yml an, falls es fehlt (idempotent, nicht-destruktiv).
    # Opt-in: Standard aus, Empfehlung governance_mode=heavy. Aktivierung als Required Check
    # separat via setup-branch-protection.sh-Re-Run. Surfacing: DEVELOPER_ONBOARDING.md §Add-ons (BOO-248).
    log_info "BOO-254: CI-Spec-Gate-Workflow .github/workflows/spec-gate-ci.yml sichern"
    local wf=".github/workflows/spec-gate-ci.yml"
    if [[ -f "$wf" ]]; then
        log_skip "$wf bereits vorhanden"
        return 0
    fi
    mkdir -p .github/workflows
    cat > "$wf" <<'SPECGATE_EOF'
# .github/workflows/spec-gate-ci.yml — server-seitiges Spec-Linkage-Gate (opt-in, BOO-254)
# DE: Prueft auf PR server-seitig, dass die Aenderung eine existierende specs/<ISSUE>.md referenziert.
# EN: On a PR, verifies server-side that the change references an existing specs/<ISSUE>.md.
name: Spec-Linkage
on:
  pull_request:
    branches: [main]

permissions:
  contents: read

jobs:
  spec-linkage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Verify spec linkage
        env:
          HEAD_REF: ${{ github.head_ref }}
          PR_TITLE: ${{ github.event.pull_request.title }}
        run: |
          set -euo pipefail
          # DE: Issue-Keys aus Branch-Name + PR-Titel (squash-merge-fest; Commit-Messages werden gequetscht).
          # EN: Issue keys from branch name + PR title (squash-merge-safe; commit messages get collapsed).
          KEYS=$(printf '%s\n%s\n' "$HEAD_REF" "$PR_TITLE" | grep -oE '[A-Z]+-[0-9]+' | sort -u || true)
          if [[ -z "$KEYS" ]]; then
            echo "::error::No issue key ([A-Z]+-[0-9]+) in branch name or PR title — no spec reference provable."
            echo "branch='$HEAD_REF' title='$PR_TITLE'"
            exit 1
          fi
          FOUND=0
          for key in $KEYS; do
            if [[ -f "specs/${key}.md" ]]; then
              echo "OK: specs/${key}.md referenced."
              FOUND=1
            fi
          done
          if [[ "$FOUND" -ne 1 ]]; then
            echo "::error::No referenced specs/<ISSUE>.md found (checked: $KEYS). Add specs/<KEY>.md or name the key in branch/PR title."
            exit 1
          fi
SPECGATE_EOF
    log_info "$wf angelegt — als Required Check aktivieren: bash bootstrap/scripts/setup-branch-protection.sh (Re-Run)"
}

migrate_boo_190() {
    # BOO-190 — financials-Skill: Projekt-Budget-Template + Worker-Equivalent-Baseline-Pointer
    # https://linear.app/owlist/issue/BOO-190
    #
    # Generiert die Financials-Templates ins Zielprojekt (Bootstrap-Triplikat-Verteilung):
    #   (1) docs/financials/budget.md      — schlankes Projekt-Budget (Verrechnungssatz/Geo/Token).
    #       Heredoc unten ist BYTE-IDENTISCH zur SSoT docs/financials/budget.md im Framework-Repo
    #       und zum Template-Block in bootstrap/references/file-templates.md §docs/financials/budget.md.
    #   (2) docs/financials/worker-equivalent-baseline.md — KURZER Pointer-Stub. Die volle ~60-Zeilen-
    #       Geo-Default-Tabelle ist Framework-Referenz (Skill financials), KEIN pro-Projekt-Heredoc
    #       (Triplikat-Pflege vermeiden). Der Stub haelt nur den aktiven Satz lokal + verweist auf die
    #       Skill-Referenz.
    # Idempotent, nicht-destruktiv: existiert eine Datei bereits, wird sie [SKIP]ped (Operator-Pflege
    # bleibt erhalten). Zweiter Lauf doppelt nichts.
    log_info "BOO-190: Financials-Templates anlegen (budget.md + worker-equivalent-baseline.md Pointer-Stub)"

    ensure_dir "docs/financials"

    # --- 1. docs/financials/budget.md (byte-identisch zur SSoT) ---
    local budget="docs/financials/budget.md"
    if [[ -f "$budget" ]]; then
        log_skip "$budget existiert — nicht ueberschrieben (idempotent, Operator-Pflege)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $budget (byte-identisch zur SSoT docs/financials/budget.md)"
    else
        cat > "$budget" <<'BUDGET_MD_EOF'
# Projekt-Budget — Worker-Equivalent & Kosten

> Schlankes Budget-Template für die Financials-/ROI-Sicht eines Projekts (BOO-190). Von `/bootstrap`
> (Financials-Frage) angelegt, danach vom Operator gepflegt. Verweist auf die zwei Mess-/Referenz-Quellen
> daneben — selbst hält diese Datei nur die Projekt-Annahmen.

## Projekt-Annahmen

```yaml
geo: <CH | DE | AT | US>
currency: <CHF | EUR | USD>
rate_per_hour: <Zahl>             # = aktiver Satz aus worker-equivalent-baseline.md Abschnitt 1
token_cost_assumption: <optional> # falls KI-Token-Kosten separat budgetiert werden
```

## Quellen daneben (nicht hier duplizieren)

| Quelle | Was sie liefert | Datei |
|--------|------------------|-------|
| Verrechnungssatz + Geo-Defaults | aktiver Satz (intern/market-research) + Fallback-Baseline | [`worker-equivalent-baseline.md`](worker-equivalent-baseline.md) |
| Ist-Token-/Kosten-Verbrauch | gemessene ccusage-Snapshots pro Sprint/Story (BOO-189) | [`sprint-costs.md`](sprint-costs.md) |
| Worker-Equivalent-Report pro Sprint | KI-Kosten / Mensch-Equiv / ROI / Wall-Clock (BOO-191) | `sprint-XX-worker-equivalent.md` |

## So rechnet die ROI-Sicht (Kurzform)

- **KI-Kosten** = gemessener Token-/Kosten-Verbrauch (`sprint-costs.md`).
- **Mensch-Equivalent-Kosten** = Σ `effort_human_equiv_hours` der Sprint-Stories × `rate_per_hour`.
- **ROI-Faktor** = Mensch-Equivalent-Kosten ÷ KI-Kosten.
- **Wall-Clock** = reale Sprint-Dauer aus dem Sprint-Log.

> Die Doppelspalte `effort_ai_hours` / `effort_human_equiv_hours` pro Story (BOO-193) ist die
> Datenquelle. ROI-Sprache bleibt vorerst intern, bis ≥3 Sprints Daten vorliegen (ADR-D §Offen).
BUDGET_MD_EOF
        log_info "created $budget (byte-identisch zur SSoT)"
    fi

    # --- 2. docs/financials/worker-equivalent-baseline.md (kurzer Pointer-Stub, kein Voll-Duplikat) ---
    local baseline="docs/financials/worker-equivalent-baseline.md"
    if [[ -f "$baseline" ]]; then
        log_skip "$baseline existiert — nicht ueberschrieben (idempotent)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $baseline (Pointer-Stub auf financials-Skill-Referenz, kein Voll-Duplikat)"
    else
        cat > "$baseline" <<'BASELINE_STUB_EOF'
# Worker-Equivalent-Baseline — aktiver Satz (Pointer-Stub)

> Pointer-Stub (BOO-190). Diese Datei haelt **nur den aktiven Projekt-Verrechnungssatz** (Abschnitt 1).
> Die vollstaendigen **Market-Research-Geo-Defaults** (CH/DE/AT/US, primaer + konservativ, mit Quelle,
> Confidence und Erhebungsjahr) sind **Framework-Referenz** und werden vom Skill `financials`
> dokumentiert — sie werden hier bewusst **nicht dupliziert** (Triplikat-Pflege vermeiden).
>
> **Regel native Waehrung:** Satz bleibt nativ pro Geo (CH CHF, DE/AT EUR, US USD). **Keine**
> FX-Cross-Umrechnung. Bei Kurs-Drift >5 % nur Nutzerhinweis, kein automatisches Umrechnen.

## 1. Aktiver Verrechnungssatz (dieses Projekt)

> Von `/bootstrap` (Financials-Frage) gesetzt. Eigener Satz → `source: intern`. Frage uebersprungen →
> Market-Research-Default (`source: market-research-2026`). **Intern-Vorrang:** ein eingegebener
> interner Satz schlaegt den Default immer (ADR-D, entschieden).

```yaml
geo: <CH | DE | AT | US>          # bestimmt die Waehrung
currency: <CHF | EUR | USD>
rate_per_hour: <Zahl>             # Verrechnungssatz pro Stunde, native Waehrung
source: <intern | market-research-2026>
erhebungsjahr: <Jahr>             # bei intern: Jahr des internen Satzes; bei market-research: 2025
basis: <freelance-p50 | intern-vollkosten | eigen>
```

## 2. Market-Research-Geo-Defaults

Vollstaendige Geo-Default-Tabelle (CH/DE/AT/US, primaer extern P50 + konservativ intern, je mit
Quelle/Confidence/Erhebungsjahr), Methodik, Quellen-Hierarchie und Update-Trigger: siehe Skill-Referenz
`financials` (Framework-Doku). Diese Projekt-Datei haelt nur den aktiven Satz oben.
BASELINE_STUB_EOF
        log_info "created $baseline (Pointer-Stub auf financials-Skill-Referenz)"
    fi

    log_manual "BOO-190: Financials ist ein Opt-in — Bootstrap fragt beim Setup, ob aktivieren. Aktiven Verrechnungssatz in docs/financials/worker-equivalent-baseline.md Abschnitt 1 setzen (oder Market-Research-Default uebernehmen). Geo-Default-Tabelle + Methodik: Skill financials. Intern-Vorrang bei Konflikt."
    return 0
}

# -----------------------------------------------------------------------------
# CLI / Argument Parsing
# -----------------------------------------------------------------------------

# Liste aller verfuegbaren Issues (fuer --list und --issue Validierung)
ALL_ISSUES=(
    BOO-1 BOO-2
    BOO-3 BOO-4 BOO-5 BOO-12 BOO-15 BOO-27 BOO-28 BOO-29 BOO-30 BOO-34 BOO-36 BOO-38 BOO-39 BOO-40
    BOO-8 BOO-13 BOO-14 BOO-16 BOO-25
    BOO-7 BOO-10 BOO-21 BOO-24 BOO-26 BOO-35
    BOO-11 BOO-17 BOO-18 BOO-19
    BOO-20 BOO-37
    BOO-31 BOO-32 BOO-33
    BOO-84
    BOO-69
    BOO-70 BOO-71
    BOO-72
    BOO-74
    BOO-75 BOO-76 BOO-77
    BOO-79 BOO-80 BOO-81
    BOO-86
    BOO-87
    BOO-91
    BOO-92
    BOO-93
    BOO-108
    BOO-140 BOO-141 BOO-142 BOO-143
    BOO-146 BOO-148 BOO-149
    BOO-176
    BOO-177
    BOO-180
    BOO-190
    BOO-229
)

print_help() {
    cat <<EOF
$SCRIPT_NAME — Migrations-Skript fuer INTENTRON-Governance v1 -> v2

DE:
  --all               Alle Auto-Schritte fuer alle BOO-Issues ausfuehren.
  --issue BOO-N       Nur die Funktion fuer ein einzelnes Issue ausfuehren.
  --list              Alle unterstuetzten BOO-Issues auflisten.
  --dry-run           Nur loggen, keine Datei-Operationen ausfuehren.
  --force             Bestehende Auto-Generate-Files ueberschreiben (z.B. BOO-34).
  -h, --help          Diese Hilfe anzeigen.

EN: same flags, same semantics. The script is idempotent and safe to re-run.

Beispiele / Examples:
  $SCRIPT_NAME --all
  $SCRIPT_NAME --issue BOO-21
  $SCRIPT_NAME --dry-run --all
  $SCRIPT_NAME --issue BOO-34 --force
  $SCRIPT_NAME --list
EOF
}

list_issues() {
    log_info "Verfuegbare / available BOO-Issues:"
    local issue
    for issue in "${ALL_ISSUES[@]}"; do
        printf '  %s\n' "$issue"
    done
}

run_single_issue() {
    local issue="$1"
    local found=false
    local known
    for known in "${ALL_ISSUES[@]}"; do
        if [[ "$known" == "$issue" ]]; then
            found=true
            break
        fi
    done
    if [[ "$found" != "true" ]]; then
        log_warn "Unbekannter Issue: $issue (siehe --list)"
        return 1
    fi
    local fn_name
    fn_name="migrate_boo_${issue#BOO-}"
    if declare -F "$fn_name" >/dev/null; then
        "$fn_name"
    else
        log_warn "Funktion $fn_name nicht implementiert"
        return 1
    fi
}

main() {
    if [[ $# -eq 0 ]]; then
        print_help
        exit 0
    fi

    local mode=""
    local single_issue=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                mode="all"
                shift
                ;;
            --issue)
                mode="single"
                single_issue="${2:-}"
                if [[ -z "$single_issue" ]]; then
                    log_warn "--issue benoetigt einen Wert (z.B. BOO-21)"
                    exit 1
                fi
                shift 2
                ;;
            --list)
                mode="list"
                shift
                ;;
            --dry-run)
                DRY_RUN="true"
                log_info "DRY-RUN aktiv — keine Datei-Operationen werden ausgefuehrt."
                shift
                ;;
            --force)
                FORCE="true"
                log_info "FORCE aktiv — bestehende Auto-Generate-Files werden ueberschrieben."
                shift
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            *)
                log_warn "Unbekanntes Argument: $1"
                print_help
                exit 1
                ;;
        esac
    done

    case "$mode" in
        all)    migrate_all ;;
        single) run_single_issue "$single_issue" ;;
        list)   list_issues ;;
        "")     print_help ;;
    esac
}

main "$@"

# DE: Dieses Skript ist ein Skelett. Konkrete Migration pro BOO-Issue wird beim Done des jeweiligen Issues nachgereicht.
# EN: This script is a skeleton. Concrete migration logic per BOO issue lands when each issue ships.
