{ config, lib, pkgs, flakeRoot, ... }:

let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.bash.enable = lib.mkEnableOption "Bash shell configuration";
  config = lib.mkIf config.myConfig.modules.bash.enable {
    programs.bash.completion.enable = true;
    environment.systemPackages = with pkgs; [ fzf blesh ];
    home-manager.users.${username} = ({ config, ... }: {
      home.file.".local/bin".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/bin";
      programs.bash = {
        enable = true;
        shellAliases = {
          du = "dust";
          ls = "eza";
          ps = "procs";
          v = "nvim";
          e = "emacsclient -n -c -a emacs";
          etui = "emacsclient -t -a emacs";
          gits = "git status";
          gitd = "git diff";
          gitdc = "git diff --cached";
          gita = "git add -v . && git status";
          gitp = "git push";
        };
        historyControl = [ "ignoredups" "erasedups" ];
        historySize = 100000;
        historyFileSize = 100000;
        shellOptions = [
          "histappend"
          "checkwinsize"
          "cmdhist"
          "globstar"
          "autocd"
          "cdspell"
          "dirspell"
        ];
        bashrcExtra = ''
          
          # Ensure ~/.local/bin (where dotfiles/bin is symlinked) is on PATH.
          case ":$PATH:" in
            *":$HOME/.local/bin:"*) ;;
            *) export PATH="$HOME/.local/bin:$PATH" ;;
          esac
          
          # Readline-dependent setup. Skip cleanly on bash builds without
          # readline (pkgs.bash in nix dev shells) — `set -o vi`, `bind`,
          # `complete`, and the fzf bindings all need readline. The cd-to-home
          # block below is intentionally outside this gate.
          if [[ $- == *i* ]] && type bind >/dev/null 2>&1; then
            # vi-mode (use 'set -o emacs' to switch back temporarily)
            set -o vi
          
            # fzf integration (Ctrl-R for fuzzy history, Alt-C for cd)
            if command -v fzf-share >/dev/null 2>&1; then
              source "$(fzf-share)/key-bindings.bash"
              source "$(fzf-share)/completion.bash"
            fi
          
            # blesh: fish-style autosuggestions + syntax highlighting
            if [ -f /run/current-system/sw/share/blesh/ble.sh ]; then
              source /run/current-system/sw/share/blesh/ble.sh --noattach
              ble-attach
            fi
          fi
          
          # Change to home dir on interactive start (skip in Emacs vterm).
          # No readline dep, runs even in stripped bash.
          if [ -z "$INSIDE_EMACS" ] && [ -t 0 ]; then
            case "$PWD" in
              "$HOME"*) ;;
              *) cd "$HOME" ;;
            esac
          fi
        '';
      };
    });
  };
}
