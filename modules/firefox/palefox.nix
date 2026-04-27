{ config, lib, pkgs, inputs, ... }:
let
  username = config.myConfig.modules.users.username;

  # palefox flake input — `inputs.palefox` resolves to the flake's source
  # tree (path-based, re-read every evaluation). Only TRACKED files are
  # visible; bun-built artifacts must be committed before `firn rebuild`.
  palefoxRoot = inputs.palefox;

  # Wrap Firefox: bake palefox's hash-pinned bootstrap directly into the
  # Nix-store derivation. The bootstrap content lives in the immutable
  # Nix store from this point on — full security model intact.
  #
  # For dev iteration on palefox source (no nixos-rebuild per change),
  # use the test rig: `bun run test:integration` / `bun run test:rig`.
  # See palefox docs/dev/loader-pipeline.md for the full architecture.
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
    # Palefox implies firefox
    myConfig.modules.firefox.enable = lib.mkDefault true;

    # palefox: system-level Firefox with hash-pinned JS loader baked in
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
            # Legacy stylesheets pref OFF — palefox CSS now loads via the
            # hash-pinned loader's chrome:// CSS registration, NOT through
            # Firefox's direct userChrome.css load.
            "toolkit.legacyUserProfileCustomizations.stylesheets" = false;
            # fx-autoconfig loader gate — required for boot.sys.mjs to
            # actually load palefox JS and CSS.
            "userChromeJS.enabled" = true;

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

      # Symlink palefox chrome dir into the profile (out-of-store so live
      # source is what loads, but the bootstrap still hash-validates it
      # against the manifest baked into the wrapped Firefox derivation).
      # NOTE: this uses an absolute path because mkOutOfStoreSymlink runs
      # at home-manager activation time, NOT at Nix evaluation time, so
      # /home access is fine here.
      home.file.".mozilla/firefox/${username}/chrome".source =
        config.lib.file.mkOutOfStoreSymlink "/home/${username}/code/palefox/chrome";
    };
  };
}
