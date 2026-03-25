{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.ssh;
in
{
  config = lib.mkIf cfg.enable {
    # OpenSSH daemon configuration
    services.openssh.enable = true;
  };
}
