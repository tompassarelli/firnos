{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.password;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bitwarden            # password manager
    ];
  };
}
