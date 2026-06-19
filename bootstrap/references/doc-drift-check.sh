#!/usr/bin/env bash
# doc-drift-check.sh — Doku-Drift-Checker fuer ein INTENTRON-Projekt (BOO-229).
#
# Beantwortet die Frage "Stimmt die Doku-Landkarte noch mit der Realitaet?".
# Liest ARCHITECTURE_DESIGN.md §Referenzen + INDEX.md als Single Source of Truth
# (SSoT) und prueft drei billige Signale, gibt pro Check PASS / WARN / FAIL aus:
#   1) Vollstaendigkeit  — existiert jede in §Referenzen/INDEX registrierte Datei?
#                          ist jedes erwartbare Doku-Artefakt registriert?
#   2) Frische           — ist ARCHITECTURE_DESIGN.md aelter als der Schwellwert
#                          (thresholds.architecture_doc_freshness_days, Default 30)?
#   3) Lokal vs. Remote  — haengt eine getrackte Doku hinter origin (git fetch)?
# Read-only — aendert nichts.
#
# ABGRENZUNG: Dies ist das PROJEKT-Skript (prueft das Kundenprojekt). Das
# repo-interne .github/scripts/docs_drift_check.py prueft das Framework-Repo
# selbst (SKILL.md <-> README.md-Versionen) — ein anderes Ding.
#
# SEVERITY-STEUERUNG (BOO-229): Dieses Skript klassifiziert ehrlich PASS/WARN/FAIL
# und setzt rc=1 bei FAIL. OB ein FAIL einen Skill blockiert, entscheidet die
# aufrufende Stufe: Standard = warn-only (informativ), Compliance (compliance_doc_gate,
# BOO-229 B2) = Hard-Block. Das Skript selbst trifft diese Entscheidung NICHT.
#
# Nutzung (im Projekt-Root):
#   bash scripts/doc-drift-check.sh            # Report, Exit 1 bei FAIL
#   bash scripts/doc-drift-check.sh --strict   # WARN zaehlt auch als FAIL
#   bash scripts/doc-drift-check.sh --quiet    # nur Summary + Exit-Code
#   bash scripts/doc-drift-check.sh --no-fetch # Remote-Check ohne git fetch (offline)
#
# BSD- und Linux-kompatibel, keine Abhaengigkeiten ausser bash/git/grep/sed/awk.
set -uo pipefail

STRICT=0
QUIET=0
NO_FETCH=0
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    --quiet) QUIET=1 ;;
    --no-fetch) NO_FETCH=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  esac
done

PASS=0; WARN=0; FAIL=0
ENV_FILE=".claude/environment.json"
ARCH_DOC="ARCHITECTURE_DESIGN.md"
INDEX_DOC="INDEX.md"

c_pass() { PASS=$((PASS+1)); [[ $QUIET -eq 1 ]] || printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
c_warn() { WARN=$((WARN+1)); [[ $QUIET -eq 1 ]] || printf '  \033[33mWARN\033[0m  %s\n' "$1"; }
c_fail() { FAIL=$((FAIL+1)); [[ $QUIET -eq 1 ]] || printf '  \033[31mFAIL\033[0m  %s\n' "$1"; }
c_skip() { [[ $QUIET -eq 1 ]] || printf '  ----  %s\n' "$1"; }
section() { [[ $QUIET -eq 1 ]] || printf '\n\033[1m%s\033[0m\n' "$1"; }

# Liest einen flachen Wert aus environment.json ohne jq (grep/sed) — wie verify-setup.sh.
env_val() { grep -o "\"$1\"[[:space:]]*:[[:space:]]*[^,}]*" "$ENV_FILE" 2>/dev/null | head -1 | sed -E 's/.*:[[:space:]]*//; s/[[:space:]]*$//; s/^"//; s/"$//'; }

# Schneidet den Abschnitt unter einer Ueberschrift heraus, die $1 enthaelt
# (bis zur naechsten Ueberschrift gleicher/hoeherer Ebene). Robust gegen die
# variable Sektionsnummer (§6/§9 "Referenzen").
md_section() {
  awk -v pat="$1" '
    /^#+[[:space:]]/ {
      if (insec) { exit }
      if (index($0, pat) > 0) { insec=1; next }
    }
    insec { print }
  ' "$2" 2>/dev/null
}

