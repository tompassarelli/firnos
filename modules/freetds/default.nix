{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.freetds.enable = lib.mkEnableOption "FreeTDS (TDS protocol library for MSSQL)";

  config = lib.mkIf config.myConfig.modules.freetds.enable {
    environment.systemPackages = [ pkgs.freetds ];
  };
}
