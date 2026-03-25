{ lib, ... }:
{
  options.myConfig.pkg-config.enable = lib.mkEnableOption "pkg-config build tool";
  imports = [ ./pkg-config.nix ];
}
