{ lib, ... }:
{
  options.myConfig.modules.awscli.enable = lib.mkEnableOption "awscli";
  imports = [ ./awscli.nix ];
}
