{ lib, ... }:
{
  options.myConfig.modules.parted.enable = lib.mkEnableOption "disk partitioning tool";
  imports = [ ./parted.nix ];
}
