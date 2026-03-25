{ lib, ... }:
{
  options.myConfig.modules.lem = {
    enable = lib.mkEnableOption "Lem Common Lisp editor";
  };

  imports = [
    ./lem.nix
  ];
}
