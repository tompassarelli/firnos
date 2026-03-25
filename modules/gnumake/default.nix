{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.gnumake.enable = lib.mkEnableOption "GNU Make build tool";

  config = lib.mkIf config.myConfig.modules.gnumake.enable {
    environment.systemPackages = [ pkgs.gnumake ];
  };
}
