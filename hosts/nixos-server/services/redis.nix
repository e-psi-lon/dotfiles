{
  services.redis = {
    enable = true;
    servers = {
      default = {
        port = 6379;
        bind = "127.0.0.1";
        requirePassFile = ""; # TODO: Add the sops secret for the password
      };
    };
  };
}