# Extrahiert aus Markdown-Tabellenzeilen den ersten Backtick-getoken Pfad pro Zeile
# (Spalte 1 in INDEX, Spalte "Pfad" in §Referenzen — beide das erste `...`-Token).
md_table_paths() {
  grep -E '^[[:space:]]*\|' 2>/dev/null \
    | grep -vE '^\s*\|[[:space:]:-]+\|?\s*$' \
    | grep -oE '`[^`]+`' \
    | sed 's/`//g' \
    | awk 'NF'
}

# Tage seit letztem Commit (Fallback: stat-mtime) einer Datei.
file_age_days() {
  local f="$1" epoch now
  epoch="$(git log -1 --format=%ct -- "$f" 2>/dev/null)"
  if [[ -z "$epoch" ]]; then
    epoch="$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null)"
  fi
  [[ -z "$epoch" ]] && { echo "-1"; return; }
  now="$(date +%s)"
  echo $(( (now - epoch) / 86400 ))
}

[[ $QUIET -eq 1 ]] || printf '\033[1mINTENTRON Doku-Drift-Check\033[0m (BOO-229)\n'

# --- 0. SSoT vorhanden? ----------------------------------------------------
section "0. SSoT-Quellen (ARCHITECTURE_DESIGN.md §Referenzen + INDEX.md)"
HAVE_ARCH=0; HAVE_INDEX=0
if [[ -f "$ARCH_DOC" ]]; then HAVE_ARCH=1; c_pass "$ARCH_DOC vorhanden"; else c_skip "$ARCH_DOC fehlt — Projekt noch nicht weit genug, Drift-Check uebersprungen"; fi
if [[ -f "$INDEX_DOC" ]]; then HAVE_INDEX=1; c_pass "$INDEX_DOC vorhanden"; else c_skip "$INDEX_DOC fehlt — INDEX-Pruefung uebersprungen"; fi
if [[ $HAVE_ARCH -eq 0 && $HAVE_INDEX -eq 0 ]]; then
  printf '\n\033[1mErgebnis:\033[0m %d PASS, %d WARN, %d FAIL — keine SSoT-Quelle, nichts zu pruefen.\n' "$PASS" "$WARN" "$FAIL"
  exit 0
fi

# --- 1. Vollstaendigkeit ---------------------------------------------------
section "1. Vollstaendigkeit (registrierte Dateien existieren / erwartbare Artefakte registriert)"
REGISTERED=""
if [[ $HAVE_ARCH -eq 1 ]]; then
  arch_paths="$(md_section 'Referenzen' "$ARCH_DOC" | md_table_paths)"
  if [[ -z "$arch_paths" ]]; then
    c_warn "$ARCH_DOC: kein §Referenzen-Tabellenblock gefunden — Format pruefen (| Dokument | Pfad | Inhalt |)"
  fi
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    REGISTERED="${REGISTERED}|${p}"
    if [[ -e "$p" ]]; then c_pass "§Referenzen: $p existiert"; else c_fail "§Referenzen: registrierte Datei $p fehlt — Doku zeigt auf nicht vorhandene Datei"; fi
  done <<< "$arch_paths"
fi
if [[ $HAVE_INDEX -eq 1 ]]; then
  index_paths="$(md_table_paths < "$INDEX_DOC")"
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    REGISTERED="${REGISTERED}|${p}"
    if [[ -e "$p" ]]; then c_pass "INDEX: $p existiert"; else c_fail "INDEX: registrierte Datei $p fehlt — Doku zeigt auf nicht vorhandene Datei"; fi
  done <<< "$index_paths"
