{ paths, hashes }:
final: prev: {
  modelio = final.callPackage ./modelio.nix { inherit hashes; };
  setup-dev = final.callPackage ./setup-dev { inherit paths; };
  kobweb-cli = final.callPackage ./kobweb-cli { inherit hashes; };
  labymod = final.callPackage ./labymod.nix { inherit hashes; };
  launch-in-vm = final.callPackage ./launch-in-vm { };
  linuxKernel = prev.linuxKernel // {
    packagesFor = kernel: (prev.linuxKernel.packagesFor kernel).extend (lpFinal: lpPrev: {
      hid-nintendolic = lpFinal.callPackage ./hid-nintendolic.nix { inherit hashes; };
    });
  };
}
