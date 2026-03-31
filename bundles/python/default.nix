{ lib, ... }:
{
  options.myConfig.bundles.python = {
    enable = lib.mkEnableOption "Python development (python3 + uv)";
    python.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Python"; };
    uv.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable uv"; };
  };

  imports = [ ./python.nix ];
}
