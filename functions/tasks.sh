tasks() {
    local interval=2
    local filter="$1"
    local continuous=false

    # Check if the continuous flag is set
    if [ "$1" == "-c" ]; then
        continuous=true
        filter="$2"
    fi

    # Function to print the process list
    print_processes() {
        tput cup 0 0
        echo -e "\033[1;32m%-10s \033[1;34m%-8s \033[1;33m%-6s \033[1;35m%-6s \033[1;36m%-10s \033[0m%s" "PID" "USER" "%CPU" "%MEM" "START" "COMMAND"
        if [ -z "$filter" ]; then
            ps aux | grep -v grep | grep -v ps | grep -v awk | awk '{printf "\033[1;32m%-10s \033[1;34m%-8s \033[1;33m%-6s \033[1;35m%-6s \033[1;36m%-10s \033[0m%s\n", $2, $1, $3, $4, $9, $11}'
        else
            ps aux | grep -v grep | grep -v ps | grep -v awk | grep -i -e "$filter" | awk '{printf "\033[1;32m%-10s \033[1;34m%-8s \033[1;33m%-6s \033[1;35m%-6s \033[1;36m%-10s \033[0m%s\n", $2, $1, $3, $4, $9, $11}'
        fi
        tput el
    }

    # Function to handle cleanup on exit
    cleanup() {
        tput cnorm
        tput rmcup
        exit
    }

    # Trap signals to ensure cleanup
    trap cleanup INT TERM

    if $continuous; then
        tput smcup
        tput civis
        while true; do
            tput clear
            print_processes
            tput cnorm
            sleep $interval
        done
        tput rmcup
        tput cnorm
    else
        print_processes
    fi
}