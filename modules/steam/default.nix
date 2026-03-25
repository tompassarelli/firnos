{ lib, ... }:
{
  options.myConfig.steam.enable = lib.mkEnableOption "Steam gaming platform";
  imports = [ ./steam.nix ];
}
