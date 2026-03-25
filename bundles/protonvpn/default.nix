{ lib, ... }:
{
  options.myConfig.bundles.protonvpn = {
    enable = lib.mkEnableOption "ProtonVPN";
    protonvpn-gui.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ProtonVPN GUI"; };
    protonvpn-cli.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ProtonVPN CLI"; };
  };

  imports = [ ./protonvpn.nix ];
}
