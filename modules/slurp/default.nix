{ lib, ... }:
{
  options.myConfig.slurp.enable = lib.mkEnableOption "Wayland region selector";
  imports = [ ./slurp.nix ];
}
