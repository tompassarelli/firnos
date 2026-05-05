{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.boot;
in
{
  options.myConfig.modules.boot.enable = lib.mkEnableOption "boot configuration";
  config = lib.mkIf cfg.enable {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelModules = [ "uinput" ];
    boot.kernelParams = [ "amdgpu.vpe_enable=0" ];
  };
}
