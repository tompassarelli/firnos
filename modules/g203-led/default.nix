{ lib, ... }:
{
  options.myConfig.modules.g203-led.enable = lib.mkEnableOption "Logitech G102/G203 LED control";
  imports = [ ./g203-led.nix ];
}
