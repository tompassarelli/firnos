{ lib, ... }:
{
  options.myConfig.modules.ripgrep.enable = lib.mkEnableOption "ripgrep search tool";
  imports = [ ./ripgrep.nix ];
}
