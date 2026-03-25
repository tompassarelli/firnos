{ lib, ... }:
{
  options.myConfig.modules.clippy.enable = lib.mkEnableOption "Rust linter";
  imports = [ ./clippy.nix ];
}
