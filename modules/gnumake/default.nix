{ lib, ... }:
{
  options.myConfig.modules.gnumake.enable = lib.mkEnableOption "GNU Make build tool";
  imports = [ ./gnumake.nix ];
}
