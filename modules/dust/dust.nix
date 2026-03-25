{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.dust.enable {
    environment.systemPackages = with pkgs; [ dust ];
  };
}
