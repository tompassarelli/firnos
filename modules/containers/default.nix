{ config, lib, pkgs, ... }:
let
  cfg = config.myConfig.modules.containers;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.containers = {
    enable = lib.mkEnableOption "Podman containers with Distrobox";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      # Docker-compatible CLI alias (podman runs when you type `docker`)
      dockerCompat = true;
      # Enable default network for rootless containers
      defaultNetwork.settings.dns_enabled = true;
    };

    # Add user to podman group
    users.users.${username}.extraGroups = [ "podman" ];

    environment.systemPackages = with pkgs; [
      distrobox
      podman-compose
    ];
  };
}
