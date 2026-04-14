{
  mkBindMount = path: {
    device = path;
    options = [ "bind" ];
    fsType = "none";
  };

  mkBindMountWithOptions = path: options: {
    device = path;
    options = [ "bind" ] ++ options;
    fsType = "none";
  };
}