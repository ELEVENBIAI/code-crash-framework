# Perplexity API Integration

## Endpoint
`POST https://api.perplexity.ai/chat/completions`

## Auth
`Authorization: Bearer ${PERPLEXITY_API_KEY}`

## Modelle

| Modell | Verwendung | Kosten ca. |
|--------|-----------|-----------|
| `sonar` | QUICK-Fallback (wenn WebSearch nicht reicht) | $1/1M Input, $1/1M Output |
| `sonar-deep-research` | DEEP-Tier (komplexe Multi-Aspekt-Recherchen) | $2/1M Input, $8/1M Output |

## Request-Format (OpenAI-kompatibel)

```javascript
const https = require('https');

function callPerplexity(query, model = 'sonar-deep-research') {
  const apiKey = process.env.PERPLEXITY_API_KEY;

  const body = JSON.stringify({
    model,
    messages: [
      {
        role: 'system',
        content: 'Du bist ein Research-Assistent. Liefere praezise, quellengestuetzte Antworten. Strukturiere nach Aspekten. Nenne immer die Quellen.'
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
    hostname: 'api.perplexity.ai',
    path: '/chat/completions',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`
    },
    timeout: 60000
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode !== 200) {
          return reject(new Error(`Perplexity API ${res.statusCode}: ${data}`));
        }
        const json = JSON.parse(data);
        resolve({
          content: json.choices?.[0]?.message?.content || '',
          citations: json.citations || []
        });
      });
    });
    req.on('error', reject);
    req.on('timeout', () => { req.destroy(); reject(new Error('Perplexity timeout (60s)')); });
    req.write(body);
    req.end();
  });
}
```

## Response-Format

```json
{
  "choices": [{
    "message": {
      "role": "assistant",
      "content": "Strukturierte Antwort mit Quellenverweisen [1][2]..."
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

## Wichtig
- `return_citations: true` liefert ein `citations[]` Array mit URLs
- Die Response referenziert Citations als `[1]`, `[2]` etc. im Text
- Timeout: 60s fuer sonar-deep-research (kann laenger brauchen als sonar)
- Rate Limit: Abhaengig vom Perplexity-Plan (Free: 5/min, Pro: 50/min)
- Keine npm-Dependencies noetig — reines `https` stdlib
