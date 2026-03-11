{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.ssh;
in
{
  config = lib.mkIf cfg.enable {
    # OpenSSH daemon configuration
    services.openssh.enable = true;
  };
}
