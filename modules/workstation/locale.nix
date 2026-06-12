{ lib, ... }:

{
  console.keyMap = lib.mkDefault "fr";

  services.xserver.xkb = {
    layout = lib.mkDefault "fr";
    variant = lib.mkDefault "";
  };
}
