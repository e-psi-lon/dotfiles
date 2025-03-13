# Dotfiles update function
dotfiles_update() {
  local DOTFILES_DIR="$HOME/dotfiles"
  
  echo -e "\n  Checking for dotfiles updates..."
  
  if cd "$DOTFILES_DIR" 2>/dev/null; then
    git fetch --quiet
    
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u} 2>/dev/null || echo $LOCAL)
    
    if [ "$LOCAL" != "$REMOTE" ]; then
      echo -e "  󰚰 Updates available. Pulling changes..."
      git pull --quiet --ff-only
      stow "$DOTFILES_DIR"
      echo -e "  󰄬 Dotfiles updated successfully."
    else
      echo -e "  󰄬 Dotfiles already up to date."
    fi
    
    cd - > /dev/null
  else
    echo -e "  󰅙 Error: Dotfiles directory not found at $DOTFILES_DIR"
  fi
}

alias update-dotfiles="dotfiles_update"
