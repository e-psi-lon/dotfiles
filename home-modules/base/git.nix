{ pkgs, lib, ... }:
{
  programs.git = {
    lfs.enable = true;
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user = {
        name = "Lilian Maulny (e_ψ_lon)";
        email = "theg41g@gmail.com";
      };
      credential."https://gitlab.com".helper = "!${lib.getExe pkgs.glab} auth git-credential";
      alias = {
        graph = "log --oneline --all --decorate --graph";
        undo = "reset HEAD~1";
      };
    };
  };
}
