{ config, lib, pkgs, ... }:
{
  options.myConfig.modules.ladybird = {
    enable = lib.mkEnableOption "Enable Ladybird browser (bleeding edge from git)";
  };

  config = lib.mkIf config.myConfig.modules.ladybird.enable {
    environment.systemPackages = [
      pkgs.unstable.ladybird
    ];
  };
}
