{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.clippy.enable {
    environment.systemPackages = [ pkgs.unstable.clippy ];
  };
}
