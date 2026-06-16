---
name: research
description: |
  Deep Research skill: brings deep-research capabilities to Claude Code. Since Claude Code
  has no built-in deep research (only a simple WebSearch), this skill uses Perplexity
  sonar-deep-research as its deep-research engine — combined with WebSearch for cross-checking
  and supplementation. Automatic 2-tier routing: QUICK (WebSearch) for simple facts, DEEP
  (Perplexity Deep Research + WebSearch validation) for complex analyses.
  Use when the user says "research", "look into", "find out", "what do we know about",
  "deep research", "analyze" or "/research".
version: 1.2.0
requires_secrets:
  - key: PERPLEXITY_API_KEY
    service: Perplexity AI
    url: https://www.perplexity.ai/settings/api
    description: API key for the Perplexity sonar/sonar-deep-research models
    hint: "Starts with 'pplx-', 40+ characters"
    required: true
---

# Deep Research for Claude Code

## Why this skill?

Claude Code has **no built-in deep research** — only a simple WebSearch.
The deep-research feature from the Claude web app is not available in Claude Code.

This skill closes that gap:
- **Perplexity sonar-deep-research** serves as the deep-research engine (researches internally across dozens of sources, synthesizes, returns citations)
- **Claude WebSearch** complements it as fast validation and cross-check
- Together they yield reliable, source-backed in-depth research right inside Claude Code

## 2-tier routing

Analyze the complexity of the question, then route automatically:

### QUICK (default)
- **When:** fact checks, current prices/data, "What is X?", short answers
- **What happens:** Claude WebSearch with 1-3 parallel searches
- **Duration:** seconds
- **Cost:** $0 (built in)

### DEEP (for complex questions or explicit "/research deep ...")
- **When:** market analyses, comparisons, "How does X work in detail?", multi-aspect questions, anything where the user explicitly says "deep"
- **What happens:**
  1. **Perplexity sonar-deep-research** performs the main research — internally searches many sources, synthesizes results, returns citations
  2. **Claude WebSearch** runs in parallel with different search terms as cross-check and supplement
  3. Results are merged, contradictions flagged
- **Duration:** 10-60 seconds
- **Cost:** ~$0.01-0.05 per request

### Routing decision
Choose DEEP automatically when:
- The question contains comparisons ("X vs Y", "alternatives to")
- The question requires multi-aspect analysis ("pros and cons", "architecture of")
- The question concerns current market data with context ("how is X evolving and why")
- The user explicitly says "deep", "detailed", "in detail"

## Workflow

### Step 1: Sharpen the question
- What exactly should be researched?
- Which context is relevant?
- If unclear: ask the user

### Step 2: Pick the tier + research

**QUICK:**
1. WebSearch with 1-3 targeted search terms (in parallel)
2. Extract and merge relevant results

**DEEP:**
1. Run the Perplexity API call with `sonar-deep-research` (see [references/perplexity-api.en.md](references/perplexity-api.en.md))
   - Perplexity researches internally across many sources and returns a synthesized answer with citations
2. In parallel: WebSearch for cross-check/supplement (deliberately different search terms than the Perplexity request)
3. Merge results:
   - Agreements strengthen confidence
   - Contradictions are flagged explicitly
   - Supplementary info from WebSearch is added

### Step 3: Structure the result

Every research answer MUST contain:

1. **Summary** — 2-3 sentences, a direct answer to the question
2. **Details** — structured by the aspects of the question. For APIs: endpoints, auth, rate limits, cost. For technologies: architecture, pros/cons, alternatives.
3. **Sources** — URLs with title, separated by origin:
   - `[Deep Research]` title — URL (from Perplexity citations)
   - `[WebSearch]` title — URL (from Claude WebSearch)
4. **Confidence** — high / medium / low (based on source agreement between Deep Research and WebSearch)
5. **Tier** — which tier was used and why

### Step 4: Preserve context
- Deliver research results as raw data + synthesis
- Do NOT overwrite the running context of the parent task
- Return results, do not process them further on your own
