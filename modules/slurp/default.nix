{ lib, ... }:
{
  options.myConfig.modules.slurp.enable = lib.mkEnableOption "Wayland region selector";
  imports = [ ./slurp.nix ];
}
