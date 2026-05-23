{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.mail.enable = lib.mkEnableOption "email applications";
  config = lib.mkIf config.myConfig.modules.mail.enable {
    environment.systemPackages = [ pkgs.unstable.protonmail-desktop ];
  };
}
