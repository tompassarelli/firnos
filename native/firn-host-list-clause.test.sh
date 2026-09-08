#!/usr/bin/env bash
set -euo pipefail

bun=${FIRN_BUN:-$(command -v bun)}
tsc=${FIRN_TYPESCRIPT_BIN:?set FIRN_TYPESCRIPT_BIN to TypeScript 5.9.3 tsc.js}
repo=$(cd "$(dirname "$0")/.." && pwd)
oracle=${FIRN_HOST_LIST_ORACLE:-$HOME/code/nixos-config/main/dotfiles/bin/firn} # hardcoded-repo-path:allow
scratch=$(mktemp -d "${TMPDIR:-/tmp}/firn-host-list-clause.XXXXXX")
trap 'rm -rf -- "$scratch"' EXIT

compare() {
  local data_root=$1 label=$2 expected_status=$3
  shift 3
  local actual_status=0 oracle_status=0
  FIRN_REPO="$data_root" FIRN_BUN="$bun" FIRN_RUNTIME_ROOT="$scratch/uninstalled" \
    "$repo/dotfiles/bin/firn" "$@" >"$scratch/actual.out" 2>"$scratch/actual.err" \
    || actual_status=$?
  FIRN_REPO="$data_root" "$oracle" "$@" >"$scratch/oracle.out" 2>"$scratch/oracle.err" \
    || oracle_status=$?
  [[ $actual_status -eq $expected_status && $oracle_status -eq $expected_status ]]
  cmp "$scratch/actual.out" "$scratch/oracle.out"
  cmp "$scratch/actual.err" "$scratch/oracle.err"
  printf 'ok: %s\n' "$label"
}

mkdir -p "$scratch/multiple/hosts/zeta" "$scratch/multiple/hosts/alpha" "$scratch/multiple/hosts/mid"
: >"$scratch/multiple/hosts/plain-file"
ln -s zeta "$scratch/multiple/hosts/link"
compare "$scratch/multiple" directories-only 0 host list all
printf 'Hosts (3):\n  alpha\n  mid\n  zeta\n' >"$scratch/expected.out"
cmp "$scratch/actual.out" "$scratch/expected.out"
[[ ! -s "$scratch/actual.err" ]]

mkdir -p "$scratch/single/hosts/solo" "$scratch/empty/hosts" "$scratch/missing" "$scratch/bad"
compare "$scratch/single" single 0 host list
compare "$scratch/empty" empty 0 host list all
compare "$scratch/missing" missing 0 host list
: >"$scratch/bad/hosts"
compare "$scratch/bad" ENOTDIR 1 host list all
[[ ! -s "$scratch/actual.out" ]]
printf "firn tag resolve: cannot list 'hosts': errno 20\n" >"$scratch/expected.err"
cmp "$scratch/actual.err" "$scratch/expected.err"

compare "${FIRN_REAL_REPO:-$HOME/code/nixos-config/main}" real-repository 0 host list all # hardcoded-repo-path:allow

"$bun" "$tsc" --noEmit --strict --module esnext --moduleResolution bundler --target es2022 \
  "$repo/native/firn-host-list-consumer.ts"
"$bun" --eval 'const {listedHosts} = await import(Bun.argv[1]); process.stdout.write(listedHosts(Bun.argv[2]));' \
  "$repo/native/firn-host-list-consumer.ts" "$scratch/multiple" >"$scratch/typed.out"
cmp "$scratch/typed.out" "$scratch/expected.out"
printf 'ok: generated declarations consumed by TypeScript and executed in Bun\n'
