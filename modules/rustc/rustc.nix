{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.rustc.enable {
    environment.systemPackages = [ pkgs.unstable.rustc ];
  };
}
