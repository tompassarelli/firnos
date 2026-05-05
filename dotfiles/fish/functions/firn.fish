function firn --description "FirnOS config management CLI"
  # As of firnos v0.10.0, firn is a compiled Racket binary at
  # ~/.local/bin/firn (built by ./scripts/firn-build-bin). This fish
  # function used to be the implementation; now it just delegates so the
  # binary's full command set (explain, doctor, upgrade, scaffold, …)
  # isn't shadowed by a stale help text.
  if test -x ~/.local/bin/firn
    ~/.local/bin/firn $argv
  else
    echo "firn: ~/.local/bin/firn not found — run ./scripts/firn-build-bin to compile" >&2
    return 1
  end
end

# ============================================================================
# ORIGINAL FISH-BASED IMPLEMENTATION (superseded by ~/.local/bin/firn)
# Kept as a comment for reference; uncomment to fall back if the binary is
# unavailable. Note: this is missing every command added since June 2025
# (rebuild's pipeline + validation, watch, diff, scaffold, enable/disable/
# status, explain, doctor, upgrade).
# ============================================================================
#
# function firn --description "FirnOS config management CLI"
#   switch $argv[1]
#     case rebuild
#       if test (count $argv) -le 1
#         sudo nixos-rebuild switch --flake ~/code/nixos-config/
#       else
#         sudo nixos-rebuild switch --flake ~/code/nixos-config/#$argv[2]
#       end
#       or return 1
#       set -l gen (nixos-rebuild list-generations 2>/dev/null | grep current | string trim | cut -d' ' -f1)
#       if test -n "$gen"
#         git -C ~/code/nixos-config tag -f "gen-$gen" HEAD 2>/dev/null
#         echo "Tagged: gen-$gen"
#       end
#
#     case list
#       set -l flag ""
#       test (count $argv) -ge 2; and set flag $argv[2]
#       set -l modules (ls -1 ~/code/nixos-config/modules/)
#       set -l bundles (ls -1 ~/code/nixos-config/bundles/)
#       set -l hosts_dir ~/code/nixos-config/hosts
#       set -l bundles_dir ~/code/nixos-config/bundles
#       # …~150 more lines of cases for refs / mod / bundle / secret / gen…
#   end
# end
