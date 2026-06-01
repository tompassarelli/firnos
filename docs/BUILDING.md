# Building FirnOS

FirnOS is authored in [nisp](https://github.com/tompassarelli/nisp) — a Racket
`#lang` for writing Nix as s-expressions. nisp ships the language plus the
full validation toolchain as a single dispatcher (`nisp validate`,
`nisp extract-schema`, `nisp edit`, `nisp rename`, `nisp import`,
`nisp schema`) plus the `nisp-lsp` server; FirnOS is one consumer of that
toolchain.

- **nisp** ([repo](https://github.com/tompassarelli/nisp)) — language + library + CLI
- **firnos** (this repo) — modules, tags, hosts, scaffolding, the `firn` CLI for daily workflow

`scripts/firn-validate` and `scripts/firn-extract-schema` in this repo
are thin wrappers — they invoke `nisp validate` / `nisp extract-schema`
with FirnOS-specific defaults (NixOS target, HM allowlist for the
home-manager skip-heuristic).

Every `*.nix` file in this repo is generated from a sibling `*.rkt` source by
`scripts/firn-build`. The `.rkt` files are source-of-truth. The `.nix` files
are committed because the flake reads from the git tree (`nixos-rebuild` needs
them visible).

## Bootstrap

```bash
git clone https://github.com/tompassarelli/firnos
git clone https://github.com/tompassarelli/nisp     # sibling clone — firn-build expects ../nisp
# or set NISP_PATH=/wherever/you/cloned/nisp
cd firnos
./scripts/firn-build                                  # links nisp via raco pkg, regenerates .nix
sudo nixos-rebuild switch --flake .#my-machine
```

## Pipeline

```
*.rkt   ──(racket file.rkt > file.nix)──>   *.nix   ──(nixos-rebuild)──>   system
```

1. Author / edit a `*.rkt` file using `#lang nisp`.
2. Run `./scripts/firn-build` to regenerate every `*.nix` whose `.rkt` source
   has changed.
3. `git add` both files.
4. `nixos-rebuild switch` (or `firn host rebuild`) builds from the regenerated
   `flake.nix`.

`firn-build` is idempotent and only re-runs `racket` for `.rkt` files that are
newer than their `.nix` output, so re-running it after a clean build is a
no-op.

## The `firn` CLI

`scripts/firn.rkt` is a Racket-based CLI that wraps the routine config
operations. The grammar is entity-first and walkable: every invocation
is one or more `<node> <edge> [<leaf>]` triples. Leaves default
sensibly when omitted (`'all` for aggregate views, current-hostname
for host-scoped commands), and walks can be chained for batches.
Command implementations live in `scripts/firn-cmds/*.rkt`; `firn.rkt`
itself is dispatcher + legacy-alias rewriter. Highlights:

- `firn module enable <name>` / `firn module disable <name>` — syntax-aware host-config edits to `enabled-tags.bnix` (`:disabled` list). `enable` un-blacklists a module; `disable` appends to the hard-off list.
- `firn tag enable <tag>` / `firn tag disable <tag>` / `firn tag opt-in <tag> <module>` / `firn tag opt-out <tag> <module>` / `firn tag status` — mutate `hosts/<host>/enabled-tags.bnix` directly. `enable`/`disable` add/remove tags from the `:enabled` vector; `opt-in`/`opt-out` add `+<module>` / `-<module>` flags under a tag.
- `firn host status` — flat enabled-modules list (modules pulled in directly or via tag resolution)
- `firn schema explain <path | validator-error-line>` — show the schema entry, declarations, and every `.rkt` that references the path. Accepts pasted validator errors directly (extracts the path)
- `firn repo doctor` — five-check repo health report (untracked .bnix/.nix, stale .nix, schema cache, orphaned modules, validator)
- `firn repo upgrade now` / `firn repo upgrade dry-run` — bump flake inputs, re-extract schema, diff vs the previous snapshot, and surface deprecated/type-changed paths that this repo references
- `firn repo diff` — re-emit Nix from `.bnix` and unified-diff against committed `.nix` (drift sentinel)
- `firn module list <all|used|unused>` / `firn module refs <name>` / `firn module add <name>` / `firn template <service|submodule|home|host> <name>` — module introspection and scaffolding (`template service` queries the schema cache and pre-fills commented stubs). `firn module list unused` finds dead modules — modules not enabled by any host directly or transitively via a tag.
- `firn tag list` / `firn tag show <module>` / `firn tag filter <tag>` / `firn tag resolve <host>` / `firn tag index` — tag-driven composition. Tags are the only composition mechanism (the legacy `bundle` node has been removed). Sources: explicit `:tags` and `:tags-opt-in` clauses in the module source. `tag index` writes a regenerable jsonl to `.beagle-cache/tags.jsonl`; pass leaf `stdout` to pipe instead.
- `firn platform list` / `firn platform show <name>` / `firn platform safelist` — schema-driven cross-platform compatibility report (NixOS vs darwin). See `docs/MACOS.md`.
- `firn secret list|show|edit` / `firn host gen` — sops wrapper and generation numbers

Old top-level shapes (`firn status`, `firn doctor`, `firn rebuild`, `firn tags`, `firn platforms`, …) still work with a one-line deprecation pointing to the new form, so muscle memory degrades gracefully.

`scripts/firn.rkt` is invokable directly via `racket scripts/firn.rkt …`
but for daily use it should be compiled. `firn-build-bin` uses `raco demod`
(whole-program optimizer + dead-code elimination) for a small fast result:

```
./scripts/firn-build-bin
# → ~/.local/share/firn/firn.zo   (~1.3 MB bytecode)
# → ~/.local/bin/firn             (~75 byte wrapper)

firn help                          # ~80ms cold start
```

The wrapper exec's `racket` on the bytecode, so the system needs Racket
on PATH (already provided by `modules/racket`). Add `~/.local/bin` to
PATH if it isn't already.

## `firn host rebuild` and `nh`

`firn host rebuild` runs `firn-build → firn-validate → rebuild → tag generation`.
The rebuild step prefers [`nh`](https://github.com/nix-community/nh) (a
Rust wrapper around `nixos-rebuild`) when it's on PATH — `nh os switch`
gives nicer progress output, a generation diff after activation, and
handles `sudo` itself. `modules/nh/default.rkt` installs it.

When `nh` isn't available, `firn host rebuild` falls back to
`sudo nixos-rebuild switch --flake …` automatically. To force the
fallback, remove `nh` from your config or use `--skip-checks` and call
`nixos-rebuild` directly.

## Validation: catching typos before `nixos-rebuild`

`scripts/firn-validate` checks every `(set …)` and `(enable …)` path in
your `.rkt` sources against the cached NixOS options schema. Typos are
caught at the source line — no waiting for Nix evaluation:

```
$ ./scripts/firn-validate
modules/printing/default.rkt:6:7: unknown option services.pipwire.alsa.enable
  did you mean: services.pipewire.alsa.enable or services.pipewire.pulse.enable?
```

The schema is extracted once into `.firn-build/schema.json` (gitignored).
Regenerate after `nix flake update` or after adding/changing options
in your own modules:

```
./scripts/firn-extract-schema             # default: whiterabbit
./scripts/firn-extract-schema thinkpad-x1e # other host
```

The validator skips paths inside `(home-of …)` bodies (they're inside
home-manager submodules our schema doesn't go into), paths with `${…}`
interpolation, and paths whose first segment is one of a small set of
common HM/submodule roots (`programs`, `home`, `xdg`, etc.). This trades
some false negatives for zero false positives — real typos in *those*
namespaces still surface at Nix-eval time.

## Required modules

The pipeline runs `racket` on every `.bnix` source, so racket must be on the
system that does the rebuild. Two things are load-bearing:

| Path                   | Why it's required                                              |
| ---------------------- | -------------------------------------------------------------- |
| `modules/racket`       | Installs `pkgs.racket-minimal` — the interpreter `firn-build` invokes. Pulled in via the `lisp` tag (or by enabling the module directly). |
| `../beagle` (sibling)  | The DSL implementation. `firn-build` registers it via `raco pkg install --link` against `$BEAGLE_PATH` (default `../beagle`). |

Make sure `modules/racket` ends up in the active set on every host that runs
`firn-build`. Either enable a tag whose membership includes `racket`
(e.g. `lisp`), or `firn module enable racket` (un-blacklists it if needed).

Without `modules/racket` active, the *system* will lack `racket`, and the
next `firn-build` invocation will fail with `racket: command not found`.

`modules/drracket` is optional — useful if you want to author `.bnix` sources
in the IDE, but `firn-build` itself only needs the `racket` interpreter from
`modules/racket`.

## Authoring a new module

For a typical "install one package" module like `modules/<name>/default.rkt`:

```racket
#lang nisp

(module-file modules <name>
  (desc "<one-line description>")
  (config-body
    (set environment.systemPackages (with-pkgs <name>))))
```

Then:

```bash
./scripts/firn-build
git add modules/<name>/default.rkt modules/<name>/default.nix
```

The flake's dynamic `imports = ...` (in `flake.rkt`'s inline module) picks up
every directory under `modules/`, so no flake change is required when you add
a new module.

## Authoring a new tag

Tags are not authored as files — they emerge from `:tags` / `:tags-opt-in`
clauses in module sources. To introduce a new tag, add it to the `:tags`
list of every module that should join it by default, and to `:tags-opt-in`
on modules that should be opt-in-only:

```clojure
:tags [terminal lisp]                  ;; default-on memberships
:tags-opt-in [headless-ok]             ;; only when host explicitly opts in
```

For per-tag value overrides (non-enable proxies), add `:tag-overrides`:

```clojure
:tag-overrides
  {browsers {:myConfig.modules.firefox.default true}}
```

See `docs/TAGS.md` for the full model, the resolution algorithm, and worked
examples (kitchen-sink, edited tag, opt-in plus, hard disable).

## Authoring a new host

```racket
#lang nisp

(host-file
  (set myConfig.modules.system.stateVersion "25.11")
  (set myConfig.modules.users.username "you")
  (enable myConfig.modules.users
          myConfig.modules.boot
          myConfig.modules.networking))
```

Then author `hosts/<host>/enabled-tags.bnix` with the tag selection:

```clojure
{:enabled [lisp terminal development]   ;; lisp pulls in modules/racket (REQUIRED)
 :disabled []}
```

Then add the entry to `flake.rkt`'s `nixosConfigurations`:

```racket
(nixosConfigurations
  (att
    (your-host
      (call self.lib.mkSystem
        (att
          (hostname "your-host")
          (hostConfig (p "./hosts/your-host/configuration.nix"))
          (hardwareConfig (p "./hardware-configuration.nix")))))))
```

Regenerate (`./scripts/firn-build`) and commit both `.rkt` and `.nix`.

## What stays in `.nix`

A small set of files don't have a `.rkt` source and aren't regenerated:

- `hardware-configuration.nix` — generated by NixOS at install time
  (`nixos-generate-config`); leave it as-is.
- `secrets/` — sops-encrypted YAML, not Nix code.
- `dotfiles/` and `assets/` — non-Nix content.

## Bootstrapping nisp

The first time you clone a fresh checkout on a new machine, `racket` may not
yet be on the system. Bootstrap order:

1. `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
   (uses the *currently committed* `*.nix` files — no `firn-build` needed).
2. `sudo nixos-rebuild switch --flake .#<host>` — installs racket via
   `modules/racket` (active because the `lisp` tag is enabled).
3. From now on, edit `.bnix` sources and run `./scripts/firn-build` before
   `nixos-rebuild`.

## Editing the DSL itself

The DSL lives in the [tompassarelli/nisp](https://github.com/tompassarelli/nisp) repo (cloned alongside this one as a sibling). If you modify `../nisp/main.rkt`:

1. Run `raco setup nisp` to recompile (or just re-run `./scripts/firn-build`, which `raco pkg install --link`s the sibling clone).
2. Run `./scripts/firn-build` to regenerate every `.nix` from its `.rkt` source — the new emitter applies everywhere at once.
3. Diff the result. Cosmetic differences are fine; semantic differences are bugs.

## Quick reference

| nisp form | Generated Nix |
| --- | --- |
| `(module-file modules vim ...)` | `{ config, lib, pkgs, ... }: let cfg = ...; in { options... ; config = mkIf cfg.enable {...}; }` |
| `(host-file ...)`               | `{ lib, ... }: { ... }` (just option setters) |
| `(flake-file ...)`              | full `flake.nix` |
| `(pkg vim "Vim text editor")`   | full module-file installing `pkgs.vim` (shortcut) |
| `(svc openssh)`                 | full module-file enabling `services.openssh.enable` (shortcut) |
| `(set foo.bar val)`             | `foo.bar = val;` |
| `(enable a b c)`                | `a.enable = true; b.enable = true; c.enable = true;` |
| `(with-pkgs vim git fd)`        | `with pkgs; [ vim git fd ]` |
| `(att (k v) ...)`               | `{ k = v; ... }` |
| `(lst a b c)`                   | `[ a b c ]` |
| `(let-in ([k v]...) body)`      | `let k = v; ... in body` |
| `(fn (a b) body)`               | `a: b: body` |
| `(module [a b] body)`           | `{ a, b, ... }: body` (NixOS module / open-attrs lambda) |
| `(fn-set [a (b "x")] body)`     | `{ a, b ? "x" }: body` (closed attrs) |
| `(overlay [final prev] body)`   | `final: prev: body` (Nix overlay, exactly 2 formals) |
| `(derivation {:pname ... :src ...})` | `pkgs.stdenv.mkDerivation { pname = ...; src = ...; }` |
| `(flake {:description ... :inputs ... :outputs ...})` | flake.nix shape |
| `(with-cfg config.X body)`      | `let cfg = config.X; in body` (also rewrites config.X.foo → cfg.foo) |
| `(call f x y)`                  | `f x y` |
| `(not x)` / `(neg x)`           | `!x` / `-x` |
| `(and a b c)` / `(or a b)` / `(implies a b)` | `a && b && c` / `a \|\| b` / `a -> b` |
| `(== a b)` / `(!= a b)` / `(< a b)` / `(<= a b)` etc. | `a == b` / `a != b` / `a < b` / `a <= b` |
| `(+ a b c)` / `(- a b)` / `(* a b)` / `(/ a b)` | `a + b + c` / `a - b` / `a * b` / `a / b` |
| `(get base 'a.b.c)` / `(get-or base 'a.b.c d)` | `base.a.b.c` / `base.a.b.c or d` |
| `(has base 'a.b.c)`             | `base ? a.b.c` |
| `(assert cond body)`            | `assert cond; body` |
| `(search-path nixpkgs)`         | `<nixpkgs>` |
| `(inherit a b c)` / `(inherit-from ns a b)` | `inherit a b c;` / `inherit (ns) a b;` |
| `(rec-attrs k v ...)`           | `rec { k = v; ... }` |
| `(with ns body)`                | `with ns; body` (Nix scope; shape-disambiguated from record update) |
| `~"hi ${name}!"`                | `"hi ${name}!"` (reader macro; lowers to `(s "hi " name "!")`) |
| `(pipe-to x f)` / `(pipe-from f x)` | `x \|> f` / `f <\| x` (Nix 2.15+) |
| `(mkif cond body)`              | `lib.mkIf cond body` |
| `(mkdefault v)` / `(mkforce v)` | `lib.mkDefault v` / `lib.mkForce v` |
| `(mkenable "desc")`             | `lib.mkEnableOption "desc"` |
| `(mkopt #:type t #:default d #:desc s)` | `lib.mkOption { type = t; default = d; description = s; }` |
| `(s "lit " expr "...")`         | `"lit ${expr}..."` |
| `(ms "line1" "line2")`          | `''<NL>  line1<NL>  line2<NL>''` |
| `(p "./foo")`                   | `./foo` |
| `(cat a b)` / `(concat-list a b)` / `(merge a b)` | `a + b` / `a ++ b` / `a // b` |
| `(home-of u body...)`           | `home-manager.users.${u} = { config, ... }: { body... };` |
| `(home-of-bare u body...)`      | `home-manager.users.${u} = { body... };` |
| `(sops-secret "name" (k v)...)` | `sops.secrets."name" = { k = v; ... };` |

Full DSL reference lives in the [upstream nisp repo](https://github.com/tompassarelli/nisp).
