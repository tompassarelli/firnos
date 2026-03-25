{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.nodejs.enable = lib.mkEnableOption "Node.js runtime";

  config = lib.mkIf config.myConfig.modules.nodejs.enable {
    environment.systemPackages = [ pkgs.nodejs ];
  };
}
