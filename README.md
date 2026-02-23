# Android Optimization Module

This repository contains a collection of scripts designed to optimize Android system performance, improve battery life, and reduce background tracking/bloatware. Every tweak in this module has been systematically audited for its effectiveness on modern Android.

## Features

- **Balanced Optimization:** A single, carefully tuned profile that provides improved responsiveness and system efficiency without excessive battery drain.
- **Thoroughly Audited Tweaks:** Every active tweak has been verified against AOSP documentation and proven effectiveness. Legacy placebos and unverified "snake oil" tweaks have been removed.
- **Hardware-Aware Tuning:** Automatically detects and applies optimizations for Qualcomm (Adreno) and MediaTek (MTK) platforms.
- **Modern Android Support:** Includes specific optimizations for Android 12, 13, and 14, such as FUSE passthrough, MGLRU, and Userfaultfd GC.
- **Memory & LMKD:** Advanced ZRAM algorithm selection, watermark tuning, and optimized LMKD strategy to reduce UI lag.
- **Input & Scrolling:** Improved touch responsiveness and faster scrolling velocity via verified system properties.
- **DEX Optimization:** Manages background app optimization via the system's `bg-dexopt-job`.
- **Debloating:** Disables common system bloatware and analytics packages with safety checks.
- **Clean Trash:** Automatically removes temporary junk files and app caches on boot.
- **Safe Reset:** Includes a dedicated script to revert all applied changes without touching user data or unrelated preferences.

## Scripts

- `post-fs-data.sh`: Core system property tweaks and `device_config` adjustments.
- `service.sh`: Boot-time execution manager and DEX optimizer.
- `aio`: Advanced kernel and system-level performance tuning.
- `debloat`: Disables unwanted system applications safely.
- `cleantrash`: Cleans junk files and caches.
- `dga`: Disables Google Analytics and other tracking components in user apps.
- `reset_mod`: Safely reverts tweaks to system defaults.

## Configuration

This module is designed to work "out-of-the-box" with a balanced profile. No manual configuration is required; the module automatically applies the most effective and safe tweaks for your specific hardware and Android version.

## Safety & Compatibility

- **Target:** General Android (Android 10+ recommended).
- **Hardware:** Auto-detection for Qualcomm and MediaTek platforms.
- **Non-destructive:** Does not delete important system files. Use `reset_mod` to revert settings if needed.

## License

This project is provided as-is. Use it at your own risk.
