#!/usr/bin/env bash
set -euxo pipefail

errorMessage () {
  echo "ERROR: $@" >&2
}

syncMac () {
  export OUTPUT_DIR="$(dirname $0)"
  export TARGET_KARABINER_DIR="${HOME}/.config/karabiner/"
  export TARGET_LOL_BETA_FILE="/Applications/League of Legends (PBE).app/Contents/LoL/Config/PersistedSettings.json"
  export TARGET_LOL_STABLE_FILE="/Applications/League of Legends.app/Contents/LoL/Config/PersistedSettings.json"

  rsync -a "${TARGET_KARABINER_DIR}" ${OUTPUT_DIR}/snapshot/karabiner/
  rsync -a "${TARGET_LOL_BETA_FILE}" ${OUTPUT_DIR}/snapshot/lol-beta/
  rsync -a "${TARGET_LOL_STABLE_FILE}" ${OUTPUT_DIR}/snapshot/lol-stable/
}

syncLinux () {
  export OUTPUT_DIR="$(dirname $0)"
  export TARGET_LOL_BETA_FILE="/mnt/c/Riot Games/League of Legends (PBE)/Config/PersistedSettings.json"
  export TARGET_LOL_STABLE_FILE="/mnt/c/Riot Games/League of Legends/Config/PersistedSettings.json"

  rsync -a "${TARGET_LOL_BETA_FILE}" ${OUTPUT_DIR}/snapshot/lol-beta/
  rsync -a "${TARGET_LOL_STABLE_FILE}" ${OUTPUT_DIR}/snapshot/lol-stable/
}


case "${OSTYPE}" in
# macOS
darwin*)
    syncMac
    ;;
# Linux (WSL)
linux*)
    syncLinux
    ;;
*) # Default case (wildcard)
    errorMessage "Unsupported platform: ${OSTYPE}"
    exit 1
    ;;
esac
