{ lib, ... }:
{
  options.myConfig.styling = {
    enable = lib.mkEnableOption "system-wide theming and styling";
  };

  imports = [
    ./styling.nix
  ];
}
