{
  # This is not actually a service but rather a user with podman available
  users = let
    username = "podman-user";
    uidGid = 7630;
  in {
    groups.${username} = {
      gid = uidGid;
      members = [ username ];
    };
    users.${username} = {
      uid = uidGid;
      group = username;
      isNormalUser = true;
      description = "User for running podman containers";
      autoSubUidGidRange = true;
      linger = true;
      
    };
  };
}