{ config, lib, pkgs, inputs, ... }:

let
  username = config.myConfig.modules.users.username;
  palefoxRoot = inputs.palefox;
  palefoxFirefox = pkgs.firefox.overrideAttrs (old: {
    buildCommand = (old.buildCommand or "") + ''
      cat >> "$out/lib/firefox/defaults/pref/autoconfig.js" <<'EOF'
      pref("general.config.filename", "config.js");
      pref("general.config.sandbox_enabled", false);
      EOF
      cp ${palefoxRoot}/program/config.generated.js "$out/lib/firefox/config.js"
    '';
  });
in
{
  config = lib.mkIf config.myConfig.modules.firefox.palefox.enable {
    myConfig.modules.firefox.enable = lib.mkDefault true;
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
            "toolkit.legacyUserProfileCustomizations.stylesheets" = false;
            "userChromeJS.enabled" = true;
            "browser.toolbars.bookmarks.visibility" = "never";
            "devtools.chrome.enabled" = true;
            "devtools.debugger.remote-enabled" = true;
          };
          extensions = {
            force = true;
            packages = [ inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.rycee.firefox-addons.sidebery ];
          };
        };
      };
      home.file.".mozilla/firefox/.${username}./chrome".source = config.lib.file.mkOutOfStoreSymlink "/home/${username}/code/palefox/chrome";
    };
  };
}
