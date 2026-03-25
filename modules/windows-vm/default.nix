{ lib, ... }:
{
  options.myConfig.modules.windows-vm = {
    enable = lib.mkEnableOption "Windows VM via QEMU/KVM with virt-manager";
  };

  imports = [
    ./windows-vm.nix
  ];
}
