function firn --description "FirnOS config management CLI"
  # All logic (racket-version detection, recompile-on-mismatch) lives in
  # the wrapper at ~/.local/bin/firn — see scripts/firn-build-bin.
  if test -x ~/.local/bin/firn
    ~/.local/bin/firn $argv
  else
    set -l repo (test -n "$FIRN_REPO"; and echo $FIRN_REPO; or echo ~/code/nixos-config)
    echo "firn: no binary at ~/.local/bin/firn — run $repo/scripts/firn-build-bin to compile." >&2
    return 1
  end
end
