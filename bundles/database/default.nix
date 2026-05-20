{ config, lib, pkgs, ... }:

{
  options.myConfig.bundles.database = {
    enable = lib.mkEnableOption "database tools";
    dbeaver.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable DBeaver";
    };
    sqlite.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable SQLite";
    };
    postgresql.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable PostgreSQL";
    };
    freetds.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable FreeTDS";
    };
  };
  config = lib.mkIf config.myConfig.bundles.database.enable {
    myConfig.modules.dbeaver.enable = lib.mkDefault config.myConfig.bundles.database.dbeaver.enable;
    myConfig.modules.sqlite.enable = lib.mkDefault config.myConfig.bundles.database.sqlite.enable;
    myConfig.modules.postgresql.enable = lib.mkDefault config.myConfig.bundles.database.postgresql.enable;
    myConfig.modules.freetds.enable = lib.mkDefault config.myConfig.bundles.database.freetds.enable;
  };
}
