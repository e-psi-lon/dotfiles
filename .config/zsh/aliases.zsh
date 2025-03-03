# define zsh aliases
alias windows="cd /mnt/c"
# Alias for android
alias android="cd /storage/emulated/0"
alias arch="proot-distro login archlinux"
# Other aliases
alias cls="clear; fastfetch"
alias cdl="zoxide query -l -s"
alias grep="grep --color=auto"
alias act="gh act"
alias edit="$EDITOR"
alias reload="source $HOME/.zshrc"
alias shrug="echo '¯\_(ツ)_/¯'"
# It's important to be kind with your computer :)
alias please="sudo"
# Define an alias for fastfech because on some
# systems, it doesn't exists and neofetch is used
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ $ID = "ubuntu" ] || [ $ID = "linuxmint" ]; then
        alias fastfetch="neofetch"
    fi
fi