# Provider Postflight

Goal: Bootstrap separates **locally installed artifacts** from **externally verified providers**. A skill or configuration file does not make GitHub, Linear, Research, Miro, Grafana, or Obsidian sync operational by itself.

## Status model

| Status | Meaning |
|---|---|
| `OK` | Provider was selected and the connection was verified, or the operator consciously confirmed it as already active. |
| `WARN` | Artifact or selection exists, but verification, credential, account, MCP, or live test is missing. |
| `SKIP` | Provider was intentionally deselected or is not relevant for this project. |
| `FAIL` | Provider should be active, but verification failed or is blocked. |

Secrets are never shown, never written into repository files, and never copied into closing reports. Only existence or live-test result may be checked.

## Required matrix in the closing report

| Provider | Local artifact | Credential exists | Live test | Status | Next action |
|---|---|---|---|---|---|
| GitHub | Remote / `.github/` | n/a | `git ls-remote` or `gh repo view` | OK/WARN/SKIP/FAIL | Create remote, repair auth, or continue deliberately without GitHub |
| Backlog | Backlog Record / adapter config | only when API/MCP is used | Linear/GitHub/Jira/Azure/Planner reachable | OK/WARN/SKIP/FAIL | Activate adapter or document Markdown-only |
| Research | `research` skill or companion source | `PERPLEXITY_API_KEY`, OpenRouter key, or MCP | optional probe call without secret output | OK/WARN/SKIP/FAIL | Set up provider or mark Research as offline/companion |
| Visualize/Miro | `visualize` skill / diagram fallback | Miro auth or MCP config | Miro MCP tool reachable | OK/WARN/SKIP/FAIL | Connect Miro or set Excalidraw/Mermaid as fallback |
| Monitoring | `docs/MONITORING.md`, Grafana/Sonar/health concept | provider-specific | dashboard/API/health check reachable | OK/WARN/SKIP/FAIL | Use central platform, prepare own setup, or document architecture question |
| Obsidian | Vault path / DocSync | n/a | path exists and optional write test | OK/WARN/SKIP/FAIL | Fix vault path or document repo-only mode |

> **SonarCloud (external provider, BOO-58/119):** With SonarQube Cloud enabled (D.5 = yes), the provider postflight is where the **SonarCloud-side** setup is checked (org/project key/`SONAR_TOKEN` secret). Step by step: **HANDBUCH Appendix AA** (two scenarios: account exists / from zero). Without a valid token, `sonar.yml` fails red and blocks the first merge (see BOO-122).

## Monitoring and logging question

Bootstrap asks:

```text
Is there an existing monitoring/logging platform?
  a) Yes, use the central platform
  b) No, prepare a project-owned monitoring setup
  c) Not clear yet, document as an architecture question
```

The logging contract must at least define:

- log format,
- storage or transport,
- required fields: `timestamp`, `level`, `service`, `run_id`, `trace_id`, `message`,
- forbidden contents: secrets, tokens, cookies, raw personal data,
- metrics,
- health endpoints,
- responsible owner.

Artifact: `docs/MONITORING.md` or a clearly marked section in `GOVERNANCE.md` / `observability.md`.

## Research decision

Bootstrap asks:

```text
Research skill source (a vendored bundle skill since BOO-219, in the Minimum set):
  a) included in INTENTRON (default — installed in Phase 5)
  b) already installed globally
  c) do not install

Provider:
  a) local Perplexity MCP
  b) direct Perplexity API
  c) OpenRouter
  d) no provider
```

Rule: Research may only be marked `OK` when skill source and provider status were evaluated separately. Without a provider, Research is `WARN` or `SKIP`, not `OK`.

## Visualize and Miro decision

Bootstrap asks:

```text
Visualization:
  - Should the visualize skill be installed?
  - Should Miro be used as the diagram target?
  - Is a Miro account available?
  - Is Miro MCP configured?
  - Should the connection be tested?
  - Fallback: Excalidraw / Mermaid / none?
```

Closing report:

```text
Visualize Skill: OK / WARN / SKIP / FAIL
Miro MCP: OK / WARN / SKIP / FAIL
Diagram fallback: Excalidraw / Mermaid / none
```

## Write rule

Provider postflight writes only this into project artifacts:

- status,
- source or adapter,
- last verification as date/short note,
- next action.

It never writes:

- API keys,
- tokens,
- cookies,
- private URLs with credentials,
- raw personal data,
- local session files.
