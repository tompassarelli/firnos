{ lib, ... }:
{
  options.myConfig.auth = {
    enable = lib.mkEnableOption "authentication (polkit + GNOME Keyring)";
  };

  imports = [
    ./auth.nix
  ];
}
