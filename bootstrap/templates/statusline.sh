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
