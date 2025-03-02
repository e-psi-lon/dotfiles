# define zsh aliases
alias windows="cd /mnt/c"
# Alias for android
alias android="cd /storage/emulated/0"
alias arch="proot-distro login archlinux"
# Other aliases
alias ls='eza --color=auto -F --icons=auto'
alias cls="clear; fastfetch"
alias cdl="zoxide query -l -s"
alias la="ls --all"
alias grep="grep --color=auto"
alias act="gh act"
# Define an alias for fastfech because on some
# systems, it doesn't exists and neofetch is used
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ $ID = "ubuntu" ] || [ $ID = "linuxmint" ]; then
        alias fastfetch="neofetch"
    fi
fi