# This script is executed during the post-fs-data stage of the Android boot process.
# It uses 'resetprop' to set system properties and 'device_config' or 'settings'
# to modify system configurations. These changes can affect performance, debugging,
# UI behavior, and other system aspects.
# Lines starting with '#' are comments and are ignored.

# Disable Atrace tags and Skia Atrace for debugging/profiling to reduce overhead.
resetprop -n debug.atrace.tags.enableflags 0
resetprop -n debug.hwui.skia_atrace_enabled false

# Enable real-time thread for camera (vendor specific).
resetprop -n persist.vendor.camera.realtimethread 1
# Enable Skia operation task splitting reduction for render thread.
resetprop -n renderthread.skia.reduceopstasksplitting true

# IORAP (I/O Read-Ahead Prediction) settings (commented out).
# These would enable IORAP for faster app startups.
#resetprop -n iorapd.perfetto.enable true
#resetprop -n iorapd.readahead.enable true
#resetprop -n ro.iorapd.enable true

# Enable FUSE passthrough for potentially better filesystem performance.
resetprop -n persist.sys.fuse.passthrough.enable true

# SurfaceFlinger and display refresh rate optimizations.
resetprop -n ro.surface_flinger.use_content_detection_for_refresh_rate true
resetprop -n vendor.display.enable_optimize_refresh 1

# Dalvik VM (ART) settings for DEX (Dalvik Executable) optimization.
resetprop -n dalvik.vm.dex2oat64.enabled true # Enable 64-bit dex2oat.
resetprop -n dalvik.vm.dexopt.secondary true   # Enable secondary dex optimization.

# Package Manager (pm) dexopt filter settings.
# These control how and when apps are optimized (dexopt).
# 'everything' is a very aggressive optimization strategy.
# Most are commented out, only 'bg-dexopt' (background dexopt) and 'secondary' are active.
#resetprop -n pm.dexopt.ab-ota everything
#resetprop -n pm.dexopt.baseline everything
resetprop -n pm.dexopt.bg-dexopt everything
#resetprop -n pm.dexopt.boot-after-mainline-update everything
#resetprop -n pm.dexopt.boot-after-ota everything
#resetprop -n pm.dexopt.cmdline everything
#resetprop -n pm.dexopt.first-boot everything
#resetprop -n pm.dexopt.first-use everything
#resetprop -n pm.dexopt.inactive everything
#resetprop -n pm.dexopt.install everything
#resetprop -n pm.dexopt.install-bulk everything
#resetprop -n pm.dexopt.install-bulk-downgraded everything
#resetprop -n pm.dexopt.install-bulk-secondary everything
#resetprop -n pm.dexopt.install-bulk-secondary-downgraded everything
#resetprop -n pm.dexopt.install-create-dm everything
#resetprop -n pm.dexopt.install-fast everything
#resetprop -n pm.dexopt.post-boot everything
resetprop -n pm.dexopt.secondary everything
#resetprop -n pm.dexopt.shared everything

# SurfaceFlinger latch unsignaled settings for smoother UI.
resetprop -n debug.sf.latch_unsignaled 0
resetprop -n debug.sf.auto_latch_unsignaled 1

# Disable MIUI NDCD (Network Diagnostic & Connectivity Daemon) - specific to MIUI ROMs.
resetprop -n sys.miui.ndcd off

# Enable SurfaceFlinger layer command batching and multithreaded presentation for performance.
resetprop -n debug.sf.enable_layer_command_batching true
resetprop -n debug.sf.multithreaded_present true

# --- device_config settings ---
# 'device_config' is a tool to change system configurations, often for A/B testing or dynamic adjustments.

# Disable sync for tests (persistent setting).
device_config set_sync_disabled_for_tests persistent

# Disable looper stats (commented out).
#cmd looper_stats disable
# Enable fixed performance mode (commented out, can drain battery).
#cmd power set-fixed-performance-mode-enabled true

# Activity Manager settings (most are commented out).
# These affect how apps are managed in terms of caching, killing, etc.
#device_config put activity_manager max_cached_processes 65535
#device_config put activity_manager max_empty_time_millis 43200000
#device_config put activity_manager max_phantom_processes 2147483647
#device_config put activity_manager proactive_kills_enabled false
device_config put activity_manager use_compaction false        # Disable memory compaction by ActivityManager.
device_config put activity_manager use_oom_re_ranking true    # Enable OOM re-ranking.
device_config put activity_manager uses_weight true           # Use process weight for OOM decisions.
device_config put activity_manager_native_boot modern_queue_enabled true # Enable modern queue for native boot.
device_config put activity_manager_native_boot offload_queue_enabled true # Enable offload queue for native boot.
device_config put activity_manager_native_boot use_freezer true         # Use cgroup freezer for native boot.

