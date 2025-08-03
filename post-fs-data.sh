#!/system/bin/sh

# This script applies system properties and settings during the post-fs-data stage.

# --- Performance & Debugging ---
resetprop -n debug.atrace.tags.enableflags 0
resetprop -n debug.hwui.skia_atrace_enabled false

# --- Camera ---
resetprop -n persist.vendor.camera.realtimethread 1
resetprop -n renderthread.skia.reduceopstasksplitting true

# --- Filesystem ---
resetprop -n persist.sys.fuse.passthrough.enable true

# --- UI & Graphics ---
resetprop -n ro.surface_flinger.use_content_detection_for_refresh_rate true
resetprop -n vendor.display.enable_optimize_refresh 1
resetprop -n debug.sf.latch_unsignaled 0
resetprop -n debug.sf.auto_latch_unsignaled 1
resetprop -n debug.sf.enable_layer_command_batching true
resetprop -n debug.sf.multithreaded_present true
resetprop -n ro.zygote.disable_gl_preload 1

# --- Dalvik VM & Dex ---
resetprop -n dalvik.vm.dex2oat64.enabled true
resetprop -n dalvik.vm.dexopt.secondary true
resetprop -n pm.dexopt.secondary everything
resetprop -n pm.dexopt.bg-dexopt everything
resetprop -n pm.dexopt.ab-ota everything
resetprop -n pm.dexopt.baseline everything
resetprop -n pm.dexopt.boot-after-mainline-update everything
resetprop -n pm.dexopt.boot-after-ota everything
resetprop -n pm.dexopt.cmdline everything
resetprop -n pm.dexopt.first-boot everything
resetprop -n pm.dexopt.first-use everything
resetprop -n pm.dexopt.inactive everything
resetprop -n pm.dexopt.install everything
resetprop -n pm.dexopt.install-bulk everything
resetprop -n pm.dexopt.install-bulk-downgraded everything
resetprop -n pm.dexopt.install-bulk-secondary everything
resetprop -n pm.dexopt.install-bulk-secondary-downgraded everything
resetprop -n pm.dexopt.install-create-dm everything
resetprop -n pm.dexopt.install-fast everything
resetprop -n pm.dexopt.post-boot everything
resetprop -n pm.dexopt.shared everything
resetprop -n dalvik.vm.usap_pool_enabled true

# --- Activity Manager ---
device_config set_sync_disabled_for_tests persistent
device_config put activity_manager use_compaction false
device_config put activity_manager use_oom_re_ranking true
device_config put activity_manager uses_weight true
device_config put activity_manager_native_boot modern_queue_enabled true
device_config put activity_manager_native_boot offload_queue_enabled true
device_config put activity_manager_native_boot use_freezer true
device_config put runtime_native usap_pool_enabled true
device_config put runtime_native use_app_image_startup_cache true
device_config put runtime_native_boot pin_camera false

# --- Power & Battery ---
cmd power set-adaptive-power-saver-enabled true
cmd power set-fixed-performance-mode-enabled false
cmd power set-mode 0

# --- Misc Settings ---
settings put global hotword_detection_enabled 0
settings put global mobile_data_always_on 0
settings put global network_recommendations_enabled 0
settings put global wifi_scan_always_enabled 0
settings put secure speed_mode_enable 1
settings put secure screensaver_activate_on_dock 0
settings put secure screensaver_activate_on_sleep 0
settings put secure screensaver_enabled 0
settings put secure send_action_app_error 0

# --- Networking ---
device_config put netd_native happy_eyeballs_enable true
device_config put netd_native parallel_lookup true
device_config put netd_native sort_nameservers true

# --- MIUI Specific ---
resetprop -n sys.miui.ndcd off

# --- Security ---
resetprop -n ro.adb.secure 1
resetprop -n ro.debuggable 0
resetprop -n ro.force.debuggable 0
resetprop -n ro.secure 1