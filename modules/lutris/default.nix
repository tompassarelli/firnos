{ lib, ... }:
{
  options.myConfig.lutris.enable = lib.mkEnableOption "Lutris gaming platform";
  imports = [ ./lutris.nix ];
}
