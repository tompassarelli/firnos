{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.modules.input.enable {
    # Touchpad support
    services.libinput.enable = true;
  };
}
