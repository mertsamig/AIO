resetprop -n debug.atrace.tags.enableflags 0
resetprop -n debug.hwui.skia_atrace_enabled false

resetprop -n persist.vendor.camera.realtimethread 1
resetprop -n renderthread.skia.reduceopstasksplitting true

#resetprop -n iorapd.perfetto.enable true
#resetprop -n iorapd.readahead.enable true
#resetprop -n ro.iorapd.enable true

resetprop -n persist.sys.fuse.passthrough.enable true

resetprop -n ro.surface_flinger.use_content_detection_for_refresh_rate true
resetprop -n vendor.display.enable_optimize_refresh 1

resetprop -n dalvik.vm.dex2oat64.enabled true
resetprop -n dalvik.vm.dexopt.secondary true

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

resetprop -n debug.sf.latch_unsignaled 0
resetprop -n debug.sf.auto_latch_unsignaled 1

resetprop -n sys.miui.ndcd off

resetprop -n debug.sf.enable_layer_command_batching true
resetprop -n debug.sf.multithreaded_present true

device_config set_sync_disabled_for_tests persistent
#cmd looper_stats disable
#cmd power set-fixed-performance-mode-enabled true
#device_config put activity_manager max_cached_processes 65535
#device_config put activity_manager max_empty_time_millis 43200000
#device_config put activity_manager max_phantom_processes 2147483647
#device_config put activity_manager proactive_kills_enabled false
device_config put activity_manager use_compaction false
device_config put activity_manager use_oom_re_ranking true
device_config put activity_manager uses_weight true
device_config put activity_manager_native_boot modern_queue_enabled true
device_config put activity_manager_native_boot offload_queue_enabled true
device_config put activity_manager_native_boot use_freezer true
#device_config put clipboard auto_clear_enabled false
#device_config put media media_metrics_mode 0
#device_config put runtime_native metrics.write-to-statsd false
device_config put runtime_native usap_pool_enabled true
device_config put runtime_native use_app_image_startup_cache true
#device_config put runtime_native_boot disable_lock_profiling true
#device_config put runtime_native_boot enable_generational_cc true
#device_config put runtime_native_boot enable_perfetto true
#device_config put runtime_native_boot enable_readahead true
#device_config put runtime_native_boot enable_uffd_gc_2 true
#device_config put runtime_native_boot iorap_perfetto_enable true
#device_config put runtime_native_boot iorap_readahead_enable true
#device_config put runtime_native_boot is_uffd_gc_enabled true
device_config put runtime_native_boot pin_camera false
#device_config put odad westworld_logging false
settings put global hotword_detection_enabled 0
settings put global mobile_data_always_on 0
#settings put global netstats_enabled 0
settings put global network_recommendations_enabled 0
#settings put global settings_enable_monitor_phantom_procs false
settings put secure speed_mode_enable 1
settings put secure screensaver_activate_on_dock 0
settings put secure screensaver_activate_on_sleep 0 
settings put secure screensaver_enabled 0
settings put secure send_action_app_error 0
device_config put netd_native happy_eyeballs_enable true
device_config put netd_native parallel_lookup true
device_config put netd_native sort_nameservers true
settings put global wifi_scan_always_enabled 0

settings put system deviceLevelList "v:1,c:3,g:3"
#settings put system miui_app_cache_optimization 0

resetprop -n dalvik.vm.usap_pool_enabled true
#resetprop -n vendor.perf.framepacing.enable false
resetprop -n persist.sys.background_blur_supported true

#settings put system thermal_limit_refresh_rate 1
#resetprop -n persist.sys.miui_animator_sched.big_prime_cores 4-7
#resetprop -n persist.sys.miui_animator_sched.bigcores 4-7

resetprop -n ro.adb.secure 1
resetprop -n ro.debuggable 0
resetprop -n ro.force.debuggable 0
resetprop -n ro.secure 1
resetprop -n ro.boot.selinux enforcing
resetprop -n sys.oem_unlock_allowed 0