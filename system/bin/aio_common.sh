#!/system/bin/sh

# Common functions for AIO scripts

# Log an informational message
log_i() {
    echo "[$(date +%T)]: [*] $1" >> "$klog"
    echo "" >> "$klog"
}

# Log a debug message to file and stdout
log_d() {
    echo "$1" >> "$kdbg"
    echo "$1"
}

# Log an error message to file and stdout
log_e() {
    echo "[!] $1" >> "$kdbg"
    echo "[!] $1"
}

# Write a value to a file if it's different from the current value.
# Sets the file to writable, writes the value, and then sets it back to read-only.
#
# @param $1: The file path
# @param $2: The value to write
write() {
    local file="$1"
    local value="$2"
    if [ ! -f "$file" ]; then
        log_e "$file doesn't exist"
        return 1
    fi

    if [ ! -w "$file" ]; then
        chmod +w "$file" 2>/dev/null || {
            log_e "Cannot make $file writable"
            return 1
        }
    fi

    local curval=$(cat "$file" 2>/dev/null)
    if [ "$curval" == "$value" ]; then
        log_d "$file already set to $value"
        return 0
    fi

    echo -n "$value" > "$file" 2>/dev/null || {
        log_e "Failed to write $value to $file (current: $curval)"
        return 1
    }

    chmod -w "$file" 2>/dev/null
    log_d "$file: $curval -> $value"
}

# Kill a service by its name.
#
# @param $1: The service name
kill_svc() {
    local svc="$1"
    pid=$(pidof "$svc")
    if [ -n "$pid" ]; then
        kill -15 "$pid"
        sleep 2
        if kill -0 "$pid" 2>/dev/null; then
            kill -9 "$pid"
        fi
    fi
}
