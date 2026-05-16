{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.thermal-management;
in
{
  options.myConfig.modules.thermal-management.enable = lib.mkEnableOption "CPU thermal management for sustained builds";
  config = lib.mkIf cfg.enable {
    boot.kernelParams = [ "amd_pstate=active" ];
    services.auto-cpufreq.enable = true;
    services.auto-cpufreq.settings = {
      charger = {
        governor = "performance";
        turbo = "never";
        energy_performance_preference = "balance_performance";
      };
      battery = {
        governor = "powersave";
        turbo = "never";
        energy_performance_preference = "power";
      };
    };
  };
}
