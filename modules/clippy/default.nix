{ lib, ... }:
{
  options.myConfig.clippy.enable = lib.mkEnableOption "Rust linter";
  imports = [ ./clippy.nix ];
}
