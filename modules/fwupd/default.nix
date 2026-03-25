{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.fwupd.enable = lib.mkEnableOption "fwupd firmware updater";

  config = lib.mkIf config.myConfig.modules.fwupd.enable {
    environment.systemPackages = [ pkgs.fwupd ];
  };
}
