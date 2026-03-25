{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.hugo.enable = lib.mkEnableOption "Hugo static site generator";

  config = lib.mkIf config.myConfig.modules.hugo.enable {
    environment.systemPackages = [ pkgs.hugo ];
  };
}
