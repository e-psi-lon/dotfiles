{ pkgs, lib, paths, subPath, hashes, ... }:
{
  programs.zsh = {
    enable = true;
    plugins = with pkgs; [
      {
        name = "fast-syntax-highlighting";
        file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
        src = zsh-fast-syntax-highlighting;
      }
      {
        name = "zsh-autosuggestions";
        file = "share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh";
        src = zsh-autosuggestions;
      }
      {
        name = "zsh-autocomplete";
        file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
        src = zsh-autocomplete;
      }
      {
        name = "eza";
        src = fetchFromGitHub {
          owner = "zap-zsh";
          repo = "exa";
          rev = "master";
          sha256 = hashes.zsh.zap-exa;
        };
      }
      {
        name = "fzf";
        src = fetchFromGitHub {
          owner = "zap-zsh";
          repo = "fzf";
          rev = "master";
          sha256 = hashes.zsh.zap-fzf;
        };
      }
      {
        name = "colored-man-pages";
        src = fetchFromGitHub {
          owner = "ael-code";
          repo = "zsh-colored-man-pages";
          rev = "master";
          sha256 = hashes.zsh.zsh-colored-man-pages;
        };
      }
    ];
    initContent =
      let
        zshConfigEarlyInit = lib.mkOrder 500 ''
          ${builtins.readFile (subPath paths.resources "zsh/extract.zsh")}
          ${builtins.readFile (subPath paths.resources "zsh/fzfd.zsh")}
        '';
        zshConfig = lib.mkOrder 1000 ''
          # Fix key bind for Delete key
          bindkey '^[[3~' delete-char
          # Fix key bind for Ctrl+Left and Ctrl+Right (should move cursor word by word)
          bindkey '^[[1;5D' backward-word
          bindkey '^[[1;5C' forward-word

          # Setup completions
          eval "$(${lib.getExe pkgs.uv} generate-shell-completion zsh)"
          # Can't use lib.getExe because uvx is not the main program of pkgs.uv
          eval "$(${pkgs.uv}/bin/uvx --generate-shell-completion zsh)" 
          eval "$(${lib.getExe pkgs.tailscale} completion zsh)"
          eval "$(${lib.getExe pkgs.atuin} gen-completions --shell zsh)"
        '';
        zshConfigAfter = lib.mkOrder 1500 ''
          cls
        '';
      in
      lib.mkMerge [
        zshConfigEarlyInit
        zshConfig
        zshConfigAfter
      ];
  };
}
