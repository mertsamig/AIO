#!/system/bin/sh
# This script attempts to fix issues related to Google Mobile Services (GMS)
# by deleting files containing 'gms' in their names within the /data/data directory.
# WARNING: This is a potentially destructive operation. Use with extreme caution.
# It might help in some GMS-related problem scenarios but could also break GMS functionality
# or other apps if it deletes critical files unintentionally.

# Synchronize data on disk with memory.
# This ensures that any pending write operations are completed before proceeding.
sync

# Change the current directory to /data/data.
# This is the directory where applications store their private data.
cd /data/data

# Find and delete files within the current directory (/data/data) and its subdirectories
# that have 'gms' in their filename.
# - '.' specifies the current directory as the starting point for the search.
# - '-type f' restricts the search to regular files only (not directories, links, etc.).
# - '-name '*gms*'' searches for files where 'gms' appears anywhere in the name.
# - '-delete' performs the deletion of the found files.
# THIS IS A POWERFUL COMMAND. ENSURE YOU UNDERSTAND THE IMPLICATIONS.
find . -type f -name '*gms*' -delete

# Inform the user that a reboot is needed for the changes to potentially take effect.
# Deleting files might not be enough; services might need to be restarted,
# which a reboot would typically achieve.
echo "Reboot to apply changes."

# Script finished.