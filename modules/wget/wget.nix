{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.wget.enable {
    environment.systemPackages = [ pkgs.wget ];
  };
}
