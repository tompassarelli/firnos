{ config, lib, pkgs, flakeRoot, ... }:
let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.fish = {
    enable = lib.mkEnableOption "Fish shell configuration";
  };

  config = lib.mkIf config.myConfig.modules.fish.enable {
    # ============ SYSTEM-LEVEL CONFIGURATION ============

    # Enable fish shell system-wide
    programs.fish.enable = true;

    # ============ HOME-MANAGER CONFIGURATION ============

    home-manager.users.${username} = { config, ... }: {
      # Fish shell configuration
      programs.fish = {
        enable = true;
        shellAliases = {
          # modern utils
          du = "dust";
          ls = "eza";
          ps = "procs";
          v = "nvim";
          # emacs client (connect to daemon for fast startup)
          e = "emacsclient -n -c -a emacs";  # GUI emacs (-n = no-wait, -c = new frame)
          etui = "emacsclient -t -a emacs";  # terminal emacs
          # shorthands
          gits = "git status";
          gitd = "git diff";
          gitdc = "git diff --cached";
          gita = "git add -v . && git status";
          gitp = "git push";
        };
        interactiveShellInit = ''
          # Change to default directory (skip in Emacs vterm)
          if not set -q INSIDE_EMACS
            cd ~
          end
        '';
      };

      # Symlink fish functions individually (out of store for live editing)
      # Whole-directory symlink would conflict with auto-generated functions (e.g. yazi's yy.fish)
      xdg.configFile = let
        functionsDir = "${config.home.homeDirectory}/code/nixos-config/dotfiles/fish/functions";
        functionFiles = builtins.attrNames
          (lib.filterAttrs (n: v: v == "regular" && lib.hasSuffix ".fish" n)
            (builtins.readDir (flakeRoot + "/dotfiles/fish/functions")));
      in lib.listToAttrs (map (f: {
        name = "fish/functions/${f}";
        value.source = config.lib.file.mkOutOfStoreSymlink "${functionsDir}/${f}";
      }) functionFiles);
    };
  };
}
