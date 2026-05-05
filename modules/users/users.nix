{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.users;
in
{
  options.myConfig.modules.users.enable = lib.mkEnableOption "Enable user configuration";
  options.myConfig.modules.users.username = lib.mkOption {
    type = lib.types.str;
    default = "tom";
    description = "Primary system username";
  };
  config = lib.mkIf cfg.enable {
    users.users = {
      ${cfg.username} = {
        shell = pkgs.fish;
        isNormalUser = true;
        home = "/home/${cfg.username}";
        extraGroups = [ "wheel" "networkmanager" "plugdev" ];
      };
    };
    security.sudo.extraConfig = ''
      Defaults timestamp_timeout=30
      Defaults timestamp_type=global
    '';
    systemd.tmpfiles.rules = [
      "d /home/${cfg.username}/Documents 0755 ${cfg.username} users -"
      "d /home/${cfg.username}/Pictures/Screenshots 0755 ${cfg.username} users -"
      "d /home/${cfg.username}/code 0755 ${cfg.username} users -"
      "d /home/${cfg.username}/src 0755 ${cfg.username} users -"
    ];
  };
}
