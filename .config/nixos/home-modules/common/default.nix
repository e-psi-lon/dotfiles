{ pkgs, lib, ... }:
{
  imports = [
    ./packages.nix
  ];

  home = {
    username = "e-psi-lon";
    homeDirectory = "/home/e-psi-lon";

    shell = {
      enableZshIntegration = true;
    };
    shellAliases = {
      cls = "clear; ${pkgs.fastfetch}/bin/fastfetch";
      la = "ls -a";
      lla = "ls -la";
      cdl = "${pkgs.zoxide}/bin/zoxide query -l -s";
      grep = "grep --color=auto";
      # act = "gh act";
      edit = "$EDITOR";
      shrug = "echo '¯\\_(ツ)_/¯'";
      # It's important to be kind with your computer :)
      please = "sudo";
    };
  };
  xdg.enable = true;

  programs = let 
    ff = import ../../lib/fastfetch;
    inherit (ff) green cyan yellow magenta red override fastfetchModules;

    in
    {
    zsh = {
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
            ${builtins.readFile ../../resources/zsh/extract.zsh}
            ${builtins.readFile ../../resources/zsh/fzfd.zsh}
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
    git = {
      lfs.enable = true;
      settings = {
        init.defaultBranch = "main";
        user = {
          name = "Lilian Maulny (e_ψ_lon)";
          email = "theg41g@gmail.com";
        };
        credential = {
          "https://github.com".helper = "!gh auth git-credential";
          "https://gist.github.com".helper = "!gh auth git-credential";
          # TODO: Add gitlab CLI and its credential helper
          # "https://gitlab.com".helper = "";
        };
        alias = {
          graph = "log --oneline --all --decorate --graph";
          undo = "reset HEAD~1";
        };
      };
    };
    atuin = {
      enable = true;
      enableZshIntegration = true;
    };
    oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      settings = builtins.fromJSON (
        builtins.unsafeDiscardStringContext (builtins.readFile ../../resources/oh-my-posh/theme.json)
      );
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    gh = {
      enable = true;
      extensions = with pkgs; [
        gh-copilot
        gh-contribs
      ];
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
    fastfetch = {
      enable = true;
      settings = {
        display = {
          key.type = "both-2";
          color = "dim_white";
        };
        modules = with fastfetchModules; [
          (override title {
            color = {
              user = "cyan";
              at = "default";
              host = "blue";
            };
          })
          separator
          os
          host
          kernel
          uptime
          packages

          (green shell {})
          (green terminal {})
          (green de {})
          (green wm {})

          (cyan cpu {
            format = "{name} ({cores-physical}C/{cores-logical}T) @ {freq-base} ({freq-max})";
          })
          (cyan gpu {})

          (yellow memory {})
          (yellow swap {})
          (yellow disk {
            showExternal = false;
          })

          (magenta display {
            format = "{width}x{height} @ {refresh-rate}″ Hz in {inch} [{type}]";
          })
          (magenta wifi {})
          (magenta localip {
            format = "{ipv4} @ {speed} ({mac})";
          })

          (red battery {
            format = "{capacity-bar} {capacity}% [{status}] {time-formatted}";
            percent = {
              type = [ "num" "num-color" "bar" ];
              green = 80;
              yellow = 20;
            };
          })

          breakModule
          colors
        ];
      };
    };
  };
}
