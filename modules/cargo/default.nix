{ lib, ... }:
{
  options.myConfig.modules.cargo.enable = lib.mkEnableOption "Rust package manager";
  imports = [ ./cargo.nix ];
}
