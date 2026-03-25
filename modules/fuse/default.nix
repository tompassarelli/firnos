{ lib, ... }:
{
  options.myConfig.fuse.enable = lib.mkEnableOption "FUSE filesystem support";
  imports = [ ./fuse.nix ];
}
