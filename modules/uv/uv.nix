{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.uv.enable {
    environment.systemPackages = [ pkgs.uv ];
  };
}
