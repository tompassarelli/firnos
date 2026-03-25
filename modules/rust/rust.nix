{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.rust.enable {
    environment.systemPackages = with pkgs; [
      unstable.rustc          # compiler
      unstable.cargo          # package manager
      unstable.rust-analyzer  # language server
      unstable.clippy         # linter
      unstable.rustfmt        # formatter
      pkg-config              # find system libraries during compilation
      gcc                     # C compiler for native dependencies
    ];
  };
}
