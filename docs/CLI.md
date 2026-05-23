# The `firn` CLI

Two surfaces over one graph: **daily shortcuts** for the common cases,
and the underlying **entity-first graph** for everything else.

## Daily shortcuts (preferred form)

The single-word commands. Defaults are auto-detected (current host,
`all` for aggregates) — no need to type them.

```
firn rebuild           build + validate + switch (current host)
firn build             regenerate .nix from .bnix
firn validate          lint + type / path check
firn impact            what will rebuild, estimated time
firn doctor            repo health check
firn status            enabled modules / bundles
firn enable <name>     toggle a module or bundle on
firn disable <name>    toggle off
firn diff              re-emit and diff vs committed .nix
firn diff --semantic   option-level changelog
```

These are first-class, not deprecated. `scripts/firn.rkt:316` lists
them in the help output as "Common shortcuts (default host is
auto-detected)". The dispatcher silently rewrites each to its
entity-first form; nothing is printed about it.

Run `firn` with no args to see the full grid; `firn <node>` for one
entity's edges.

## The underlying graph

Every command is ultimately a `<node> <edge> [<leaf>]` triple. Use this
form when you need to override defaults — rebuild a different host,
target a specific bundle, etc.

```
host    rebuild  [<host>]          firn-build → validate → nixos-rebuild → tag
host    status   [<host>]          enabled modules + bundles for a host
host    doctor   [<host>]          repo health check (untracked, stale, validator)
host    impact   [<host>]          dry-run preview: what will build, est. time
host    gen      [<host>]          current/next generation numbers
host    list     all               every host directory under hosts/

module  enable   <name>            toggle on in the default host
module  disable  <name>            toggle off
module  status   all               flat list of enabled modules
module  list     all|used|unused   list modules with optional usage filter
module  refs     <name>            show what references this module
module  add      <name>            scaffold a minimal module

bundle  enable   <name>            toggle bundle on in the default host
bundle  disable  <name>
bundle  status   <name>|all        per-bundle sub-toggle tree
bundle  list     all|used|unused
bundle  refs     <name>
bundle  add      <name>            scaffold a new (empty) bundle

repo    diff     [<target>]        re-emit Nix and diff vs committed .nix
repo    doctor   all               full repo health (5 checks)
repo    upgrade  now|dry-run       flake update + schema diff + revalidate
repo    watch    all               re-run validator on .bnix save

schema  explain  <path|err-line>   schema entry + repo references for an option
schema  extract  [<host>]          regenerate options schema cache
secret  list|show|edit <name>      sops list / decrypt / edit
tag     list|show|filter|index     module tag index
platform list|show|safelist        NixOS vs darwin compatibility report
template service|submodule|home|host <name>   scaffolded skeletons
```

Walks chain — `firn module list bundle list` runs both with default
leaves.

## Bulk auto-fix

```bash
beagle-validate --auto-fix
```

Rewrites unambiguous Levenshtein-distance typos across the whole tree.

## Native binary

```bash
./scripts/firn-build-bin
# → ~/.local/bin/firn (~1.3 MB, ~80ms cold start)
```

The wrapper exec's `racket` on bytecode, so Racket must be on `PATH`
(already provided by `bundles/racket`).
