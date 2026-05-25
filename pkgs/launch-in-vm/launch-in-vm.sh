
if [ -z "${XDG_CONFIG_HOME:-}" ]; then
    XDG_CONFIG_HOME="$HOME/.config"
fi

CONFIG_FILE="$XDG_CONFIG_HOME/launch-in-vm/config.toml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE."
    echo "Please create a config.toml file with the necessary settings."
    exit 1
fi


VM_DIR=$(taplo get -f "$CONFIG_FILE" vm.dir 2>/dev/null || echo "")
if [ -z "$VM_DIR" ]; then
    echo "Error: 'vm.dir' is not set in $CONFIG_FILE."
    exit 1
fi

VM_NAME=$(taplo get -f "$CONFIG_FILE" vm.name 2>/dev/null || basename "$VM_DIR")
SSH_HOST=$(taplo get -f "$CONFIG_FILE" ssh.host 2>/dev/null || echo "$VM_NAME")
VM_RAM=$(taplo get -f "$CONFIG_FILE" vm.ram 2>/dev/null || echo "8G")
VM_CORES=$(taplo get -f "$CONFIG_FILE" vm.cores 2>/dev/null || echo "2")
VM_THREADS=$(taplo get -f "$CONFIG_FILE" vm.threads 2>/dev/null || echo "2")
VM_SOCKETS=$(taplo get -f "$CONFIG_FILE" vm.sockets 2>/dev/null || echo "1")

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/launch-in-vm/$VM_NAME"
mkdir -p "$RUNTIME_DIR"

PROGRAM_NAME=${1:-}

# If the first argument is "stop", then stop the VM and exit
if [[ "$PROGRAM_NAME" == "stop" ]]; then
    if [ -f "$RUNTIME_DIR/qemu.pid" ]; then
        echo "system_powerdown" | socat - UNIX-CONNECT:"$RUNTIME_DIR/monitor.socket" || true
        # Wait for the VM to shut down
        TIMEOUT=30
        while [ -f "$RUNTIME_DIR/qemu.pid" ] && [ $TIMEOUT -gt 0 ]; do
            sleep 1
            TIMEOUT=$((TIMEOUT - 1))
        done
        [ $TIMEOUT -eq 0 ] && echo "Warning: VM did not shut down cleanly"
        echo "VM stopped successfully."
    else
        echo "No running VM found to stop."
    fi
    if [ -f "$RUNTIME_DIR/waypipe.pid" ]; then
        WAYPIPE_PID=$(cat "$RUNTIME_DIR/waypipe.pid")
        if kill -0 "$WAYPIPE_PID" 2>/dev/null; then
            kill "$WAYPIPE_PID"
            echo "Waypipe client with PID $WAYPIPE_PID stopped successfully."
        else
            echo "Waypipe client with PID $WAYPIPE_PID is not running. Removing stale PID file."
        fi
        rm -f "$RUNTIME_DIR/waypipe.pid"
    else
        echo "No running waypipe client found to stop."
    fi
    exit 0
fi
if [ -n "$PROGRAM_NAME" ]; then
    echo "Launching VM with program: $PROGRAM_NAME"
else
    echo "No specified program to launch. Exiting."
    exit 1
fi

# Start waypipe client before VM boots
if [ -f "$RUNTIME_DIR/waypipe.pid" ] && kill -0 "$(cat "$RUNTIME_DIR/waypipe.pid")" 2>/dev/null; then
    echo "Waypipe client is already running with PID $(cat "$RUNTIME_DIR/waypipe.pid"). Re-using it for the client."
else
    if [ -f "$RUNTIME_DIR/waypipe.pid" ]; then
        echo "Stale waypipe PID file found. Removing it."
        rm -f "$RUNTIME_DIR/waypipe.pid"
    fi
    waypipe \
        --vsock -s 1234 \
        --title-prefix "[VM] " \
        --compress none \
        client > /dev/null 2>&1 &
    WAYPIPE_PID=$!
    disown $WAYPIPE_PID

    echo "$WAYPIPE_PID" > "$RUNTIME_DIR/waypipe.pid"
fi

