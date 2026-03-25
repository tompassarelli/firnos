{ lib, ... }:
{
  options.myConfig.mini-serve = {
    enable = lib.mkEnableOption "Enable mini-serve localhost background page";
  };

  imports = [
    ./mini-serve.nix
  ];
}
