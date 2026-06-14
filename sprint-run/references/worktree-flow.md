# Worktree-Flow — ein Worktree pro Story

Referenz zu `/sprint-run` Schritt 4.1 (Vorbereitung: anlegen) und `/goal` (Ausfuehrung: merge +
cleanup). Jede Story laeuft in ihrem eigenen `git worktree` mit eigenem Branch — das ist die
**Sicherheits-Boundary** fuer die native Subagents (Kollisionsschutz Ebene 2,
`docs/kollisionsschutz-drei-ebenen.md`). `/sprint-run` legt den Worktree **vor** dem `/goal`-Aufruf
an; Merge und Cleanup uebernimmt `/goal` waehrend der Ausfuehrung.

## Warum Worktree statt Branch-Wechsel?

- **Isolation:** Jede Story hat einen eigenen Arbeitsbaum — kein `git checkout`-Hin-und-Her,
  kein versehentliches Mischen von Aenderungen.
- **Parallel-faehig:** Bei `parallel_story_limit > 1` koennen mehrere Stories gleichzeitig in
  disjunkten Worktrees laufen (disjunkte `write_scopes` vorausgesetzt).
- **Sauberes `main`:** Der Haupt-Arbeitsbaum bleibt unangetastet, bis gemerged wird.

## Ablauf pro Story

```bash
# /sprint-run Schritt 4.1 — anlegen (eigener Branch je Story), VOR dem /goal-Aufruf
git worktree add ../wt-BOO-<n> -b feat/boo-<n>-<slug>

# /goal (Story-Subagent) — im Worktree: /implement + Remote-CI-Wait
cd ../wt-BOO-<n>
# ... der Story-Subagent setzt /implement um, pusht den Branch, wartet auf gruene CI ...

# /goal — Merge NUR bei gruener CI + gruener Gate-Assertion, dann aufraeumen
cd <repo-root>
git merge --no-ff feat/boo-<n>-<slug>      # oder PR-Merge via gh
git worktree remove ../wt-BOO-<n>
git branch -d feat/boo-<n>-<slug>          # nach erfolgreichem Merge
```

## Regeln

- **Branch-Naming:** `feat/boo-<n>-<slug>` (bzw. die von Linear vorgeschlagene `gitBranchName`).
- **Merge-Gate:** kein Merge ohne gruene Remote-CI (BOO-148) + gruene Gate-Assertion.
- **Cleanup ist Pflicht:** nach Merge `git worktree remove` + Branch loeschen. Verwaiste
  Worktrees blockieren spaetere Laeufe.
- **Bei Fehler:** Worktree entfernen (oder fuer Diagnose behalten und im Sprint-Report vermerken).
- **Dirty `main`:** niemals mergen, wenn der Haupt-Baum nicht clean ist — STOPP.

## Drei Ebenen des Kollisionsschutzes (Einordnung)

- **Ebene 1 — Multi-User:** eigener Klon pro Person.
- **Ebene 2 — Multi-Session/Subagent:** `git worktree` pro Story ← *hier wirkt `/sprint-run` + `/goal`*.
- **Ebene 3 — Multi-Agent:** Execution-Isolation + disjunkte Write-Scopes (`/implement` Schritt 0c).

Sketch: `docs/story-breakdown.png` + `docs/github-integration.png` (HANDBUCH Anhang AD).
