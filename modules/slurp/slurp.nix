{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.slurp.enable {
    environment.systemPackages = [ pkgs.slurp ];
  };
}
