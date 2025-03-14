# Dotfiles update function
dotfiles_update() {
  local DOTFILES_DIR="$HOME/dotfiles"
  
  printf "\nChecking for dotfiles updates...\n"
  
  if cd "$DOTFILES_DIR" 2>/dev/null; then
    git fetch --quiet
    
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u} 2>/dev/null || echo $LOCAL)
    
    if [ "$LOCAL" != "$REMOTE" ]; then
      printf "󰚰 Updates available. Pulling changes...\n"
      git pull --quiet --ff-only
      stow .
      printf "󰄬 Dotfiles updated successfully.\n"
    else
      printf "󰄬 Dotfiles already up to date.\n"
    fi
    
    cd - > /dev/null
  else
    printf "󰅙 Error: Dotfiles directory not found at %s\n" "$DOTFILES_DIR"
  fi
}

alias update-dotfiles="dotfiles_update"
