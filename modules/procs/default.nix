{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.procs;
in
{
  options.myConfig.modules.procs.enable = lib.mkEnableOption "Enable procs (modern ps replacement)";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ procs ];
  };
}
