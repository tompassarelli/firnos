{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.slurp.enable {
    environment.systemPackages = [ pkgs.slurp ];
  };
}
