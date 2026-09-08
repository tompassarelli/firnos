// SPDX-License-Identifier: MIT OR Apache-2.0

const modulePath = process.env.FIRN_DISPATCHER_MODULE
  ?? new URL('../lib/firn-dispatcher.js', import.meta.url).pathname;
const args = Bun.argv.slice(2);
const clauseModule = process.env.FIRN_CLAUSE_HOST_LIST_MODULE;
const hostList = clauseModule ? await import(clauseModule) : undefined;

if (hostList?.handles(args)) {
  process.exitCode = hostList.run(process.env.FIRN_REPO, args);
} else {
const { run } = await import(modulePath);

const runtimeBin = process.env.FIRN_RUNTIME_BIN;
const bridge = Object.freeze({
  out(text) { process.stdout.write(text); },
  err(text) { process.stderr.write(text); },
  executeRuntime(name, args) {
    if (!runtimeBin) {
      process.stderr.write(
        'firn: FIRN_RUNTIME_BIN is not set by the user launcher\n',
      );
      return 127;
    }
    const child = Bun.spawnSync({
      cmd: [`${runtimeBin}/${name}`, ...args],
      env: process.env,
      stdin: 'inherit',
      stdout: 'inherit',
      stderr: 'inherit',
    });
    return child.exitCode;
  },
});

process.exitCode = run(bridge, args);
}
