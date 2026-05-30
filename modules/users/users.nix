{ config, lib, pkgs, ... }:

let
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.users.enable = lib.mkEnableOption "Enable user configuration";
  options.myConfig.modules.users.username = lib.mkOption {
    type = lib.types.str;
    default = "tom";
    description = "Primary system username";
  };
  config = lib.mkIf config.myConfig.modules.users.enable {
    users.users.${username} = {
      shell = pkgs.bashInteractive;
      isNormalUser = true;
      home = "/home/${username}";
      extraGroups = [ "wheel" "networkmanager" "plugdev" ];
    };
    security.sudo.extraConfig = ~;
    "''Defaults" = timestamp_timeout=30;
    ${Defaults} = timestamp_type=global;
    "'':systemd.tmpfiles.rules" = [
      "d /home/${username}/Documents 0755 ${username} users -"
      "d /home/${username}/Pictures/Screenshots 0755 ${username} users -"
      "d /home/${username}/code 0755 ${username} users -"
      "d /home/${username}/src 0755 ${username} users -"
    ];
  };
}