if [ -f "$RUNTIME_DIR/qemu.pid" ] && kill -0 "$(cat "$RUNTIME_DIR/qemu.pid")" 2>/dev/null; then
    echo "VM is already running with PID $(cat "$RUNTIME_DIR/qemu.pid"). Keeping it for new ${1:-}"
else
    if [ -f "$RUNTIME_DIR/qemu.pid" ]; then
        echo "Stale VM PID file found. Removing it."
        rm -f "$RUNTIME_DIR/qemu.pid"
    fi

    if [ ! -S "/run/virtiofsd/$USER.sock" ]; then
        echo "Error: virtiofsd socket not found at /run/virtiofsd/$USER.sock."
        echo "Please ensure a virtiofsd daemon is running and sharing the desired directory at /run/virtiofsd/$USER.sock."
        exit 1
    fi

    qemu-kvm \
        -name "$VM_NAME",process="$VM_NAME" \
        -machine q35,smm=off,vmport=off,accel=kvm \
        -global kvm-pit.lost_tick_policy=discard \
        -cpu host,topoext \
        -smp cores="$VM_CORES",threads="$VM_THREADS",sockets="$VM_SOCKETS" \
        -m "$VM_RAM" \
        -object memory-backend-memfd,id=mem,size="$VM_RAM",share=on \
        -numa node,memdev=mem \
        -device virtio-balloon-pci,id=balloon0,free-page-reporting=on \
        -device vhost-vsock-pci,guest-cid=3 \
        -pidfile "$RUNTIME_DIR/qemu.pid" \
        -rtc base=utc,clock=host \
        \
        -device virtio-vga-gl \
        -display egl-headless,rendernode=/dev/dri/renderD128 \
        \
        -device virtio-rng-pci,rng=rng0 \
        -object rng-random,id=rng0,filename=/dev/urandom \
        \
        -device usb-ehci,id=input \
        -device usb-kbd,bus=input.0 \
        -device usb-tablet,bus=input.0 \
        -k en-us \
        \
        -audiodev pipewire,id=audio0 \
        -device intel-hda \
        -device hda-micro,audiodev=audio0 \
        \
        -device virtio-net-pci,netdev=nic \
        -netdev user,hostname="$VM_NAME",hostfwd=tcp::22220-:22,id=nic \
        -global driver=cfi.pflash01,property=secure,value=on \
        \
        -drive if=pflash,format=raw,unit=0,file="${EDK2_CODE_FD}",readonly=on \
        -drive if=pflash,format=raw,unit=1,file="$VM_DIR/OVMF_VARS.fd" \
        -device virtio-blk-pci,drive=SystemDisk \
        -drive id=SystemDisk,if=none,format=qcow2,file="$VM_DIR/disk.qcow2",discard=unmap,detect-zeroes=unmap,cache=writeback,aio=threads \
        \
        -chardev socket,id=char0,path=/run/virtiofsd/"$USER".sock \
        -device vhost-user-fs-pci,chardev=char0,tag=home_share \
        \
        -monitor unix:"$RUNTIME_DIR/monitor.socket",server,nowait \
        -serial unix:"$RUNTIME_DIR/serial.socket",server,nowait \
        > "$RUNTIME_DIR/qemu.log" 2>&1 &
    QEMU_PID=$!
    disown $QEMU_PID
    echo "VM launched successfully. Waiting for it to boot..."
fi

TIMEOUT=15
until ssh -o ConnectTimeout=5 -o ConnectionAttempts=1 "$SSH_HOST" exit 2>/dev/null; do
    sleep 5
    echo "Waiting..."
    TIMEOUT=$((TIMEOUT - 1))
    if [ $TIMEOUT -le 0 ]; then
        echo "Error: VM did not boot within expected time. Please check the logs at $RUNTIME_DIR/qemu.log for more details."
        exit 1
    fi

done
ssh -f -n "$SSH_HOST" "nohup /usr/bin/waypipe --vsock -s 1234 --xwls --compress none --unlink-socket server -- $(printf '%q' "$PROGRAM_NAME") > /dev/null 2>&1 &"
echo "Program '$PROGRAM_NAME' launched successfully in the VM."