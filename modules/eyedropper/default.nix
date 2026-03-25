{ lib, ... }:
{
  options.myConfig.eyedropper.enable = lib.mkEnableOption "Wayland color picker";
  imports = [ ./eyedropper.nix ];
}
