{ paths, ... }: { 
  imports = [ (paths.home-modules + "/computer") ]; 
  home.stateVersion = "26.11";
}
