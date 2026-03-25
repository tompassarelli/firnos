function wlc --description "copy file contents to Wayland clipboard"
  if test -f "$argv[1]"
    cat "$argv[1]" | wl-copy
    echo "Copied $argv[1] to clipboard"
  else
    echo "Error: File not found: $argv[1]"
    return 1
  end
end
