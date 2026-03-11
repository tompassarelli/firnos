{ lib, ... }:
{
  options.myConfig.containers = {
    enable = lib.mkEnableOption "Podman containers with Distrobox";
  };

  imports = [
    ./containers.nix
  ];
}
