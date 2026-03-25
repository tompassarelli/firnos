{ lib, ... }:
{
  options.myConfig.modules.grim.enable = lib.mkEnableOption "Grim screenshot tool";
  imports = [ ./grim.nix ];
}
