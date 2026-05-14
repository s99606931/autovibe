// LMStudio 프록시 — OpenClaw의 tool-calling 요청을 gemma 호환 형식으로 변환
// gemma-4-e4b-it는 tool_choice=auto 시 응답 포맷이 맞지 않아 tool_choice=none + tools=[] 주입
const http = require('http');

const TARGET = { host: '127.0.0.1', port: 1234 };
const PROXY_PORT = 11435;

http.createServer((req, res) => {
  let chunks = [];
  req.on('data', c => chunks.push(c));
  req.on('end', () => {
    const raw = Buffer.concat(chunks);
    let body = raw;

    if (req.url.includes('chat/completions') && raw.length > 0) {
      try {
        const json = JSON.parse(raw.toString());
        const toolCount = json.tools ? json.tools.length : 0;
        console.log(`[proxy] ${req.url} | tools=${toolCount} | tool_choice=${json.tool_choice || 'unset'} | ${raw.length}b`);

        json.tool_choice = 'none';
        json.tools = [];
        body = Buffer.from(JSON.stringify(json));
        console.log('[proxy] → tools stripped, tool_choice=none');
      } catch (e) {
        console.log('[proxy] parse error:', e.message);
      }
    }

    const opts = {
      hostname: TARGET.host,
      port: TARGET.port,
      path: req.url,
      method: req.method,
      headers: {
        ...req.headers,
        host: TARGET.host + ':' + TARGET.port,
        'content-length': body.length,
      },
    };

    const upstream = http.request(opts, upRes => {
      const resChunks = [];
      upRes.on('data', c => resChunks.push(c));
      upRes.on('end', () => {
        if (req.url.includes('chat/completions')) {
          try {
            const rj = JSON.parse(Buffer.concat(resChunks).toString());
            const content = rj.choices?.[0]?.message?.content || '';
            const finish = rj.choices?.[0]?.finish_reason || '';
            console.log(`[proxy] ← finish=${finish} content="${content.slice(0, 80)}"`);
          } catch (_) {}
        }
      });
      res.writeHead(upRes.statusCode, upRes.headers);
      upRes.pipe(res);
    });

    upstream.on('error', err => {
      console.error('[proxy] upstream error:', err.message);
      res.writeHead(502);
      res.end('Proxy error: ' + err.message);
    });

    upstream.write(body);
    upstream.end();
  });
}).listen(PROXY_PORT, '127.0.0.1', () => {
  console.log(`[proxy] http://127.0.0.1:${PROXY_PORT} → http://${TARGET.host}:${TARGET.port}`);
  console.log('[proxy] gemma tool-call 호환 레이어 활성화');
});
