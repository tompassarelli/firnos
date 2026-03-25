{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.gcc.enable {
    environment.systemPackages = [ pkgs.gcc ];
  };
}
