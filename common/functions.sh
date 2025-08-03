#!/system/bin/sh

# Helper functions for AIO installation

cleanup() {
	rm -rf "$MODPATH/common"
	rm -rf "$MODPATH/LICENSE"
}

abort() {
	ui_print "$1"
	rm -rf "$MODPATH"
	rm -rf "$TMPDIR"
	exit 1
}

# Simplified script to inject variables into other scripts.
# The complex copy/backup logic has been removed as it's not used by this module.
install_script() {
    local script_path="$1"

    # The -p and -l flags are no longer needed, but we'll handle them for compatibility
    if [ "$1" = "-p" ] || [ "$1" = "-l" ]; then
        shift
        script_path="$1"
    fi

    if [ ! -f "$script_path" ]; then return; fi

    # Ensure the script has a shebang
    if ! grep -q "^#!/system/bin/sh" "$script_path"; then
        sed -i "1i #!/system/bin/sh" "$script_path"
    fi

    # Inject variables after the shebang, but only if they haven't been injected before
    if ! grep -q "# AIO_VARS_INJECTED" "$script_path"; then
        sed -i "2i # AIO_VARS_INJECTED\nMODPATH='$MODPATH'\nMODID='$MODID'\nINFO='$INFO'\nLIBDIR='$LIBDIR'" "$script_path"
    fi
}

# --- Volume Key Selector Functions ---

# Find the correct input device for key events
find_key_event_device() {
    for device in /dev/input/event*; do
        if grep -q "KEY_VOLUMEUP" "$device" && grep -q "KEY_VOLUMEDOWN" "$device"; then
            KEY_EVENT_DEVICE="$device"
            return
        fi
    done
    KEY_EVENT_DEVICE=""
}

# Wait for a key press and identify it
key_check() {
    if [ -z "$KEY_EVENT_DEVICE" ]; then
        find_key_event_device
    fi

    if [ -z "$KEY_EVENT_DEVICE" ]; then
        abort "Error: Could not find volume key event device."
    fi

    local key_press
    key_press=$(dd if="$KEY_EVENT_DEVICE" bs=1 count=1 2>/dev/null | od -t x1 | awk '{print $2}')

    case "$key_press" in
        "6a" | "73") # Volume Up
            return 0
            ;;
        "69" | "72") # Volume Down
            return 1
            ;;
        *) # Other key
            return 2
            ;;
    esac
}

# Generic list selection function
# Usage: choose_from_list "Menu Title" "choices_array" "default_selection_index"
choose_from_list() {
    local title="$1"
    local choices_str="$2"
    local default_idx="$3"

    # Convert string to array
    local choices
    eval "choices=($choices_str)"

    local count=${#choices[@]}
    local current_idx=$default_idx

    while true; do
        ui_print " "
        ui_print "  $title"
        ui_print " "
        for i in $(seq 0 $((count - 1))); do
            if [ "$i" -eq "$current_idx" ]; then
                ui_print "  > [${choices[$i]}]"
            else
                ui_print "    [${choices[$i]}]"
            fi
        done
        ui_print " "
        ui_print "  Volume Up/Down to navigate, another key to select."

        key_check
        local result=$?

        case $result in
            0) # VolUp
                current_idx=$(( (current_idx - 1 + count) % count ))
                ;;
            1) # VolDown
                current_idx=$(( (current_idx + 1) % count ))
                ;;
            2) # Select
                SELECTED_CHOICE_INDEX=$current_idx
                return
                ;;
        esac
    done
}