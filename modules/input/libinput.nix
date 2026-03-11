{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.input.enable {
    # Touchpad support
    services.libinput.enable = true;
  };
}
