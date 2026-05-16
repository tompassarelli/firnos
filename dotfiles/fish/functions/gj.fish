function gj --description "gjoa dev CLI — mach build / import / run / sail"
  set -l root ~/code/gjoa
  set -l bin $root/engine/obj-x86_64-pc-linux-gnu/dist/bin/gjoa

  if not test -d $root
    echo "gj: $root not found" >&2
    return 1
  end

  switch $argv[1]
    case build
      # `gj build faster` → ~30s omni.ja re-zip (Lane 2 — daily dev)
      # `gj build`        → full incremental (Lane 3 — minutes to hours)
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
        echo "gj: no built binary at $bin" >&2
        echo "    build it first: gj import; and gj build faster" >&2
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
      # subsequent `gj sync` just refreshes dist/ — symlink auto-
      # propagates. Restart gjoa (or open a new window) to pick up
      # changes.
      # Chained in a single direnv exec so the dev-shell env activates once.
      direnv exec $root sh -c 'cd "$1" && bun run chrome:dist && bun run chrome:install' _ $root
    case watch
      # Auto-rebundle on src/gjoa/chrome/src/ changes. Symlink stays
      # live so each save is reflected on next window-open.
      direnv exec $root env -C $root bun run chrome:watch
    case test
      # bun test across tests/ + src/gjoa/chrome/src/**/*.test.ts.
      # Excludes engine/ via bunfig.toml pathIgnorePatterns.
      direnv exec $root env -C $root bun test $argv[2..-1]
    case icons
      # regenerate logo*.png from assets/gjoa.svg
      direnv exec $root env -C $root bun run icons
    case clean
      # mach clobber — wipe objdir if build state gets confused
      direnv exec $root env -C $root/engine ./mach clobber
    case '' '-h' '--help' help
      echo "gj — gjoa dev CLI"
      echo
      echo "Usage:"
      echo "  gj sync               bundle chrome TS → install symlink (Lane 2 — sub-sec)"
      echo "  gj watch              auto-rebundle chrome TS on save"
      echo "  gj test [path|…]      bun test (tests/ + src/gjoa/**/*.test.ts)"
      echo "  gj build [faster|…]   mach build in engine/ (Lane 3 — minutes)"
      echo "  gj import             sync src/gjoa/ → engine/ (run before mach build)"
      echo "  gj run                run the built binary (foreground)"
      echo "  gj sail               run the built binary detached + close terminal"
      echo "  gj icons              regenerate icons from assets/gjoa.svg"
      echo "  gj clean              mach clobber (wipe objdir)"
      echo
      echo "Chrome JS/CSS loop (sub-second):  edit src/gjoa/chrome/src/…; and gj sync; and gj run"
      echo "Full mach loop:                   gj import; and gj build faster; and gj run"
    case '*'
      echo "gj: unknown subcommand '$argv[1]'" >&2
      return 1
  end
end
