{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.swap;
in
{
  options.myConfig.modules.swap.enable = lib.mkEnableOption "zram-based compressed swap";
  config = lib.mkIf cfg.enable {
    zramSwap.enable = true;
    zramSwap.algorithm = "zstd";
    zramSwap.memoryPercent = 50;
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };
  };
}
