{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.sqlite.enable = lib.mkEnableOption "SQLite database";

  config = lib.mkIf config.myConfig.modules.sqlite.enable {
    environment.systemPackages = [ pkgs.sqlite ];
  };
}
