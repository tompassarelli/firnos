{ config, lib, pkgs, ... }:
let
  cfg = config.myConfig.modules.ssh;
in
{
  options.myConfig.modules.ssh = {
    enable = lib.mkEnableOption "SSH server";
  };

  config = lib.mkIf cfg.enable {
    # OpenSSH daemon configuration
    services.openssh.enable = true;
  };
}
