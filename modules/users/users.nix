{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.users;
in
{
  options.myConfig.users = {
    enable = lib.mkEnableOption "Enable user configuration";

    username = lib.mkOption {
      type = lib.types.str;
      default = "tom";
      description = "Primary system username";
    };
  };

  config = lib.mkIf cfg.enable {
    # Define user account
    users.users.${cfg.username} = {
      shell = pkgs.fish;
      isNormalUser = true;
      home = "/home/${cfg.username}";
      extraGroups = [ "wheel" "networkmanager" "plugdev" ]; # Enable 'sudo' for the user
    };

    # Sudo configuration - extend timeout to 30 minutes
    security.sudo.extraConfig = ''
      Defaults timestamp_timeout=30
    '';

    # Create user directories on boot
    systemd.tmpfiles.rules = [
      "d /home/${cfg.username}/Documents 0755 ${cfg.username} users -"
      "d /home/${cfg.username}/Pictures/Screenshots 0755 ${cfg.username} users -"
      "d /home/${cfg.username}/code 0755 ${cfg.username} users -"
      "d /home/${cfg.username}/src 0755 ${cfg.username} users -"
    ];
  };
}
