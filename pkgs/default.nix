{ paths }:
final: prev: {
  modelio = final.callPackage ./modelio.nix { };
  setup-dev = final.callPackage ./setup-dev { inherit paths; };
  kobweb-cli = final.callPackage ./kobweb-cli { };
  labymod = final.callPackage ./labymod.nix { };
    linuxKernel = prev.linuxKernel // {
    packagesFor = kernel: (prev.linuxKernel.packagesFor kernel).extend (lpFinal: lpPrev: {
      hid-nintendolic = lpFinal.callPackage ./hid-nintendolic.nix { };
    });
  };
}
