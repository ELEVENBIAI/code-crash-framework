#!/usr/bin/env bash
# check-skill-sources.sh — Source-Garantie fuer Bundle-Skills (BOO-121)
#
# Sichert die Source-Konvention ab: ALLE Bundle-Skills (inkl. `intent`) werden
# aus dem intentron-Repo gesourced — NIE aus `claudecodeskills`. claudecodeskills
# liefert nur die optionalen Allzweck-Skills (research, design-md-generator,
# setup-checklist, skill-creator). Plus Mirror-Integritaet: jeder gelistete
# Bundle-Skill liegt tatsaechlich als Top-Level-Ordner mit SKILL.md im Repo.
#
# Hintergrund: Der im Probelauf beobachtete Fehler ("intent aus claudecodeskills")
# war das Pre-BOO-74-Verhalten einer veralteten lokalen bootstrap-Skill-Version.
#
# Exit 0 = konsistent · Exit 1 = Verstoss. Dependency-frei (bash + git + coreutils).
# Lokal + in CI lauffaehig.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP="$(cd "$SCRIPT_DIR/.." && pwd)"     # bootstrap/
REPO="$(cd "$BOOTSTRAP/.." && pwd)"           # intentron Repo-Root
SKILL_MD="$BOOTSTRAP/SKILL.md"
SKILLS_SETUP="$BOOTSTRAP/references/skills-setup.md"

# --- Single Source of Truth: die Bundle-Skill-Liste (alle aus intentron) ---
BUNDLE_SKILLS=(architecture-review backlog bootstrap cloud-system-engineer dpo \
  grafana ideation implement intent knowledge-onboarding pitch research \
  security-architect sprint-review visualize)
# Keine optionale claudecodeskills-Clone-Frage mehr im Bootstrap (BOO-219):
# research ist seit BOO-219 vendored Bundle-Skill, setup-checklist ein eigenes
# oeffentliches Repo (BOO-113), design-md-generator/skill-creator bleiben
# global/standalone und werden nicht vom Framework gesourced.
GENERAL_SKILLS=()

fail=0
err() { printf '  \xe2\x9c\x97 %s\n' "$1"; fail=1; }
ok()  { printf '  \xe2\x9c\x93 %s\n' "$1"; }

echo "== Source-Garantie: Bundle-Skills aus intentron (BOO-121) =="

# 1) Mirror-Integritaet: jeder Bundle-Skill liegt als Top-Level-Ordner mit SKILL.md im Repo.
for s in "${BUNDLE_SKILLS[@]}"; do
  if [[ -f "$REPO/$s/SKILL.md" ]]; then ok "Mirror vorhanden: $s/SKILL.md"
  else err "Bundle-Skill fehlt im intentron-Repo: $s/SKILL.md"; fi
done

# 2) Source-Garantie: kein Bundle-Skill ueber einen literalen claudecodeskills/<skill>-Pfad.
#    (Pfad-literal statt Prosa -> keine False-Positives auf Master/Mirror-Erwaehnungen.)
BUNDLE_RE="$(IFS='|'; echo "${BUNDLE_SKILLS[*]}")"
hits="$(grep -nE "claudecodeskills/(${BUNDLE_RE})([/\"' ]|\$)" "$SKILL_MD" "$SKILLS_SETUP" 2>/dev/null || true)"
if [[ -n "$hits" ]]; then
  err "Bundle-Skill via literalem claudecodeskills/<skill>-Pfad gesourced:"
  printf '%s\n' "$hits" | sed 's/^/      /'
else
  ok "kein literaler claudecodeskills/<bundle-skill>-Pfad in SKILL.md / skills-setup.md"
fi

# 3) intent explizit: muss als Bundle-Skill im Repo liegen (Schwerpunkt BOO-120/121).
if [[ -f "$REPO/intent/SKILL.md" ]]; then ok "intent liegt im intentron-Repo (Bundle)"
else err "intent fehlt als Bundle-Skill im intentron-Repo"; fi

# 4) Der aktive Phase-5-Clone zieht intentron (nicht claudecodeskills) fuer die Bundle-Skills.
if grep -qE "git clone .*github\.com/vibercoder79/intentron" "$SKILL_MD"; then
  ok "Phase 5 cloned intentron als Bundle-Quelle"
else
  err "Phase-5-Clone von intentron in SKILL.md nicht gefunden"
fi

echo
if [[ "$fail" -eq 0 ]]; then echo "Source-Garantie: OK"; else echo "Source-Garantie: VERSTOSS gefunden"; fi
exit "$fail"
