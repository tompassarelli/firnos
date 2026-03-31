{ config, lib, ... }:
let cfg = config.myConfig.bundles.terminal;
in {
  options.myConfig.bundles.terminal = {
    enable = lib.mkEnableOption "terminal environment";
    kitty.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Kitty"; };
    fish.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Fish"; };
    zoxide.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable zoxide"; };
    atuin.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Atuin"; };
    starship.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Starship"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.kitty.enable = lib.mkDefault cfg.kitty.enable;
    myConfig.modules.fish.enable = lib.mkDefault cfg.fish.enable;
    myConfig.modules.zoxide.enable = lib.mkDefault cfg.zoxide.enable;
    myConfig.modules.atuin.enable = lib.mkDefault cfg.atuin.enable;
    myConfig.modules.starship.enable = lib.mkDefault cfg.starship.enable;
  };
}
