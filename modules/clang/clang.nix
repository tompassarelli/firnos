{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.clang.enable {
    environment.systemPackages = [ pkgs.clang ];
  };
}
