#!/usr/bin/env bash
set -euo pipefail

# Define your UUIDs from your config
UUID_HOMEOFFICE="7deb8fd9-c681-4339-86c5-1db5ebf1a7a1"
UUID_LIVINGROOM="88c87dfa-e831-4a67-bd96-bd6049a37040"

# Determine which profile to use based on the physical hardware detected
if [ -e "/dev/disk/by-uuid/$UUID_HOMEOFFICE" ]; then
  PROFILE="homeoffice"
elif [ -e "/dev/disk/by-uuid/$UUID_LIVINGROOM" ]; then
  PROFILE="livingroom"
elif curl -s --max-time 3 -o /dev/null https://backup.laenzlinger.net; then
  PROFILE="nas"
else
  wezterm start --class float_wezterm -- bash -c "echo 'ERROR: No backup target available!'; read"
  exit 1
fi

# Launch WezTerm
wezterm start --class float_wezterm -- bash -i -c "
    echo 'Fetching snapshots for profile: $PROFILE...'
    [ \"$PROFILE\" = \"nas\" ] && export RESTIC_REPOSITORY=\$(secret-tool lookup restic nas-repo)
    resticprofile $PROFILE-term.snapshots -c --latest 2
    echo '--- Local Btrfs Snapshots (Root) ---'
    snapper -c root list | tail -n 3
    echo -e '\n--- Local Btrfs Snapshots (Home) ---'
    snapper -c home list | tail -n 3
    read -n 1 -s -r
    " &
sleep 0.2
swaymsg "[app_id=\"float_wezterm\"] floating enable, border pixel 4"
sleep 0.1
swaymsg "[app_id=\"float_wezterm\"] resize set 1000 700, move position center"
