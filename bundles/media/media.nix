{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.media;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
    # Social/Communication
    discord              # as stable as its name implies
    zoom-us              # meetings

    # Music
    spotify              # enjoyable sounds
    youtube-music        # also enjoyable sounds

    # Media viewers
    imv                  # img viewer
    mpv                  # video player
    zathura              # PDF viewer

    # Gaming
    lutris               # retro game frontend and gaming platform

    # Wayland desktop tools
    nautilus             # gtk file manager (needed for file dialogs)
    swaylock             # lock screen: Super + Alt + L
    swayidle             # auto-lock after idle
    swaybg               # wallpaper setter
    grim                 # primary screenshot tool
    slurp                # region selector for screenshots

    # System utilities
    pavucontrol          # audio control GUI
    ];
  };
}
