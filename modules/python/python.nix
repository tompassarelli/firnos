{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.python.enable {
    environment.systemPackages = [
      pkgs.python3
      pkgs.uv
    ];
  };
}
