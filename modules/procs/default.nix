{ config, lib, pkgs, ... }:
{
  options.myConfig.modules.procs = {
    enable = lib.mkEnableOption "Enable procs (modern ps replacement)";
  };

  config = lib.mkIf config.myConfig.modules.procs.enable {
    environment.systemPackages = with pkgs; [ procs ];
  };
}
