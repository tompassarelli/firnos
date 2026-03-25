{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.pkg-config.enable = lib.mkEnableOption "pkg-config build tool";

  config = lib.mkIf config.myConfig.modules.pkg-config.enable {
    environment.systemPackages = [ pkgs.pkg-config ];
  };
}
