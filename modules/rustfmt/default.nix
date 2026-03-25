{ lib, ... }:
{
  options.myConfig.rustfmt.enable = lib.mkEnableOption "Rust formatter";
  imports = [ ./rustfmt.nix ];
}
