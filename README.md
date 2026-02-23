# Android Optimization Module

This repository contains a collection of scripts designed to optimize Android system performance, improve battery life, and reduce background tracking/bloatware.

## Features

- **Performance Profiles:** Choose between `balance`, `performance`, and `battery` profiles.
- **Hardware-Aware Tweaks:** Automatically detects and applies tweaks for Qualcomm (Adreno) and MediaTek (MTK) platforms.
- **Input & Scrolling:** Improved touch responsiveness and faster scrolling velocity.
- **Memory Management:** zRAM algorithm selection (`zstd`/`lz4`), MGLRU, and watermark tuning.
- **DEX Optimization:** Manages background app optimization via `bg-dexopt-job`.
- **Debloating:** Disables common system bloatware and analytics packages.
- **Clean Trash:** Automatically removes temporary junk files and app caches on boot.
- **Reset Module:** A safe way to revert module-applied settings without touching user preferences.

## Scripts

- `post-fs-data.sh`: Core system property tweaks and `device_config` adjustments.
- `service.sh`: Boot-time execution manager.
- `aio`: Advanced kernel and system-level performance tuning.
- `debloat`: Disables unwanted system applications.
- `cleantrash`: Cleans junk files and caches.
- `dga`: Disables Google Analytics and other tracking components in user apps.
- `reset_mod`: Reverts tweaks to system defaults.

## How to Configure Profiles

To change the active profile, you need to edit the `MOD_PROFILE` variable at the top of the following files:

1. `post-fs-data.sh`
2. `aio`
3. `service.sh`

### Available Profiles:

- `balance` (Default): A balanced approach between performance and battery life.
- `performance`: Aggressive tweaks for high performance (gaming), may increase battery consumption.
- `battery`: Focuses on power saving by reducing system overhead.

## Safety & Compatibility

- Target: General Android (Android 10+ recommended).
- Hardware: Auto-detection for Qualcomm and MediaTek.
- Non-destructive: Does not delete important system files. The `reset_mod` script safely reverts settings.

## License

This project is provided as-is. Use it at your own risk.
