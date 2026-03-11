{ lib, ... }:
{
  options.myConfig.password = {
    enable = lib.mkEnableOption "password management tools";
  };

  imports = [
    ./password.nix
  ];
}
