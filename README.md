# Dotfiles

This repository contains my dotfiles. I use [Nix](https://nixos.org/) and [Home Manager](https://nix-community.github.io/home-manager/) to manage my entire environment.

# Credits

- [Nix](https://nixos.org/) obviously since it's the core of my setup.
- I would like to thank [Rignchen](https://gitlab.com/Rignchen) for her [dotfiles](https://gitlab.com/Rignchen/dotfiles) from which I took a lot of inspiration (and there used to be some copy-pasted code).
- [Oh My Posh](https://ohmyposh.dev/) for the awesome prompt. I use a custom theme based on the [Rignchen's theme](https://gitlab.com/Rignchen/dotfiles/-/blob/main/.config/oh-my-posh/theme.toml) which is itself based on the Mojada pre-installed theme.

# TODO

- Create a CI/CD pipeline to build configuration files such as `.zshrc` for non-NixOS systems ready to use with [GNU Stow](https://www.gnu.org/software/stow/).
- Explore flakes to see if they can help simplify some parts of the current dotfiles structure.