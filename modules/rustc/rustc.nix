{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.rustc.enable {
    environment.systemPackages = [ pkgs.unstable.rustc ];
  };
}
