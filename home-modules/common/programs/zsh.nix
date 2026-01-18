{ pkgs, lib, paths, subPath, ... }:
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
          sha256 = "sha256-gYyLML7tTRtMskKks/cxHXZL4MxAfGb1T7GJJCQUFTk=";
        };
      }
      {
        name = "fzf";
        src = fetchFromGitHub {
          owner = "zap-zsh";
          repo = "fzf";
          rev = "master";
          sha256 = "sha256-jwcOmhPNmE8g+xOTDsysAFxE76xdUwxvi5211xlwM7s=";
        };
      }
      {
        name = "colored-man-pages";
        src = fetchFromGitHub {
          owner = "ael-code";
          repo = "zsh-colored-man-pages";
          rev = "master";
          sha256 = "sha256-087bNmB5gDUKoSriHIjXOVZiUG5+Dy9qv3D69E8GBhs=";
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

          # Setup github copilot cli
          eval "$(${pkgs.gh}/bin/gh copilot alias -- zsh)"

          # Setup completions
          eval "$(${pkgs.uv}/bin/uv generate-shell-completion zsh)"
          eval "$(${pkgs.uv}/bin/uvx --generate-shell-completion zsh)"
          eval "$(${pkgs.tailscale}/bin/tailscale completion zsh)"
          eval "$(${pkgs.atuin}/bin/atuin gen-completions --shell zsh)"
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
