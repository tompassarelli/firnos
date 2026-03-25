{ config, lib, ... }:

let
  cfg = config.myConfig.csharp;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.dotnet.enable = lib.mkDefault cfg.dotnet.enable;
    myConfig.sqlcmd.enable = lib.mkDefault cfg.sqlcmd.enable;
    myConfig.windows-vm.enable = lib.mkDefault cfg.windows-vm.enable;
  };
}
