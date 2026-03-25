{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.rust-analyzer.enable = lib.mkEnableOption "Rust language server";

  config = lib.mkIf config.myConfig.modules.rust-analyzer.enable {
    environment.systemPackages = [ pkgs.unstable.rust-analyzer ];
  };
}
