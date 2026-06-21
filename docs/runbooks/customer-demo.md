# Kunden-Demo — Framework in 1–2 h vorführen (Runbook)

[🇩🇪 Deutsch](./customer-demo.md) · [🇬🇧 English](./customer-demo.en.md)

> Drehbuch, um das Framework **live in 1–2 h** zu zeigen — „so wird entwickelt". Was zeige ich in welcher Reihenfolge, was sage ich dazu, und welche Rollen-Use-Cases. Quelle: BOO-238.

> [!warning] Demo-Projekt-Repo = Folge-Arbeit
> Ein fertiges, klonbares **Demo-Repo** (vorgebootstrappt, mit Issues + CI) ist eigene Folge-Arbeit (siehe `specs/BOO-238.md`, offene Akzeptanz). Für jetzt nutzt du ein kleines, frisch gebootstrapptes Projekt.

## 0. Vorbereitung (vor dem Termin)

- **Demo-Projekt** vorab gebootstrappt + auf GitHub: Branch-Protection + Hooks aktiv, 2–3 Linear-Issues mit Akzeptanzkriterien angelegt, CI-Workflows grün.
- **Accounts/Keys bereit:** GitHub, Linear, optional Deploy-Plattform + SonarCloud, Anthropic-API.
- **Trockenlauf** einmal komplett durchgespielt (Timing geprüft).
- **Offline-Fallback:** Screenshots/Aufzeichnung der Kernschritte, falls Netz/Live-Risiko.

## 1. Ablauf (1–2 h, mit Timing)

| Zeit | Schritt | Talking Point |
|---|---|---|
| 0:00–0:10 | Intro + „Unsere Position" | autonom bis PR, Mensch am Merge — kontrolliertes Vertrauen |
| 0:10–0:25 | Idee → `/ideation` → Linear-Issue mit ACs | „Intent vor Spec — die KI baut nicht sauber das Falsche" |
| 0:25–0:45 | `/implement` live: **Gate-Block provozieren** (Commit ohne Spec → `spec-gate` blockt) → auflösen → grün | „kein Commit ohne Spec — das ist der Unterschied zu einem Prompt" |
| 0:45–1:05 | `/sprint-run --auto`: Autopilot bis zum PR | „läuft unbeaufsichtigt, merged aber nicht selbst" |
| 1:05–1:25 | Rollen-Brille (CISO / CTO / DPO) an konkreten Gates | siehe §2 |
| 1:25–1:40 | CI/CD sichtbar (GitHub Actions, SonarCloud) + Token-/Worker-Equivalent (Status-Line) | „gemessen, nicht vermutet" |
| 1:40–2:00 | Q&A + Reset | |

## 2. Rollen-Use-Cases (Demo-Szenen)

| Rolle | Was zeige ich | Beleg / Runbook |
|---|---|---|
| **CISO** | `sensitive-paths`-Gate greift → `review-ok`; `security-architect` | [`ciso-security.md`](./ciso-security.md) |
| **CTO** | Quality-Gates (Coverage, Slopsquatting, `quality-gate-audit`), `architecture-review` | [`cto-code-quality.md`](./cto-code-quality.md) |
| **DPO** | `personal-data`-Gate → `privacy-ok`, dpo-Kontrollkatalog | [`dpo-privacy.md`](./dpo-privacy.md) |
| **CEO** | Worker-Equivalent / ROI (Status-Line) | [`ceo-business-case.md`](./ceo-business-case.md) |
| **Auditor** | Traceability Idee→Issue→Spec→Commit, `audit-trace.sh` | [`audit-perspective.md`](./audit-perspective.md) |

## 3. Der „Wow"-Moment: Gate-Block live

1. Datei ändern, **ohne** Spec committen → `spec-gate` blockt (Meldung zeigen).
2. `specs/<ISSUE>.md` anlegen → erneut committen → grün.
3. Optional: Edit an einem `sensitive-path` → Stopp bis menschliches `review-ok`.

→ Botschaft: die Leitplanken sind unsichtbar, bis sie etwas fangen — und wenn sie fangen, erklären sie warum.

## 4. Reset (wiederholbar)

- Demo-Branches löschen, Linear-Issues zurücksetzen, Demo-Repo auf den Ausgangs-Commit. Macht die Demo idempotent wiederholbar.

## 5. Was bewusst NICHT live passiert

Merge nach `main`, Deploy, Secrets-Rotation — bleiben menschlich freigegeben (Verweis [Unsere Position](../../README.md#unsere-position-sequenzielle-pipeline-menschlich-freigegebene-merges)). Genau das ist das Vertrauens-Argument vor dem Kunden.

## Verwandt

Rollen-Runbooks ([`docs/runbooks/`](./)) · Onboarding-Checklisten ([`docs/onboarding/`](../onboarding/)) · [Entwickler-Schnelleinstieg](../quickstart-entwickler.md) · [Unsere Position](../../README.md#unsere-position-sequenzielle-pipeline-menschlich-freigegebene-merges).
