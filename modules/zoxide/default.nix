{ lib, ... }:
{
  options.myConfig.zoxide = {
    enable = lib.mkEnableOption "zoxide smart directory jumper";
  };

  imports = [
    ./zoxide.nix
  ];
}
