#!/bin/sh
# This script is used to disable a list of pre-defined Android applications.
# It iterates through a list of package names and disables them using the package manager (pm).

# Array of application package names to be disabled.
# Add or remove package names from this list as needed.
apps=(
	"com.miui.analytics"                     # MIUI Analytics
	"com.google.android.setupwizard"         # Google Setup Wizard
	"com.mi.globalminusscreen"               # MIUI Minus Screen (App Vault)
	"com.google.ambient.streaming"           # Google Ambient Streaming (for Chromecast)
	"com.google.android.apps.restore"        # Google Restore
	"com.google.android.apps.docs"           # Google Docs
	"com.miui.bugreport"                     # MIUI Bug Report
	"com.xiaomi.glgm"                        # Xiaomi GLGM (Unknown, potentially related to Google services)
	"com.android.hotwordenrollment.xgoogle"  # Google Hotword Enrollment (XGoogle variant)
	"com.android.hotwordenrollment.okgoogle" # Google Hotword Enrollment (OKGoogle variant)
	"com.google.android.gms.location.history" # Google Location History
	"com.google.android.apps.subscriptions.red" # Google Play Subscriptions (Red / YouTube Premium related)
	"com.google.android.onetimeinitializer"  # Google One Time Initializer
	"com.google.android.partnersetup"        # Google Partner Setup
	"com.google.android.videos"              # Google Play Movies & TV
	"com.milink.service"                     # MiLink Service (Xiaomi connectivity)
	"com.google.android.feedback"            # Google Feedback
	"com.google.android.apps.tachyon"        # Google Duo (now Google Meet)
	"com.facebook.system"                    # Facebook System Service
	"com.facebook.appmanager"                # Facebook App Manager
	"com.facebook.services"                  # Facebook Services
	"com.mi.globalbrowser"                   # Mi Browser
	"com.xiaomi.payment"                     # Xiaomi Payment Service
	"com.xiaomi.mi_connect_service"          # Xiaomi Mi Connect Service
	"com.miui.mishare.connectivity"          # MIUI MiShare Connectivity
	"com.miui.videoplayer"                   # MIUI Video Player
	"com.miui.msa.global"                    # MIUI MSA (MIUI System Ads)
	#"com.miui.miservice"                     # MIUI Mi Service (Commented out - consider keeping)
	#"com.miui.daemon"                        # MIUI Daemon (Commented out - consider keeping, core component)
	"com.miui.yellowpage"                    # MIUI Yellow Pages
	"com.google.android.youtube"             # YouTube
	"com.google.android.apps.youtube.music"  # YouTube Music
	"com.microsoft.appmanager"               # Microsoft App Manager (potentially bloatware from partnerships)
	"com.xiaomi.mirror"                      # Xiaomi Mirror (Screen sharing)
	"com.google.android.projection.gearhead" # Android Auto
	"com.google.android.adservices.api"      # Google Ad Services API
	"com.miui.phrase"                        # MIUI Phrase (Quick replies)
	"com.mi.android.globalFileexplorer"      # Mi File Explorer
	"com.google.android.healthconnect.controller" # Google Health Connect
	#"com.xiaomi.joyose"                      # Xiaomi Joyose (Performance/gaming boost, commented out)
	"com.miui.player"                        # MIUI Music Player
	"com.google.android.apps.safetyhub"      # Google Personal Safety
	"com.miui.touchassistant"                # MIUI Touch Assistant (Quick Ball)
	"com.tencent.soter.soterserver"          # Tencent Soter Server (Biometric authentication)
	"com.google.android.tts"                 # Google Text-to-Speech Engine
	"com.android.traceur"                    # System Tracing
	"com.android.managedprovisioning"        # Android Managed Provisioning (for work profiles)
	"com.google.android.googlequicksearchbox" # Google Search App / Assistant
	"com.android.htmlviewer"                 # HTML Viewer
	"com.google.android.apps.googleassistant" # Google Assistant App
	"com.google.android.marvin.talkback"     # Google TalkBack (Accessibility)
	"com.google.android.contactkeys"         # Google Contact Keys (related to RCS/Chat)
	"com.google.android.safetycore"          # Google Safety Core
)

# Loop through the 'apps' array and disable each application.
# The output and errors are redirected to /dev/null to keep the execution clean.
for app in "${apps[@]}"; do
	# Alternative commands for removing or uninstalling apps (commented out):
	# pm uninstall "$app" > /dev/null 2>&1                       # Uninstall for current user
	# pm uninstall --user 0 "$app" > /dev/null 2>&1              # Uninstall for user 0 (primary user)
	# pm install-existing "$app" > /dev/null 2>&1              # Reinstall if previously uninstalled for user 0

	# Disable the application for the current user.
	# This is generally safer than uninstalling system apps.
	pm disable "$app" > /dev/null 2>&1
done

# Script execution finished.