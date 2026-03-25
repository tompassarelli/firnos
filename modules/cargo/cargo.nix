{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.cargo.enable {
    environment.systemPackages = [ pkgs.unstable.cargo ];
  };
}
