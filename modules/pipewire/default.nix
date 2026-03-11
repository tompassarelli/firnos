{ lib, ... }:
{
  options.myConfig.pipewire = {
    enable = lib.mkEnableOption "PipeWire audio configuration";
  };

  imports = [
    ./pipewire.nix
  ];
}
