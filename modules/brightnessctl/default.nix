{ lib, ... }:
{
  options.myConfig.brightnessctl = {
    enable = lib.mkEnableOption "screen brightness control";
  };

  imports = [
    ./brightnessctl.nix
  ];
}
