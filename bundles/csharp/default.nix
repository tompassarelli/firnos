{ config, lib, ... }:
let cfg = config.myConfig.bundles.csharp;
in {
  options.myConfig.bundles.csharp = {
    enable = lib.mkEnableOption "C# / .NET development (dotnet, sqlcmd, Windows VM)";
    dotnet.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable .NET SDK"; };
    sqlcmd.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable sqlcmd"; };
    unixodbc.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable unixODBC with MSSQL driver"; };
    windows-vm.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Windows VM"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.dotnet.enable = lib.mkDefault cfg.dotnet.enable;
    myConfig.modules.sqlcmd.enable = lib.mkDefault cfg.sqlcmd.enable;
    myConfig.modules.unixodbc.enable = lib.mkDefault cfg.unixodbc.enable;
    myConfig.modules.windows-vm.enable = lib.mkDefault cfg.windows-vm.enable;
  };
}
