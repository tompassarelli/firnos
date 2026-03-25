{ lib, ... }:
{
  options.myConfig.csharp = {
    enable = lib.mkEnableOption "C# / .NET development (dotnet, sqlcmd, Windows VM)";
    dotnet.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable .NET SDK"; };
    sqlcmd.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable sqlcmd"; };
    windows-vm.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Windows VM"; };
  };

  imports = [
    ./csharp.nix
  ];
}
