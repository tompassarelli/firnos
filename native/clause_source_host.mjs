// SPDX-License-Identifier: MIT OR Apache-2.0

import { mkdirSync, mkdtempSync, readFileSync, rmdirSync, unlinkSync } from 'node:fs';
import { createRequire } from 'node:module';
import { join } from 'node:path';

const load = createRequire(import.meta.url);

export function readTextSequenceSource(compiler, source, entry, outputRoot, maximum) {
  let directory;
  try {
    if (readFileSync(source).length > maximum) {
      throw new Error(`source exceeds ${maximum} bytes`);
    }
    mkdirSync(outputRoot, { recursive: true });
    directory = mkdtempSync(join(outputRoot, 'source-'));
    const output = join(directory, 'source.js');
    const compiled = Bun.spawnSync([compiler, 'compile-js', source, output], {
      stdout: 'pipe', stderr: 'pipe', timeout: 120000,
    });
    if (compiled.exitCode !== 0) {
      throw new Error(compiled.stderr.toString() || `compiler exited ${compiled.exitCode}`);
    }
    const callable = load(output)[entry];
    if (typeof callable !== 'function') throw new Error(`missing exported callable ${entry}`);
    const value = callable();
    if (!Array.isArray(value) || value.some(item => typeof item !== 'string')) {
      throw new Error(`${entry} must return Sequence<Text>`);
    }
    return Object.freeze({ status: 0, value: Object.freeze([...value]), message: '' });
  } catch (error) {
    return Object.freeze({ status: Math.abs(Number(error?.errno)) || 1,
      value: null, message: String(error?.message ?? error) });
  } finally {
    if (directory) {
      for (const name of ['source.js', 'source.d.ts']) {
        const file = join(directory, name);
        delete load.cache[file];
        try { unlinkSync(file); } catch (error) { if (error.code !== 'ENOENT') throw error; }
      }
      rmdirSync(directory);
    }
  }
}
