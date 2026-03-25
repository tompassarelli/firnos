{ lib, ... }:
{
  options.myConfig.bundles.rust = {
    enable = lib.mkEnableOption "Rust development toolchain";
    rustc.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Rust compiler"; };
    cargo.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Cargo"; };
    rust-analyzer.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable rust-analyzer"; };
    clippy.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Clippy"; };
    rustfmt.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable rustfmt"; };
    pkg-config.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable pkg-config"; };
    gcc.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable GCC"; };
    bevy.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Bevy game engine libs"; };
  };

  imports = [
    ./rust.nix
  ];
}
