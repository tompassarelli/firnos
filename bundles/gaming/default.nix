{ lib, ... }:
{
  options.myConfig.bundles.gaming = {
    enable = lib.mkEnableOption "gaming platforms and tools";
    steam.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable steam"; };
    lutris.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable lutris"; };
    wowup.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable wowup"; };
  };

  imports = [ ./gaming.nix ];
}
