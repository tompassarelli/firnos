{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.libtool.enable = lib.mkEnableOption "GNU Libtool";

  config = lib.mkIf config.myConfig.modules.libtool.enable {
    environment.systemPackages = [ pkgs.libtool ];
  };
}
