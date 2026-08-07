{
  nginx = {
    extraDirs = c: [
      c.extraHttpDirectory
      c.extraStreamDirectory
    ];
  };
  bypass-cors = { };
  minecraft-server = {
    extraDirs = c: [ c.serverDirectory ];
  };
  postgres = {
    extraDirs = c: [ c.dataDirectory ];
    secrets = c: {
      postgres-password = {
        file = c.postgresPasswordPath;
      };
    };
  };
  redis = {
    extraDirs = c: [ c.dataDirectory ];
  };
}
