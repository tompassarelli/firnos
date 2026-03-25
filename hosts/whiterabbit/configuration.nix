# Host-specific config for whiterabbit (Framework 13 laptop)
# This matches exactly what was in flake.nix before refactor
{ lib, ... }:
{
  # Hardware
  # - framework laptop
  myConfig.framework.enable = true;
  # - custom keyboard qmk firmware
  myConfig.via.enable = false;
  # - everything else
  myConfig.pipewire.enable = true;
  myConfig.bluetooth.enable = true;
  myConfig.printing.enable = true;
  myConfig.input.enable = true;
  myConfig.wl-clipboard.enable = true;
  myConfig.brightnessctl.enable = true;
  myConfig.wl-gammarelay.enable = true;
  myConfig.piper.enable = true;
  myConfig.kanata = {
    enable = true;
    capsLockEscCtrl = true;
    spacebarSymbols = true;
    devices = [
      "/dev/input/event0"  # AT Translated Set 2 keyboard
      "/dev/input/by-id/usb-Kingsis_Peripherals_ZOWIE_Gaming_mouse-event-mouse"
      "/dev/input/by-id/usb-Logitech_G102_LIGHTSYNC_Gaming_Mouse_2072387E5847-event-mouse"
    ];
  };
  myConfig.glide.enable = true;

  # System
  myConfig.system.stateVersion = "25.05";
  myConfig.nix-settings.enable = true;
  myConfig.boot.enable = true;
  myConfig.users.enable = true;
  myConfig.users.username = "tom";
  myConfig.networking.enable = true;
  myConfig.wireguard.enable = true;
  myConfig.remmina.enable = true;
  myConfig.protonvpn.enable = true;
  myConfig.timezone.enable = true;
  myConfig.ssh.enable = true;
  myConfig.auto-upgrade.enable = true;

  # Terminal
  myConfig.kitty.enable = true;
  myConfig.fish.enable = true;
  myConfig.zoxide.enable = true;
  myConfig.atuin.enable = true;
  myConfig.starship.enable = true;

  # Utils
  myConfig.yazi.enable = true;
  myConfig.tree.enable = true;
  myConfig.dust.enable = true;
  myConfig.eza.enable = true;
  myConfig.procs.enable = true;
  myConfig.tealdeer.enable = true;
  myConfig.fastfetch.enable = true;
  myConfig.btop.enable = true;

  # Desktop Environment
  myConfig.niri.enable = true;
  myConfig.upower.enable = true;
  myConfig.auth.enable = true;
  myConfig.rofi-wayland.enable = true;
  myConfig.walker.enable = false;
  myConfig.waybar.enable = false;
  myConfig.quickshell.enable = true;
  myConfig.mako.enable = false;

  # Theming
  myConfig.gtk.enable = true;
  myConfig.styling.enable = true;
  myConfig.theming.enable = true;
  myConfig.theming.chosenTheme = "everforest-dark-hard";
  myConfig.theme-switcher.enable = true;

  # Development
  myConfig.git.enable = true;
  myConfig.neovim.enable = true;
  myConfig.doom-emacs.enable = true;
  myConfig.lem.enable = true;
  myConfig.development.enable = true;
  myConfig.zed.enable = true;
  myConfig.rust = {
    enable = true;
    bevy = true;
  };
  myConfig.claude.enable = true;
  myConfig.postgresql.enable = true;
  myConfig.sqlcmd.enable = true;
  myConfig.direnv.enable = true;
  myConfig.dotnet.enable = true;

  # Applications
  myConfig.firefox = {
    enable = true;
    fennec.enable = true;
  };
  myConfig.chrome.enable = true;
  myConfig.nyxt.enable = true;
  myConfig.ladybird.enable = true;
  myConfig.steam = {
    enable = true;
    wowup.enable = true;
  };
  myConfig.productivity.enable = true;
  myConfig.creative.enable = true;
  myConfig.media.enable = true;
  myConfig.password.enable = true;
  myConfig.mail.enable = true;

  # Virtualization
  myConfig.windows-vm.enable = true;
  myConfig.containers.enable = true;
  myConfig.mini-serve.enable = true;
}
