{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.pandoc.enable = lib.mkEnableOption "Pandoc document converter";

  config = lib.mkIf config.myConfig.modules.pandoc.enable {
    environment.systemPackages = [ pkgs.pandoc ];
  };
}
