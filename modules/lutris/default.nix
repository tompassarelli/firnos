{ lib, ... }:
{
  options.myConfig.modules.lutris.enable = lib.mkEnableOption "Lutris gaming platform";
  imports = [ ./lutris.nix ];
}
