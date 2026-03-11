{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.dust.enable {
    environment.systemPackages = with pkgs; [ dust ];
  };
}
