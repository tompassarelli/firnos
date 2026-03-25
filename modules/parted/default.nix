{ lib, ... }:
{
  options.myConfig.parted.enable = lib.mkEnableOption "disk partitioning tool";
  imports = [ ./parted.nix ];
}
