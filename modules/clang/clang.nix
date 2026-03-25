{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.clang.enable {
    environment.systemPackages = [ pkgs.clang ];
  };
}
