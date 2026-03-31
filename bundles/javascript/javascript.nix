{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.javascript;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.nodejs.enable = lib.mkDefault cfg.nodejs.enable;
  };
}
