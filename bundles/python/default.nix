{ config, lib, pkgs, ... }:

{
  options.myConfig.bundles.python = {
    enable = lib.mkEnableOption "Python development (python3 + uv)";
    python.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable python";
    };
    uv.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable uv";
    };
  };
  config = lib.mkIf config.myConfig.bundles.python.enable {
    myConfig.modules.python.enable = lib.mkDefault config.myConfig.bundles.python.python.enable;
    myConfig.modules.uv.enable = lib.mkDefault config.myConfig.bundles.python.uv.enable;
  };
}
