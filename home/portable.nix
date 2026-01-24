{ paths, subPath, ... }:
{
  imports = [
    (subPath paths.homeModules "common")
  ];
}