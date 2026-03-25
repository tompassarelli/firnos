{ lib, ... }:
{
  options.myConfig.cargo.enable = lib.mkEnableOption "Rust package manager";
  imports = [ ./cargo.nix ];
}
