{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.swaylock.enable = lib.mkEnableOption "swaylock screen locker";

  config = lib.mkIf config.myConfig.modules.swaylock.enable {
    environment.systemPackages = [ pkgs.swaylock ];
  };
}
