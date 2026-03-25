{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.zathura.enable = lib.mkEnableOption "Zathura PDF viewer";

  config = lib.mkIf config.myConfig.modules.zathura.enable {
    environment.systemPackages = [ pkgs.zathura ];
  };
}
