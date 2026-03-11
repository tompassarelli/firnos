{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.styling;
  username = config.myConfig.users.username;
  chosenTheme = config.myConfig.theming.chosenTheme;

  # Read the base16 scheme YAML to get the variant (dark/light)
  schemeFile = "${pkgs.base16-schemes}/share/themes/${chosenTheme}.yaml";
  schemeYaml = builtins.readFile schemeFile;

  # Extract variant from YAML (crude but works for our use case)
  # Looks for lines like: variant: "dark" or variant: "light"
  variant =
    let
      lines = lib.splitString "\n" schemeYaml;
      variantLine = lib.findFirst (line: lib.hasPrefix "variant:" line) "" lines;
      # Extract the value between quotes
      match = builtins.match ".*variant: \"([^\"]+)\".*" variantLine;
    in
      # Fallback to "dark" if variant field is missing or malformed
      if match != null then builtins.head match else "dark";
in
{
  config = lib.mkIf cfg.enable {
    # ============ SYSTEM-LEVEL CONFIGURATION ============

    stylix = {
      enable = true;
      base16Scheme = schemeFile;

      # Auto-detect polarity from base16 scheme variant field
      polarity = variant;

      # Font configuration
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.commit-mono;
          name = "CommitMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
        sizes = {
          terminal = 14;
        };
      };
    };

    # ============ HOME-MANAGER CONFIGURATION ============

    home-manager.users.${username} = { config, ... }: {
      # Stylix Firefox target configuration
      stylix.targets.firefox = {
        profileNames = [ username ];
        colorTheme.enable = true;
      };

      # Themes directory (wallpapers and other theme assets)
      xdg.configFile."themes".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/nixos-config/dotfiles/themes";
    };
  };
}
