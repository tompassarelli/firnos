{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.terminal;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.kitty.enable = lib.mkDefault cfg.kitty.enable;
    myConfig.modules.fish.enable = lib.mkDefault cfg.fish.enable;
    myConfig.modules.zoxide.enable = lib.mkDefault cfg.zoxide.enable;
    myConfig.modules.atuin.enable = lib.mkDefault cfg.atuin.enable;
    myConfig.modules.starship.enable = lib.mkDefault cfg.starship.enable;
  };
}
