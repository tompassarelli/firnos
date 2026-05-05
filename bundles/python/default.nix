{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.python;
in
{
  options.myConfig.bundles.python.enable = lib.mkEnableOption "Python development (python3 + uv)";
  options.myConfig.bundles.python.python.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable python";
  };
  options.myConfig.bundles.python.uv.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable uv";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.python.enable = lib.mkDefault cfg.python.enable;
    myConfig.modules.uv.enable = lib.mkDefault cfg.uv.enable;
  };
}
