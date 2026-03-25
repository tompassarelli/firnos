{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.todoist.enable {
    environment.systemPackages = [ pkgs.todoist-electron ];
  };
}
