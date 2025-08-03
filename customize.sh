#!/system/bin/sh

# This script is executed by the Magisk installer.

# The installation framework used by this module requires manual unzipping.
# First, we extract the functions script to a temporary directory.
SKIPUNZIP=0
unzip -qjo "$ZIPFILE" 'common/functions.sh' -d "$TMPDIR" >&2
. "$TMPDIR/functions.sh"

# --- Installation Functions ---

# Function to run the main installation process
install_module() {
    ui_print "[*] Installing for $ARCH SDK $API device..."

    # Pre-process scripts and prop files (remove comments/blank lines)
    for i in $(find "$MODPATH" -type f -name *.sh -o -name *.prop -o -name *.rule); do
        [[ -f "$i" ]] && {
            sed -i -e "/^#/d" -e "/^ *$/d" "$i"
            [[ "$(tail -1 "$i")" ]] && echo "" >>"$i"
        } || continue
    done

    # Install service scripts
    install_script -l "$MODPATH/service.sh"
    install_script -p "$MODPATH/post-fs-data.sh"
    install_script "$MODPATH/uninstall.sh"

    # Set permissions
    ui_print "[*] Setting Permissions..."
    set_perm_recursive "$MODPATH" 0 0 0755 0644
    if [ -d "$MODPATH/system/bin" ]; then
        set_perm_recursive "$MODPATH/system/bin" 0 0 0755 0755 u:object_r:system_bin_file:s0
    fi

    # Clean up installation-only files
    cleanup
}

# --- Interactive Menu Logic ---

ui_print "********************************************************"
ui_print "*      AIO - All-In-One QoL Tweaks Installer         *"
ui_print "********************************************************"

# Set default choices
ENABLE_CPU_TWEAKS=true
ENABLE_GPU_TWEAKS=true
ENABLE_IO_TWEAKS=true
ENABLE_NETWORK_TWEAKS=true
ENABLE_VM_LMK_TWEAKS=true
ENABLE_SCHEDULER_TWEAKS=true
ENABLE_MISC_TWEAKS=true
DISABLE_LOGGING_SERVICES=true
DISABLE_DEBUGGING=true
RUN_DEBLOAT=false
RUN_DGA=false

# Main menu
choose_from_list "Select Installation Type" "'Default (Recommended)' 'Custom'" 0
if [ "$SELECTED_CHOICE_INDEX" -eq 1 ]; then
    # Custom installation

    # Tweak selection menu
    tweak_choices=("'1. CPU Tweaks       (Current: $ENABLE_CPU_TWEAKS)'"
                   "'2. GPU Tweaks       (Current: $ENABLE_GPU_TWEAKS)'"
                   "'3. I/O Tweaks       (Current: $ENABLE_IO_TWEAKS)'"
                   "'4. Network Tweaks   (Current: $ENABLE_NETWORK_TWEAKS)'"
                   "'5. VM/LMK Tweaks    (Current: $ENABLE_VM_LMK_TWEAKS)'"
                   "'6. Scheduler Tweaks (Current: $ENABLE_SCHEDULER_TWEAKS)'"
                   "'7. Misc Tweaks      (Current: $ENABLE_MISC_TWEAKS)'"
                   "'8. Disable Logging  (Current: $DISABLE_LOGGING_SERVICES)'"
                   "'9. Disable Debugging(Current: $DISABLE_DEBUGGING)'"
                   "'10. Done'"
                  )

    while true; do
        choose_from_list "Toggle Tweaks (Press Other Key to Toggle)" "${tweak_choices[*]}" 9

        case $SELECTED_CHOICE_INDEX in
            0) ENABLE_CPU_TWEAKS=$(! $ENABLE_CPU_TWEAKS && echo true || echo false) ;;
            1) ENABLE_GPU_TWEAKS=$(! $ENABLE_GPU_TWEAKS && echo true || echo false) ;;
            2) ENABLE_IO_TWEAKS=$(! $ENABLE_IO_TWEAKS && echo true || echo false) ;;
            3) ENABLE_NETWORK_TWEAKS=$(! $ENABLE_NETWORK_TWEAKS && echo true || echo false) ;;
            4) ENABLE_VM_LMK_TWEAKS=$(! $ENABLE_VM_LMK_TWEAKS && echo true || echo false) ;;
            5) ENABLE_SCHEDULER_TWEAKS=$(! $ENABLE_SCHEDULER_TWEAKS && echo true || echo false) ;;
            6) ENABLE_MISC_TWEAKS=$(! $ENABLE_MISC_TWEAKS && echo true || echo false) ;;
            7) DISABLE_LOGGING_SERVICES=$(! $DISABLE_LOGGING_SERVICES && echo true || echo false) ;;
            8) DISABLE_DEBUGGING=$(! $DISABLE_DEBUGGING && echo true || echo false) ;;
            9) break ;;
        esac

        # Update menu text
        tweak_choices[0]="'1. CPU Tweaks       (Current: $ENABLE_CPU_TWEAKS)'"
        tweak_choices[1]="'2. GPU Tweaks       (Current: $ENABLE_GPU_TWEAKS)'"
        tweak_choices[2]="'3. I/O Tweaks       (Current: $ENABLE_IO_TWEAKS)'"
        tweak_choices[3]="'4. Network Tweaks   (Current: $ENABLE_NETWORK_TWEAKS)'"
        tweak_choices[4]="'5. VM/LMK Tweaks    (Current: $ENABLE_VM_LMK_TWEAKS)'"
        tweak_choices[5]="'6. Scheduler Tweaks (Current: $ENABLE_SCHEDULER_TWEAKS)'"
        tweak_choices[6]="'7. Misc Tweaks      (Current: $ENABLE_MISC_TWEAKS)'"
        tweak_choices[7]="'8. Disable Logging  (Current: $DISABLE_LOGGING_SERVICES)'"
        tweak_choices[8]="'9. Disable Debugging(Current: $DISABLE_DEBUGGING)'"
    done

    # Optional scripts menu
    choose_from_list "Run Optional Scripts Now?" "'Run Debloat Script'" "'Run DGA Script'" "'Run Both'" "'Skip'" 3
    case $SELECTED_CHOICE_INDEX in
        0) RUN_DEBLOAT=true ;;
        1) RUN_DGA=true ;;
        2) RUN_DEBLOAT=true; RUN_DGA=true ;;
        3) ;;
    esac
