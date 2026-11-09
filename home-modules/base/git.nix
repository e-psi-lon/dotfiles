{ pkgs, lib, config, ... }: 
{
  programs.git = {
    lfs.enable = true;
    enable = true;
    signing = {
      format = "ssh";
      key = "key::${config.selfKey}";
      signByDefault = config.services.ssh-agent.enable;
    };
    settings = {
      gpg.ssh.allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
      init.defaultBranch = "main";
      user = {
        name = "Lilian Maulny (e_ψ_lon)";
        email = "me@e-psi-lon.dev";
      };
      credential."https://gitlab.com".helper = "!${lib.getExe pkgs.glab} auth git-credential";
      alias = {
        graph = "log --oneline --all --decorate --graph";
        undo = "reset HEAD~1";
      };
    };
  };

  xdg.configFile."git/allowed_signers".text = ''
    ${config.programs.git.settings.user.email} namespaces="git" ${config.selfKey}
  '';
}