fi
# Reverse-Heuristik: erwartbare Doku-Artefakte, die existieren, aber nirgends registriert sind.
for f in SECURITY.md API_INVENTORY.md PRIVACY.md GOVERNANCE.md SYSTEM_ARCHITECTURE.md COMPONENT_INVENTORY.md PROCESS_CATALOG.md CONVENTIONS.md; do
  if [[ -f "$f" ]] && ! printf '%s' "$REGISTERED" | grep -qF "|$f"; then
    c_warn "$f existiert, ist aber nicht in §Referenzen/INDEX registriert (Kern-Regel: jede Datei eintragen)"
  fi
done

# --- 2. Frische ------------------------------------------------------------
section "2. Frische (ARCHITECTURE_DESIGN.md vs. thresholds.architecture_doc_freshness_days)"
if [[ $HAVE_ARCH -eq 1 ]]; then
  THRESH="$(env_val architecture_doc_freshness_days)"
  [[ "$THRESH" =~ ^[0-9]+$ ]] || THRESH=30
  AGE="$(file_age_days "$ARCH_DOC")"
  if [[ "$AGE" -lt 0 ]]; then
    c_warn "$ARCH_DOC: Aenderungszeitpunkt nicht ermittelbar (kein Git-Log, kein stat)"
  elif [[ "$AGE" -gt "$THRESH" ]]; then
    c_warn "$ARCH_DOC ist $AGE Tage alt (Schwelle $THRESH) — /architecture-review erwaegen"
  else
    c_pass "$ARCH_DOC ist $AGE Tage alt (Schwelle $THRESH) — frisch genug"
  fi
else
  c_skip "Frische-Check uebersprungen (kein $ARCH_DOC)"
fi

# --- 3. Lokal vs. Remote ---------------------------------------------------
section "3. Lokal vs. Remote (haengt getrackte Doku hinter origin?)"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  c_skip "Kein Git-Repo — Remote-Check uebersprungen"
else
  UPSTREAM="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)"
  if [[ -z "$UPSTREAM" ]]; then
    c_skip "Kein Upstream-Tracking-Branch gesetzt — Remote-Check uebersprungen"
  else
    if [[ $NO_FETCH -eq 0 ]]; then
      git fetch --quiet 2>/dev/null || c_warn "git fetch fehlgeschlagen (offline?) — Vergleich gegen letzten bekannten Stand von $UPSTREAM"
    fi
    BEHIND="$(git rev-list --count "HEAD..$UPSTREAM" 2>/dev/null || echo 0)"
    if [[ "$BEHIND" =~ ^[0-9]+$ ]] && [[ "$BEHIND" -gt 0 ]]; then
      changed_docs="$(git diff --name-only "HEAD..$UPSTREAM" -- '*.md' 2>/dev/null | head -20)"
      if [[ -n "$changed_docs" ]]; then
        c_warn "Doku haengt hinter $UPSTREAM ($BEHIND Commit(s) voraus) — 'git pull'. Betroffen:"
        [[ $QUIET -eq 1 ]] || printf '%s\n' "$changed_docs" | sed 's/^/          - /'
      else
        c_pass "Branch ist $BEHIND Commit(s) hinter $UPSTREAM, aber keine getrackte Doku betroffen"
      fi
    else
      c_pass "Doku ist auf dem Stand von $UPSTREAM"
    fi
  fi
fi

# --- Summary ---------------------------------------------------------------
printf '\n\033[1mErgebnis:\033[0m %d PASS, %d WARN, %d FAIL\n' "$PASS" "$WARN" "$FAIL"
if [[ $FAIL -gt 0 ]]; then
  printf '\033[31m=> Doku-Drift: FAIL. Registrierte Dateien fehlen — §Referenzen/INDEX korrigieren.\033[0m\n'
  exit 1
fi
if [[ $WARN -gt 0 && $STRICT -eq 1 ]]; then
  printf '\033[33m=> --strict: WARN als FAIL gewertet.\033[0m\n'
  exit 1
fi
if [[ $WARN -gt 0 ]]; then
  printf '\033[33m=> Doku funktionsfaehig, WARN-Punkte pruefen.\033[0m\n'
else
  printf '\033[32m=> Keine Doku-Drift erkannt.\033[0m\n'
fi
exit 0
