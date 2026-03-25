{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.csharp;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.dotnet.enable = lib.mkDefault cfg.dotnet.enable;
    myConfig.modules.sqlcmd.enable = lib.mkDefault cfg.sqlcmd.enable;
    myConfig.modules.windows-vm.enable = lib.mkDefault cfg.windows-vm.enable;
  };
}
