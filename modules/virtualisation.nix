# Virtual machines — virt-manager on libvirt/QEMU-KVM. Unlike WinPodX's rootless
# Podman, these run under the system libvirtd (qemu:///system), which the
# libvirtd group may manage without a password. VirtualBox .vdi disks:
# see TIPS.md "Virtual machines (virt-manager)".
{ flake, ... }:

{
  flake.modules.nixos.virtualisation =
    { username, ... }:
    {
      programs.virt-manager.enable = true;

      virtualisation.libvirtd = {
        enable = true;
        qemu.swtpm.enable = true; # emulated TPM (Windows 11 guests)
      };

      users.users.${username}.extraGroups = [ "libvirtd" ];
    };
}
