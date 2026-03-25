{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.fd.enable = lib.mkEnableOption "fd file finder";

  config = lib.mkIf config.myConfig.modules.fd.enable {
    environment.systemPackages = [ pkgs.fd ];
  };
}
