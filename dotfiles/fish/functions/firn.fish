function firn --description "FirnOS config management CLI"
  if test -x ~/.local/bin/firn
    ~/.local/bin/firn $argv
  else
    echo "firn: ~/.local/bin/firn not found — run ./scripts/firn-build-bin to compile" >&2
    return 1
  end
end
