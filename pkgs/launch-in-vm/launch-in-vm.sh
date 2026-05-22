
if [ -z "${XDG_CONFIG_HOME:-}" ]; then
    XDG_CONFIG_HOME="$HOME/.config"
fi

CONFIG_FILE="$XDG_CONFIG_HOME/launch-in-vm/config"

if [ -f "$CONFIG_FILE" ]; then
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        value="${value#[\"\']}"
        value="${value%[\"\']}"
        case "$key" in
            VMDIR|VM_NAME|SSH_HOST|VM_RAM|VM_CORES|VM_THREADS|VM_SOCKETS)
                printf -v "$key" '%s' "$value"
                ;;
            *)
                echo "Warning: ignoring unknown config key '$key'" >&2
                ;;
        esac
    done < "$CONFIG_FILE"
fi

if [ -z "${VMDIR:-}" ]; then
    echo "Error: VMDIR environment variable or config option is not set. Please set it to the directory containing your VM's disk image and OVMF_VARS.fd."
    exit 1
fi
VM_NAME="${VM_NAME:-$(basename "$VMDIR")}"
SSH_HOST="${SSH_HOST:-$VM_NAME}"
VM_RAM="${VM_RAM:-8G}"
VM_CORES="${VM_CORES:-2}"
VM_THREADS="${VM_THREADS:-2}"
VM_SOCKETS="${VM_SOCKETS:-1}"

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
        -drive if=pflash,format=raw,unit=1,file="$VMDIR/OVMF_VARS.fd" \
        -device virtio-blk-pci,drive=SystemDisk \
        -drive id=SystemDisk,if=none,format=qcow2,file="$VMDIR/disk.qcow2",discard=unmap,detect-zeroes=unmap,cache=writeback,aio=threads \
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

until ssh -o ConnectTimeout=5 -o ConnectionAttempts=1 "$SSH_HOST" exit 2>/dev/null; do
    sleep 5
    echo "Waiting..."
done
ssh -f -n "$SSH_HOST" "nohup /usr/bin/waypipe --vsock -s 1234 --xwls --compress none --unlink-socket server -- $PROGRAM_NAME > /dev/null 2>&1 &"
echo "Program '$PROGRAM_NAME' launched successfully in the VM."