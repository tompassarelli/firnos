{ config, lib, pkgs, ... }:

{
  options.myConfig.bundles.terminal = {
    enable = lib.mkEnableOption "terminal environment";
    kitty.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable kitty";
    };
    fish.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable fish";
    };
    zoxide.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable zoxide";
    };
    atuin.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable atuin";
    };
    starship.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable starship";
    };
  };
  config = lib.mkIf config.myConfig.bundles.terminal.enable {
    myConfig.modules.kitty.enable = lib.mkDefault config.myConfig.bundles.terminal.kitty.enable;
    myConfig.modules.fish.enable = lib.mkDefault config.myConfig.bundles.terminal.fish.enable;
    myConfig.modules.zoxide.enable = lib.mkDefault config.myConfig.bundles.terminal.zoxide.enable;
    myConfig.modules.atuin.enable = lib.mkDefault config.myConfig.bundles.terminal.atuin.enable;
    myConfig.modules.starship.enable = lib.mkDefault config.myConfig.bundles.terminal.starship.enable;
  };
}
