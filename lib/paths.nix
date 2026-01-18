{
  hosts = ../hosts;
  home = ../home;
  modules = ../modules;
  home-modules = ../home-modules;
  lib = ../lib;
  resources = ../resources;
  
  sub = base: name: base + "/${name}";
}
