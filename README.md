# Android Optimization Module

This repository contains a collection of scripts designed to optimize Android system performance, improve battery life, and reduce background tracking/bloatware.

## Features

- **Balanced Optimization:** A single, carefully tuned profile that provides improved responsiveness and system efficiency without excessive battery drain.
- **Hardware-Aware Tweaks:** Automatically detects and applies tweaks for Qualcomm (Adreno) and MediaTek (MTK) platforms.
- **Input & Scrolling:** Improved touch responsiveness and faster scrolling velocity.
- **Memory & LMKD:** zRAM algorithm selection (`zstd`/`lz4`), MGLRU, watermark tuning, and optimized LMKD strategy.
- **I/O & Networking:** Fine-tuned I/O scheduler parameters and TCP congestion control.
- **DEX Optimization:** Manages background app optimization via `bg-dexopt-job`.
- **Debloating:** Disables common system bloatware and analytics packages.
- **Clean Trash:** Automatically removes temporary junk files and app caches on boot.
- **Reset Module:** A way to safely revert module-applied settings without touching user preferences.

## Scripts

- `post-fs-data.sh`: Core system property tweaks and `device_config` adjustments.
- `service.sh`: Boot-time execution manager.
- `aio`: Advanced kernel and system-level performance tuning.
- `debloat`: Disables unwanted system applications.
- `cleantrash`: Cleans junk files and caches.
- `dga`: Disables Google Analytics and other tracking components in user apps.
- `reset_mod`: Reverts tweaks to system defaults.

## Configuration

This module is designed to work "out-of-the-box" with a balanced profile. There is no longer a need to manually select between performance or battery profiles; the module applies the most effective tweaks for general usage.

## Safety & Compatibility

- Target: General Android (Android 10+ recommended).
- Hardware: Auto-detection for Qualcomm and MediaTek.
- Non-destructive: Does not delete important system files. The `reset_mod` script safely reverts settings.

## License

This project is provided as-is. Use it at your own risk.
