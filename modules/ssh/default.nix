{ lib, ... }:
{
  options.myConfig.modules.ssh = {
    enable = lib.mkEnableOption "SSH server";
  };

  imports = [
    ./ssh.nix
  ];
}
