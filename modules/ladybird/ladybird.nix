{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.ladybird.enable {
    environment.systemPackages = [
      pkgs.unstable.ladybird
    ];
  };
}
