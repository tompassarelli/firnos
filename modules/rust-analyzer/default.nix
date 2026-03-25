{ lib, ... }:
{
  options.myConfig.rust-analyzer.enable = lib.mkEnableOption "Rust language server";
  imports = [ ./rust-analyzer.nix ];
}
