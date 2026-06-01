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
firn status            modules enabled directly in configuration.bnix
firn tag status        enabled-tags.bnix + resolved active modules
firn enable <name>     enable a tag (or un-blacklist a module if <name> is a module)
firn disable <name>    disable a tag (or hard-off a module)
firn diff              re-emit and diff vs committed .nix
firn diff --semantic   option-level changelog
```

These are first-class, not deprecated. `scripts/firn.rkt` lists them
in the help output as "Common shortcuts (default host is
auto-detected)". The dispatcher silently rewrites each to its
entity-first form; nothing is printed about it.

`firn enable <name>` / `firn disable <name>` route based on what `<name>`
is: a tag (the default) mutates the host's `enabled-tags.bnix :enabled`
vector; a known module routes to `firn module enable/disable`, which
removes from / appends to `:disabled`.

Run `firn` with no args to see the full grid; `firn <node>` for one
entity's edges.

## The underlying graph

Every command is ultimately a `<node> <edge> [<leaf>]` triple. Use this
form when you need to override defaults — rebuild a different host,
target a specific tag, etc.

```
host    rebuild  [<host>]          firn-build → validate → nixos-rebuild → tag
host    status   [<host>]          enabled modules from configuration.bnix
host    doctor   [<host>]          repo health check (untracked, stale, validator)
host    impact   [<host>]          dry-run preview: what will build, est. time
host    gen      [<host>]          current/next generation numbers
host    list     all               every host directory under hosts/

module  enable   <name>            remove <name> from :disabled in enabled-tags.bnix
module  disable  <name>            append <name> to :disabled (hard off)
module  status   all               flat list of enabled modules
module  list     all|used|unused   list modules with optional usage filter
module  refs     <name>            show what references this module
module  add      <name>            scaffold a minimal module

tag     enable   <name>            add <name> to :enabled (no flags)
tag     disable  <name>            remove <name> from :enabled
tag     opt-in   <tag> <module>    add +<module> under <tag> in :enabled
tag     opt-out  <tag> <module>    add -<module> under <tag> in :enabled
tag     status   [<host>]          dump :enabled / :disabled + resolved active set
tag     list     all               tag universe + module counts
tag     show     <module>          tags / opt-in tags / overrides for one module
tag     filter   <tag>             modules carrying that tag
tag     resolve  <host>            per-tag contributions + unions + final set
tag     index    repo|stdout       jsonl tag index

repo    diff     [<target>]        re-emit Nix and diff vs committed .nix
repo    doctor   all               full repo health (5 checks)
repo    upgrade  now|dry-run       flake update + schema diff + revalidate
repo    watch    all               re-run validator on .bnix save

schema  explain  <path|err-line>   schema entry + repo references for an option
schema  extract  [<host>]          regenerate options schema cache
secret  list|show|edit <name>      sops list / decrypt / edit
platform list|show|safelist        NixOS vs darwin compatibility report
template service|submodule|home|host <name>   scaffolded skeletons
```

**Note:** the `bundle` node was removed — composition is tag-driven now.
`firn bundle …` prints a pointed error directing you to the equivalent
`firn tag …` form.

Walks chain — `firn module list tag list` runs both with default leaves.

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
(already provided by `modules/racket`, pulled in by the `lisp` tag).
