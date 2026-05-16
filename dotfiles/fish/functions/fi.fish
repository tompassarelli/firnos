function fi --description "FirnOS config management CLI"
  # Compiled Racket binary at ~/.local/bin/fi (built by
  # ./scripts/firn-build-bin). This fish function just delegates so the
  # binary's full command set (rebuild, explain, doctor, upgrade,
  # scaffold, …) isn't shadowed by a stale help text.
  if test -x ~/.local/bin/fi
    ~/.local/bin/fi $argv
  else
    echo "fi: ~/.local/bin/fi not found — run ./scripts/firn-build-bin to compile" >&2
    return 1
  end
end
