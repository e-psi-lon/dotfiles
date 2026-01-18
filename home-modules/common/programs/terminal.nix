{ pkgs, paths, subPath, ... }:
{
  programs = {
    atuin = {
      enable = true;
      enableZshIntegration = true;
    };
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      settings = builtins.fromJSON (
        builtins.unsafeDiscardStringContext (builtins.readFile (subPath paths.resources "oh-my-posh/theme.json"))
      );
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
    gh = {
      enable = true;
      extensions = with pkgs; [
        gh-copilot
        gh-contribs
      ];
    };
  };
}
