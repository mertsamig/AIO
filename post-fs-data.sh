resetprop -n arm64.memtag.process.system_server off
resetprop -n dalvik.vm.dex2oat-minidebuginfo false
resetprop -n dalvik.vm.minidebuginfo false
resetprop -n debug.atrace.tags.enableflags 0
resetprop -n debug.hwui.skia_atrace_enabled false
resetprop -n debug.mdpcomp.logs 0
resetprop -n debug.sf.dump 0
resetprop -n libc.debug.malloc 0
resetprop -n media.stagefright.log-uri false
resetprop -n persist.debug.wfd.enable 0
resetprop -n persist.sys.strictmode.disable 1
resetprop -n persist.vendor.camera.realtimethread 1
resetprop -n persist.vendor.radio.adb_log_on 0
resetprop -n persist.vendor.sys.modem.logging.enable false
resetprop -n renderthread.skia.reduceopstasksplitting true
resetprop -n ro.lmk.debug false
resetprop -n ro.lmk.log_stats false
resetprop -n sys.wifitracing.started 0
resetprop -n persist.vendor.wifienhancelog 0

resetprop -n iorapd.perfetto.enable false
resetprop -n iorapd.readahead.enable false
resetprop -n ro.iorapd.enable false

resetprop -n persist.sys.fuse.passthrough.enable true
resetprop -n persist.vendor.btstack.enable.lpa true
resetprop -n ro.surface_flinger.use_content_detection_for_refresh_rate true
resetprop -n vendor.display.disable_rotator_downscale 1

resetprop -n sys.fflag.override.settings_seamless_transfer true
resetprop -n vendor.display.enable_optimize_refresh 1
resetprop -n ro.audio.monitorRotation true

resetprop -n dalvik.vm.dex2oat64.enabled true
resetprop -n dalvik.vm.dexopt.secondary true
resetprop -n pm.dexopt.bg-dexopt everything
resetprop -n pm.dexopt.cmdline everything
resetprop -n pm.dexopt.shared everything

resetprop -n vendor.display.enable_async_powermode 1
resetprop -n vendor.display.enable_inline_writeback 1
resetprop -n vendor.display.enable_perf_hint_large_comp_cycle 1

resetprop -n sdm.debug.disable_skip_validate 1
resetprop -n dev.pm.dyn_samplingrate 1

resetprop -n debug.sf.latch_unsignaled 0
resetprop -n debug.sf.auto_latch_unsignaled 1

resetprop -n debug.sf.enable_small_dirty_detection true
resetprop -n sys.miui.ndcd off
