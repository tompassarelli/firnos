{ config, lib, pkgs, ... }:
let
  cfg = config.myConfig.modules.password;
in
{
  options.myConfig.modules.password = {
    enable = lib.mkEnableOption "password management tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bitwarden            # password manager
    ];
  };
}
