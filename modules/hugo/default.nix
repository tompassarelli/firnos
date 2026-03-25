{ lib, ... }:
{
  options.myConfig.modules.hugo.enable = lib.mkEnableOption "Hugo static site generator";
  imports = [ ./hugo.nix ];
}
