#!/system/bin/sh
# This script aims to disable components (services, receivers, providers) within installed Android applications
# that are commonly associated with analytics, tracking, ads, and logging.

# Define log file paths
LOG_FILE="/storage/emulated/0/aio/dga.log"      # Main log for general messages
DBG_LOG_FILE="/storage/emulated/0/aio/dga_dbg.log" # Debug log for detailed disabled components

# Clear/Create log files at the start of the script
: > "$LOG_FILE"
: > "$DBG_LOG_FILE"

# Function to append a message to the main log file
LOG() { echo "$1" >> "$LOG_FILE"; }
# Function to append a timestamped message to the main log file
LOG_D() { echo "[$(date +%T)]: $1" >> "$LOG_FILE"; }

LOG_D "- Searching and disabling useless components; services, receivers, and providers of your apps."

# Get a list of all installed package names
PACKAGES=$(pm list packages | cut -f 2 -d ":")

# Define an exception pattern. Components matching this will NOT be disabled.
# Useful for critical components that might match keywords but are necessary.
EXCEPTION_PATTERN="com.whatsapp.crash.upload.ExceptionsUploadService"

# Define a pattern of keywords to search for within component names.
# These keywords are typically found in components related to ads, analytics, logging, etc.
KEYWORD_PATTERN="adactivity|analytic|applog|crash|debug|diagnostic|error|logcat|logger|logging|logservice|measure|metric|report|stats|trace|tracing|track|\.ads|admob|com\.my\.target\.|tagmanager|unity|telemetry"

# Initialize counters
PROCESSED_COUNT=0 # Total number of components checked
DISABLED_COUNT=0  # Total number of components successfully disabled

# Iterate through each installed package
for package in $PACKAGES; do
    # Get a list of components for the current package that match the KEYWORD_PATTERN (case-insensitive)
    # 'dumpsys package [package_name]' provides detailed information about the package, including its components.
    components=$(dumpsys package "$package" | grep -Ei "$KEYWORD_PATTERN")

    # If components matching the pattern are found
    if [ -n "$components" ]; then
        # Process each found component line by line
        while read -r component; do
            PROCESSED_COUNT=$((PROCESSED_COUNT + 1)) # Increment processed components counter
            # Extract the component name (usually the second field, e.g., package/component.name)
            component_name=$(echo "$component" | cut -d ' ' -f 2)

            # Check if the component name is not empty and does not match the EXCEPTION_PATTERN
            if [ -n "$component_name" ] && [ "$component_name" != "$EXCEPTION_PATTERN" ]; then
                # Attempt to disable the component using 'pm disable'
                # Output and errors are redirected to /dev/null to keep the console clean.
                if pm disable "$package/$component_name" >/dev/null 2>/dev/null; then
                    # If disabling was successful, log it to the debug log and increment the disabled counter
                    echo "DISABLED: $package/$component_name" >> "$DBG_LOG_FILE"
                    DISABLED_COUNT=$((DISABLED_COUNT + 1))
                fi
            fi
        done <<< "$components" # Feed the 'components' variable to the while loop
    fi
done

# Synchronize data on disk with memory to ensure all log writes are flushed
sync

# Log summary information
LOG " "
LOG_D "- Finished."

LOG " "
LOG "～～～～～～～～～～～～～～～～～～～～～～～～～"
LOG "DisableGoogleAnalytics is successfully applied." # Script name might be a bit misleading if it disables more than just GA
LOG "Total processed components: $PROCESSED_COUNT"
LOG "Total disabled components: $DISABLED_COUNT"
LOG "～～～～～～～～～～～～～～～～～～～～～～～～～"

# Script finished