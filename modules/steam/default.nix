{ lib, ... }:
{
  options.myConfig.modules.steam.enable = lib.mkEnableOption "Steam gaming platform";
  imports = [ ./steam.nix ];
}
