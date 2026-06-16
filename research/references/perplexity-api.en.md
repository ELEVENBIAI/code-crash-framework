# Perplexity via OpenRouter API integration

Perplexity models are called via OpenRouter — no separate Perplexity key required.

## Endpoint
`POST https://openrouter.ai/api/v1/chat/completions`

## Auth
`Authorization: Bearer ${OPENROUTER_API_KEY}`

## Models

| Model | OpenRouter name | Usage | Cost approx. |
|-------|-----------------|-------|--------------|
| `perplexity/sonar` | `perplexity/sonar` | QUICK fallback (when WebSearch is not enough) | $1/1M input, $1/1M output |
| `perplexity/sonar-deep-research` | `perplexity/sonar-deep-research` | DEEP tier (complex multi-aspect research) | $2/1M input, $8/1M output + $5/1000 searches |

## Request format (OpenAI-compatible)

```javascript
const https = require('https');

function callPerplexityViaOpenRouter(query, model = 'perplexity/sonar-deep-research') {
  const apiKey = process.env.OPENROUTER_API_KEY;

  const body = JSON.stringify({
    model,
    messages: [
      {
        role: 'system',
        content: 'You are a research assistant. Deliver precise, source-backed answers. Structure by aspect. Always cite sources.'
      },
      {
        role: 'user',
        content: query
      }
    ],
    max_tokens: 4096,
    return_citations: true
  });

  const options = {
    hostname: 'openrouter.ai',
    path: '/api/v1/chat/completions',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`,
      'HTTP-Referer': process.env.APP_URL || 'https://your-project.com',
      'X-Title': process.env.APP_NAME || 'YourProject'
    },
    timeout: 120000
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode !== 200) {
          return reject(new Error(`OpenRouter/Perplexity ${res.statusCode}: ${data.slice(0, 300)}`));
        }
        const json = JSON.parse(data);
        resolve({
          content: json.choices?.[0]?.message?.content || '',
          citations: json.citations || []
        });
      });
    });
    req.on('error', reject);
    req.on('timeout', () => { req.destroy(); reject(new Error('OpenRouter/Perplexity timeout (120s)')); });
    req.write(body);
    req.end();
  });
}
```

## Response format

```json
{
  "choices": [{
    "message": {
      "role": "assistant",
      "content": "Structured answer with source references [1][2]..."
    }
  }],
  "citations": [
    "https://example.com/source1",
    "https://example.com/source2"
  ],
  "usage": {
    "prompt_tokens": 150,
    "completion_tokens": 800
  }
}
```

## Notes
- `return_citations: true` returns a `citations[]` array with URLs
- The response references citations as `[1]`, `[2]` etc. in the text
- Timeout: 120s for sonar-deep-research (can take longer than the direct Perplexity API)
- `OPENROUTER_API_KEY` must be set in `.env` — no separate Perplexity key required
- No npm dependencies needed — pure `https` stdlib
