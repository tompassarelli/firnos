{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.slurp.enable = lib.mkEnableOption "Wayland region selector";

  config = lib.mkIf config.myConfig.modules.slurp.enable {
    environment.systemPackages = [ pkgs.slurp ];
  };
}
