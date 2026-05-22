{ 
  writeShellApplication,
  qemu,
  waypipe,
  socat,
  openssh,
}:
writeShellApplication {
  name = "launch-in-vm";
  runtimeInputs = [
    qemu
    waypipe
    socat
    openssh
  ];
  text = ''
    export EDK2_CODE_FD="${qemu}/share/qemu/edk2-x86_64-code.fd"
    ${builtins.readFile ./launch-in-vm.sh}
  '';
}
