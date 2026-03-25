{ lib, ... }:
{
  options.myConfig.modules.rustfmt.enable = lib.mkEnableOption "Rust formatter";
  imports = [ ./rustfmt.nix ];
}
