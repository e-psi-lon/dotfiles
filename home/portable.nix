{ paths, subPath, ... }:
{
  imports = [ (subPath paths.homeModules "base") ];
}
