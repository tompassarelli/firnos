{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.shellcheck.enable {
    environment.systemPackages = [ pkgs.shellcheck ];
  };
}
