{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.firefox.enable {
    programs.firefox.enable = true;

    # Set as default browser if specified
    xdg.mime.defaultApplications = lib.mkIf config.myConfig.firefox.default {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
