{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.procs.enable {
    environment.systemPackages = with pkgs; [ procs ];
  };
}
