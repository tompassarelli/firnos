{ lib, ... }:
{
  options.myConfig.modules.styling = {
    enable = lib.mkEnableOption "system-wide theming and styling";
  };

  imports = [
    ./styling.nix
  ];
}
