# Building FirnOS

FirnOS is authored in [nisp](nisp.md) — a Racket `#lang` for writing Nix
as s-expressions. nisp lives in its own repo at
[tompassarelli/nisp](https://github.com/tompassarelli/nisp); FirnOS
consumes it as a `raco pkg` link.

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
4. `nixos-rebuild switch` (or `firn rebuild`) builds from the regenerated
   `flake.nix`.

`firn-build` is idempotent and only re-runs `racket` for `.rkt` files that are
newer than their `.nix` output, so re-running it after a clean build is a
no-op.

## The `firn` CLI

`scripts/firn.rkt` is a Racket-based CLI that wraps the routine config
operations (rebuild, list/refs, scaffolding new modules/bundles, secrets
management, generation tagging) and adds two new commands that need
syntax-aware host-config edits:

- `firn enable <name>` — toggle a module/bundle on in the current host
- `firn disable <name>` — toggle off
- `firn status` — list what's enabled

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
on PATH (already provided by `bundles/racket`). Add `~/.local/bin` to
PATH if it isn't already.

## `firn rebuild` and `nh`

`firn rebuild` runs `firn-build → firn-validate → rebuild → tag generation`.
The rebuild step prefers [`nh`](https://github.com/nix-community/nh) (a
Rust wrapper around `nixos-rebuild`) when it's on PATH — `nh os switch`
gives nicer progress output, a generation diff after activation, and
handles `sudo` itself. `modules/nh/default.rkt` installs it.

When `nh` isn't available, `firn rebuild` falls back to
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

## Required modules and bundles

The pipeline runs `racket` on every `.rkt` source, so racket must be on the
system that does the rebuild. Two modules and one bundle are load-bearing:

| Path                   | Why it's required                                              |
| ---------------------- | -------------------------------------------------------------- |
| `modules/racket`       | Installs `pkgs.racket-minimal` — the interpreter `firn-build` invokes. |
| `bundles/racket`       | Top-level toggle that pulls `modules/racket` (and optionally `modules/drracket`) into the host config. |
| `nisp/`                | The DSL itself — `info.rkt`, `lang/reader.rkt`, `main.rkt`. Registered with `raco pkg install --link ./nisp`. |

In every host configuration, set:

```racket
(enable myConfig.bundles.racket)
;; or, if you don't want DrRacket:
(set myConfig.bundles.racket (att (enable #t) (drracket.enable #f)))
```

Without `bundles/racket` enabled, the *system* will lack `racket`, and the
next `firn-build` invocation will fail with `racket: command not found`.

`modules/drracket` is optional — useful if you want to author `.rkt` sources
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

## Authoring a new bundle

A bundle that just toggles a list of child modules:

```racket
#lang nisp

(bundle-file <name>
  (desc "<one-liner>")
  (sub-modules a b c d))
```

Or with mixed defaults:

```racket
(bundle-file <name>
  (desc "<one-liner>")
  (sub-modules* (a #t) (b #t) (c #f)))
```

For non-bool options or non-`myConfig.modules.X.enable` targets, use the
manual form (`option-attrs` + `config-body`); see `bundles/lisp/default.rkt`
or `bundles/theming/default.rkt`.

## Authoring a new host

```racket
#lang nisp

(host-file
  (set myConfig.modules.system.stateVersion "25.11")
  (set myConfig.modules.users.username "you")
  (enable myConfig.modules.users
          myConfig.modules.boot
          myConfig.modules.networking)

  (enable myConfig.bundles.racket   ; REQUIRED
          myConfig.bundles.terminal
          myConfig.bundles.development))
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
- The `nisp/` package itself — written directly in Racket; it's the
  implementation, not a target.

## Bootstrapping nisp

The first time you clone a fresh checkout on a new machine, `racket` may not
yet be on the system. Bootstrap order:

1. `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
   (uses the *currently committed* `*.nix` files — no `firn-build` needed).
2. `sudo nixos-rebuild switch --flake .#<host>` — installs racket via the
   `bundles/racket` toggle.
3. From now on, edit `.rkt` sources and run `./scripts/firn-build` before
   `nixos-rebuild`.

## Editing the DSL itself

If you modify `nisp/main.rkt` (adding a new form, fixing the emitter):

1. Run `raco setup nisp` to recompile.
2. Run `./scripts/firn-build` to regenerate every `.nix` from its `.rkt`
   source — the new emitter applies everywhere at once.
3. Diff the result. Cosmetic differences are fine; semantic differences are
   bugs.

## Quick reference

| nisp form | Generated Nix |
| --- | --- |
| `(file-module modules vim ...)` | `{ config, lib, pkgs, ... }: let cfg = ...; in { options... ; config = mkIf cfg.enable {...}; }` |
| `(bundle-file auth ...)`        | same shape under `myConfig.bundles.auth` |
| `(host-file ...)`               | `{ lib, ... }: { ... }` (just option setters) |
| `(flake-file ...)`              | full `flake.nix` |
| `(set foo.bar val)`             | `foo.bar = val;` |
| `(enable a b c)`                | `a.enable = true; b.enable = true; c.enable = true;` |
| `(with-pkgs vim git fd)`        | `with pkgs; [ vim git fd ]` |
| `(att (k v) ...)`               | `{ k = v; ... }` |
| `(lst a b c)`                   | `[ a b c ]` |
| `(let-in ([k v]...) body)`      | `let k = v; ... in body` |
| `(fn (a b) body)`               | `a: b: body` |
| `(fn-set-rest (a (b "x")) body)`| `{ a, b ? "x", ... }: body` |
| `(fn-set@ self (a b) body)`     | `{ a, b } @ self: body` |
| `(call f x y)`                  | `f x y` |
| `(not x)` / `(neg x)`           | `!x` / `-x` |
| `(and a b c)` / `(or a b)` / `(impl a b)` | `a && b && c` / `a \|\| b` / `a -> b` |
| `(== a b)` / `(!= a b)` / `(< a b)` / `(<= a b)` etc. | `a == b` / `a != b` / `a < b` / `a <= b` |
| `(+ a b c)` / `(- a b)` / `(* a b)` / `(/ a b)` | `a + b + c` / `a - b` / `a * b` / `a / b` |
| `(get base 'a.b.c)` / `(get-or base 'a.b.c d)` | `base.a.b.c` / `base.a.b.c or d` |
| `(has base 'a.b.c)`             | `base ? a.b.c` |
| `(assert-do cond body)`         | `assert cond; body` |
| `(spath "nixpkgs")`             | `<nixpkgs>` |
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

Full DSL reference lives at `nisp.md`.
