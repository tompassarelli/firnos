# My machine configuration
# Enable the modules you want from FirnOS
{
  # ============ REQUIRED ============
  myConfig.modules.system.stateVersion = "25.05";  # Set to your NixOS install version
  myConfig.modules.users.username = "yourname";   # Change this!

  # ============ BUNDLES ============
  # Groups of modules under one toggle. Override individual members as needed.
  myConfig.bundles.auth.enable = true;
  myConfig.bundles.development.enable = true;
  # myConfig.bundles.development = {
  #   enable = true;
  #   dbeaver.enable = false;  # everything except this
  # };
  myConfig.bundles.media.enable = true;
  myConfig.bundles.productivity.enable = true;
  # myConfig.bundles.creative.enable = true;

  # ============ SYSTEM ============
  myConfig.modules.nix-settings.enable = true;
  myConfig.modules.boot.enable = true;
  myConfig.modules.users.enable = true;
  myConfig.modules.networking.enable = true;
  # myConfig.modules.wireguard.enable = true;
  # myConfig.modules.remmina.enable = true;
  # myConfig.bundles.protonvpn.enable = true;
  myConfig.modules.timezone.enable = true;
  myConfig.modules.ssh.enable = true;
  # myConfig.modules.auto-upgrade.enable = true;

  # ============ HARDWARE ============
  myConfig.modules.pipewire.enable = true;
  myConfig.modules.bluetooth.enable = true;
  myConfig.modules.input.enable = true;
  # myConfig.modules.wl-clipboard.enable = true;
  # myConfig.modules.brightnessctl.enable = true;
  # myConfig.modules.wl-gammarelay.enable = true;
  # myConfig.modules.piper.enable = true;
  # myConfig.bundles.printing.enable = true;
  # myConfig.modules.framework.enable = true;  # Only for Framework laptops
  # myConfig.modules.via.enable = true;        # QMK/VIA keyboard firmware

  myConfig.modules.kanata = {
    enable = true;
    capsLockEscCtrl = true;
    # spacebarSymbols = true;
    # devices = [          # Find yours: ls /dev/input/by-id/
    #   "/dev/input/event0"
    # ];
  };

  # ============ DESKTOP ============
  myConfig.modules.niri.enable = true;
  myConfig.modules.upower.enable = true;
  myConfig.modules.walker.enable = true;
  myConfig.modules.waybar.enable = true;
  myConfig.modules.mako.enable = true;

  # ============ THEMING ============
  myConfig.modules.gtk.enable = true;
  myConfig.modules.styling.enable = true;
  myConfig.modules.stylix.enable = true;
  myConfig.modules.stylix.chosenTheme = "tokyo-night-dark";
  # myConfig.modules.theme-switcher.enable = true;

  # ============ TERMINAL ============
  myConfig.modules.kitty.enable = true;
  myConfig.modules.fish.enable = true;
  myConfig.modules.zoxide.enable = true;
  myConfig.modules.atuin.enable = true;
  myConfig.modules.starship.enable = true;

  # ============ CLI TOOLS ============
  myConfig.modules.yazi.enable = true;
  myConfig.modules.git.enable = true;
  myConfig.modules.tree.enable = true;
  myConfig.modules.dust.enable = true;
  myConfig.modules.eza.enable = true;
  myConfig.modules.procs.enable = true;
  myConfig.modules.tealdeer.enable = true;
  myConfig.modules.fastfetch.enable = true;
  myConfig.modules.btop.enable = true;

  # ============ EDITORS ============
  myConfig.modules.neovim.enable = true;
  # myConfig.bundles.doom-emacs.enable = true;
  # myConfig.modules.lem.enable = true;

  # ============ APPLICATIONS ============
  myConfig.modules.firefox = {
    enable = true;
    fennec.enable = true;
  };
  # myConfig.modules.chrome.enable = true;
  myConfig.modules.password.enable = true;
  # myConfig.modules.mail.enable = true;
  # myConfig.modules.steam.enable = true;

  # ============ VIRTUALIZATION ============
  # myConfig.modules.windows-vm.enable = true;
  # myConfig.modules.containers.enable = true;
}
