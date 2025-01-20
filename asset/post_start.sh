#!/bin/bash

MID_CONTAINER_DIR="/opt/snc_mid_server/mid_container"
LOG_FILE="/opt/snc_mid_server/mid-container.log"

logInfo () {
  msg="$(date '+%Y-%m-%dT%T.%3N') ${1}"
  echo "$msg" | tee -a ${LOG_FILE}
}

if [[ -d $MID_CONTAINER_DIR ]]
then
  LOG_FILE="${MID_CONTAINER_DIR}/mid-container.log";
fi

DRAIN_MARKER_FILE="/opt/snc_mid_server/.drain_before_termination"
if [[ -f "$DRAIN_MARKER_FILE" ]]; then
    logInfo "Remove the drain marker file: ${DRAIN_MARKER_FILE}"
    rm -f $DRAIN_MARKER_FILE
fi
