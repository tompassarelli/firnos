{ config, lib, ... }:
{
  options.myConfig.modules.input = {
    enable = lib.mkEnableOption "touchpad support (libinput)";
  };

  config = lib.mkIf config.myConfig.modules.input.enable {
    # Touchpad support
    services.libinput.enable = true;
  };
}
