{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.fuse.enable = lib.mkEnableOption "FUSE filesystem support";

  config = lib.mkIf config.myConfig.modules.fuse.enable {
    environment.systemPackages = [ pkgs.fuse ];
  };
}
