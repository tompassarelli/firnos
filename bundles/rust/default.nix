{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.rust;
in
{
  options.myConfig.bundles.rust.enable = lib.mkEnableOption "Rust development toolchain";
  options.myConfig.bundles.rust.rustc.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable rustc";
  };
  options.myConfig.bundles.rust.cargo.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable cargo";
  };
  options.myConfig.bundles.rust.rust-analyzer.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable rust-analyzer";
  };
  options.myConfig.bundles.rust.clippy.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable clippy";
  };
  options.myConfig.bundles.rust.rustfmt.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable rustfmt";
  };
  options.myConfig.bundles.rust.pkg-config.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable pkg-config";
  };
  options.myConfig.bundles.rust.gcc.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable gcc";
  };
  options.myConfig.bundles.rust.bevy.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable bevy";
  };
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
