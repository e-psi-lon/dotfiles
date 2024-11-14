# Load from stow
current_path=$(pwd)
cd $HOME/dotfiles
output=$(git pull)

if ping -q -c 1 -W 1 google.com > /dev/null; then
  if [[ $output != *"Already up to date."* ]] && [[ $output != *"Déjà à jour."* ]]; then
      source ~/.bashrc
      unset current_path output
      return
  fi
fi

stow .
cd $current_path
unset current_path output

# Load local file
if [ -f $HOME/local.sh ]; then
    source $HOME/local.sh
fi


# Alias for wsl
alias windows="cd /mnt/c"
# Alias for android
alias android="cd /storage/emulated/0"
alias arch="proot-distro login archlinux"
# Other aliases
alias ls='ls --color=auto -F'
alias cls=". $HOME/.bashrc"
alias cdl="zoxide query -l -s"
alias la="ls -A"
alias grep="grep --color=auto"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ $ID = "ubuntu" ] || [ $ID = "linuxmint" ]; then
        alias fastfetch="neofetch"
    fi
fi

if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Load completion
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

# Load nano coloration
> $HOME/.nanorc
for dir in /etc/share/nano /etc/share/nano/extra /data/data/com.termux/files/usr/share/nano /data/data/com.termux/files/usr/share/nano/extra; do
	if [ -d "$dir" ]; then
		for file in "$dir"/*.nanorc; do
			[ -e "$file" ] && echo "include $file" >> $HOME/.nanorc
		done
	fi
done

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

parse_git_commit() {
  commit=$(git rev-parse --short HEAD 2>/dev/null)
  if [ -n "$commit" ]; then
    echo "[$commit]"
  fi
  unset commit
}
# Le commit en rouge
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;33m\]\$(parse_git_branch)\[\033[01;31m\]\$(parse_git_commit)\[\033[00m\]\$ "
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT='%F %T '
export HISTIGNORE="&:ls:[bf]g:exit:clear:history"
export EDITOR=nano
shopt -s histappend
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Functions
source $HOME/.functions/tasks.sh
source $HOME/.functions/extract.sh
source $HOME/.functions/symlink.sh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
# Vérifie si ktx est installé
if [ ! -d "$HOME/.sdkman/candidates/ktx" ]; then
    sdk install ktx
    . "$HOME/.bashrc"
else
    source "$HOME/.sdkman/candidates/ktx/0.1.2/.ktxrc"
fi
