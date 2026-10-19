const assert = require('node:assert/strict');
const addon = require(process.argv[2]);
assert.equal(addon.hello(), 'Hello from ungyp!');
console.log('Loaded addon successfully:', process.argv[2]);
