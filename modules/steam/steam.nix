{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.steam;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.steam = {
        enable = true;
        package = pkgs.unstable.steam;
      };
    })

    (lib.mkIf cfg.wowup.enable {
      environment.systemPackages = [ pkgs.wowup-cf ];
    })
  ];
}
