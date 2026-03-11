{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.procs.enable {
    environment.systemPackages = with pkgs; [ procs ];
  };
}
