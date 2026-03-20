{ lib, ... }:
{
  options.myConfig.dotnet = {
    enable = lib.mkEnableOption ".NET SDK and CLI tools";
  };

  imports = [
    ./dotnet.nix
  ];
}
