{ config, lib, pkgs, ... }:
let
  cfg = config.myConfig.windows-vm;
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf cfg.enable {
    # Enable the libvirt daemon
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        # UEFI support (required for Windows 11)
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
        # TPM emulation (required for Windows 11)
        swtpm.enable = true;
      };
    };

    # Virt-manager GUI
    programs.virt-manager.enable = true;

    # Add user to libvirtd group
    users.users.${username}.extraGroups = [ "libvirtd" ];

    # Useful packages
    environment.systemPackages = with pkgs; [
      spice-gtk        # USB redirection and clipboard sharing
      win-virtio       # VirtIO drivers ISO for Windows guests
    ];

    # Samba file sharing for Windows VM guests
    services.samba = {
      enable = true;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          "server string" = "NixOS";
          security = "user";
          # Only allow connections from the libvirt VM network
          "hosts allow" = "192.168.122. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
        };
        shared = {
          path = "/home/${username}/shared";
          browseable = "yes";
          "read only" = "no";
          "valid users" = username;
          "create mask" = "0644";
          "directory mask" = "0755";
        };
      };
    };

    # Open Samba ports only on the libvirt bridge interface
    networking.firewall.interfaces."virbr0" = {
      allowedTCPPorts = [ 445 139 ];
      allowedUDPPorts = [ 137 138 ];
    };  };
}
