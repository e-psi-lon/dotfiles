# WSL specific aliases
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    # Navigate to Windows drives
    alias windows="cd /mnt/c"
    # Open files/folders in Windows
    alias explorer="explorer.exe ."
    alias vscode="code.exe"
    
    # Convert paths between WSL and Windows
    alias wslpath="wslpath -w"  # WSL to Windows path
    alias winpath="wslpath -u"  # Windows to WSL path
fi
# Alias for android
if [[ -d /data/data/com.termux || -n "$(command -v termux-info 2>/dev/null)" ]]; then
    # Basic navigation
    alias android="cd /storage/emulated/0"
    alias fedora="proot-distro login fedora"
fi
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