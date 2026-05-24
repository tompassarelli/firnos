function firn --description "FirnOS config management CLI"
  # The wrapper at ~/.local/bin/firn handles everything: version mismatch
  # detection, background rebuild, lock-file management, stale-lock prompts.
  # See scripts/firn-build-bin (cat $WRAPPER section) for the logic.
  if test -x ~/.local/bin/firn
    ~/.local/bin/firn $argv
  else
    set -l repo (test -n "$FIRN_REPO"; and echo $FIRN_REPO; or echo ~/code/nixos-config)
    echo "firn: no binary at ~/.local/bin/firn — run $repo/scripts/firn-build-bin to compile." >&2
    return 1
  end
end
