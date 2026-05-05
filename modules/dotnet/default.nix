{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.dotnet;
in
{
  options.myConfig.modules.dotnet.enable = lib.mkEnableOption ".NET SDK and CLI tools";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ dotnet-sdk_8 ];
    environment.sessionVariables.PATH = [ "$HOME/.dotnet/tools" ];
  };
}
