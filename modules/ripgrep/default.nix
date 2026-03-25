{ lib, ... }:
{
  options.myConfig.ripgrep.enable = lib.mkEnableOption "ripgrep search tool";
  imports = [ ./ripgrep.nix ];
}
