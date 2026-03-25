{ lib, ... }:
{
  options.myConfig.modules.gimp.enable = lib.mkEnableOption "GIMP image editor";
  imports = [ ./gimp.nix ];
}
