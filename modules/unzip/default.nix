{ lib, ... }:
{
  options.myConfig.modules.unzip.enable = lib.mkEnableOption "unzip archive tool";
  imports = [ ./unzip.nix ];
}
