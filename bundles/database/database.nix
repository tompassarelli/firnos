{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.database;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.dbeaver.enable = lib.mkDefault cfg.dbeaver.enable;
    myConfig.modules.sqlite.enable = lib.mkDefault cfg.sqlite.enable;
    myConfig.modules.postgresql.enable = lib.mkDefault cfg.postgresql.enable;
  };
}
