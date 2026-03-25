{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.rustfmt.enable = lib.mkEnableOption "Rust formatter";

  config = lib.mkIf config.myConfig.modules.rustfmt.enable {
    environment.systemPackages = [ pkgs.unstable.rustfmt ];
  };
}
