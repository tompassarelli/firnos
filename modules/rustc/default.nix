{ lib, ... }:
{
  options.myConfig.rustc.enable = lib.mkEnableOption "Rust compiler";
  imports = [ ./rustc.nix ];
}
