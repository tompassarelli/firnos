{ lib, ... }:
{
  options.myConfig.modules.piper = {
    enable = lib.mkEnableOption "gaming mouse configuration (Piper + ratbagd)";
  };

  imports = [
    ./piper.nix
  ];
}
