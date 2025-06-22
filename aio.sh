#!/system/bin/sh
# This script is designed to optimize Android system performance by tweaking various kernel parameters.

# Define log file paths
klog="/storage/emulated/0/aio/aio.log" # Main log file
kdbg="/storage/emulated/0/aio/aio_dbg.log" # Debug log file

# Remove existing log files to start fresh
rm -f "$kdbg" "$klog"

# Create empty log files
: > "$kdbg"
: > "$klog"

# Function to log informational messages
log_i() {
	echo "[$(date +%T)]: [*] $1" >> "$klog" # Append timestamped message to main log
	echo "" >> "$klog" # Add an empty line for readability
}

# Function to log debug messages
log_d() {
	echo "$1" >> "$kdbg" # Append message to debug log
	echo "$1" # Also print to stdout
}

# Function to log error messages
log_e() {
	echo "[!] $1" >> "$kdbg" # Append error message to debug log
	echo "[!] $1" # Also print error to stdout
}

# Function to write a value to a system file
# Arguments:
#   $1: file path
#   $2: value to write
write() {
    local file="$1"
    local value="$2"
    # Check if the file exists
    [[ ! -f "$file" ]] && {
        log_e "$file doesn't exist"
        return 1 # Return error if file not found
    }

    # Check if the file is writable, if not, try to make it writable
    if [[ ! -w "$file" ]]; then
        chmod +w "$file" 2>/dev/null || { # Suppress chmod errors
            log_e "Cannot make $file writable"
            return 1 # Return error if cannot make writable
        }
    fi

    # Get the current value of the file
    local curval=$(cat "$file" 2>/dev/null) # Suppress cat errors
    # If current value is already the target value, do nothing
    [[ "$curval" == "$value" ]] && {
        log_d "$file already set to $value"
        return 0 # Return success
    }

    # Write the new value to the file
    echo -n "$value" > "$file" 2>/dev/null || { # Suppress echo errors
        log_e "Failed to write $value to $file (current: $curval)"
        return 1 # Return error if write failed
    }

    # Remove write permissions from the file
    chmod -w "$file" 2>/dev/null # Suppress chmod errors
    log_d "$file: $curval -> $value" # Log the change
}

# Function to kill a service by its name
# Arguments:
#   $1: service name
kill_svc() {
    local svc="$1"
	pid=$(pidof "$svc") # Get Process ID of the service
	if [ -n "$pid" ]; then # If PID exists
		kill -15 $pid # Send SIGTERM (graceful shutdown)
		sleep 2 # Wait for the service to terminate
		# Check if the process is still running
		if kill -0 $pid 2>/dev/null; then # Suppress kill errors
			kill -9 $pid # Send SIGKILL (force kill)
		fi
	fi
}

# Define common system paths for easier access
dbg="/sys/kernel/debug/sched_features"
f2fs="/sys/fs/f2fs/"
fs="/proc/sys/fs/"
gpu="/sys/class/kgsl/kgsl-3d0/"
kdbg="/sdcard/aio/aio_dbg.log" # Redefined, consider removing duplicate
kernel="/proc/sys/kernel/"
klog="/sdcard/aio/aio.log" # Redefined, consider removing duplicate
lmk="/sys/module/lowmemorykiller/parameters/"
stune="/dev/stune/"
tcp_v4="/proc/sys/net/ipv4/"
vm="/proc/sys/vm/"
mm="/sys/kernel/mm/"

# Function to stop various logging and debugging services
stop_services() {
	services=(
		"aplogd"
		"charge_logger"
		"cnss_diag"
		"dumpstate"
		"idd-logreader"
		"idd-logreadermain"
		"ipacm-diag"
		"logcat"
		"logcatd"
		"logd"
		"ramdump"
		"stats"
		"statscompanion"
		"statsd"
		"subsystem_ramdump"
		"tcpdump"
		"tombstoned"
		"traced"
		"traced_probes"
		"vendor.cnss_diag"
		"vendor.ipacm-diag"
		"vendor.tcpdump"
		"wlan_logging"
		"miuibooster"
	"aee.log-1-1"
	"vendor_tcpdump"
	"emdlogger"
	"consyslogger"
	"mobile_log_d"
	"wifi_dump"
	"bt_dump"
	"cnss-daemon"
	)

	# Kill each service in the list in the background
	for service in "${services[@]}"; do
	kill_svc "$service" &
	done
	wait # Wait for all background kill processes to complete

	log_i "Disabled few debug services and userspace daemons"
}

