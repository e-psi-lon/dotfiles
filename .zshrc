# Load computer specific configurations
[ -f "$HOME/.config/zsh/computer.zsh" ] && source "$HOME/.config/zsh/computer.zsh"

# Setup default plugins
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug $HOME/.config/zsh/plugins.zsh
plug $HOME/.config/zsh/aliases.zsh

(dotfiles_update &>/dev/null &) &>/dev/null

[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh)"
  eval "$(atuin gen-completions --shell zsh)"
else
  echo " Atuin not found. History synchronization disabled."
fi
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
else
  echo "󰉋 Zoxide not found. Enhanced directory navigation disabled."
fi
if command -v fzf &>/dev/null; then
  eval "$(fzf --zsh)"
else
  echo "󰍉 FZF not found. Fuzzy finding disabled."
fi
if command -v gh &>/dev/null; then
  eval "$(gh copilot alias -- zsh)"
else
  echo " GitHub CLI not found. Disabling GitHub integration"
fi
if command -v oh-my-posh &>/dev/null; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/themes/e-psi-lon.omp.json)"
else
  echo "󰓆 Oh-my-posh not found. Using default prompt."
fi
if command -v uv &>/dev/null; then
  eval "$(uv generate-shell-completion zsh)"
  eval "$(uvx --generate-shell-completion zsh)"
else
  echo " uv not found. Disabling uv auto-completion."
fi

# Fix key bind for Delete key
bindkey '^[[3~' delete-char
# Fix key bind for Ctrl+Left and Ctrl+Right (should move cursor word by word)
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Load and initialise completion system
autoload -Uz compinit
compinit

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
# TODO: Remove this to use vim/nvim as default editor
if [[ -z "$EDITOR" || "$EDITOR" == "nano" ]]; then
  > $HOME/.nanorc
  for dir in /etc/share/nano /etc/share/nano/extra /data/data/com.termux/files/usr/share/nano /data/data/com.termux/files/usr/share/nano/extra; do
    if [ -d "$dir" ]; then
      for file in "$dir"/*.nanorc; do
        [ -e "$file" ] && echo "include $file" >> $HOME/.nanorc
      done
    fi
  done
fi
export EDITOR=nano

cls
