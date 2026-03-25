{ lib, ... }:
{
  options.myConfig.modules.zoxide = {
    enable = lib.mkEnableOption "zoxide smart directory jumper";
  };

  imports = [
    ./zoxide.nix
  ];
}
