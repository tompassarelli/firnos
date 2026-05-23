{ config, lib, pkgs, flakeRoot, ... }:

let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.fish.enable = lib.mkEnableOption "Fish shell configuration";
  config = lib.mkIf config.myConfig.modules.fish.enable {
    programs.fish.enable = true;
    home-manager.users.${username} = { config, ... }: {
      programs.fish = {
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
        interactiveShellInit = ''
          set -g fish_greeting
          fish_vi_key_bindings
          bind -M default ! __history_previous_command
          bind -M default '$' __history_previous_command_arguments
          bind -M insert ! __history_previous_command
          bind -M insert '$' __history_previous_command_arguments
          # Change to default directory (skip in Emacs vterm)
          if not set -q INSIDE_EMACS
            cd ~
          end
        '';
      };
      xdg.configFile = let
        functionsDir = "${config.home.homeDirectory}/code/nixos-config/dotfiles/fish/functions";
        functionFiles = builtins.attrNames (lib.filterAttrs (n: v: ((v == "regular") && lib.hasSuffix ".fish" n)) (builtins.readDir "${flakeRoot}/dotfiles/fish/functions"));
      in
      lib.listToAttrs (builtins.map (f: {
        name = "fish/functions/${f}";
        value.source = config.lib.file.mkOutOfStoreSymlink "${functionsDir}/${f}";
      }) functionFiles);
    };
  };
}
