# Demo-Vorbereitung — fertige Kunden-Demo aufsetzen (Runbook)

[🇩🇪 Deutsch](./demo-vorbereitung.md) · [🇬🇧 English](./demo-vorbereitung.en.md)

> Das Drehbuch *vor* der Demo: was du **vorher** abarbeitest, damit du mit einer **fertigen, lauffähigen Demo** beim Kunden ankommst. Gegenstück zu [`customer-demo.md`](./customer-demo.md) (Ablauf *während* der Demo). Quelle: BOO-238.

> [!tip] Bewusst kein gepflegtes Demo-Repo
> Statt ein dauerhaftes Demo-Projekt zu pflegen (das driftet und grün gehalten werden muss), setzt du die Demo **reproduzierbar aus diesem Runbook** frisch auf. Der Reset am Ende (Schritt 5) macht sie wiederholbar.

## 0. Vorab-Checkliste

- **Accounts/Keys:** GitHub, Linear, Anthropic-API; optional Deploy-Plattform + SonarCloud.
- **Vorlaufzeit:** ~60–90 Min einplanen.
- **Trockenlauf** einmal komplett (Timing + dass die Gates wirklich feuern).
- **Offline-Fallback:** Screenshots/Aufzeichnung der Kernschritte (falls Netz/Live-Risiko beim Kunden).

## 1. VPS aufsetzen (Hostinger)

- VPS bereitstellen + härten → [Hostinger-VPS-Setup](./hostinger-vps-setup.md); für Team/Multi-User → [VPS-Team-Setup](./vps-team-setup.md).
- Claude Code CLI auf der VPS installieren, GitHub- und Linear-Zugang einrichten.
- *(Lokal am Mac geht auch — die VPS macht die Demo „echter" und erlaubt unbeaufsichtigte Läufe; Steuerung unterwegs siehe Runbook „VPS vom Handy", BOO-240.)*

## 2. Framework installieren (`/bootstrap`)

- Leeres Demo-Projekt anlegen, `/bootstrap` ausführen → `CLAUDE.md`, Git-Hooks, CI-Workflows, Branch-Protection, Skill-Auswahl.
- **Verifizieren:** `bootstrap/references/verify-setup.sh` grün; ein Test-Commit ohne Spec zeigt, dass der **spec-gate** greift (das ist später dein Wow-Moment).

## 3. Beispiel-Story + kopierfertiger Prompt

Wähle eine Story, die durch **möglichst viele Features** läuft. Empfehlung (Stack **Node/TS**):

> **„POST `/login`-Endpoint mit Eingabe-Validierung"** — trifft einen `auth`-Pfad (→ **sensitive-paths-Gate** feuert live), braucht Tests (→ **Coverage-Gate**), und ist klein genug für eine Live-Demo.

Kopierfertige Prompts (in Claude Code, im Demo-Projekt eingeben):

```text
/intent Wir wollen einen sicheren Login, damit sich Nutzer authentifizieren können — Sicherheit vor Tempo.
```

```text
/ideation POST /login-Endpoint (Node/TS): nimmt E-Mail + Passwort, validiert die Eingabe,
gibt bei Erfolg ein Session-Token zurück. Mit Akzeptanzkriterien und Tests. Erstelle das Linear-Issue.
```

```text
/implement <ISSUE-ID>
```

*(Optional ganzer Sprint: `/sprint-run`; unbeaufsichtigt bis PR: `/sprint-run --auto`.)*

## 4. Feature-Walkthrough (das zeigst du)

- `/intent` → das **Warum** vor der Spec.
- `/ideation` → **Linear-Issue mit Akzeptanzkriterien**.
- `/implement` → **Gate-Block live**: Commit ohne Spec → **spec-gate** blockt → Spec anlegen → grün; der `auth`-Pfad → **sensitive-paths** → menschliches `review-ok`.
- `/sprint-run --auto` → **Autopilot bis zum PR** (merged nicht selbst).
- **CI/CD** (GitHub Actions, SonarCloud) + **Status-Line** (Worker-Equivalent) sichtbar machen.
- `/pitch` → Evidenz-Briefing für die Stakeholder.

→ Detail-Drehbuch mit Timing + Rollen-Use-Cases: [`customer-demo.md`](./customer-demo.md).

## 5. Reset (wiederholbar)

- Demo-Branches löschen, Linear-Issues zurücksetzen, Repo auf den Ausgangs-Commit. Damit ist die Demo **idempotent wiederholbar**.

## Verwandt

[`customer-demo.md`](./customer-demo.md) (Ablauf *während* der Demo) · Onboarding-Checklisten ([`docs/onboarding/`](../onboarding/)) · [Entwickler-Schnelleinstieg](../quickstart-entwickler.md) · [Hostinger-VPS-Setup](./hostinger-vps-setup.md).
