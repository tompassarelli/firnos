{ lib, ... }:

{
  myConfig.modules.system.stateVersion = "25.05";
  myConfig.modules.users.username = "yourname";
  myConfig.modules.nix-settings.enable = true;
  myConfig.modules.boot.enable = true;
  myConfig.modules.users.enable = true;
  myConfig.modules.networking.enable = true;
  myConfig.modules.timezone.enable = true;
  myConfig.modules.ssh.enable = true;
  myConfig.modules.pipewire.enable = true;
  myConfig.modules.bluetooth.enable = true;
  myConfig.modules.input.enable = true;
  myConfig.modules.kanata = {
    enable = true;
    capsLockEscCtrl = true;
  };
  myConfig.bundles.terminal.enable = true;
  myConfig.bundles.cli-tools.enable = true;
  myConfig.bundles.desktop.enable = true;
  myConfig.bundles.theming = {
    enable = true;
    stylix.chosenTheme = "tokyo-night-dark";
  };
  myConfig.bundles.auth.enable = true;
  myConfig.bundles.development.enable = true;
  myConfig.bundles.browsers.enable = true;
  myConfig.bundles.media.enable = true;
  myConfig.bundles.communication.enable = true;
  myConfig.bundles.productivity.enable = true;
  myConfig.bundles.racket.enable = true;
  myConfig.modules.neovim.enable = true;
  myConfig.modules.password.enable = true;
}
