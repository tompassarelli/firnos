{ lib, ... }:
{
  options.myConfig.modules.eyedropper.enable = lib.mkEnableOption "Wayland color picker";
  imports = [ ./eyedropper.nix ];
}
