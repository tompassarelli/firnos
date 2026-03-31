{ config, lib, ... }:
let cfg = config.myConfig.bundles.rust;
in {
  options.myConfig.bundles.rust = {
    enable = lib.mkEnableOption "Rust development toolchain";
    rustc.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable rustc"; };
    cargo.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Cargo"; };
    rust-analyzer.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable rust-analyzer"; };
    clippy.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Clippy"; };
    rustfmt.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable rustfmt"; };
    pkg-config.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable pkg-config"; };
    gcc.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable GCC"; };
    bevy.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Bevy game engine libs"; };
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
