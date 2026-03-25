{ lib, ... }:
{
  options.myConfig.ssh = {
    enable = lib.mkEnableOption "SSH server";
  };

  imports = [
    ./ssh.nix
  ];
}
