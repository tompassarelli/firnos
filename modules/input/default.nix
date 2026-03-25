{ lib, ... }:
{
  options.myConfig.modules.input = {
    enable = lib.mkEnableOption "touchpad support (libinput)";
  };

  imports = [
    ./input.nix
  ];
}
