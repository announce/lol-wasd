#!/usr/bin/env bash
set -euxo pipefail

# Specify the target config directories and files
export TARGET_KARABINER_DIR="${HOME}/.config/karabiner/"
export TARGET_LOL_BETA_FILE="/Applications/League of Legends (PBE).app/Contents/LoL/Config/PersistedSettings.json"
export TARGET_LOL_STABLE_FILE="/Applications/League of Legends.app/Contents/LoL/Config/PersistedSettings.json"

rsync -av "${TARGET_KARABINER_DIR}" ./snapshot/karabiner/
rsync -av "${TARGET_LOL_BETA_FILE}" ./snapshot/lol-beta/
rsync -av "${TARGET_LOL_STABLE_FILE}" ./snapshot/lol-stable/
