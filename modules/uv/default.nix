{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.uv.enable = lib.mkEnableOption "uv Python package manager";

  config = lib.mkIf config.myConfig.modules.uv.enable {
    environment.systemPackages = [ pkgs.uv ];
  };
}
