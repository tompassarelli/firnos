{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.rustfmt.enable {
    environment.systemPackages = [ pkgs.unstable.rustfmt ];
  };
}
