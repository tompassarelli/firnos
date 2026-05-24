function firn --description "FirnOS config management CLI"
  # Fast path: run the compiled binary (~140ms). If it fails with a Racket
  # version mismatch (typically after a nixpkgs bump rebuilt racket), kick
  # the rebuild off in the BACKGROUND and serve THIS invocation from source
  # (~1.3s). User waits seconds instead of 20s; next invocation is fast
  # again because the background rebuild has finished by then.
  #
  # Lock file: `.rebuild-in-progress` prevents two failure modes during the
  # rebuild window — (a) running the half-written .zo (load error), and
  # (b) spawning multiple racing rebuilds if the user invokes firn N times
  # while the first rebuild is still going.
  #
  # Repo location: $FIRN_REPO env var wins (consistent with firn-build,
  # firn-validate, etc.), else default to ~/code/nixos-config.
  set -l repo (test -n "$FIRN_REPO"; and echo $FIRN_REPO; or echo ~/code/nixos-config)
  set -l lock ~/.local/share/firn/.rebuild-in-progress

  # Lock present → either rebuild is in flight (recent, silent fallback)
  # or it's stale (old, prompt to clear). The prompt only fires on TTY;
  # non-interactive callers (scripts, CI) silently fall through to source.
  if test -e $lock
    set -l age (math (date +%s) - (stat -c %Y $lock))
    if test $age -gt 60; and isatty stdin
      set -l age_h (test $age -lt 60; and echo $age"s"; or echo (math $age / 60)"m"(math $age % 60)"s")
      echo "firn: lock file at $lock is $age_h old." >&2
      echo "      Purpose: prevents racing rebuilds + reading a half-written binary." >&2
      echo "      Expected rebuild time: ~20s. This lock is stale — rebuild probably crashed." >&2
      echo "      Last rebuild log: /tmp/firn-rebuild.log" >&2
      read -P "      Remove lock and retry binary? [y/N] " response
      if test "$response" = "y" -o "$response" = "Y"
        rm -f $lock
        # Fall through to binary attempt below.
      else
        racket $repo/scripts/firn.rkt $argv
        return
      end
    else
      # Fresh lock, or non-TTY — silently use source.
      racket $repo/scripts/firn.rkt $argv
      return
    end
  end

  if test -x ~/.local/bin/firn
    if ~/.local/bin/firn $argv 2>/tmp/firn-bin.err
      return 0
    end
    if grep -q "version mismatch" /tmp/firn-bin.err
      if test -x $repo/scripts/firn-build-bin
        echo "firn: compiled binary stale (Racket version mismatch); rebuilding in background, running from source for this call." >&2
        # Create lock file; spawn background rebuild that removes it on exit.
        mkdir -p (dirname $lock); and touch $lock
        nohup sh -c "$repo/scripts/firn-build-bin >/tmp/firn-rebuild.log 2>&1; rm -f $lock" >/dev/null 2>&1 &
        disown
        # Foreground: serve this invocation from source.
        racket $repo/scripts/firn.rkt $argv
        return
      end
    end
    cat /tmp/firn-bin.err >&2
    return 1
  end
  # No binary at all → fall back to source (slower, ~1.3s).
  echo "firn: no compiled binary; using source (slow). Run $repo/scripts/firn-build-bin to fix." >&2
  racket $repo/scripts/firn.rkt $argv
end
