{ config, lib, pkgs, ... }:
let
  username = config.myConfig.modules.users.username;
in
{
  config = lib.mkIf config.myConfig.modules.nyxt.enable {
    environment.systemPackages = [ pkgs.nyxt4 ];

    # AppImages need FUSE
    myConfig.modules.fuse.enable = lib.mkDefault true;
    programs.appimage.enable = true;

    xdg.mime.defaultApplications = lib.mkIf config.myConfig.modules.nyxt.default {
      "text/html" = "nyxt.desktop";
      "x-scheme-handler/http" = "nyxt.desktop";
      "x-scheme-handler/https" = "nyxt.desktop";
      "x-scheme-handler/about" = "nyxt.desktop";
      "x-scheme-handler/unknown" = "nyxt.desktop";
    };

    home-manager.users.${username} = { config, ... }: {
      xdg.configFile."nyxt/config.lisp".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/nixos-config/dotfiles/nyxt/config.lisp";
    };
  };
}
