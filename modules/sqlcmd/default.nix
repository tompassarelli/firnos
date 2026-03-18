{ lib, ... }:
{
  options.myConfig.sqlcmd = {
    enable = lib.mkEnableOption "sqlcmd for Microsoft SQL Server";
  };

  imports = [
    ./sqlcmd.nix
  ];
}
