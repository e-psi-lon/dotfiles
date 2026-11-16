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
}
