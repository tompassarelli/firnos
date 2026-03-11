{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.chrome.enable {
    # Install Google Chrome
    environment.systemPackages = with pkgs; [
      google-chrome
    ];

    # Set as default browser if specified
    xdg.mime.defaultApplications = lib.mkIf config.myConfig.chrome.default {
      "text/html" = "google-chrome.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "x-scheme-handler/about" = "google-chrome.desktop";
      "x-scheme-handler/unknown" = "google-chrome.desktop";
    };
  };
}
