{ config, lib, ... }:

let
  cfg = config.myConfig.terminal;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.kitty.enable = lib.mkDefault cfg.kitty.enable;
    myConfig.fish.enable = lib.mkDefault cfg.fish.enable;
    myConfig.zoxide.enable = lib.mkDefault cfg.zoxide.enable;
    myConfig.atuin.enable = lib.mkDefault cfg.atuin.enable;
    myConfig.starship.enable = lib.mkDefault cfg.starship.enable;
  };
}
