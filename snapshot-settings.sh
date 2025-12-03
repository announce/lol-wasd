#!/usr/bin/env bash
set -euxo pipefail

errorMessage () {
  echo "ERROR: $@" >&2
}

help () {
  showUsage
}

showUsage () {
  declare -F | awk '{print $3}'
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

outputSummary () {
  export TARGET_JSON_FILE="${1:-"$(dirname $0)/snapshot/lol-stable/PersistedSettings.json"}"
  export OUTPUT_JSON_FILE="${2:-"$(dirname $0)/snapshot/lol-stable/PersistedSettings.json"}"

  jq -r '["Name", "Value"], (
    .files[]
    | select(.name == "Input.ini")
    | .sections[]
    | select(.name == "WASD")
    | .settings[]
    | [.name, .value]
  ) | @csv' "${TARGET_JSON_FILE}" \
  > "${OUTPUT_JSON_FILE}.csv"

  jq -r '["Name", "Value"], (
    .files[]
    | select(.name == "Input.ini")
    | .sections[]
    | select(.name == "WASD")
    | .settings[]
    | ["\(.name)", "`\(.value)`"]
  ) | @csv' "${TARGET_JSON_FILE}" \
  | pipx run csv2md \
  > "${OUTPUT_JSON_FILE}.md"

  wc -l "${OUTPUT_JSON_FILE}".*
}

outputWasdConfig () {
  export TARGET_JSON_FILE="${1:-"$(dirname $0)/snapshot/lol-stable/PersistedSettings.json"}"

  jq -r '.files[]
    | select(.name == "Input.ini")
    | .sections[]
    | select(.name == "WASD")
    ' "${TARGET_JSON_FILE}" \
  | sed 's/\r(?!\n)/\r\n/g'
}

takeSnapshots () {
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
}

if [[ $# = 0 ]]; then
  # Execute the default command
  takeSnapshots
elif [[ "$(type -t "$1")" = "function" ]]; then
  $1 "$(shift && echo "$@")"
else
  errorMessage "No such command: $*"
  showUsage
fi
