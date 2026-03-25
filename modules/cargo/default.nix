{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.cargo.enable = lib.mkEnableOption "Rust package manager";

  config = lib.mkIf config.myConfig.modules.cargo.enable {
    environment.systemPackages = [ pkgs.unstable.cargo ];
  };
}
