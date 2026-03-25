{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.sbcl.enable {
    environment.systemPackages = [ pkgs.sbcl ];
  };
}
