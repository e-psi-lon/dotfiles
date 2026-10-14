{ paths, hashes }: final: prev: {
  modelio = final.callPackage ./modelio.nix { inherit hashes; };
  setup-dev = final.callPackage ./setup-dev { inherit paths; };
  labymod = final.callPackage ./labymod.nix { inherit hashes; };
  launch-in-vm = final.callPackage ./launch-in-vm { };
}
