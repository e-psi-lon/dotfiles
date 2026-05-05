{ pkgs, username, ... }: 

{
  virtualisation  = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;
  
  systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];

  boot = {
    binfmt.emulatedSystems = [
      "aarch64-linux"
      "riscv64-linux"
    ];
    kernelParams = [ "tsc=reliable" ];
    extraModprobeConfig = ''
      options kvm ignore_msrs=1
      options kvm report_ignored_msrs=0
    '';
  };


  users.users.${username} = {
    extraGroups = [ "libvirtd" "qemu-libvirtd" ];
};

}