{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.curl.enable {
    environment.systemPackages = [ pkgs.curl ];
  };
}