# Function to tune CPU boost parameters
boost_tune() {
    # Disable dynamic stune boost if available
	[[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]] && {
		write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "0"
		log_i "Disabled dynamic stune boost"
	}

    # Disable CAF CPU input boost parameters if available
	[[ -d "/sys/module/cpu_boost/" ]] && {
		write "/sys/module/cpu_boost/parameters/input_boost_ms" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "0"
		write "/sys/module/cpu_boost/parameters/sched_boost_on_powerkey_input" "0"
		write "/sys/module/cpu_boost/parameters/powerkey_input_boost_ms" "0"
		log_i "Disabled CAF CPU input boost"
	}

    # Disable CPU input boost parameters if available
	[[ -d "/sys/module/cpu_input_boost/" ]] && {
		write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "0"
		write "/sys/module/cpu_input_boost/parameters/wake_boost_duration" "0"
		log_i "Disabled CPU input boost"
	}

    # Disable other miscellaneous boost parameters
	write "${kernel}launcher_boost_enabled" "0"
	write "${kernel}slide_boost_enabled" "0"
	write "/sys/devices/system/cpu/sched/sched_boost" "0"
	write "/sys/kernel/tracing/events/sched/sched_boost_cpu" "0"
}

# Function to tune I/O scheduler parameters
io_tune() {
    # Iterate over all block device queues
	for queue in /sys/block/*/queue/; do
		avail_scheds=$(cat "${queue}scheduler") # Get available schedulers

        # Set the I/O scheduler to the first available one in the preferred list
		for sched in none noop kyber bfq mq-deadline cfq; do
			if [[ "$avail_scheds" == *"$sched"* ]]; then
				write "${queue}scheduler" "$sched"
				break # Exit loop once a scheduler is set
			fi
		done

		write "${queue}add_random" "0" # Disable adding random data to entropy pool
		#write "${queue}io_poll" "0" # Potentially disable I/O polling
		#write "${queue}iostats" "0" # Potentially disable I/O statistics
	done

	# Potentially disable iostat for f2fs filesystems
	#for i in ${f2fs}*/; do
		#write "${i}iostat_enable" "0"
	#done

	log_i "Tweaked I/O scheduler"
}

