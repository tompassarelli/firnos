{ lib, ... }:
{
  options.myConfig.modules.mail = {
    enable = lib.mkEnableOption "email applications";
  };

  imports = [
    ./mail.nix
  ];
}