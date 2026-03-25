{ lib, ... }:
{
  options.myConfig.unrar.enable = lib.mkEnableOption "unrar archive tool";
  imports = [ ./unrar.nix ];
}
