{ lib, ... }:
{
  options.myConfig.gimp.enable = lib.mkEnableOption "GIMP image editor";
  imports = [ ./gimp.nix ];
}
