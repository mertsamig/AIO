# AIO - All-In-One QoL Tweaks

## Overview

AIO is a Magisk module that provides a collection of Quality of Life (QoL) tweaks for Android devices. It aims to improve performance, battery life, and the overall user experience by adjusting a wide range of system parameters.

This module is designed to be highly configurable, allowing you to choose which tweaks you want to apply.

## Features

- **System & Kernel Tweaks:** Adjusts CPU, GPU, I/O, VM, and scheduler settings for a smoother experience.
- **Network Optimizations:** Applies TCP tweaks to potentially improve network performance.
- **Debloater:** Includes a script to easily remove a list of pre-installed applications.
- **Analytics Blocker:** Includes a script to disable analytics and tracking components in other apps.
- **Configurable:** All major tweak categories can be enabled or disabled through a configuration file.

---

## Configuration

After installing the module, you can find the configuration file at:
`/data/adb/modules/aio/aio.conf`

You can edit this file to enable or disable groups of tweaks. Set the value to `true` to enable a feature, or `false` to disable it.

**Example `aio.conf`:**
```sh
# AIO Configuration File
# Set the following values to 'true' to enable a group of tweaks,
# or 'false' to disable them.

# --- Core System Tweaks ---
ENABLE_CPU_TWEAKS=true
ENABLE_GPU_TWEAKS=true
ENABLE_IO_TWEAKS=true
ENABLE_NETWORK_TWEAKS=true
ENABLE_VM_LMK_TWEAKS=true
ENABLE_SCHEDULER_TWEAKS=true

# --- Miscellaneous ---
ENABLE_MISC_TWEAKS=true
DISABLE_LOGGING_SERVICES=true
DISABLE_DEBUGGING=true
```

Changes to this file will be applied on the next reboot.

---

## Customization

### Debloat Script

The module includes a script to uninstall a list of common bloatware. You can customize this list to your liking.

The script is located at: `/data/adb/modules/aio/system/bin/debloat`

To prevent an app from being uninstalled, open the `debloat` script and put a `#` at the beginning of the line with the app's package name.

**Example:**
To keep the YouTube app, find the line `"com.google.android.youtube"` and change it to `#"com.google.android.youtube"`.

---

## Scripts Overview

This module includes several scripts that perform its core functions:

- **`post-fs-data.sh`**: Applies system property tweaks early in the boot process.
- **`service.sh`**: Runs after the device has fully booted. It starts the main `aio` tweaking script.
- **`system/bin/aio`**: The main script that applies the bulk of the kernel and system tweaks based on your `aio.conf` settings.
- **`system/bin/debloat`**: The debloat script. This is not run automatically. You can run it from a root shell to remove the apps in its list (e.g., `su -c /system/bin/debloat`).
- **`system/bin/dga`**: A script to disable analytics components in other apps. Not run automatically.
- **`system/bin/fixgms`**: A script to safely reset Google Play Services data. Not run automatically.
- **`system/bin/reset_mod`**: A script to safely uninstall the entire AIO module.

---

## Disclaimer

The tweaks included in this module are generally considered safe, but they can have different effects on different devices and Android versions. Use at your own risk. It is always recommended to have a backup of your device before installing system-level modifications.
