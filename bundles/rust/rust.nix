{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.rust;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.rustc.enable = lib.mkDefault cfg.rustc.enable;
    myConfig.modules.cargo.enable = lib.mkDefault cfg.cargo.enable;
    myConfig.modules.rust-analyzer.enable = lib.mkDefault cfg.rust-analyzer.enable;
    myConfig.modules.clippy.enable = lib.mkDefault cfg.clippy.enable;
    myConfig.modules.rustfmt.enable = lib.mkDefault cfg.rustfmt.enable;
    myConfig.modules.pkg-config.enable = lib.mkDefault cfg.pkg-config.enable;
    myConfig.modules.gcc.enable = lib.mkDefault cfg.gcc.enable;
    myConfig.modules.bevy.enable = lib.mkDefault cfg.bevy.enable;
  };
}
