// json-server 0.17 (stable programmatic API) with /v1 versioning + {data, error, meta} envelope.
const path = require('path');
const jsonServer = require('json-server');

const PORT = Number(process.env.PORT || 3000);
const LATENCY_MS = Number(process.env.LATENCY_MS || 0);
const FAIL_RATE = Number(process.env.FAIL_RATE || 0);
const API_VERSION = 1;

const server = jsonServer.create();
const router = jsonServer.router(path.join(__dirname, 'data', 'db.json'));

server.use('/static', require('express').static(path.join(__dirname, 'public')));
server.use(jsonServer.defaults({ static: path.join(__dirname, 'public'), logger: true }));

server.use((req, res, next) => setTimeout(next, LATENCY_MS));
server.use((req, res, next) => {
  if (FAIL_RATE > 0 && Math.random() < FAIL_RATE) {
    return res.status(503).jsonp(envelope(null, { code: 'UNAVAILABLE', message: 'Simulated outage' }));
  }
  next();
});

// Read-only API: the app never writes public data.
server.use((req, res, next) =>
  req.method === 'GET' ? next() : res.status(405).jsonp(envelope(null, { code: 'METHOD_NOT_ALLOWED', message: 'Read-only' })));

server.get('/v1/health', (req, res) => res.jsonp(envelope({ status: 'ok' })));
server.use(jsonServer.rewriter({ '/v1/*': '/$1' }));

function envelope(data, error = null) {
  const meta = { version: API_VERSION, updatedAt: router.db.get('meta.updatedAt').value() };
  if (Array.isArray(data)) meta.count = data.length;
  return { data, error, meta };
}

router.render = (req, res) => {
  const body = res.locals.data;
  const notFound = res.statusCode === 404 || (body && typeof body === 'object' && !Array.isArray(body) && Object.keys(body).length === 0);
  if (notFound) return res.status(404).jsonp(envelope(null, { code: 'NOT_FOUND', message: `${req.path} not found` }));
  res.jsonp(envelope(body));
};

server.use(router);
server.listen(PORT, () => console.log(`J'Donuts mock API → http://localhost:${PORT}/v1`));
