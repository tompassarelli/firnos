{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.rustc.enable = lib.mkEnableOption "Rust compiler";

  config = lib.mkIf config.myConfig.modules.rustc.enable {
    environment.systemPackages = [ pkgs.unstable.rustc ];
  };
}
