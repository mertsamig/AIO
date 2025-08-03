#!/system/bin/sh

wait_until_login() {
  until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 1
  done

  test_file="/storage/emulated/0/Android/.PERMISSION_TEST"
  until touch "$test_file" 2>/dev/null; do
    sleep 1
  done
  rm -f "$test_file"
}

wait_until_login

sleep 30

pm disable com.google.android.gms/.analytics.AnalyticsService
pm disable com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver
pm disable com.google.android.gms/.nearby.messages.service.NearbyMessagesService
pm enable com.google.android.gms/.chimera.GmsIntentOperationService

aio
