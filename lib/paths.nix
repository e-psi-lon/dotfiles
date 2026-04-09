{
  hosts = ../hosts;
  home = ../home;
  modules = ../modules;
  home-modules = ../home-modules;
  lib = ../lib;
  resources = ../resources;
  custom-pkgs = ../pkgs;
  dev-flakes = ../dev-flakes;
  containers = ../containers;

  subPath = base: name: "${base}/${name}";
}
