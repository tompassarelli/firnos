{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.fastfetch;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.fastfetch.enable = lib.mkEnableOption "Enable fastfetch system info display";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ fastfetch ];
    home-manager.users.${username} = { config, ... }: {
      xdg.configFile."fastfetch/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/fastfetch/config.jsonc";
    };
  };
}
