# INTENTRON — Entwickler-Schnelleinstieg

[🇩🇪 Deutsch](./quickstart-entwickler.md) · [🇬🇧 English](./quickstart-entwickler.en.md)

> **Das Wichtigste auf einen Blick — „Wann nehme ich was?"** Kein Setup-Guide (das ist [README §Schnellstart](../README.md) + [HANDBUCH §4](../HANDBUCH.md)), sondern die **Befehlswahl im Alltag**. Druckbar auf ≤5 Seiten.

## 1. Der Flow auf einen Blick

```
💡 Idee
  └─ /intent ........... das WARUM festhalten (vor der Spec)
      └─ /ideation ..... Idee → Linear-Issue mit Akzeptanzkriterien
          └─ /backlog .. Priorisierung: welche Story jetzt?
              └─ /implement ........ eine Story: Spec → Code → Gates → Commit
                  └─ /architecture-review .. Risiken? Tech Debt?
                      └─ /sprint-review ..... Quartals-Retro: was hat funktioniert?
                          └─ /pitch ........ Evidenz-Briefing für die Stakeholder-Demo
```

## 2. Wann nehme ich was?

| Ich will … | Befehl |
|---|---|
| das *Warum* vor der Spec festhalten | `/intent` |
| aus einer Idee eine Story mit Akzeptanzkriterien machen | `/ideation` |
| priorisieren, welche Story als nächstes dran ist | `/backlog` |
| **eine einzelne Story umsetzen** | **`/implement`** |
| **einen ganzen Sprint fahren** (mehrere Stories, Worktree, CI, Merge) | **`/sprint-run`** |
| **unbeaufsichtigt bis zum prüfbaren PR** (Autopilot) | **`/sprint-run --auto`** |
| Architektur prüfen (Risiken, Tech Debt) | `/architecture-review` |
| Quartals-Retro / Sprint-Audit | `/sprint-review` |
| prüfen, ob meine Quality-Gates *wirklich greifen* | `/quality-gate-audit` |
| eine Stakeholder-Demo vorbereiten | `/pitch` |

## 3. `/implement` vs `/sprint-run` vs `--auto` (die häufigste Frage)

| | `/implement` | `/sprint-run` | `/sprint-run --auto` |
|---|---|---|---|
| **Umfang** | genau **eine** Story | **mehrere** Stories nacheinander | mehrere Stories, **unbeaufsichtigt** |
| **Aufsicht** | du begleitest | du startest, schaust zu | läuft allein bis zum PR |
| **Worktree/Branch** | ein Branch | Worktree + Branch pro Story | dito |
| **Endpunkt** | Commit/PR der Story | PRs + `/sprint-review` am 80%-Token-Boundary | PRs, dann Stopp |
| **NICHT automatisch** | — | Merge / Deploy / Secrets | Merge / Deploy / Secrets (bleiben menschlich, siehe [Unsere Position](../README.md#unsere-position-sequenzielle-pipeline-menschlich-freigegebene-merges)) |

**Faustregel:** eine Story → `/implement`. Ein Schwung Stories → `/sprint-run`. Über Nacht / auf der VPS → `/sprint-run --auto`.

## 4. Befehls-Referenz (laufzeit-relevant)

| Skill | Wozu |
|---|---|
| `/bootstrap` | **Einstieg:** Projekt-Setup (CLAUDE.md, Hooks, Backlog, Skill-Auswahl) |
| `/intent` · `/ideation` · `/backlog` | Vorlauf: Warum → Story → Priorisierung |
| `/implement` · `/sprint-run` | Umsetzung: eine Story bzw. ganzer Sprint |
| `/architecture-review` · `/sprint-review` | Prüfung: Architektur bzw. Sprint-Retro |
| `/quality-gate-audit` | prüft, ob Gates *verdrahtet* sind (nicht nur konfiguriert) |
| `/pitch` | Evidenz-Briefing für die Demo (keine Slides) |
| `/security-architect` · `/dpo` | Security- bzw. Datenschutz-Review (Bundle) |
| `/knowledge-onboarding` · `/infrastructure-onboarding` | Bestands-Doku bzw. Infra-Layer nachziehen (post-Bootstrap) |

Vollständige Tabelle: [README §Die Skills](../README.md#die-skills).

## 5. Schalter & Modi

| Schalter | Bedeutung |
|---|---|
| **Schalter A** — `runtime_target=claude-code` | Claude-Code-first-Default (aktiviert z.B. die Status-Line) |
| **`governance_mode`** — `lite` / `standard` / `heavy` | Strenge der Gates: Solo bis Konzern, dieselbe Platte, nur dimmt |
| **`change_type: prototype`** | bewusste Gate-Lockerung ohne Compliance-Bruch |
| **`--auto`** | Autopilot-Modus von `/sprint-run` (unbeaufsichtigt bis PR) |

## 6. Gates — was blockt wann, wie gebe ich frei

| Gate | Blockt wenn … | Freigabe |
|---|---|---|
| **spec-gate** | Commit ohne verknüpfte Spec | `specs/<ISSUE>.md` anlegen |
| **sensitive-paths** (BOO-18) | Edit an Auth/Payment/PII-Pfaden | menschliches `review-ok` |
| **personal-data** (BOO-69) | Edit an personenbezogenen Pfaden | menschliches `privacy-ok` |
| **Coverage** | neuer Code < 80 % getestet | Tests ergänzen |
| **Slopsquatting** | verdächtiger (halluzinierter) Paketname | Paket prüfen / entfernen |
| **Layer-0-Bodyguard** | riskanter Edit vor dem Schreiben | bewusst bestätigen |

## 7. „Gate blockt — was tun?"

1. **Lies die Meldung** — sie nennt Gate + Grund + meist den Fix.
2. **spec-gate** → Spec anlegen (`specs/<ISSUE>.md`), dann erneut committen.
3. **sensitive-paths / personal-data** → der Mensch setzt `review-ok` / `privacy-ok` (bewusste Freigabe, kein Auto-Bypass).
4. **Coverage / Slopsquatting / Lint** → Ursache beheben (Tests, Paketname, Lint), nicht das Gate abschalten.
5. Im Autopilot pausiert `/sprint-run` bei nicht-selbstheilbarem Block und wartet auf dich.

## Mehr Tiefe

[HANDBUCH §6 „Die Skills — wann nutze ich was?"](../HANDBUCH.md) · [Klartext-Glossar](./glossar.md) · [Unsere Position (sequenziell, human-gated)](../README.md#unsere-position-sequenzielle-pipeline-menschlich-freigegebene-merges) · [README §Schnellstart](../README.md) (Installation).
