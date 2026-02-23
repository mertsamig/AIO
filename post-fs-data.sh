#!/system/bin/sh
# MOD_PROFILE: balance, performance, battery
MOD_PROFILE="balance"

# Get Android Version
SDK_VERSION=$(getprop ro.build.version.sdk)
# Check for MIUI
IS_MIUI=$(getprop ro.miui.ui.version.name)

# --- Useless / Placebo / Unproved Tweaks (Commented Out) ---
# resetprop -n iorapd.perfetto.enable true # iorapd is deprecated/removed in newer Android
# device_config set_sync_disabled_for_tests persistent # Meant for CTS testing, might break sync
# settings put global hotword_detection_enabled 0 # User preference
# settings put global mobile_data_always_on 0 # User preference
# settings put global network_recommendations_enabled 0 # Redundant
# settings put global wifi_scan_always_enabled 0 # User preference

# --- Performance Tweaks ---
if [ "$MOD_PROFILE" != "battery" ]; then
    # Disable tracing to reduce system overhead
    resetprop -n debug.atrace.tags.enableflags 0
    resetprop -n debug.hwui.skia_atrace_enabled false

    # Increase priority for camera threads
    resetprop -n persist.vendor.camera.realtimethread 1
    # Optimize Skia rendering by reducing task splitting
    resetprop -n renderthread.skia.reduceopstasksplitting true

    # FUSE passthrough: Android 12+ optimization to bypass FUSE daemon for better I/O
    if [ "$SDK_VERSION" -ge 31 ]; then
        resetprop -n persist.sys.fuse.passthrough.enable true
    fi

    # SurfaceFlinger optimizations
    # Content detection helps in adjusting refresh rate dynamically based on content
    resetprop -n ro.surface_flinger.use_content_detection_for_refresh_rate true
    # Vendor specific display optimization
    resetprop -n vendor.display.enable_optimize_refresh 1

    # ART/Dalvik optimizations
    resetprop -n dalvik.vm.dex2oat64.enabled true
    resetprop -n dalvik.vm.dexopt.secondary true
    resetprop -n dalvik.vm.dex2oat-resolve-startup-strings true

    # Reduce input latency by adjusting latching behavior
    resetprop -n debug.sf.latch_unsignaled 0
    resetprop -n debug.sf.auto_latch_unsignaled 1

    # Enable layer command batching and multithreaded present for SurfaceFlinger
    resetprop -n debug.sf.enable_layer_command_batching true
    resetprop -n debug.sf.multithreaded_present true
    # Backpressure reduces UI stuttering by controlling frame production rate
    resetprop -n debug.sf.enable_gl_backpressure 1

    # Improve scrolling and touch responsiveness
    resetprop -n ro.max.fling_velocity 15000
    resetprop -n ro.min.fling_velocity 8000
    settings put system windowsmgr.max_events_per_sec 300
fi

# --- MIUI Specific ---
if [ -n "$IS_MIUI" ]; then
    # Disable MIUI network data control daemon to reduce background activity
    resetprop -n sys.miui.ndcd off
    # Set device performance level (v:1,c:3,g:3 is high level)
    settings put system deviceLevelList "v:1,c:3,g:3"
    # Background blur support for MIUI launcher/system UI
    resetprop -n persist.sys.background_blur_supported true
fi

# --- Device Config / Activity Manager ---
# Proactive kills: false keeps more apps in RAM, true frees up RAM more aggressively
if [ "$MOD_PROFILE" != "battery" ]; then
    device_config put activity_manager proactive_kills_enabled false
else
    device_config put activity_manager proactive_kills_enabled true
fi

# App compaction: Saves CPU cycles when disabled, but increases RAM usage
if [ "$MOD_PROFILE" = "performance" ]; then
    device_config put activity_manager use_compaction false
else
    device_config put activity_manager use_compaction true
fi

# Improve OOM management
device_config put activity_manager use_oom_re_ranking true
device_config put activity_manager uses_weight true
# Use new OOM score adjustment logic for better memory management
device_config put activity_manager use_new_oom_score_adj true

# Modern queue and freezer for better background task management (Android 11+)
if [ "$SDK_VERSION" -ge 30 ]; then
    device_config put activity_manager_native_boot modern_queue_enabled true
    device_config put activity_manager_native_boot offload_queue_enabled true
    device_config put activity_manager_native_boot use_freezer true
    # Prevent system from killing background processes (like Termux) aggressively
    device_config put activity_manager max_phantom_processes 2147483647
fi

# USAP (Unspecialized App Process) pool for faster app launching
device_config put runtime_native usap_pool_enabled true
device_config put runtime_native use_app_image_startup_cache true
resetprop -n dalvik.vm.usap_pool_enabled true

# ART/GC optimizations
# Generational Concurrent Copying: reduces GC pauses
device_config put runtime_native_boot enable_generational_cc true
# Userfaultfd GC: modern GC mechanism (Android 13+)
if [ "$SDK_VERSION" -ge 33 ]; then
    device_config put runtime_native_boot is_uffd_gc_enabled true
fi

# --- Networking ---
# DNS and IPv4/IPv6 selection optimizations
device_config put netd_native happy_eyeballs_enable true
device_config put netd_native parallel_lookup true
device_config put netd_native sort_nameservers true

# Improve Wi-Fi switching and scoring
settings put global wifi_badging_thresholds "10:1000,20:2000,30:4000,40:8000,50:16000"
settings put global wifi_score_params "rssi2=-95:-87:-73:-60,rssi5=-90:-85:-70:-57,rssi6=-90:-85:-70:-57"

# --- Secure Settings ---
# Enable system speed mode and disable error reporting
settings put secure speed_mode_enable 1
settings put secure send_action_app_error 0

# Disable screensaver/Daydream to save power/resources
settings put secure screensaver_activate_on_dock 0
settings put secure screensaver_activate_on_sleep 0
settings put secure screensaver_enabled 0

# --- Commands ---
# Disable looper statistics gathering
cmd looper_stats disable

# Set power mode based on profile
if [ "$MOD_PROFILE" = "performance" ]; then
    cmd power set-fixed-performance-mode-enabled true
    cmd power set-mode 1
else
    cmd power set-fixed-performance-mode-enabled false
    cmd power set-mode 0
fi
