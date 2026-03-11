{ lib, ... }:
{
  options.myConfig.gnome-keyring = {
    enable = lib.mkEnableOption "GNOME Keyring (secrets storage + Seahorse GUI)";
  };

  imports = [
    ./gnome-keyring.nix
  ];
}
