#!/bin/sh

# Professional Init - System Utilities
# Providing essential system state management

# Safe Shutdown Function
power_off() {
    echo -e "\033[0;31m[!] Initiating System Shutdown...\033[0m"
    
    # Send SIGTERM to all processes
    kill -15 -1
    sleep 2
    # Send SIGKILL to stubborn processes
    kill -9 -1
    
    echo "[*] Unmounting all filesystems..."
    umount -a -r
    
    echo "[+] Powering off. Goodbye, Professional."
    reboot -p
}

# System Reboot Function
reboot_sys() {
    echo -e "\033[0;33m[!] System Rebooting...\033[0m"
    sync
    umount -a -r
    reboot
}

# Professional Memory Management
clean_caches() {
    echo "[*] Dropping Kernel Caches to free RAM..."
    sync
    echo 3 > /proc/sys/vm/drop_caches
}
