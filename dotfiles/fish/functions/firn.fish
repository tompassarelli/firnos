function firn --description "FirnOS config management CLI"
  # Try the compiled binary first; if it fails (typically a Racket version
  # mismatch after a nixpkgs bump rebuilt racket), fall back to running
  # from source so the user always gets a working command. Print a one-
  # line hint so the binary rebuild doesn't get forgotten silently.
  if test -x ~/.local/bin/firn
    if ~/.local/bin/firn $argv 2>/tmp/firn-bin.err
      return 0
    end
    if grep -q "version mismatch" /tmp/firn-bin.err
      echo "firn: compiled binary is stale (Racket version mismatch). Rebuilding..." >&2
      set -l repo (firn-repo-root) 2>/dev/null; or set repo ~/code/nixos-config
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
  set -l repo ~/code/nixos-config
  echo "firn: no compiled binary; using source (slow). Run $repo/scripts/firn-build-bin to fix." >&2
  racket $repo/scripts/firn.rkt $argv
end
