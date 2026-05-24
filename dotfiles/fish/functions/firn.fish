function firn --description "FirnOS config management CLI"
  # Fast path: run the compiled binary (~140ms). If it fails with a Racket
  # version mismatch (typically after a nixpkgs bump rebuilt racket), kick
  # the rebuild off in the BACKGROUND and serve THIS invocation from source
  # (~1.3s). User waits seconds instead of 20s; next invocation is fast
  # again because the background rebuild has finished by then.
  #
  # Repo location: $FIRN_REPO env var wins (consistent with firn-build,
  # firn-validate, etc.), else default to ~/code/nixos-config.
  set -l repo (test -n "$FIRN_REPO"; and echo $FIRN_REPO; or echo ~/code/nixos-config)
  if test -x ~/.local/bin/firn
    if ~/.local/bin/firn $argv 2>/tmp/firn-bin.err
      return 0
    end
    if grep -q "version mismatch" /tmp/firn-bin.err
      if test -x $repo/scripts/firn-build-bin
        echo "firn: compiled binary stale (Racket version mismatch); rebuilding in background, running from source for this call." >&2
        # Background rebuild — detached, logs to /tmp/firn-rebuild.log so the
        # user can check on it if it ever fails silently.
        nohup $repo/scripts/firn-build-bin >/tmp/firn-rebuild.log 2>&1 &
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