fi

# --- Start of installation logic ---

# Unzip module files
ui_print "[*] Extracting module files..."
unzip -o "$ZIPFILE" -x 'META-INF/*' 'common/functions.sh' -d "$MODPATH" >&2

# Clean up old files
ui_print "[*] Removing old files..."
[[ -f "$INFO" ]] && {
	while read LINE; do
		[[ "$(echo -n "$LINE" | tail -c 1)" == "~" ]] && continue || [[ -f $LINE~ ]] && mv -f "$LINE"~ "$LINE" || rm -f "$LINE"
			while true; do
				LINE=$(dirname "$LINE")
				[[ "$(ls -A "$LINE")" ]] && break 1 || rm -rf "$LINE"
			done
	done <"$INFO"
	rm -f "$INFO"
}

# Generate aio.conf from choices
ui_print "[*] Generating aio.conf..."
cat > "$MODPATH/aio.conf" <<EOF
# AIO Configuration File
# Generated by installer on $(date)

# --- Core System Tweaks ---
ENABLE_CPU_TWEAKS=$ENABLE_CPU_TWEAKS
ENABLE_GPU_TWEAKS=$ENABLE_GPU_TWEAKS
ENABLE_IO_TWEAKS=$ENABLE_IO_TWEAKS
ENABLE_NETWORK_TWEAKS=$ENABLE_NETWORK_TWEAKS
ENABLE_VM_LMK_TWEAKS=$ENABLE_VM_LMK_TWEAKS
ENABLE_SCHEDULER_TWEAKS=$ENABLE_SCHEDULER_TWEAKS

# --- Miscellaneous ---
ENABLE_MISC_TWEAKS=$ENABLE_MISC_TWEAKS
DISABLE_LOGGING_SERVICES=$DISABLE_LOGGING_SERVICES
DISABLE_DEBUGGING=$DISABLE_DEBUGGING
EOF

# Run optional scripts if selected
if [ "$RUN_DEBLOAT" = true ]; then
    ui_print "[*] Running Debloat script..."
    sh "$MODPATH/system/bin/debloat"
fi
if [ "$RUN_DGA" = true ]; then
    ui_print "[*] Running DGA script..."
    sh "$MODPATH/system/bin/dga"
fi

# Run main installation
install_module

ui_print " "
ui_print "********************************************************"
ui_print "         AIO Tweaks Installed Successfully!             "
ui_print "********************************************************"