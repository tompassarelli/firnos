{ config, lib, pkgs, ... }:
let
  cfg = config.myConfig.modules.direnv;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.direnv = {
    enable = lib.mkEnableOption "direnv for automatic dev shell activation";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;  # better caching for nix flakes
    };

    # Make devenv available (provides `use devenv` for direnv)
    environment.systemPackages = [ pkgs.unstable.devenv ];

    # Add shell integration via home-manager
    home-manager.users.${username} = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      # Register devenv's `use_devenv` function with direnv
      xdg.configFile."direnv/lib/use_devenv.sh".text = ''
        use_devenv() {
          watch_file devenv.nix
          watch_file devenv.yaml
          watch_file devenv.lock
          watch_file .devenv.flake.nix
          eval "$(devenv print-dev-env)"
        }
      '';
    };
  };
}
