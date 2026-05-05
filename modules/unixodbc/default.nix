{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.unixodbc;
  msodbcsql18 = pkgs.unstable.unixodbcDrivers.msodbcsql18;
in
{
  options.myConfig.modules.unixodbc.enable = lib.mkEnableOption "unixODBC with MSSQL driver";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.unixODBC msodbcsql18 ];
    environment.variables = {
      ODBCSYSINI = "/etc";
      ODBCINI = "/etc/odbc.ini";
    };
    environment.etc = {
      ${"odbcinst.ini"} = {
        text = ''
          [ODBC Driver 18 for SQL Server]
          Description = Microsoft ODBC Driver 18 for SQL Server
          Driver = ${msodbcsql18}/lib/libmsodbcsql-18.1.so.1.1
        '';
      };
      ${"odbc.ini"} = {
        text = ''
          [msa_data]
          Driver = ODBC Driver 18 for SQL Server
          Server = localhost
          Database = msa_data
          TrustServerCertificate = Yes
        '';
      };
    };
  };
}
