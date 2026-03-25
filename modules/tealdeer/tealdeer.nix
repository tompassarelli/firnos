{ config, lib, pkgs, ... }:
let
  username = config.myConfig.modules.users.username;
in
{
  config = lib.mkIf config.myConfig.modules.tealdeer.enable {
    environment.systemPackages = with pkgs; [ tealdeer ];

    home-manager.users.${username} = { config, ... }: {
      xdg.configFile."tealdeer/config.toml".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/nixos-config/dotfiles/tealdeer/config.toml";
    };
  };
}
