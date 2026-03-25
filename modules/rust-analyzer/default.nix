{ lib, ... }:
{
  options.myConfig.modules.rust-analyzer.enable = lib.mkEnableOption "Rust language server";
  imports = [ ./rust-analyzer.nix ];
}
