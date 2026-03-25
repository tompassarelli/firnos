{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.clippy.enable = lib.mkEnableOption "Rust linter";

  config = lib.mkIf config.myConfig.modules.clippy.enable {
    environment.systemPackages = [ pkgs.unstable.clippy ];
  };
}
