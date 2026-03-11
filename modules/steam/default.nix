{ lib, ... }:
{
  options.myConfig.steam = {
    enable = lib.mkEnableOption "Steam gaming platform";
    wowup.enable = lib.mkEnableOption "WowUp-CF addon manager for World of Warcraft";
  };

  imports = [
    ./steam.nix
  ];
}