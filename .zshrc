# Load computer specific configurations
[ -f "$HOME/.config/zsh/computer.zsh" ] && source "$HOME/.config/zsh/computer.zsh"

# Setup default plugins
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug $HOME/.config/zsh/plugins.zsh
plug $HOME/.config/zsh/aliases.zsh

{
  (dotfiles_update &>/dev/null &)
} &>/dev/null


eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(gh copilot alias -- zsh)"
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/themes/e-psi-lon.omp.json)"
[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"
eval "$(atuin gen-completions --shell zsh)"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

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