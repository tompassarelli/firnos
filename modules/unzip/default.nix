{ lib, ... }:
{
  options.myConfig.unzip.enable = lib.mkEnableOption "unzip archive tool";
  imports = [ ./unzip.nix ];
}
