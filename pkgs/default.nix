{ paths }:
final: prev: {
  modelio = final.callPackage ./modelio.nix { };
  setup-dev = final.callPackage ./setup-dev { inherit paths; };
  kobweb-cli = final.callPackage ./kobweb-cli { };
}
