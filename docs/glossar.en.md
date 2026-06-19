# Glossary for non-developers (plain language)

> Training glossary (BOO-131): the key framework terms in 1–2 sentences with an everyday analogy — for business stakeholders, management and customers. The technical short form is in **HANDBUCH Appendix C**. DE: [`glossar.md`](glossar.md).

## Basics

- **Repository (repo)** — the central folder holding all of a project's code + docs, including the full change history. *Analogy:* the project's filing cabinet where every version is archived.
- **Commit** — a saved set of changes with a short description. *Analogy:* "save + a note on what I changed".
- **Branch** — a parallel working copy where you can work safely without disturbing the main state. *Analogy:* a draft alongside the original.
- **`main`** — the main state that must always work. *Analogy:* the approved fair copy.
- **Pull Request (PR) / merge** — the request to take a branch change into `main` — only after review. *Analogy:* "request for approval" before the draft flows into the fair copy.

## Quality & automation

- **Gate** — an automatic check that must pass before things continue. *Analogy:* the barrier that only opens on green.
- **Hook** — a small script that fires automatically on a certain event (e.g. before saving). *Analogy:* a motion sensor that triggers an action.
- **Linter** — a tool that automatically checks code for style and careless errors. *Analogy:* the spell-checker for code.
- **SAST** (Static Application Security Testing) — automatic search for security flaws in the code without running it. *Analogy:* inspectors reading the blueprints instead of driving the car.
- **Runner** — the computer (often in the cloud) that executes the automatic checks. *Analogy:* the test bench the checks run on.
- **CI** (Continuous Integration) — the automation that starts all checks on the runner on every change. *Analogy:* the end-of-line inspection that fires for each item.
- **Branch protection** — the rule that forbids changing `main` directly and enforces PR + green gates. *Analogy:* "only via quality control, no shortcut into the fair copy".
- **Auditor** — a reviewer (cyber-security or code quality) who checks after the fact whether the framework was actually followed — without changing anything themselves. *Analogy:* the auditor who reads the books but does not do the bookkeeping. Dedicated entry runbook: [`audit-perspective.en.md`](runbooks/audit-perspective.en.md).
- **Audit trail** — the unbroken chain that leads every change back to its documented intent and the work step that triggered it (commit → spec → session). *Analogy:* the document flow in accounting: every entry has a receipt.
- **Audit artifact** — a piece of evidence the framework produces for an auditor to inspect (e.g. check reports, privacy audit, sprint metrics). *Analogy:* the stamped inspection records in the binder. What matters is durability: permanent in the repo, 30 days in CI, or only ephemeral on the working machine.
- **Slopsquatting** — when an AI recommends a package that does not exist, and an attacker registers exactly that made-up name with malicious code. The framework counters this with a list of known fake/malicious packages (a *wordlist*) that is refreshed regularly. *Analogy:* a blacklist of fake suppliers — only worth anything when kept current.
- **Wiring canary** — a small test file with a deliberate flaw that only produces a finding when the check is actually wired in. If it stays silent, the check is blind. *Analogy:* the canary in the coal mine — as long as it sings, the warning works.

## Audit & control

- **Threshold** — the limit at which a check counts as passed, warned or failed (e.g. test coverage: green from 80%, yellow from 60%; wordlist max. 90 days old; architecture docs max. 30 days behind the code). *Analogy:* the measuring stick with green, yellow and red marks.
- **Audit status** `wired` / `nominal` / `blind` — how a check scores in the wiring check: *wired* = connected and fires, *nominal* = set up but never runs (false sense of safety), *blind* = claims to check but checks nothing. *Analogy:* a smoke detector that beeps (wired), one on the ceiling with no battery (nominal), and one that is merely painted on (blind).
- **Sprint** vs. **cycle** — a *sprint* here is a unit of work that fits into the AI's token window (about 80% of it), not a fixed calendar period. *Cycles* (Linear's own time-boxing concept) are deliberately not enabled; the sprint assignment lives in `Sprints.md`. *Analogy:* we don't measure the leg of the journey in days, but in how much the AI can take in at once.

## Docs & control

- **Spec** (specification) — the short statement of *what* a task must achieve, before code is written. *Analogy:* the work order with acceptance criteria.
- **ADR** (Architecture Decision Record) — a short document capturing an important decision and its rationale. *Analogy:* the minutes "we decided X because Y".
- **Bootstrap** — the one-time setup run that sets a project up with all rules, templates and checks. *Analogy:* the factory setup before production starts.
- **Skill** — a repeatable AI workflow invoked with `/name` (e.g. `/ideation`, `/implement`). *Analogy:* a rehearsed standard procedure at the push of a button.
- **Scaffold** — automatically creating the skeleton files (empty templates). *Analogy:* the scaffolding + shell that gets filled in later.

## AI connection

- **MCP** (Model Context Protocol) — the standardized "plug" through which the AI gets secure connections to tools/data (e.g. Linear, GitHub). *Analogy:* the USB standard for AI tools.
- **Agent / sub-agent** — an AI instance that handles a bounded task on its own. *Analogy:* a specialist with a clear assignment.

## Strategy & native paths (from Sprint 3)

- **Build-vs-buy doctrine** — the guiding rule to *use* capabilities the AI vendor (Anthropic) ships natively instead of rebuilding them in the framework. *Analogy:* don't build your own power plant when there's a reliable grid connection. (ADR-1)
- **Claude-Code-first / native paths (switches A/B/C)** — three switches that flip the framework onto native Claude Code features instead of running its own rebuilds. *Analogy:* setting the defaults to "manufacturer original parts".
- **`/goal` (termination engine)** — the native feature that repeats an automated run until the goal (all checks green) is reached, then stops cleanly. *Analogy:* cruise control that only switches off once you've arrived.
- **Native subagent** — a standalone AI instance with its own fresh memory (context window) that handles a sub-task independently. *Analogy:* a specialist with their own empty desk rather than one sharing the same cluttered table.
- **Ultraplan** — an especially thorough planning run in the cloud, suggested automatically for large stories (over 5 story points). *Analogy:* having the architect plan at length before a big remodel instead of swinging the hammer right away.
- **`/insights`** — a native end-of-sprint analysis that complements the framework's own sprint review. *Analogy:* a second opinion after your own retrospective. (skill `insights-review`)
- **Worker-equivalent** — the conversion of AI effort into "this many human work hours it would have cost", as an ROI anchor alongside raw token cost. *Analogy:* the exchange rate between AI time and person-days.
- **Status line** — Claude Code's native status line, here enriched with model, budget and worker-equivalent — the live dashboard of the work. *Analogy:* the dashboard showing speed and fuel at a glance.
- **Native-feature watch** — a monthly reminder that flags when a rebuilt feature has become natively available and should be re-evaluated. *Analogy:* the note "check whether you can now buy this off the shelf" before you keep tinkering.

## References

Technical short definitions: HANDBUCH **Appendix C**. How it's all documented together: [`how-we-document.en.md`](how-we-document.en.md).
