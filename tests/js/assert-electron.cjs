const { spawnSync } = require('node:child_process');
const path = require('node:path');

for (const addon of process.argv.slice(3)) {
  // Electron is a GUI executable on Windows. Explicitly wait and capture its exit
  // status so a shell cannot report success before the addon has been loaded.
  const result = spawnSync(path.resolve(process.argv[2]), [
    path.join(__dirname, 'assert-addon.cjs'), path.resolve(addon),
  ], {
    env: { ...process.env, ELECTRON_RUN_AS_NODE: '1' },
    stdio: 'inherit',
    timeout: 30000,
  });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status || 1);
}