# Function to tune CPU governor and frequency scaling parameters
cpu_tune() {
	# Potentially disable MTK core control or MSM thermal management
	#write "/sys/module/mtk_core_ctl/parameters/policy_enable" "0"
    #write "/sys/module/msm_thermal/parameters/enabled" "N"
	#write "/sys/module/msm_thermal/core_control/enabled" "0"
	#write "/sys/kernel/msm_thermal/enabled" "0"

	# Potentially disable core control for individual CPU cores
	#for core in /sys/devices/system/cpu/cpu*/core_ctl/; do
		#write "${core}enable" "0"
	#done

    # Iterate over all CPU cores' frequency settings
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
		min_freq=$(cat "${cpu}cpuinfo_min_freq") # Get minimum CPU frequency
		max_freq=$(cat "${cpu}cpuinfo_max_freq") # Get maximum CPU frequency
		write "${cpu}scaling_min_freq" "$min_freq" # Set scaling minimum frequency
		write "${cpu}scaling_max_freq" "$max_freq" # Set scaling maximum frequency
		avail_scheds=$(cat "${cpu}scaling_available_governors") # Get available governors
        # Set CPU governor and its parameters
		for sched in sugov_ext schedutil; do
			if [[ "$avail_scheds" == *"$sched"* ]]; then
				write "${cpu}scaling_governor" "$sched"
				write "${cpu}${sched}/hispeed_freq" "4294967295" # Max value, effectively disabling a separate hispeed_freq
				write "${cpu}${sched}/hispeed_load" "90"
				write "${cpu}${sched}/iowait_boost_enable" "1"
				write "${cpu}${sched}/pl" "1" # Phase lock
				break # Exit loop once a governor is set
			fi
		done
	done

    # Allow CPUs to use their deepest sleep state if available
	[[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] && {
		write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
		log_i "Allowed CPUs to use it's deepest sleep state"
	}

	log_i "Tweaked CPU governor"
}

# Function to tune GPU parameters
gpu_tune() {
    # If GPU directory exists, apply tweaks
	[[ -d "$gpu" ]] && {
		write "${gpu}bus_split" "1" # Enable bus split
		write "${gpu}devfreq/adrenoboost" "0" # Disable Adreno boost
		write "${gpu}force_bus_on" "0" # Disable forcing bus on
		write "${gpu}force_clk_on" "0" # Disable forcing clock on
		write "${gpu}force_no_nap" "0" # Disable forcing no nap state
		write "${gpu}force_rail_on" "0" # Disable forcing rail on
		write "${gpu}popp" "0" # Power Off Peripheral Processor
		write "${gpu}pwrnap" "1" # Enable power nap
		write "${gpu}thermal_pwrlevel" "0" # Set thermal power level to minimum
		write "${gpu}throttling" "0" # Disable GPU throttling
		write "${gpu}boost" "0" # Disable GPU boost
		write "${gpu}cl_boost_disable" "0" # Disable OpenCL boost (ensure it's disabled)

		log_i "Tweaked GPU parameters"
	}

    # Disable Simple GPU Algorithm if present
	[[ -d "/sys/module/simple_gpu_algorithm/parameters/" ]] && {
		write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "0"
		log_i "Disabled SGPU algorithm"
	}

    # Disable Adreno idler if present
	[[ -d "/sys/module/adreno_idler/" ]] && {
		write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
		log_i "Disabled adreno idler"
	}

}

# Function to disable forced cryptography self-tests
disable_crypto_tests() {
	[[ -d "/sys/module/cryptomgr/" ]] && {
		write "/sys/module/cryptomgr/parameters/notests" "Y" # 'Y' to disable tests
		log_i "Disabled forced cryptography tests"
	}
}

# Function to tune schedtune parameters for different cgroups
schedtune_tune() {
	[[ -d "$stune" ]] && { # If stune directory exists
        # Background tasks: no boost, no prefer idle
		write "${stune}background/schedtune.boost" "0"
		write "${stune}background/schedtune.prefer_idle" "0"
		write "${stune}background/schedtune.sched_boost" "0"
        # Camera daemon: boost, prefer idle
		write "${stune}camera-daemon/schedtune.boost" "1"
		write "${stune}camera-daemon/schedtune.prefer_idle" "1"
		write "${stune}camera-daemon/schedtune.sched_boost" "0"
        # Foreground tasks: boost, no prefer idle
		write "${stune}foreground/schedtune.boost" "1"
		write "${stune}foreground/schedtune.prefer_idle" "0"
		write "${stune}foreground/schedtune.sched_boost" "0"
        # Real-time tasks: no boost, no prefer idle
		write "${stune}rt/schedtune.boost" "0"
		write "${stune}rt/schedtune.prefer_idle" "0"
		write "${stune}rt/schedtune.sched_boost" "0"
        # Default schedtune: no boost, no prefer idle
		write "${stune}schedtune.boost" "0"
		write "${stune}schedtune.prefer_idle" "0"
		write "${stune}schedtune.sched_boost" "0"
        # Top-app tasks: boost, prefer idle
		write "${stune}top-app/schedtune.boost" "1"
		write "${stune}top-app/schedtune.prefer_idle" "1"
		write "${stune}top-app/schedtune.sched_boost" "0"
		log_i "Tweaked schedtune settings"
	}
}

# Function to configure filesystem parameters
config_fs() {
	[[ -d "$fs" ]] && { # If /proc/sys/fs/ directory exists
		#write "${fs}dir-notify-enable" "0" # Potentially disable directory notifications
		write "${fs}lease-break-time" "10" # Set lease break time to 10 seconds
		write "${fs}leases-enable" "1" # Enable file leases
		log_i "Tweaked FS"
	}
}

# Function to configure dynamic fsync
config_dyn_fsync() {
	[[ -d "/sys/kernel/dyn_fsync/" ]] && { # If dynamic fsync directory exists
		write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "Y" # Enable dynamic fsync
		log_i "Enabled dynamic fsync"
	}
}

# Function to disable CRC checks for MMC core (may improve performance at risk of data integrity)
disable_crc() {
	[[ -d "/sys/module/mmc_core/" ]] && {
		write "/sys/module/mmc_core/parameters/crc" "N" # Disable CRC
		write "/sys/module/mmc_core/parameters/removable" "N" # Treat as non-removable (if applicable)
		write "/sys/module/mmc_core/parameters/use_spi_crc" "N" # Disable SPI CRC
		log_i "Disabled CRC"
	}
}

# Function to tune scheduler parameters
sched_tune() {
	write "${kernel}hung_task_timeout_secs" "0" # Disable hung task timeout
	write "${kernel}perf_cpu_time_max_percent" "5" # Limit CPU time for perf events
	#write "${kernel}printk_devkmsg" "off" # Potentially disable printk to /dev/kmsg
	write "${kernel}sched_autogroup_enabled" "1" # Enable scheduler autogrouping
	write "${kernel}sched_boost" "0" # Disable general scheduler boost
	write "${kernel}sched_boost_top_app" "1" # Enable scheduler boost for top app
	write "${kernel}sched_child_runs_first" "0" # Parent runs first after fork
	write "${kernel}sched_conservative_pl" "1" # Enable conservative phase lock
	write "${kernel}sched_cstate_aware" "1" # Enable C-state awareness in scheduler
	write "${kernel}sched_energy_aware" "1" # Enable energy-aware scheduling
	write "${kernel}sched_init_task_load" "20" # Initial task load value
	write "${kernel}sched_initial_task_util" "0" # Initial task utilization
	write "${kernel}sched_migration_fixup" "0" # Disable migration fixup
	write "${kernel}sched_min_task_util_for_boost" "0"
	write "${kernel}sched_min_task_util_for_colocation" "0"
	write "${kernel}sched_prefer_sync_wakee_to_waker" "1" # Prefer waking task on waker's CPU
	#write "${kernel}sched_schedstats" "0" # Potentially disable scheduler statistics
	write "${kernel}sched_tunable_scaling" "0" # Disable tunable scaling
	write "${kernel}sched_walt_rotate_big_tasks" "1" # Enable WALT rotation for big tasks
	write "${kernel}timer_migration" "1" # Enable timer migration
	write "/proc/sys/dev/tty/ldisc_autoload" "0" # Disable line discipline autoloading
	write "/sys/devices/system/cpu/cpufreq/hotplug/cpu_hotplug_disable" "1" # Disable CPU hotplug (if supported this way)
	write "/sys/devices/system/cpu/sched/hint_enable" "0" # Disable scheduler hint
	write "/sys/devices/system/cpu/eas/enable" "1" # Enable Energy Aware Scheduling (EAS)
	#write "/sys/devices/system/cpu/perf/enable" "1" # Potentially enable CPU performance events
	write "/sys/kernel/debug/msm_vidc/disable_thermal_mitigation" "0" # Ensure thermal mitigation for video is NOT disabled
	#write "/sys/kernel/rcu_expedited" "0" # Potentially use normal RCU
	#write "/sys/kernel/rcu_normal" "1" # Potentially use normal RCU
	log_i "Tweaked various kernel parameters to a better overall performance"
}

# Function to disable fingerprint sensor boost
fp_boost() {
	[[ -d "/sys/kernel/fp_boost/" ]] && {
		write "/sys/kernel/fp_boost/enabled" "0"
		log_i "Disabled fingerprint boost"
	}
}

# Function to tune Virtual Memory (VM) and Low Memory Killer (LMK) parameters
vm_lmk_tune() {
	sync # Synchronize data on disk with memory
    # LMK tweaks
	write "${lmk}enable_adaptive_lmk" "0" # Disable adaptive LMK
	write "${lmk}lmk_fast_run" "0" # Disable LMK fast run
	write "${lmk}oom_reaper" "1" # Enable OOM reaper
    # VM tweaks
	write "${vm}block_dump" "0" # Disable block dump on OOM
	write "${vm}dirty_background_ratio" "10" # Start background writeback at 10% dirty memory
	#write "${vm}dirty_expire_centisecs" "3000" # How long dirty data can stay in cache
	write "${vm}dirty_ratio" "30" # Start foreground writeback at 30% dirty memory
	#write "${vm}dirty_writeback_centisecs" "3000" # How often to wake for writeback
	#write "${vm}extfrag_threshold" "750" # External fragmentation threshold
	write "${vm}laptop_mode" "0" # Disable laptop mode (less aggressive disk writes)
	write "${vm}oom_dump_tasks" "0" # Disable dumping tasks info on OOM
	write "${vm}overcommit_memory" "1" # Always allow memory overcommit
	write "${vm}overcommit_ratio" "100" # Allow overcommit up to 100% of swap + RAM
	#write "${vm}page-cluster" "2" # Number of pages to read ahead
	write "${vm}reap_mem_on_sigkill" "1" # Reap memory on SIGKILL
	#write "${vm}stat_interval" "10" # VM statistics interval
	#write "${vm}vfs_cache_pressure" "100" # Tendency to reclaim VFS cache
	write "${vm}swappiness" "40" # Moderate swappiness
    # Multi-Gen LRU tweaks (if available)
	write "${mm}lru_gen/enabled" "Y"
	write "${mm}lru_gen/min_ttl_ms" "1000"
    # Swap tweaks
	write "${mm}swap/vma_ra_enabled" "true" # Enable VMA read-ahead for swap
	write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0" # Disable process reclaim
	# Transparent Huge Pages (THP) - often disabled for performance/stability
	#write "${mm}transparent_hugepage/khugepaged/defrag" "0"
	#write "${mm}transparent_hugepage/defrag" "never"
	#write "${mm}transparent_hugepage/enabled" "never"
	#write "${mm}transparent_hugepage/shmem_enabled" "never"
	#write "${mm}transparent_hugepage/use_zero_page" "0"
    # Compaction tweaks
	write "${vm}compact_unevictable_allowed" "0" # Disallow compacting unevictable pages
	write "${vm}compaction_proactiveness" "0" # Disable proactive compaction
	log_i "Tweaked various VM and LMK parameters for a improved user-experience"
}

# Function to enable power efficient workqueues
pewq() {
	[[ -e "/sys/module/workqueue/parameters/power_efficient" ]] && {
		write "/sys/module/workqueue/parameters/power_efficient" "Y"
		log_i "Enabled power efficient workqueue"
	}
}

# Function to configure TCP congestion control algorithm and other network parameters
config_tcp() {
	avail_con=$(cat "${tcp_v4}tcp_available_congestion_control") # Get available TCP congestion algorithms

    # Set TCP congestion control to the first available one in the preferred list
	for con in bbr2 bbr c2tcp cdg westwood cubic; do
		if [[ "$avail_con" == *"$con"* ]]; then
			write "${tcp_v4}tcp_congestion_control" "$con"
			break # Exit loop once set
		fi
	done

    # Various TCP/IP tweaks
	write "${tcp_v4}ip_no_pmtu_disc" "0" # Enable Path MTU Discovery
	write "${tcp_v4}tcp_ecn" "1" # Enable Explicit Congestion Notification
	write "${tcp_v4}tcp_fastopen" "3" # Enable TCP Fast Open (client and server)
	write "${tcp_v4}tcp_mtu_probing" "1" # Enable MTU probing
	write "${tcp_v4}tcp_sack" "1" # Enable Selective Acknowledgements
	write "${tcp_v4}tcp_slow_start_after_idle" "0" # Disable slow start after idle
	write "${tcp_v4}tcp_timestamps" "1" # Enable TCP timestamps
	write "${tcp_v4}tcp_tw_recycle" "1" # Enable TIME_WAIT socket recycling (use with caution, can break NAT)
	write "${tcp_v4}tcp_tw_reuse" "1" # Allow reuse of TIME_WAIT sockets
	write "${tcp_v4}tcp_window_scaling" "1" # Enable window scaling
	write "/proc/sys/net/core/netdev_max_backlog" "65536" # Increase network device backlog
	log_i "Applied TCP tweaks"
}

# Function to disable kernel battery saver features (if any)
kern_pwrsave() {
	[[ -d "/sys/module/battery_saver/" ]] && {
		write "/sys/module/battery_saver/parameters/enabled" "N"
		log_i "Disabled kernel battery saver"
	}
}

# Function to enable PM2 idle sleep mode (specific to some SoCs)
pm2_idle_mode() {
	[[ -d "/sys/module/pm2/parameters/" ]] && {
		write "/sys/module/pm2/parameters/idle_sleep_mode" "Y"
		log_i "Enabled pm2 idle sleep mode"
	}
}

# Function to enable USB fast charging (if supported)
enable_usb_fast_chrg() {
	[[ -e "/sys/kernel/fast_charge/force_fast_charge" ]] && {
		write "/sys/kernel/fast_charge/force_fast_charge" "1"
		log_i "Enabled USB 3.0 fast charging"
	}
}

# Function to disable various debugging features across the system
disable_debug() {
    # List of common debug-related file names
    useless=(
        "debug"
        "compat-log"
        "debug_level"
        "debug_mask"
        "debug_mode"
        "edac_mc_log"
        "enable_event_log"
        "enable_ramdumps"
        "log_ce"
        "log_ecn_error"
        "log_enabled"
        "log_level"
        "log_ue"
        "mballoc_debug"
        "seclog"
        "snapshot_crashdumper"
        "tracing_on"
    )

    # Find and disable (write "0") to files matching the keywords
	for keyword in "${useless[@]}"; do
		for file in $(find /sys/ -type f -name "$keyword"); do # Search only within /sys/
			write "$file" "0"
		done
	done

    # Disable specific debug-related kernel parameters and sysfs nodes
	write "${kernel}compat-log" "0"
	write "${kernel}panic" "0" # Disable panic on oops
	write "${kernel}panic_on_oops" "0"
	write "${kernel}printk" "0 0 0 0" # Suppress most kernel messages to console
	write "${kernel}softlockup_panic" "0" # Disable panic on soft lockup
	write "${vm}panic_on_oom" "0" # Disable panic on Out Of Memory
	write "/proc/sys/debug/exception-trace" "0" # Disable exception tracing
	write "/sys/kernel/debug/debug_enabled" "0" # Generic debug toggle
	write "/sys/kernel/debug/dri/0/debug/enable" "0" # Disable DRM debugging
	write "/sys/kernel/debug/rpm_log" "0" # Disable RPM logging
	write "/sys/kernel/debug/sde_rotator0/clk_always_on" "0" # Disable SDE rotator clock always on
	write "/sys/kernel/debug/sde_rotator0/evtlog/enable" "0" # Disable SDE rotator event log
	write "/sys/kernel/printk_mode/printk_mode" "0" # Set printk mode to off/quiet
    # Module-specific debug parameters
	write "/sys/module/bluetooth/parameters/disable_ertm" "Y" # Disable Bluetooth Enhanced Retransmission Mode
	write "/sys/module/bluetooth/parameters/disable_esco" "Y" # Disable Bluetooth eSCO
	write "/sys/module/dwc3/parameters/ep_addr_rxdbg_mask" "0" # Disable DWC3 RX debug
	write "/sys/module/dwc3/parameters/ep_addr_txdbg_mask" "0" # Disable DWC3 TX debug
	write "/sys/module/hid_apple/parameters/fnmode" "0" # Set Apple HID fnmode
	write "/sys/module/hid_magicmouse/parameters/emulate_3button" "N" # Disable 3-button emulation for Magic Mouse
	write "/sys/module/hid_magicmouse/parameters/emulate_scroll_wheel" "N" # Disable scroll wheel emulation for Magic Mouse
	write "/sys/module/logger/parameters/log_mode" "2" # Set logger mode (specific meaning depends on kernel)
	write "/sys/module/mdss_fb/parameters/backlight_dimmer" "N" # Disable MDSS framebuffer backlight dimmer
	write "/sys/module/otg_wakelock/parameters/enabled" "N" # Disable OTG wakelock
	write "/sys/module/printk/parameters/console_suspend" "Y" # Allow console to suspend
	write "/sys/module/service_locator/parameters/enable" "0" # Disable service locator
	write "/sys/module/spurious/parameters/noirqdebug" "Y" # Disable IRQ debugging for spurious interrupts
	log_i "Disabled misc debugging"
}

# Function to disable touch boost mechanisms
disable_tb() {
    # Try disabling MSM performance touchboost
	[[ -e "/sys/module/msm_performance/parameters/touchboost" ]] && {
		write "/sys/module/msm_performance/parameters/touchboost" "0"
		log_i "Disabled msm_performance touch boost"
    # Else, try disabling PNPMGR touchboost
	} || [[ -e "/sys/power/pnpmgr/touch_boost" ]] && {
		write "/sys/power/pnpmgr/long_duration_touch_boost" "0"
		write "/sys/power/pnpmgr/touch_boost" "0"
		log_i "Disabled pnpmgr touch boost"
    # Else, try disabling generic proc touchboost
	} || [[ -d "/proc/touch_boost/" ]] && {
		write "/proc/touch_boost/enable" "0"
		write "/proc/touch_boost/boost_duration" "0"
		log_i "Disabled touch boost"
	}
}

# Function to run background dex optimization for packages
dexopt() {
	cmd package bg-dexopt-job # Trigger background dexopt job
	# Alternative dexopt commands (commented out)
	#pm compile -m everything -a
	#pm compile -m everything --secondary-dex -a
	#pm compile --compile-layouts -a
	#pm compile -m everything --full -a
	#pm art dexopt-packages -r bg-dexopt
	#pm art cleanup
	log_i "Background optimization task executed"
}

# --- Main script execution starts here ---

log_i "Initializing"
init=$(date +%s) # Record start time
sync # Sync filesystem

# Set thermal configuration (specific to some devices)
write "/sys/class/thermal/thermal_message/sconfig" "10"

# FPSGO related tweaks (commented out, specific to some Mediatek devices)
#write "/sys/kernel/fpsgo/common/fpsgo_enable" "1"
#write "/sys/kernel/fpsgo/minitop/enable" "1"
#write "/sys/kernel/fpsgo/composer/control_hwui" "1"
#write "/sys/kernel/fpsgo/composer/fpsgo_control" "1"
#for param in adjust_loading boost_affinity boost_LR gcc_hwui_hint d_boost loading_enable perfmgr_enable; do
#    write "/sys/module/mtk_fpsgo/parameters/$param" "1"
#done
#write "/sys/module/ged/parameters/ged_boost_enable" "1"

# Run dex optimization in the background
dexopt &
# Stop unnecessary services (optional, commented out)
#stop_services &

# Apply various system tweaks by calling the defined functions
disable_crc
#disable_crypto_tests  # Optional, often safe to keep enabled unless issues arise
config_fs
config_dyn_fsync
#config_tcp # Optional, network tweaks can be device/network specific
enable_usb_fast_chrg
#disable_debug # Optional, extensive debugging disable
io_tune
boost_tune
cpu_tune
gpu_tune
schedtune_tune
sched_tune
vm_lmk_tune
pewq
disable_tb
fp_boost
pm2_idle_mode
kern_pwrsave

wait # Wait for any background processes (like dexopt) to finish
log_i "Tweaks applied. Enjoy!"
exit_time=$(date +%s) # Record end time
exec_time=$((exit_time - init)) # Calculate execution time
log_i "Spent time: $exec_time seconds."
exit 0 # Exit successfully
