{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.cargo.enable {
    environment.systemPackages = [ pkgs.unstable.cargo ];
  };
}
