{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.terminal;
in
{
  options.myConfig.bundles.terminal.enable = lib.mkEnableOption "terminal environment";
  options.myConfig.bundles.terminal.kitty.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable kitty";
  };
  options.myConfig.bundles.terminal.fish.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable fish";
  };
  options.myConfig.bundles.terminal.zoxide.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable zoxide";
  };
  options.myConfig.bundles.terminal.atuin.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable atuin";
  };
  options.myConfig.bundles.terminal.starship.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable starship";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.kitty.enable = lib.mkDefault cfg.kitty.enable;
    myConfig.modules.fish.enable = lib.mkDefault cfg.fish.enable;
    myConfig.modules.zoxide.enable = lib.mkDefault cfg.zoxide.enable;
    myConfig.modules.atuin.enable = lib.mkDefault cfg.atuin.enable;
    myConfig.modules.starship.enable = lib.mkDefault cfg.starship.enable;
  };
}
