# My machine configuration
# Enable the modules you want from FirnOS
{
  # ============ REQUIRED ============
  myConfig.modules.system.stateVersion = "25.05";  # Set to your NixOS install version
  myConfig.modules.users.username = "yourname";   # Change this!

  # ============ SYSTEM ============
  myConfig.modules.nix-settings.enable = true;
  myConfig.modules.boot.enable = true;
  myConfig.modules.users.enable = true;
  myConfig.modules.networking.enable = true;
  # myConfig.modules.wireguard.enable = true;
  # myConfig.modules.remmina.enable = true;
  myConfig.modules.timezone.enable = true;
  myConfig.modules.ssh.enable = true;
  # myConfig.modules.auto-upgrade.enable = true;

  # ============ HARDWARE ============
  myConfig.modules.pipewire.enable = true;
  myConfig.modules.bluetooth.enable = true;
  myConfig.modules.input.enable = true;
  # myConfig.modules.framework.enable = true;  # Only for Framework laptops
  # myConfig.bundles.printing.enable = true;

  myConfig.modules.kanata = {
    enable = true;
    capsLockEscCtrl = true;
    # devices = [          # Find yours: ls /dev/input/by-id/
    #   "/dev/input/event0"
    # ];
  };

  # ============ BUNDLES ============
  myConfig.bundles.terminal.enable = true;
  myConfig.bundles.cli-tools.enable = true;
  myConfig.bundles.desktop.enable = true;
  myConfig.bundles.theming = {
    enable = true;
    stylix.chosenTheme = "tokyo-night-dark";
  };
  myConfig.bundles.auth.enable = true;
  myConfig.bundles.development.enable = true;
  # myConfig.bundles.rust.enable = true;
  # myConfig.bundles.creative.enable = true;
  myConfig.bundles.browsers.enable = true;
  myConfig.bundles.media.enable = true;
  myConfig.bundles.communication.enable = true;
  myConfig.bundles.productivity.enable = true;
  # myConfig.bundles.gaming.enable = true;

  # Override individual modules within a bundle:
  # myConfig.bundles.desktop = {
  #   enable = true;
  #   mako.enable = false;  # everything except this
  # };

  # ============ MODULES ============
  myConfig.modules.neovim.enable = true;
  myConfig.modules.password.enable = true;
  # myConfig.modules.containers.enable = true;
}
