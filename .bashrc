# Load from stow
export current_path=$(pwd)
cd ~/dotfiles && git pull && stow . && cd $current_path
unset current_path

# Alias for wsl
alias windows="cd /mnt/c"
# Other aliases
alias ls='ls --color=auto -F'
alias cls=". ~/.bashrc"
alias cdi="zoxide query -l -s"
alias la="ls -A"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ $ID = "ubuntu" ]; then
        alias fastfetch="neofetch"
    fi
fi

# init
clear
fastfetch
eval "$(fzf --bash)"
eval "$(zoxide init bash --cmd cd)"
shopt -s cdspell

# Exports
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups

# Functions
function psg() {
    if [ -z "$1" ]; then
        ps aux | grep -v grep | grep -v ps | grep -v awk | awk '{printf "\033[1;32m%-10s \033[1;34m%-8s \033[1;33m%-6s \033[1;35m%-6s \033[1;36m%-10s \033[0m%s\n", $2, $1, $3, $4, $9, $11}'
    else
        ps aux | grep -v grep | grep -v ps | grep -v awk | grep -i -e "$1" | awk '{printf "\033[1;32m%-10s \033[1;34m%-8s \033[1;33m%-6s \033[1;35m%-6s \033[1;36m%-10s \033[0m%s\n", $2, $1, $3, $4, $9, $11}'
    fi
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
