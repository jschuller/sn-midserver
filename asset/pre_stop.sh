#!/bin/bash

MID_CONTAINER_DIR="/opt/snc_mid_server/mid_container"
LOG_FILE="/opt/snc_mid_server/mid-container.log"
MAX_LOG_FILE_SIZE=5000000

if [[ -d $MID_CONTAINER_DIR ]]
then
  LOG_FILE="${MID_CONTAINER_DIR}/mid-container.log";
fi

logInfo () {
  msg="$(date '+%Y-%m-%dT%T.%3N') ${1}"
  echo "$msg" | tee -a ${LOG_FILE}
}

compareAndCopy() {
  source="/opt/snc_mid_server/${1}/${2}"
  target="${MID_CONTAINER_DIR}/${2}"
  if  cmp -s  $source $target ; then
    logInfo "  -> $source and $target are the same";
  elif [[ -f $source ]]; then
    logInfo "  -> copy $source to $target"
    \cp -f $source $target
  else
    logInfo "  -> *** $source doesn't exist"
  fi
}

# Make only one backup of the last LOG_FILE if it is larger than a specified max limit
if [[ -f $LOG_FILE ]]; then
  logFileSize=$(cat $LOG_FILE | wc -c)
  if [[ $logFileSize -ge $MAX_LOG_FILE_SIZE ]]; then
    \mv -f $LOG_FILE "${LOG_FILE}.1"
    touch $LOG_FILE
    logInfo "Previous $LOG_FILE was larger than $MAX_LOG_FILE_SIZE and has been moved to ${LOG_FILE}.1"
  fi
fi

# Copy the config, wrapper config and other metadata files to the persistent volume
if [[ -d $MID_CONTAINER_DIR ]]
then
  logInfo "Current user id: `id`"
  logInfo "Backup the config and other metadata files to the persistent volume"
  compareAndCopy agent              config.xml
  compareAndCopy agent/conf         wrapper-override.conf
  compareAndCopy agent              .initialized
  compareAndCopy agent              .env_hash
  compareAndCopy ""                 .container
  compareAndCopy agent/properties   glide.properties
  logInfo "Backup is completed"
else
  logInfo "The directory $MID_CONTAINER_DIR does not exist!"
fi

if [[ "${1}" == "backup_only" ]]; then
  exit 0
fi

# Create the drain marker file
DRAIN_MARKER_FILE="/opt/snc_mid_server/.drain_before_termination"
if [[ ! -f "$DRAIN_MARKER_FILE" ]]; then
  logInfo "Create the drain marker file: ${DRAIN_MARKER_FILE}"
  touch $DRAIN_MARKER_FILE
fi

# Tell the wrapper to stop the MID server. Before stop, the MID server will drain if it sees
# the drain marker file and if mid.drain.run_before_container_termination = true
logInfo "Stop the MID server"
/opt/snc_mid_server/agent/bin/mid.sh stop

# Remove the drain marker file
logInfo "Remove the drain marker file: ${DRAIN_MARKER_FILE}"
rm -f $DRAIN_MARKER_FILE
if [[ -f $DRAIN_MARKER_FILE ]]
then
  logInfo "Failed to delete ${DRAIN_MARKER_FILE}"
fi
