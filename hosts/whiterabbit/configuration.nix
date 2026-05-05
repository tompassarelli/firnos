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
  myConfig.modules.piper.enable = false;
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
  myConfig.modules.glide.enable = true;

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
  myConfig.bundles.database = {
    enable = true;
    # System Postgres disabled — Kea's dev Postgres lives in
    # ~/code/msa/docker-compose.yml (podman) on port 5433. Keeping a
    # second machine-wide Postgres around just causes confusion about
    # which instance is authoritative. Re-enable if another project
    # genuinely needs a non-dockerized Postgres on the host.
    postgresql.enable = false;
  };
  myConfig.bundles.rust = {
    enable = true;
    bevy.enable = false;
  };
  myConfig.bundles.csharp.enable = false;
  myConfig.bundles.lisp = {
    enable = true;
    lem.enable = true;
  };
  myConfig.bundles.racket.enable = true;
  myConfig.bundles.doom-emacs.enable = true;
  myConfig.bundles.browsers = {
    enable = true;
    firefox.palefox.enable = true;
    chrome.enable = true;
    zen-browser.enable = true;
    qutebrowser.enable = true;
    # librewolf.enable = true;
  };
  myConfig.bundles.gaming = {
    enable = true;
    lutris.enable = true;
    wowup.enable = true;
  };
  myConfig.bundles.creative = {
    enable = true;
    blender.enable = false;
    gimp.enable = false;
    godot.enable = false;
  };
  myConfig.bundles.media = {
    enable = true;
    youtube-music.enable = false;
  };
  myConfig.bundles.communication.enable = true;
  myConfig.bundles.productivity = {
    enable = true;
    obsidian.enable = true;
    todoist.enable = false;
    pomodoro.enable = false;
    libreoffice.enable = false;
  };
  myConfig.bundles.printing.enable = false;
  myConfig.bundles.vpn = {
    enable = true;
    protonvpn-cli.enable = false;
  };

  # ============ MODULES ============
  myConfig.modules.guix.enable = false;
  myConfig.modules.neovim.enable = true;
  myConfig.modules.password.enable = true;
  myConfig.modules.mini-serve.enable = true;
  myConfig.modules.awscli.enable = true;
  myConfig.modules.parted.enable = true;
  myConfig.modules.unixodbc.enable = true;
  myConfig.modules.nix-ld.enable = true;
  myConfig.modules.appimage.enable = true;
  myConfig.modules.codex.enable = true;
  myConfig.modules.vscode.enable = true;
  myConfig.modules.windows-vm.enable = true;
}
