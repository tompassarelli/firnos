{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.curl.enable {
    environment.systemPackages = [ pkgs.curl ];
  };
}
