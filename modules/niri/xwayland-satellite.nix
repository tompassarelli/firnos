{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.niri.enable {
    # Install xwayland-satellite for niri to use
    # Niri 25.08+ manages xwayland-satellite automatically - no systemd service needed
    environment.systemPackages = with pkgs; [
      unstable.xwayland-satellite
    ];
  };
}
