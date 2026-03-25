{ lib, ... }:
{
  options.myConfig.modules.libtool.enable = lib.mkEnableOption "GNU Libtool";
  imports = [ ./libtool.nix ];
}
