{ pkgs, ... }: 
let
  username = "podman-user";
  uidGid = 7630;
in {
  # This is not actually a service but rather a user with podman available
  users = {
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

  home-manager.users.${username} = {
    home = {
      inherit username;
      stateVersion = "26.11";
      homeDirectory = "/home/${username}";
      packages = with pkgs; [
        podman-compose
      ];
    };
  };
}