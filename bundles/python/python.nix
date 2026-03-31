{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.python;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.python.enable = lib.mkDefault cfg.python.enable;
    myConfig.modules.uv.enable = lib.mkDefault cfg.uv.enable;
  };
}
