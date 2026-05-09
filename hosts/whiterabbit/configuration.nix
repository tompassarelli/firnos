{ lib, ... }:

{
  myConfig.modules.system.stateVersion = "25.05";
  myConfig.modules.users.enable = true;
  myConfig.modules.users.username = "tom";
  myConfig.modules.nix-settings.enable = true;
  myConfig.modules.boot.enable = true;
  myConfig.modules.networking.enable = true;
  myConfig.modules.remmina.enable = true;
  myConfig.modules.timezone.enable = true;
  myConfig.modules.ssh.enable = true;
  myConfig.modules.swap.enable = true;
  myConfig.modules.auto-upgrade.enable = true;
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
    devices = [ "/dev/input/event0" "/dev/input/by-id/usb-Kingsis_Peripherals_ZOWIE_Gaming_mouse-event-mouse" "/dev/input/by-id/usb-Logitech_G102_LIGHTSYNC_Gaming_Mouse_2072387E5847-event-mouse" ];
  };
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
  myConfig.modules.nh.enable = true;
}
