#!/usr/bin/env bash

usage() {
  echo "Usage: $0 <signed_zip_file>"
  echo "    # The script will verify the digital signature of the specified ZIP file"
  echo "    # It has the exit code 0 if the signature is verified; otherwise, the exit code is 1"
  exit 1
}

error_exit() {
  echo "$1" 1>&2 
  exit 1
}

# validate arguments
if [ $# -ne 1 ]; then
  usage
fi

if [ ! -f "$1" ]; then 
  echo "Error: $1 doesn't exist"
  usage
fi

zip_file=$1
echo "DOCKER: Validating digital signature of $zip_file"
validation_result=`jarsigner -verify -strict -verbose "$zip_file"`

# Turn on a case-insensitive matching
shopt -s nocasematch

if [[ "$validation_result" == *"- Signed by "*"O=ServiceNow"*"jar verified."* ]]; then
  echo "DOCKER: Successfully verified digital signature of $zip_file"
else
  echo "ERROR: Digital signature of $zip_file cannot be verified"
  echo "DOCKER: >>Validation result: \"$validation_result\"<<<"
  exit 1
fi

# Turn off a case-insensitive matching
shopt -u nocasematch

exit 0
