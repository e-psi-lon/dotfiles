{
  services.redis = {
    servers."" = {
      port = 6379;
      bind = "127.0.0.1";
      requirePassFile = null; # TODO: Add the sops secret for the password
    };
  };
}
