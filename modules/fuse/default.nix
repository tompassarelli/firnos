{ lib, ... }:
{
  options.myConfig.modules.fuse.enable = lib.mkEnableOption "FUSE filesystem support";
  imports = [ ./fuse.nix ];
}