# Clipboard auto-clear (commented out).
#device_config put clipboard auto_clear_enabled false
# Media metrics mode (commented out).
#device_config put media media_metrics_mode 0
# Disable runtime native metrics writing to statsd (commented out).
#device_config put runtime_native metrics.write-to-statsd false
# Enable USAP (Unspecialized App Process) pool for faster app starts.
device_config put runtime_native usap_pool_enabled true
# Use app image startup cache.
device_config put runtime_native use_app_image_startup_cache true

# Runtime native boot configurations (most commented out).
# These are low-level ART runtime options.
#device_config put runtime_native_boot disable_lock_profiling true
#device_config put runtime_native_boot enable_generational_cc true
#device_config put runtime_native_boot enable_perfetto true
#device_config put runtime_native_boot enable_readahead true
#device_config put runtime_native_boot enable_uffd_gc_2 true
#device_config put runtime_native_boot iorap_perfetto_enable true
#device_config put runtime_native_boot iorap_readahead_enable true
#device_config put runtime_native_boot is_uffd_gc_enabled true
device_config put runtime_native_boot pin_camera false # Do not pin camera app in memory.
# Disable ODAD (On-Demand App Data) Westworld logging (commented out).
#device_config put odad westworld_logging false

# --- settings put commands ---
# 'settings put' is used to modify entries in the system settings database.

# Disable hotword detection (e.g., "OK Google").
settings put global hotword_detection_enabled 0
# Disable "mobile data always on" feature.
settings put global mobile_data_always_on 0
# Disable netstats (network statistics collection) (commented out).
#settings put global netstats_enabled 0
# Disable network recommendations (e.g., for Wi-Fi).
settings put global network_recommendations_enabled 0
# Disable monitoring of phantom processes (commented out).
#settings put global settings_enable_monitor_phantom_procs false

# Enable speed mode (vendor specific, likely performance mode).
settings put secure speed_mode_enable 1
# Disable screensaver activation on dock or sleep.
settings put secure screensaver_activate_on_dock 0
settings put secure screensaver_activate_on_sleep 0 
settings put secure screensaver_enabled 0
# Disable sending action app error reports.
settings put secure send_action_app_error 0

# Netd (Network Daemon) native settings for better network connectivity.
device_config put netd_native happy_eyeballs_enable true   # Enable Happy Eyeballs (RFC 8305).
device_config put netd_native parallel_lookup true         # Enable parallel DNS lookups.
device_config put netd_native sort_nameservers true        # Sort DNS nameservers.

# Disable "Wi-Fi scan always available".
settings put global wifi_scan_always_enabled 0

# Set device level list for performance classification (vendor specific).
settings put system deviceLevelList "v:1,c:3,g:3"
# Disable MIUI app cache optimization (commented out, MIUI specific).
#settings put system miui_app_cache_optimization 0

# Re-enable USAP pool via resetprop (already set via device_config, might be redundant or for different stage).
resetprop -n dalvik.vm.usap_pool_enabled true
# Disable vendor performance frame pacing (commented out).
#resetprop -n vendor.perf.framepacing.enable false
# Enable background blur support (persistent).
resetprop -n persist.sys.background_blur_supported true

# Thermal limit refresh rate (commented out).
#settings put system thermal_limit_refresh_rate 1
# MIUI animator scheduler settings for big cores (commented out, MIUI specific).
#resetprop -n persist.sys.miui_animator_sched.big_prime_cores 4-7
#resetprop -n persist.sys.miui_animator_sched.bigcores 4-7

# --- Security Related Properties ---
# These settings generally aim to make the device more secure by disabling debugging
# and ensuring secure boot states.

# Enable secure ADB (Android Debug Bridge).
resetprop -n ro.adb.secure 1
# Disable debuggable builds at runtime.
resetprop -n ro.debuggable 0
# Prevent forcing debuggable state.
resetprop -n ro.force.debuggable 0
# Ensure device is in secure state.
resetprop -n ro.secure 1
# Set SELinux to enforcing mode during boot.
resetprop -n ro.boot.selinux enforcing
# Disallow OEM unlocking (prevents bootloader unlocking).
resetprop -n sys.oem_unlock_allowed 0

# Script finished.