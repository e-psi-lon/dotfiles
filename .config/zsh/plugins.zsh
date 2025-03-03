# useful
plug "zap-zsh/exa"

# visual
plug "zsh-users/zsh-syntax-highlighting"
plug "zdharma-continuum/fast-syntax-highlighting"
plug "ael-code/zsh-colored-man-pages"

# autocompletion
plug "zsh-users/zsh-autosuggestions"
plug "marlonrichert/zsh-autocomplete"

# app autocompletion
plug "ryutok/rust-zsh-completions"

# custom commands located in .config/zsh/commands/
# Use a loop in this directory to load all of them
for file in $HOME/.config/zsh/commands/*; do
    source $file
done
