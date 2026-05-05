{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.tealdeer;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.tealdeer.enable = lib.mkEnableOption "Enable tealdeer (tldr client)";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ tealdeer ];
    home-manager.users.${username} = { config, ... }: {
      xdg.configFile = {
        ${"tealdeer/config.toml"}.source = config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/code/nixos-config/dotfiles/tealdeer/config.toml");
      };
    };
  };
}
