{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.wf-recorder.enable {
    environment.systemPackages = [ pkgs.wf-recorder ];
  };
}
