# My machine configuration
# Enable the modules you want from Firn
{ lib, ... }:
{
  # ============ REQUIRED ============
  myConfig.system.stateVersion = "25.05";  # Set to your NixOS install version
  myConfig.users.username = "yourname";   # Change this!

  # ============ SYSTEM ============
  myConfig.nix-settings.enable = true;
  myConfig.boot.enable = true;
  myConfig.users.enable = true;
  myConfig.networking.enable = true;
  # myConfig.wireguard.enable = true;
  # myConfig.remmina.enable = true;
  # myConfig.protonvpn.enable = true;
  myConfig.timezone.enable = true;
  myConfig.ssh.enable = true;
  # myConfig.auto-upgrade.enable = true;

  # ============ HARDWARE ============
  myConfig.pipewire.enable = true;
  myConfig.bluetooth.enable = true;
  myConfig.input.enable = true;
  # myConfig.wl-clipboard.enable = true;
  # myConfig.brightnessctl.enable = true;
  # myConfig.wl-gammarelay.enable = true;
  # myConfig.piper.enable = true;
  # myConfig.printing.enable = true;
  # myConfig.framework.enable = true;  # Only for Framework laptops
  # myConfig.via.enable = true;        # QMK/VIA keyboard firmware

  myConfig.kanata = {
    enable = true;
    capsLockEscCtrl = true;
    # spacebarSymbols = true;
    # customFork = true;  # Use custom kanata fork with tap-hold-release-order
    # devices = [          # Find yours: ls /dev/input/by-id/
    #   "/dev/input/event0"
    # ];
  };

  # ============ DESKTOP ============
  myConfig.niri.enable = true;
  myConfig.upower.enable = true;
  myConfig.auth.enable = true;
  myConfig.walker.enable = true;
  myConfig.waybar.enable = true;
  myConfig.mako.enable = true;

  # ============ THEMING ============
  myConfig.gtk.enable = true;
  myConfig.styling.enable = true;
  myConfig.theming.enable = true;
  myConfig.theming.chosenTheme = "tokyo-night-dark";
  # myConfig.theme-switcher.enable = true;

  # ============ TERMINAL ============
  myConfig.kitty.enable = true;
  myConfig.fish.enable = true;
  myConfig.zoxide.enable = true;
  myConfig.atuin.enable = true;
  myConfig.starship.enable = true;

  # ============ CLI TOOLS ============
  myConfig.yazi.enable = true;
  myConfig.git.enable = true;
  myConfig.tree.enable = true;
  myConfig.dust.enable = true;
  myConfig.eza.enable = true;
  myConfig.procs.enable = true;
  myConfig.tealdeer.enable = true;
  myConfig.fastfetch.enable = true;
  myConfig.btop.enable = true;

  # ============ EDITORS ============
  myConfig.neovim.enable = true;
  # myConfig.doom-emacs.enable = true;
  # myConfig.lem.enable = true;
  # myConfig.zed.enable = true;

  # ============ DEVELOPMENT ============
  myConfig.development.enable = true;
  # myConfig.rust.enable = true;
  # myConfig.claude.enable = true;
  # myConfig.direnv.enable = true;
  # myConfig.postgresql.enable = true;

  # ============ APPLICATIONS ============
  myConfig.firefox = {
    enable = true;
    fennec.enable = true;
  };
  # myConfig.chrome.enable = true;
  myConfig.productivity.enable = true;
  myConfig.media.enable = true;
  myConfig.password.enable = true;
  # myConfig.mail.enable = true;
  # myConfig.steam.enable = true;
  # myConfig.creative.enable = true;

  # ============ VIRTUALIZATION ============
  # myConfig.windows-vm.enable = true;
  # myConfig.containers.enable = true;
}
