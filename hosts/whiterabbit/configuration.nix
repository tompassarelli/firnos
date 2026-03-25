# Host-specific config for whiterabbit (Framework 13 laptop)
{ lib, ... }:
{
  # ============ REQUIRED ============
  myConfig.system.stateVersion = "25.05";
  myConfig.users.enable = true;
  myConfig.users.username = "tom";

  # ============ BUNDLES ============
  myConfig.terminal.enable = true;
  myConfig.cli-tools.enable = true;
  myConfig.desktop = {
    enable = true;
    mako.enable = false;
  };
  myConfig.look-and-feel.enable = true;
  myConfig.theming.chosenTheme = "everforest-dark-hard";
  myConfig.auth.enable = true;
  myConfig.development.enable = true;
  myConfig.rust = {
    enable = true;
    bevy.enable = true;
  };
  myConfig.csharp.enable = true;
  myConfig.lisp.enable = true;
  myConfig.browsers.enable = true;
  myConfig.firefox.fennec.enable = true;
  myConfig.gaming.enable = true;
  myConfig.creative.enable = true;
  myConfig.media.enable = true;
  myConfig.productivity.enable = true;
  myConfig.printing.enable = true;
  myConfig.protonvpn.enable = true;

  # ============ SYSTEM ============
  myConfig.nix-settings.enable = true;
  myConfig.boot.enable = true;
  myConfig.networking.enable = true;
  myConfig.wireguard.enable = true;
  myConfig.remmina.enable = true;
  myConfig.timezone.enable = true;
  myConfig.ssh.enable = true;
  myConfig.auto-upgrade.enable = true;

  # ============ HARDWARE ============
  myConfig.framework.enable = true;
  myConfig.fwupd.enable = true;
  myConfig.pipewire.enable = true;
  myConfig.bluetooth.enable = true;
  myConfig.input.enable = true;
  myConfig.piper.enable = true;
  myConfig.g203-led.enable = true;
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

  # ============ INDIVIDUAL MODULES ============
  myConfig.git.enable = true;
  myConfig.neovim.enable = true;
  myConfig.zed.enable = true;
  myConfig.claude.enable = true;
  myConfig.postgresql.enable = true;
  myConfig.direnv.enable = true;
  myConfig.containers.enable = true;
  myConfig.password.enable = true;
  myConfig.mail.enable = true;
  myConfig.mini-serve.enable = true;
}
