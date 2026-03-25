{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.ladybird.enable {
    environment.systemPackages = [
      pkgs.unstable.ladybird
    ];
  };
}
