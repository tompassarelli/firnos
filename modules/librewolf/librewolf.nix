{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.myConfig.modules.librewolf.enable {
    environment.systemPackages = [ pkgs.unstable.librewolf ];
    xdg.mime.defaultApplications = lib.mkIf config.myConfig.modules.librewolf.default {
      "text/html" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };
  };
}
