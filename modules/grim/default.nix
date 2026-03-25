{ lib, ... }:
{
  options.myConfig.grim.enable = lib.mkEnableOption "Grim screenshot tool";
  imports = [ ./grim.nix ];
}
