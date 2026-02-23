#!/system/bin/sh

# MOD_PROFILE: balance, performance, battery
MOD_PROFILE="balance"

wait_until_login() {
  until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 1
  done

  # Ensure the system is ready and we have access to /storage
  test_file="/storage/emulated/0/Android/.PERMISSION_TEST"
  until touch "$test_file" 2>/dev/null; do
    sleep 1
  done
  rm -f "$test_file"
}

wait_until_login

# Delay to ensure background services have settled
sleep 30

# Run main optimization scripts
aio
debloat

# --- DEX Optimization ---
# Optimize apps based on the selected profile
if [ "$MOD_PROFILE" != "battery" ]; then
    # bg-dexopt-job runs in the background and optimizes apps based on usage
    cmd package bg-dexopt-job

    if [ "$MOD_PROFILE" = "performance" ]; then
        # For performance, we can force a more aggressive optimization for the top apps
        # Note: This can take a long time and consume battery if run too often.
        # cmd package compile -m speed -a
        :
    fi
fi

# Clean up temporary junk files after boot
cleantrash
