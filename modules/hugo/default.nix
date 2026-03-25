{ lib, ... }:
{
  options.myConfig.hugo.enable = lib.mkEnableOption "Hugo static site generator";
  imports = [ ./hugo.nix ];
}
