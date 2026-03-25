{ lib, ... }:
{
  options.myConfig.modules.pipewire = {
    enable = lib.mkEnableOption "PipeWire audio configuration";
  };

  imports = [
    ./pipewire.nix
  ];
}
