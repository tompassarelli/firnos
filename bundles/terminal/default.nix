{ lib, ... }:
{
  options.myConfig.terminal = {
    enable = lib.mkEnableOption "terminal environment";
    kitty.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable kitty"; };
    fish.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable fish"; };
    zoxide.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable zoxide"; };
    atuin.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable atuin"; };
    starship.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable starship"; };
  };

  imports = [ ./terminal.nix ];
}
