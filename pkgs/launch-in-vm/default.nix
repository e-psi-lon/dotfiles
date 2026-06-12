{
  stdenv,
  writeShellApplication,
  qemu,
  waypipe,
  socat,
  taplo,
  openssh,
}:
let
  efiRom = 
    if stdenv.hostPlatform.isAarch64 then
      "${qemu}/share/qemu/edk2-aarch64-code.fd"
    else if stdenv.hostPlatform.isx86_64 then
      "${qemu}/share/qemu/edk2-x86_64-code.fd"
    else
      throw "Unsupported architecture: ${stdenv.hostPlatform.system}";
  archArgs = 
    if stdenv.hostPlatform.isAarch64 then ''
      QEMU_ARCH_FLAGS=(
        "-machine" "virt,gic-version=max,highmem=on,accel=kvm"
        "-cpu" "host"
      )
    ''
    else if stdenv.hostPlatform.isx86_64 then ''
      QEMU_ARCH_FLAGS=(
        "-machine" "q35,smm=off,vmport=off,accel=kvm"
        "-global" "kvm-pit.lost_tick_policy=discard"
        "-cpu" "host,topoext"
      )
    ''
    else
      throw "Unsupported architecture: ${stdenv.hostPlatform.system}";
in  
writeShellApplication {
  name = "launch-in-vm";
  runtimeInputs = [
    qemu
    waypipe
    socat
    openssh
    taplo
  ];
  text = ''
    export EDK2_CODE_FD="${efiRom}"
    ${archArgs}
    ${builtins.readFile ./launch-in-vm.sh}
  '';
}
