const assert = require('node:assert/strict');
const { spawn } = require('node:child_process');
const { createHash } = require('node:crypto');
const fs = require('node:fs');
const http = require('node:http');
const path = require('node:path');

const [cmake, source, directory] = process.argv.slice(2);
const payload = 'verified SDK download';
const hash = createHash('sha256').update(payload).digest('hex');
const servers = [];
const requests = [];
const directEnvironment = Object.fromEntries(Object.entries(process.env).filter(
  ([name]) => !/^(http|https|all|no)_proxy$/i.test(name),
));
fs.mkdirSync(directory, { recursive: true });
const driver = path.join(directory, 'download.cmake');
fs.writeFileSync(driver, [
  'cmake_minimum_required(VERSION 3.24)',
  `include("${source.replaceAll('\\', '/')}/cmake/internal/Download.cmake")`,
  '_ungyp_download("${URL}" "${OUTPUT}" "' + hash + '")',
  '',
].join('\n'));

async function listen(server) {
  servers.push(server);
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  return server.address().port;
}

function download(name, url, options = [], environment = {}) {
  const output = path.join(directory, name);
  fs.rmSync(output, { force: true });
  return new Promise((resolve, reject) => {
    const child = spawn(cmake, [`-DURL=${url}`, `-DOUTPUT=${output}`, ...options, '-P', driver], {
      env: {
        ...directEnvironment,
        ...environment,
      },
    });
    let log = '';
    child.stdout.on('data', chunk => { log += chunk; });
    child.stderr.on('data', chunk => { log += chunk; });
    child.on('error', reject);
    child.on('exit', code => {
      assert.equal(fs.existsSync(`${output}.part`), false, log);
      resolve({ code, log, output });
    });
  });
}

async function main() {
  const port = await listen(http.createServer((request, response) => {
    requests.push(request.url);
    if (request.url === '/timeout') return;
    if (request.url === '/missing') {
      response.writeHead(404).end();
    } else if (request.url === '/auth' && request.headers.authorization !== 'Basic dXNlcjpwYXNz') {
      response.writeHead(401).end();
    } else {
      response.end(payload);
    }
  }));
  const proxyPort = await listen(http.createServer((request, response) => {
    assert.equal(request.url, 'http://ungyp.invalid/sdk');
    response.end(payload);
  }));
  const proxy = await download('proxy', 'http://ungyp.invalid/sdk', [], {
    http_proxy: `http://127.0.0.1:${proxyPort}`,
  });
  assert.equal(proxy.code, 0, proxy.log);

  const netrc = path.join(directory, 'netrc');
  fs.writeFileSync(netrc, 'machine 127.0.0.1 login user password pass\n', { mode: 0o600 });
  const auth = await download('auth', `http://127.0.0.1:${port}/auth`, [
    '-DCMAKE_NETRC=REQUIRED', `-DCMAKE_NETRC_FILE=${netrc}`,
  ]);
  assert.equal(auth.code, 0, auth.log);
  const missing = await download('missing', `http://127.0.0.1:${port}/missing`);
  assert.notEqual(missing.code, 0, missing.log);
  assert.equal(requests.filter(url => url === '/missing').length, 1, 'No automatic retry');
  const timeout = await download('timeout', `http://127.0.0.1:${port}/timeout`, [
    '-DUNGYP_DOWNLOAD_TIMEOUT=1', '-DUNGYP_DOWNLOAD_INACTIVITY_TIMEOUT=1',
  ]);
  assert.notEqual(timeout.code, 0, timeout.log);

  assert.equal(fs.readFileSync(auth.output, 'utf8'), payload);
  console.log('Proxy, netrc, timeout and single-attempt failures passed');
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
}).finally(() => {
  for (const server of servers) {
    server.closeAllConnections();
    server.close();
  }
});
