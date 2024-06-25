
export current_path=$(pwd)
cd ~/dotfiles
stow .
cd $current_path
unset current_path
clear
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ $ID = "ubuntu" ]; then
        alias fastfetch="neofetch"
    fi
fi
fastfetch
alias cls="clear && fastfetch"
alias cdi="zoxide query -l -s"
eval "$(fzf --bash)"
eval "$(zoxide init bash --cmd cd)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
