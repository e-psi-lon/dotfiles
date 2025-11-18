# Load local file
if [ -f $HOME/local ]; then
    source $HOME/local
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
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

# init
clear
fastfetch
eval "$(fzf --bash)"
eval "$(zoxide init bash --cmd cd)"
eval "$(gh copilot alias -- bash)"
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

# Set the prompt to include user, host, working directory, git branch, and commit
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:"  # User and host
export PS1+="\[\033[01;34m\]\w\[\033[01;33m\]"  # Working directory
export PS1+="\$(parse_git_branch)"              # Git branch
export PS1+="\[\033[01;31m\]\$(parse_git_commit)" # Git commit
export PS1+="\[\033[00m\]\$ "                   # End of prompt
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT='%F %T '
export HISTIGNORE="&:ls:[bf]g:exit:clear:history"
export EDITOR=nano
shopt -s histappend


fzfd() {
  local path="${1:-$(pwd)}"  # Default to current directoryif no path is provided
  find "$path" -type d 2>/dev/null | fzf 
}

eval "$(uv generate-shell-completion bash)"
eval "$(uvx --generate-shell-completion bash)"
