{ lib, ... }:
{
  options.myConfig.lem = {
    enable = lib.mkEnableOption "Lem Common Lisp editor";
  };

  imports = [
    ./lem.nix
  ];
}
