{ lib, username, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = lib.mkDefault false;
    dockerCompat = true;
  };

  users.users.${username} = {
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };

}
