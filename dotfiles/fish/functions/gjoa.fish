function gjoa --description "gjoa launcher + dev CLI"
  set -l root ~/code/gjoa
  set -l nix_bin  $root/result/bin/gjoa
  set -l mach_bin $root/engine/obj-x86_64-pc-linux-gnu/dist/bin/gjoa

  if not test -d $root
    echo "gjoa: $root not found" >&2
    return 1
  end

  switch $argv[1]
    # ── launch nix (release): bare = detached, -f = foreground ──────────────
    case '' -f
      if not test -x $nix_bin
        echo "gjoa: no nix build at $nix_bin" >&2
        echo "    build it:  nix build .#gjoa --impure" >&2
        return 1
      end
      if test "$argv[1]" = "-f"
        $nix_bin $argv[2..-1]
      else
        setsid -f $nix_bin </dev/null >/dev/null 2>&1
        exit
      end

    # ── launch mach (dev): bare = detached, -f = foreground ─────────────────
    case dev
      if not test -x $mach_bin
        echo "gjoa dev: no mach build at $mach_bin" >&2
        echo "    build it:  gjoa import; and gjoa build  (full, 30-60 min cold)" >&2
        echo "    after that, daily rebuilds:  gjoa build faster  (~30 sec, omni.ja re-zip)" >&2
        return 1
      end
      if test "$argv[2]" = "-f"
        $mach_bin $argv[3..-1]
      else
        setsid -f $mach_bin </dev/null >/dev/null 2>&1
        exit
      end

    # ── help ────────────────────────────────────────────────────────────────
    case -h --help help
      echo "gjoa — launcher + dev CLI"
      echo
      echo "Launch:"
      echo "  gjoa                     nix build, detached (closes terminal)"
      echo "  gjoa -f                  nix build, foreground (shows logs)"
      echo "  gjoa dev                 mach build, detached"
      echo "  gjoa dev -f              mach build, foreground"
      echo
      echo "Dev loop:"
      echo "  gjoa import              sync src/gjoa/ → engine/ (run before mach build)"
      echo "  gjoa build [faster|…]    mach build in engine/"
      echo "  gjoa sync                bundle chrome TS → symlink into mach install"
      echo "  gjoa watch               auto-rebundle chrome TS on save"
      echo
      echo "Tests:"
      echo "  gjoa test [path|…]       bun unit tests"
      echo "  gjoa test:integration    Marionette tests against the binary"
      echo
      echo "Misc:"
      echo "  gjoa icons               regenerate icons from assets/gjoa.svg"
      echo "  gjoa clean               mach clobber (wipe objdir)"

    # ── dev-loop verbs ──────────────────────────────────────────────────────
    case build
      direnv exec $root env -C $root/engine ./mach build $argv[2..-1]
    case import
      direnv exec $root env -C $root bun run import
    case sync
      direnv exec $root sh -c 'cd "$1" && bun run chrome:dist && bun run chrome:install' _ $root
    case watch
      direnv exec $root env -C $root bun run chrome:watch

    # ── tests + misc ────────────────────────────────────────────────────────
    case test
      direnv exec $root env -C $root bun test $argv[2..-1]
    case test:integration
      direnv exec $root env -C $root bun run test:integration
    case icons
      direnv exec $root env -C $root bun run icons
    case clean
      direnv exec $root env -C $root/engine ./mach clobber

    case '*'
      echo "gjoa: unknown subcommand '$argv[1]'" >&2
      return 1
  end
end
