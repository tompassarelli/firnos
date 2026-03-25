{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.emacs.enable {
    environment.systemPackages = [ pkgs.emacs ];
  };
}
