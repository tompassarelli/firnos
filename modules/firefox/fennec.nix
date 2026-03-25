{ config, lib, pkgs, inputs, ... }:
let
  username = config.myConfig.modules.users.username;
in
{
  config = lib.mkIf config.myConfig.modules.firefox.fennec.enable {
    # Fennec implies firefox
    myConfig.modules.firefox.enable = lib.mkDefault true;

    home-manager.users.${username} = { config, ... }: {
      programs.firefox = {
        enable = true;
        profiles.${username} = {
          settings = {
            # Enable custom stylesheets
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

            # Enable browser toolbox
            "devtools.chrome.enabled" = true;
            "devtools.debugger.remote-enabled" = true;
          };

          # Extensions
          extensions = {
            # Allow Stylix to manage extension settings
            force = true;

            # Install Sidebery for vertical tabs
            packages = [
              inputs.nur.legacyPackages.${pkgs.system}.repos.rycee.firefox-addons.sidebery
            ];
          };
        };
      };

      # Symlink Fennec custom chrome directory
      home.file.".mozilla/firefox/${username}/chrome".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/fennec/chrome";
    };
  };
}
