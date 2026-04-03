# Host-specific config for whiterabbit (Framework 13 laptop)
{ lib, ... }:
{
  # ============ REQUIRED ============
  myConfig.modules.system.stateVersion = "25.05";
  myConfig.modules.users.enable = true;
  myConfig.modules.users.username = "tom";

  # ============ SYSTEM ============
  myConfig.modules.nix-settings.enable = true;
  myConfig.modules.boot.enable = true;
  myConfig.modules.networking.enable = true;
  myConfig.modules.remmina.enable = true;
  myConfig.modules.timezone.enable = true;
  myConfig.modules.ssh.enable = true;
  myConfig.modules.auto-upgrade.enable = true;

  # ============ HARDWARE ============
  myConfig.modules.framework.enable = true;
  myConfig.modules.fwupd.enable = true;
  myConfig.modules.pipewire.enable = true;
  myConfig.modules.bluetooth.enable = true;
  myConfig.modules.input.enable = true;
  myConfig.modules.piper.enable = true;
  myConfig.modules.g203-led.enable = true;
  myConfig.modules.kanata = {
    enable = true;
    configFile = ../../dotfiles/kanata/kanata.kbd;
    port = 7070;
    devices = [
      "/dev/input/event0"  # AT Translated Set 2 keyboard
      "/dev/input/by-id/usb-Kingsis_Peripherals_ZOWIE_Gaming_mouse-event-mouse"
      "/dev/input/by-id/usb-Logitech_G102_LIGHTSYNC_Gaming_Mouse_2072387E5847-event-mouse"
    ];
  };
  myConfig.modules.glide.enable = false;

  # ============ BUNDLES ============
  myConfig.bundles.terminal.enable = true;
  myConfig.bundles.cli-tools.enable = true;
  myConfig.bundles.desktop = {
    enable = true;
    mako.enable = false;
  };
  myConfig.bundles.theming = {
    enable = true;
    stylix.chosenTheme = "everforest-dark-hard";
  };
  myConfig.bundles.auth.enable = true;
  myConfig.bundles.development.enable = true;
  myConfig.bundles.javascript.enable = true;
  myConfig.bundles.python.enable = true;
  myConfig.bundles.database.enable = true;
  myConfig.bundles.rust = {
    enable = true;
    bevy.enable = true;
  };
  myConfig.bundles.csharp.enable = true;
  myConfig.bundles.lisp = {
    enable = true;
    lem.enable = false;
  };
  myConfig.bundles.browsers = {
    enable = true;
    firefox.fennec.enable = true;
    nyxt.enable = true;
    ladybird.enable = false;
  };
  myConfig.bundles.gaming = {
    enable = true;
    wowup.enable = false;
  };
  myConfig.bundles.creative = {
    enable = true;
    godot.enable = false;
  };
  myConfig.bundles.media.enable = true;
  myConfig.bundles.communication.enable = true;
  myConfig.bundles.productivity.enable = true;
  myConfig.bundles.printing.enable = true;
  myConfig.bundles.vpn.enable = true;

  # ============ MODULES ============
  myConfig.modules.neovim.enable = true;
  myConfig.modules.password.enable = true;
  myConfig.modules.mini-serve.enable = true;
  myConfig.modules.awscli.enable = true;
  myConfig.modules.parted.enable = true;
}
