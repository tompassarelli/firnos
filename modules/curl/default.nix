{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.curl.enable = lib.mkEnableOption "curl HTTP client";

  config = lib.mkIf config.myConfig.modules.curl.enable {
    environment.systemPackages = [ pkgs.curl ];
  };
}
