{ lib, ... }:
{
  options.myConfig.libtool.enable = lib.mkEnableOption "GNU Libtool";
  imports = [ ./libtool.nix ];
}
