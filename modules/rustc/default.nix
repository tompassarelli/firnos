{ lib, ... }:
{
  options.myConfig.modules.rustc.enable = lib.mkEnableOption "Rust compiler";
  imports = [ ./rustc.nix ];
}
