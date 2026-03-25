{ lib, ... }:
{
  options.myConfig.input = {
    enable = lib.mkEnableOption "touchpad support (libinput)";
  };

  imports = [
    ./input.nix
  ];
}
