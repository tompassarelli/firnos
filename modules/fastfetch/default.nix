{ config, lib, pkgs, ... }:
let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.fastfetch = {
    enable = lib.mkEnableOption "Enable fastfetch system info display";
  };

  config = lib.mkIf config.myConfig.modules.fastfetch.enable {
    # ============ SYSTEM-LEVEL CONFIGURATION ============

    environment.systemPackages = with pkgs; [ fastfetch ];

    # ============ HOME-MANAGER CONFIGURATION ============

    home-manager.users.${username} = { config, ... }: {
      # Fastfetch configuration
      xdg.configFile."fastfetch/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/nixos-config/dotfiles/fastfetch/config.jsonc";
    };
  };
}
