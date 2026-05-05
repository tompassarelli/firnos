{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.windows-vm;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.windows-vm.enable = lib.mkEnableOption "Windows VM via QEMU/KVM with virt-manager";
  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
    programs.virt-manager.enable = true;
    users.users = {
      ${username}.extraGroups = [ "libvirtd" ];
    };
    environment.systemPackages = with pkgs; [ spice-gtk virtio-win ];
    services.samba = {
      enable = true;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          ${"server string"} = "NixOS";
          security = "user";
          ${"hosts allow"} = "192.168.122. 127.0.0.1 localhost";
          ${"hosts deny"} = "0.0.0.0/0";
        };
        shared = {
          path = "/home/${username}/shared";
          browseable = "yes";
          ${"read only"} = "no";
          ${"valid users"} = username;
          ${"create mask"} = "0644";
          ${"directory mask"} = "0755";
        };
      };
    };
    networking.firewall.interfaces = {
      virbr0 = {
        allowedTCPPorts = [ 445 139 ];
        allowedUDPPorts = [ 137 138 ];
      };
    };
  };
}
