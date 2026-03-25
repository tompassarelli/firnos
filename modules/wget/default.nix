{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.wget.enable = lib.mkEnableOption "wget download tool";

  config = lib.mkIf config.myConfig.modules.wget.enable {
    environment.systemPackages = [ pkgs.wget ];
  };
}
