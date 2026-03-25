{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.eyedropper.enable = lib.mkEnableOption "Wayland color picker";

  config = lib.mkIf config.myConfig.modules.eyedropper.enable {
    environment.systemPackages = [ pkgs.eyedropper ];
  };
}
