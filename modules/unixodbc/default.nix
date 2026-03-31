{ config, lib, pkgs, ... }:
let
  cfg = config.myConfig.modules.unixodbc;
in
{
  options.myConfig.modules.unixodbc = {
    enable = lib.mkEnableOption "unixODBC with MSSQL driver";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.unixODBC
      pkgs.unixODBCDrivers.msodbcsql17
    ];

    environment.variables = {
      ODBCSYSINI = "${pkgs.unixODBC}/etc";
    };

    environment.etc."odbcinst.ini".text = ''
      [ODBC Driver 17 for SQL Server]
      Description = Microsoft ODBC Driver 17 for SQL Server
      Driver = ${pkgs.unixODBCDrivers.msodbcsql17}/lib/libmsodbcsql-17.7.so
    '';
  };
}
