#!/bin/bash
#
# Purpose: Common code that is likely loaded in most of the scripts
#          within this framework. Handles things such as a start date/time,
#          logging, and other various "common" functionality.

declare -A levels=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
log_level=${LOG_LEVEL}

# log function
log() {
  local log_message=$1
  local log_priority=$2

  # check if level exists and is of the right level to log
  [[ ${levels[$log_priority]} ]] || return 1
  (( ${levels[$log_priority]} < ${levels[$log_level]} )) && return 2

  # log in place (which for at jobs end up in the linux mail)
  echo -e "${log_priority} : ${log_message}"

  # log output to a log file
  echo -e $(date '+%d-%m-%Y %H:%M') $0 "${log_priority} : ${log_message}" >> "$NOAA_LOG"
}

command_exists() {
  if ! command -v "$1" &>/dev/null; then
    log "Required command not found: $1" "ERROR"
    exit 1
  fi
}

# run as a normal user for any scripts within
if [ $EUID -eq 0 ]; then
  log "This script shouldn't be run as root." "ERROR"
  exit 1
fi

# Log basic environment information
log "Environment: \n\tUSER: ${USER}\n\tPATH: ${PATH}" "INFO"

# Verify required binaries are present and on user's PATH
command_exists "convert"
command_exists "ffmpeg"
command_exists "gmic"
command_exists "identify"
command_exists "medet_arm"
command_exists "meteor_demod"
command_exists "predict"
command_exists "rtl_fm"
command_exists "sox"
command_exists "sqlite3"
command_exists "wxmap"
command_exists "wxtoimg"
command_exists "wkhtmltoimage"

# binary helpers
CONVERT=$(which convert)
FFMPEG=$(which ffmpeg)
GMIC=$(which gmic)
IDENTIFY=$(which identify)
MEDET_ARM=$(which medet_arm)
METEOR_DEMOD=$(which meteor_demod)
PREDICT=$(which predict)
RTL_FM=$(which rtl_fm)
SOX=$(which sox)
SQLITE3=$(which sqlite3)
WXMAP=$(which wxmap)
WXTOIMG=$(which wxtoimg)
WKHTMLTOIMG=$(which wkhtmltoimage)

# base directories for scripts
SCRIPTS_DIR="${NOAA_HOME}/scripts"
AUDIO_PROC_DIR="${SCRIPTS_DIR}/audio_processors"
IMAGE_PROC_DIR="${SCRIPTS_DIR}/image_processors"
PUSH_PROC_DIR="${SCRIPTS_DIR}/push_processors"

# frequency ranges for objects
METEOR_FREQ="137.1000"
NOAA15_FREQ="137.6200"
NOAA18_FREQ="137.9125"
NOAA19_FREQ="137.1000"

# current date and time
export START_DATE=$(date '+%d-%m-%Y %H:%M')
