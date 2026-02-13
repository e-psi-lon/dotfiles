{
  hosts = ../hosts;
  home = ../home;
  modules = ../modules;
  home-modules = ../home-modules;
  lib = ../lib;
  resources = ../resources;
  customPkgs = ../custom_pkgs;
  
  sub = base: name: base + "/${name}";
}
