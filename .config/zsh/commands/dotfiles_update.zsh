# Dotfiles update function
dotfiles_update() {
  local DOTFILES_DIR="$HOME/dotfiles"
  local TIMEOUT_SECONDS=10
  
  printf "\nChecking for dotfiles updates...\n"
  
  if cd "$DOTFILES_DIR" 2>/dev/null; then
    timeout $TIMEOUT_SECONDS git fetch --quiet
    if [ $? -ne 0 ]; then
      printf "󰅙 Timed out while fetching updates\n"
      cd - > /dev/null
      return 1
    fi
    
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u} 2>/dev/null || echo $LOCAL)
    
    if [ "$LOCAL" != "$REMOTE" ]; then
      printf "󰚰 Updates available. Pulling changes...\n"
      timeout $TIMEOUT_SECONDS git pull --quiet --ff-only
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
