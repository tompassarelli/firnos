{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.sbcl.enable {
    environment.systemPackages = [ pkgs.sbcl ];
  };
}
