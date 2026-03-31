{ lib, ... }:
{
  options.myConfig.bundles.javascript = {
    enable = lib.mkEnableOption "JavaScript / Node.js development";
    nodejs.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Node.js"; };
  };

  imports = [ ./javascript.nix ];
}
