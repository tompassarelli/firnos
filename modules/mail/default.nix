{ lib, ... }:
{
  options.myConfig.mail = {
    enable = lib.mkEnableOption "email applications";
  };

  imports = [
    ./mail.nix
  ];
}