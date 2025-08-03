#!/system/bin/sh



MODPATH="/data/adb/modules_update/aio"
DEBUG=true
mkdir -p "$MODPATH/system/bin"
moddir="/data/adb/modules/"
rm -rf "/sdcard/aio" && mkdir -p "/sdcard/aio"

SKIPUNZIP=0
unzip -qjo "$ZIPFILE" 'common/functions.sh' -d "$TMPDIR" >&2
. "$TMPDIR/functions.sh"

