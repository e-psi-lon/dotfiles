{
  nginx = {
    sharedDirs = c: [
      c.extraHttpDirectory
      c.extraStreamDirectory
    ];
  };
  bypass-cors = { };
  minecraft-server = {
    sharedDirs = c: [ c.serverDirectory ];
  };
  postgres = {
    dataDirs = c: [ c.dataDirectory ];
    secrets = c: {
      postgres-password = {
        file = c.postgresPasswordPath;
      };
    };
  };
  redis = {
    sharedDirs = c: [ c.dataDirectory ];
  };
}
