{ lib, ... }:
{
  options.myConfig.gnumake.enable = lib.mkEnableOption "GNU Make build tool";
  imports = [ ./gnumake.nix ];
}
