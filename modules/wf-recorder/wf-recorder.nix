{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.wf-recorder.enable {
    environment.systemPackages = [ pkgs.wf-recorder ];
  };
}
