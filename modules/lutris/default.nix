{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.lutris.enable = lib.mkEnableOption "Lutris gaming platform";

  config = lib.mkIf config.myConfig.modules.lutris.enable {
    environment.systemPackages = [ pkgs.lutris ];
  };
}
