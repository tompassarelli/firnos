// SPDX-License-Identifier: MIT OR Apache-2.0

const modulePath = process.env.FIRN_DISPATCHER_MODULE
  ?? new URL('../lib/firn-dispatcher.js', import.meta.url).pathname;
const args = Bun.argv.slice(2);
const { run } = await import(modulePath);

process.exitCode = run(args);
