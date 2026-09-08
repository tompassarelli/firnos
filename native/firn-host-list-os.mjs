// SPDX-License-Identifier: MIT OR Apache-2.0
import { lstatSync, readdirSync } from 'node:fs';

/** @param {unknown} error @returns {number} */
function errno(error) {
  return error instanceof Error && 'errno' in error && typeof error.errno === 'number'
    ? Math.abs(error.errno) : 1;
}

/** @param {string} path @returns {{ status: number, names: readonly string[] }} */
export function listDirectory(path) {
  try {
    return { status: 0, names: readdirSync(path) };
  } catch (error) {
    return { status: errno(error), names: [] };
  }
}

/** @param {string} path @returns {{ status: number, kind: number }} */
export function pathKind(path) {
  try {
    const stat = lstatSync(path);
    return { status: 0, kind: stat.isDirectory() ? 2 : stat.isSymbolicLink() ? 3 : 1 };
  } catch (error) {
    return { status: errno(error), kind: 0 };
  }
}
