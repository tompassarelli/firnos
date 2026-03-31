{ config, lib, pkgs, ... }:
let
  cfg = config.myConfig.modules.styling;
  username = config.myConfig.modules.users.username;
  chosenTheme = config.myConfig.modules.stylix.chosenTheme;

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
  options.myConfig.modules.styling = {
    enable = lib.mkEnableOption "system-wide theming and styling";
  };

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
          package = pkgs.maple-mono.NF;
          name = "Maple Mono NF";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        serif = {
          package = pkgs.ia-writer-quattro;
          name = "iA Writer Quattro S";
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
