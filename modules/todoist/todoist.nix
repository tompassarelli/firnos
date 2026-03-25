{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.todoist.enable {
    environment.systemPackages = [ pkgs.todoist-electron ];
  };
}
