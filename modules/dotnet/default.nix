{ lib, ... }:
{
  options.myConfig.modules.dotnet = {
    enable = lib.mkEnableOption ".NET SDK and CLI tools";
  };

  imports = [
    ./dotnet.nix
  ];
}
