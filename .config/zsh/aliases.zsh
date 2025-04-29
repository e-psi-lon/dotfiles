# WSL specific aliases
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    # Navigate to Windows drives
    alias windows="cd /mnt/c"
    # Open files/folders in Windows
    alias explorer="explorer.exe ."
    alias vscode="code.exe"
    
    # Convert paths between WSL and Windows
    alias wslpath="wslpath -w"  # Convert WSL path to Windows path
    alias winpath="wslpath -u"  # Convert Windows path to WSL path
fi
# Alias for android
if [[ -d /data/data/com.termux ]] || [ -n "$(command -v termux-info 2>/dev/null)" ]; then
    # Basic navigation
    alias android="cd /storage/emulated/0"
    alias fedora="proot-distro login fedora"
    
    # Termux:API utilities (if installed)
    if [ -n "$(command -v termux-battery-status 2>/dev/null)" ]; then
        alias battery="termux-battery-status"
        alias clipboard="termux-clipboard-get"
        alias copy="termux-clipboard-set"
        alias brightness="termux-brightness"
        alias vibrate="termux-vibrate"
        alias notify="termux-notification"
    fi

    # Termux:x11 utilities (if installed)
    if [ -n "$(command -v x11-xpra 2>/dev/null)" ]; then
        alias x11="x11-xpra"
        alias x11start="x11-xpra start :1"
        alias x11stop="x11-xpra stop :1"
    fi
fi
# Other aliases
alias cls="clear; fastfetch"
alias lla="ll -a"
alias cdl="zoxide query -l -s"
alias grep="grep --color=auto"
alias act="gh act"
alias edit="$EDITOR"
alias reload="source $HOME/.zshrc"
alias shrug="echo '¯\_(ツ)_/¯'"
# It's important to be kind with your computer :)
alias please="sudo"
# Define an alias for fastfetch because on some
# systems, it doesn't exist and neofetch is used
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID_LIKE" == *"debian"* || "$ID_LIKE" == *"ubuntu"* || "$ID" == "debian" ]]; then
        alias fastfetch="neofetch"
    fi
fi
