{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.direnv;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.direnv.enable = lib.mkEnableOption "direnv for automatic dev shell activation";
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    environment.systemPackages = [ pkgs.unstable.devenv ];
    home-manager.users.${username} = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
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
