# Load from stow
current_path=$(pwd)
cd ~/dotfiles
output=$(git pull)
cd $current_path

if [[ $output != *"Already up to date."* ]]; then
    source ~/.bashrc
    unset current_path output
    return
fi
unset current_path output


# Alias for wsl
alias windows="cd /mnt/c"
# Alias for android
alias android="cd /storage/emulated/0"
# Other aliases
alias ls='ls --color=auto -F'
alias cls=". ~/.bashrc"
alias cdl="zoxide query -l -s"
alias la="ls -A"
alias grep="grep --color=auto"
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

# Better input and history
parse_git_branch() {
  branch=$(git branch 2>/dev/null | grep '*' | sed 's/* //')
  if [ -n "$branch" ]; then
    echo "($branch)"
  fi
  unset branch
}
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;33m\]\$(parse_git_branch)\[\033[00m\]\$ "
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT='%F %T '
export HISTIGNORE="&:ls:[bf]g:exit:clear:history"
shopt -s histappend 
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Functions
function taskmanager() {
    local interval=2  # Intervalle en secondes pour l'actualisation

    if [ "$1" == "-c" ]; then
        while true; do
            tput civis  # Cache le curseur
            tput smcup  # Sauvegarde l'écran actuel
            if [ -z "$2" ]; then
                ps aux | grep -v grep | grep -v ps | grep -v awk | awk '{printf "\033[1;32m%-10s \033[1;34m%-8s \033[1;33m%-6s \033[1;35m%-6s \033[1;36m%-10s \033[0m%s\n", $2, $1, $3, $4, $9, $11}'
            else
                ps aux | grep -v grep | grep -v ps | grep -v awk | grep -i -e "$2" | awk '{printf "\033[1;32m%-10s \033[1;34m%-8s \033[1;33m%-6s \033[1;35m%-6s \033[1;36m%-10s \033[0m%s\n", $2, $1, $3, $4, $9, $11}'
            fi
            tput rmcup  # Restore the saved screen
            tput cnorm  # Restore the cursor
            sleep $interval
        done
    else
        if [ -z "$1" ]; then
            ps aux | grep -v grep | grep -v ps | grep -v awk | awk '{printf "\033[1;32m%-10s \033[1;34m%-8s \033[1;33m%-6s \033[1;35m%-6s \033[1;36m%-10s \033[0m%s\n", $2, $1, $3, $4, $9, $11}'
        else
            ps aux | grep -v grep | grep -v ps | grep -v awk | grep -i -e "$1" | awk '{printf "\033[1;32m%-10s \033[1;34m%-8s \033[1;33m%-6s \033[1;35m%-6s \033[1;36m%-10s \033[0m%s\n", $2, $1, $3, $4, $9, $11}'
        fi
    fi
}



# Extrait les fichiers compressés
extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xvjf $1    ;;
      *.tar.gz)    tar xvzf $1    ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xvf $1     ;;
      *.tbz2)      tar xvjf $1    ;;
      *.tgz)       tar xvzf $1    ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
