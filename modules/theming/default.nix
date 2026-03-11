{ lib, ... }:
{
  options.myConfig.theming = {
    enable = lib.mkEnableOption "Enable theming configuration";
    chosenTheme = lib.mkOption {
      type = lib.types.str;
      description = "The base16 theme to use for styling (e.g., 'tokyo-night-dark', 'everforest-dark-hard')";
      example = "tokyo-night-dark";
    };
  };

  imports = [
    ./fonts.nix
    ./xdg-portal.nix
    ./themes.nix
  ];
}
