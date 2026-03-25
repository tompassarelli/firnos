{ lib, ... }:
{
  options.myConfig.rust.enable = lib.mkEnableOption "Rust development toolchain";
  imports = [ ./rust.nix ];
}
