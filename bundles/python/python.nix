{ config, lib, ... }:

let
  cfg = config.myConfig.python-dev;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.python.enable = lib.mkDefault cfg.python.enable;
    myConfig.uv.enable = lib.mkDefault cfg.uv.enable;
  };
}
