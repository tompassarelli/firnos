{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.uv.enable {
    environment.systemPackages = [ pkgs.uv ];
  };
}
