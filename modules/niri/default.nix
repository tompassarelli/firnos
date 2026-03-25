{ lib, ... }:
{
  options.myConfig.modules.niri = {
    enable = lib.mkEnableOption "Enable niri compositor configuration";
  };

  imports = [
    ./niri.nix
    ./xwayland-satellite.nix  # Niri 25.08 needs this in PATH, manages it automatically
    ./swaybg.nix
    ./swayidle.nix
  ];
}
