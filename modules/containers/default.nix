{ lib, ... }:
{
  options.myConfig.modules.containers = {
    enable = lib.mkEnableOption "Podman containers with Distrobox";
  };

  imports = [
    ./containers.nix
  ];
}
