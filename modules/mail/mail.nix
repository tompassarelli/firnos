{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.mail;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.protonmail-desktop   # encrypted mail
    ];
  };
}
