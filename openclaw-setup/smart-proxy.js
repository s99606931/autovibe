// OpenClaw × Qwen3 SSE 호환 프록시 v5
// stream=true 요청 → non-streaming으로 변환 → SSE 재조립
// reasoning_content 완전 제거, /v1 URL 자동 보정
const http = require('http');

const TARGET = { host: '127.0.0.1', port: 1234 };
const PROXY_PORT = 11435;

function doRequest(opts, body) {
  return new Promise((resolve, reject) => {
    const req = http.request(opts, res => {
      const bufs = [];
      res.on('data', c => bufs.push(c));
      res.on('end', () => resolve({ status: res.statusCode, headers: res.headers, body: Buffer.concat(bufs) }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

// non-streaming JSON → SSE 스트림 변환
function toSSE(json) {
  const { id, created, model } = json;
  const choice = json.choices?.[0] || {};
  const msg = choice.message || {};
  const finishReason = choice.finish_reason;
  const lines = [];

  function chunk(delta, fr) {
    lines.push('data: ' + JSON.stringify({
      id, object: 'chat.completion.chunk', created, model,
      choices: [{ index: 0, delta, logprobs: null, finish_reason: fr || null }]
    }));
    lines.push('');
  }

  chunk({ role: 'assistant', content: '' });

  if (msg.tool_calls?.length > 0) {
    if (msg.content?.trim()) chunk({ content: msg.content });
    msg.tool_calls.forEach((tc, idx) => {
      chunk({ tool_calls: [{ index: idx, id: tc.id, type: 'function', function: { name: tc.function.name, arguments: '' } }] });
      const args = tc.function.arguments || '{}';
      for (let i = 0; i < args.length; i += 16) {
        chunk({ tool_calls: [{ index: idx, function: { arguments: args.slice(i, i + 16) } }] });
      }
    });
  } else {
    const content = msg.content || '';
    if (content) chunk({ content });
  }

  chunk({}, finishReason);
  lines.push('data: [DONE]');
  lines.push('');
  return lines.join('\n');
}

http.createServer((req, res) => {
  const chunks = [];
  req.on('data', c => chunks.push(c));
  req.on('end', async () => {
    const raw = Buffer.concat(chunks);
    let body = raw;
    let isStream = false;
    let hasTools = false;

    if (req.url.includes('chat/completions') && raw.length > 0) {
      try {
        const json = JSON.parse(raw.toString());
        isStream = json.stream === true;
        hasTools = !!(json.tools?.length);
        json.enable_thinking = false;
        if (!json.max_tokens) json.max_tokens = 8192;
        const toolCount = json.tools?.length || 0;
        console.log(`[proxy] ${req.url} | tools=${toolCount} | stream=${isStream} | msgs=${json.messages?.length}`);

        if (isStream) {
          // 모든 스트리밍 요청: non-streaming 어댑터로 처리
          json.stream = false;
          body = Buffer.from(JSON.stringify(json));
          const targetPath = req.url.startsWith('/v1/') ? req.url : '/v1' + req.url;
          const opts = {
            hostname: TARGET.host, port: TARGET.port, path: targetPath, method: req.method,
            headers: { ...req.headers, host: `${TARGET.host}:${TARGET.port}`, 'content-length': body.length, accept: 'application/json' },
          };
          try {
            const up = await doRequest(opts, body);
            if (up.status !== 200) {
              console.error(`[proxy] upstream ${up.status}:`, up.body.toString().slice(0, 200));
              res.writeHead(up.status, { 'content-type': 'application/json' });
              res.end(up.body);
              return;
            }
            const j = JSON.parse(up.body.toString());
            // reasoning_content 제거
            const msg = j.choices?.[0]?.message;
            if (msg?.reasoning_content !== undefined) delete msg.reasoning_content;
            const fr = j.choices?.[0]?.finish_reason;
            const tc = j.choices?.[0]?.message?.tool_calls;
            console.log(`[proxy] ← finish=${fr} | tool=${tc?.[0]?.function?.name || 'none'} | content=${JSON.stringify(msg?.content || '').slice(0,40)}`);
            res.writeHead(200, { 'content-type': 'text/event-stream', 'cache-control': 'no-cache', 'connection': 'keep-alive' });
            res.end(toSSE(j));
          } catch (e) {
            console.error('[proxy] adapter error:', e.message);
            res.writeHead(502);
            res.end(e.message);
          }
          return;
        }

        // 비스트리밍 패스스루
        body = Buffer.from(JSON.stringify(json));
      } catch (e) {
        console.log('[proxy] parse error:', e.message);
      }
    }

    const targetPath = (!isStream && req.url.includes('chat/completions') && !req.url.startsWith('/v1/'))
      ? '/v1' + req.url : req.url;
    const opts = {
      hostname: TARGET.host, port: TARGET.port, path: targetPath, method: req.method,
      headers: { ...req.headers, host: `${TARGET.host}:${TARGET.port}`, 'content-length': body.length },
    };
    const up = http.request(opts, upRes => {
      res.writeHead(upRes.statusCode, upRes.headers);
      upRes.pipe(res);
    });
    up.on('error', e => { console.error('[proxy] error:', e.message); res.writeHead(502); res.end(e.message); });
    up.write(body);
    up.end();
  });
}).listen(PROXY_PORT, '127.0.0.1', () => {
  console.log(`[smart-proxy v5] :${PROXY_PORT} → ${TARGET.host}:${TARGET.port}`);
  console.log('[smart-proxy] non-streaming adapter (all streams) + reasoning 제거');
});
