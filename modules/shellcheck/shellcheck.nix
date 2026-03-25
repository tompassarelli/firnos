{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.shellcheck.enable {
    environment.systemPackages = [ pkgs.shellcheck ];
  };
}
