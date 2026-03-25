{ lib, ... }:
{
  options.myConfig.modules.unrar.enable = lib.mkEnableOption "unrar archive tool";
  imports = [ ./unrar.nix ];
}
