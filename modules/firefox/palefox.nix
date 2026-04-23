{ config, lib, pkgs, inputs, ... }:
let
  username = config.myConfig.modules.users.username;

  # fx-autoconfig: patched Firefox with JS loader bootstrap
  palefoxFirefox = lib.pipe pkgs.firefox [
    (pkg: pkg.override {
      extraPrefs = ''
        try {
          let cmanifest = Cc['@mozilla.org/file/directory_service;1']
            .getService(Ci.nsIProperties).get('UChrm', Ci.nsIFile);
          cmanifest.append('utils');
          cmanifest.append('chrome.manifest');
          if(cmanifest.exists()){
            Components.manager.QueryInterface(Ci.nsIComponentRegistrar)
              .autoRegister(cmanifest);
            ChromeUtils.importESModule('chrome://userchromejs/content/boot.sys.mjs');
          }
        } catch(ex) {};
      '';
    })
    (pkg: pkg.overrideAttrs (old: {
      buildCommand = (old.buildCommand or "") + ''
        echo 'pref("general.config.sandbox_enabled", false);' >> "$out/lib/firefox/defaults/pref/autoconfig.js"
      '';
    }))
  ];
in
{
  config = lib.mkIf config.myConfig.modules.firefox.palefox.enable {
    # Palefox implies firefox
    myConfig.modules.firefox.enable = lib.mkDefault true;

    # fx-autoconfig: system-level Firefox with JS loader
    programs.firefox = {
      enable = true;
      package = palefoxFirefox;
    };

    home-manager.users.${username} = { config, ... }: {
      programs.firefox = {
        enable = true;
        package = palefoxFirefox;
        profiles.${username} = {
          settings = {
            # Enable custom stylesheets
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

            # Hide bookmarks toolbar by default
            "browser.toolbars.bookmarks.visibility" = "never";

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

      # Symlink Palefox custom chrome directory
      home.file.".mozilla/firefox/${username}/chrome".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/palefox/chrome";
    };
  };
}
