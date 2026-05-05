{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.database;
in
{
  options.myConfig.bundles.database.enable = lib.mkEnableOption "database tools";
  options.myConfig.bundles.database.dbeaver.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable dbeaver";
  };
  options.myConfig.bundles.database.sqlite.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable sqlite";
  };
  options.myConfig.bundles.database.postgresql.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable postgresql";
  };
  options.myConfig.bundles.database.freetds.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable freetds";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.dbeaver.enable = lib.mkDefault cfg.dbeaver.enable;
    myConfig.modules.sqlite.enable = lib.mkDefault cfg.sqlite.enable;
    myConfig.modules.postgresql.enable = lib.mkDefault cfg.postgresql.enable;
    myConfig.modules.freetds.enable = lib.mkDefault cfg.freetds.enable;
  };
}
