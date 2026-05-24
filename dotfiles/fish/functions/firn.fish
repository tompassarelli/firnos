function firn --description "FirnOS config management CLI"
  # Try the compiled binary first; if it fails with a Racket version
  # mismatch (typically after a nixpkgs bump rebuilt racket), auto-rebuild
  # and retry. Otherwise pass through whatever error the binary printed.
  #
  # Repo location: $FIRN_REPO env var wins (consistent with firn-build,
  # firn-validate, etc.), else default to ~/code/nixos-config.
  set -l repo (test -n "$FIRN_REPO"; and echo $FIRN_REPO; or echo ~/code/nixos-config)
  if test -x ~/.local/bin/firn
    if ~/.local/bin/firn $argv 2>/tmp/firn-bin.err
      return 0
    end
    if grep -q "version mismatch" /tmp/firn-bin.err
      echo "firn: compiled binary is stale (Racket version mismatch). Rebuilding..." >&2
      if test -x $repo/scripts/firn-build-bin
        $repo/scripts/firn-build-bin >&2
        ~/.local/bin/firn $argv
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
