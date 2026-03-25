{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.emacs.enable {
    environment.systemPackages = [ pkgs.emacs ];
  };
}
