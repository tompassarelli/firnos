{ config, lib, ... }:

let
  cfg = config.myConfig.rust;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.rustc.enable = lib.mkDefault cfg.rustc.enable;
    myConfig.cargo.enable = lib.mkDefault cfg.cargo.enable;
    myConfig.rust-analyzer.enable = lib.mkDefault cfg.rust-analyzer.enable;
    myConfig.clippy.enable = lib.mkDefault cfg.clippy.enable;
    myConfig.rustfmt.enable = lib.mkDefault cfg.rustfmt.enable;
    myConfig.pkg-config.enable = lib.mkDefault cfg.pkg-config.enable;
    myConfig.gcc.enable = lib.mkDefault cfg.gcc.enable;
    myConfig.bevy.enable = lib.mkDefault cfg.bevy.enable;
  };
}
