function gjoa --description "gjoa launcher + dev CLI"
  set -l root ~/code/gjoa
  set -l bin $root/engine/obj-x86_64-pc-linux-gnu/dist/bin/gjoa

  if not test -d $root
    echo "gjoa: $root not found" >&2
    return 1
  end

  switch $argv[1]
    case build
      # `gjoa build faster` → ~30s omni.ja re-zip (Lane 2 — daily dev)
      # `gjoa build`        → full incremental (Lane 3 — minutes to hours)
      direnv exec $root env -C $root/engine ./mach build $argv[2..-1]
    case run
      # Foreground — terminal stays attached for stdout/stderr.
      direnv exec $root sh -c '"$MOZ_OBJDIR/dist/bin/gjoa" "$@"' _ $argv[2..-1]
    case sail
      # Detach gjoa from this shell, then exit so the terminal closes.
      # setsid -f forks into a new session so the process survives the
      # parent shell dying. stdin/out/err redirected to /dev/null so
      # nothing keeps the terminal alive waiting on a write.
      if not test -x $bin
        echo "gjoa: no built binary at $bin" >&2
        echo "    build it first: gjoa import; and gjoa build faster" >&2
        return 1
      end
      setsid -f $bin </dev/null >/dev/null 2>&1
      exit
    case import
      # phases 1-4: overlay src/gjoa → engine, apply patches, branding, mozconfig
      direnv exec $root env -C $root bun run import
    case sync
      # Lane 1-2 chrome JS/CSS push: bundle src/gjoa/chrome/src/ JS +
      # stage src/gjoa/chrome/css/ → dist/chrome/{JS,CSS}/, then symlink
      # dist/chrome → <install_root>/gjoa-dev/. After the first run,
      # subsequent `gjoa sync` just refreshes dist/ — symlink auto-
      # propagates. Restart gjoa (or open a new window) to pick up
      # changes.
      direnv exec $root sh -c 'cd "$1" && bun run chrome:dist && bun run chrome:install' _ $root
    case watch
      # Auto-rebundle on src/gjoa/chrome/src/ changes. Symlink stays
      # live so each save is reflected on next window-open.
      direnv exec $root env -C $root bun run chrome:watch
    case test
      # bun test across tests/ + src/gjoa/chrome/src/**/*.test.ts.
      # Excludes engine/ via bunfig.toml pathIgnorePatterns.
      direnv exec $root env -C $root bun test $argv[2..-1]
    case test:integration
      # Marionette headless tests against the built gjoa binary.
      direnv exec $root env -C $root bun run test:integration
    case icons
      # regenerate logo*.png from assets/gjoa.svg
      direnv exec $root env -C $root bun run icons
    case clean
      # mach clobber — wipe objdir if build state gets confused
      direnv exec $root env -C $root/engine ./mach clobber
    case '' '-h' '--help' help
      # No arguments → just launch the browser detached (same as `gjoa sail`).
      # This is how `gh` works: bare `gh` shows help, but for a browser the
      # natural "just run it" is more useful. We keep --help/-h/help explicit.
      if test (count $argv) -eq 0
        if not test -x $bin
          echo "gjoa: no built binary at $bin" >&2
          echo "    build it first: gjoa import; and gjoa build faster" >&2
          return 1
        end
        setsid -f $bin </dev/null >/dev/null 2>&1
        exit
      end
      echo "gjoa — launcher + dev CLI"
      echo
      echo "Usage:"
      echo "  gjoa                     launch the built browser (detached, closes terminal)"
      echo "  gjoa sync                bundle chrome TS → install symlink (Lane 2 — sub-sec)"
      echo "  gjoa watch               auto-rebundle chrome TS on save"
      echo "  gjoa test [path|…]       bun unit tests"
      echo "  gjoa test:integration    Marionette tests against the binary"
      echo "  gjoa build [faster|…]    mach build in engine/ (Lane 3 — minutes)"
      echo "  gjoa import              sync src/gjoa/ → engine/ (run before mach build)"
      echo "  gjoa run                 run the built binary (foreground)"
      echo "  gjoa sail                run the built binary detached + close terminal"
      echo "  gjoa icons               regenerate icons from assets/gjoa.svg"
      echo "  gjoa clean               mach clobber (wipe objdir)"
      echo
      echo "Chrome JS/CSS loop (sub-second):  edit src/gjoa/chrome/src/…; and gjoa sync; and gjoa sail"
      echo "Full mach loop:                   gjoa import; and gjoa build faster; and gjoa sail"
    case '*'
      echo "gjoa: unknown subcommand '$argv[1]'" >&2
      return 1
  end
end
