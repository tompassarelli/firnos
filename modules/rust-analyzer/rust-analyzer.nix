{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.rust-analyzer.enable {
    environment.systemPackages = [ pkgs.unstable.rust-analyzer ];
  };
}
