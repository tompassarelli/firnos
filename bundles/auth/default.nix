{ lib, ... }:
{
  options.myConfig.auth = {
    enable = lib.mkEnableOption "authentication (polkit + GNOME Keyring)";
    polkit.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable polkit"; };
    gnome-keyring.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable GNOME Keyring"; };
  };

  imports = [
    ./auth.nix
  ];
}
