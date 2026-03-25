{ lib, ... }:
{
  options.myConfig.modules.brightnessctl = {
    enable = lib.mkEnableOption "screen brightness control";
  };

  imports = [
    ./brightnessctl.nix
  ];
}
