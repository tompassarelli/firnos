{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.imv.enable = lib.mkEnableOption "imv image viewer";

  config = lib.mkIf config.myConfig.modules.imv.enable {
    environment.systemPackages = [ pkgs.imv ];
  };
}
