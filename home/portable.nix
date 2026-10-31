{ paths, ... }: { 
  imports = [ (paths.home-modules + "/base") ]; 
  home.stateVersion = "26.11";
}
