{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.csharp;
in
{
  options.myConfig.bundles.csharp.enable = lib.mkEnableOption "C# / .NET development (dotnet, sqlcmd, Windows VM)";
  options.myConfig.bundles.csharp.dotnet.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable dotnet";
  };
  options.myConfig.bundles.csharp.sqlcmd.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable sqlcmd";
  };
  options.myConfig.bundles.csharp.unixodbc.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable unixodbc";
  };
  options.myConfig.bundles.csharp.windows-vm.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable windows-vm";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.dotnet.enable = lib.mkDefault cfg.dotnet.enable;
    myConfig.modules.sqlcmd.enable = lib.mkDefault cfg.sqlcmd.enable;
    myConfig.modules.unixodbc.enable = lib.mkDefault cfg.unixodbc.enable;
    myConfig.modules.windows-vm.enable = lib.mkDefault cfg.windows-vm.enable;
  };
}
