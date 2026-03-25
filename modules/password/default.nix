{ lib, ... }:
{
  options.myConfig.modules.password = {
    enable = lib.mkEnableOption "password management tools";
  };

  imports = [
    ./password.nix
  ];
}
